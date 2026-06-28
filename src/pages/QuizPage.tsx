import { useState, useEffect, useCallback, useRef } from 'react';
import { useAuth } from '../context/AuthContext';
import { supabase, Question, ChildRecord, XP_AWARDS, COIN_AWARDS, isCorrectOption, getCorrectOptionText } from '../lib/supabase';
import { ArrowLeft, CircleCheck as CheckCircle, Circle as XCircle, ChevronRight, Trophy, Check } from 'lucide-react';

interface Props {
  childId?: string | null;
  category?: string;
  isWeeklyTest?: boolean;
  questionIds?: string[];  // pre-selected question set (AI weekly test)
  weeklyTestId?: string;   // id of the ai_weekly_tests row to update on completion
  onComplete: (score: number, total: number) => void;
  onBack: () => void;
}

type Phase = 'loading' | 'question' | 'selected' | 'feedback' | 'results';

// Pool of unused candidate questions, keyed by `${topic}|${difficulty}`.
// Used to pick the next question adaptively, based on whether the previous
// answer (in that same topic) was right or wrong.
type Pool = Map<string, Question[]>;

const poolKey = (topic: string, difficulty: number) => `${topic}|${difficulty}`;

function takeFromPool(pool: Pool, topic: string, difficulty: number): Question | null {
  // Try the exact tier first, then fall back to nearby tiers (closer first).
  const tryOrder = [difficulty, difficulty - 1, difficulty + 1, difficulty - 2, difficulty + 2]
    .filter(d => d >= 1 && d <= 3);

  for (const d of tryOrder) {
    const bucket = pool.get(poolKey(topic, d));
    if (bucket && bucket.length > 0) {
      return bucket.shift() ?? null; // mutates the bucket in place so it isn't reused
    }
  }
  return null;
}

export function QuizPage({ childId, category, isWeeklyTest = false, questionIds, weeklyTestId, onComplete, onBack }: Props) {
  const { user } = useAuth();
  const [questions, setQuestions]     = useState<Question[]>([]); // the sequence actually shown so far
  const [child, setChild]             = useState<ChildRecord | null>(null);
  const [idx, setIdx]                 = useState(0);
  const [selected, setSelected]       = useState<string | null>(null);
  const [phase, setPhase]             = useState<Phase>('loading');
  const [correctCount, setCorrectCount] = useState(0);
  const [answers, setAnswers]         = useState<{ question: Question; chosen: string; correct: boolean }[]>([]);
  const [newAchievements, setNewAchievements] = useState<string[]>([]);
  const [totalPlanned, setTotalPlanned] = useState(10); // how many questions this quiz has, fixed at load time
  const savedRef                      = useRef(false);

  // Per-topic current difficulty tier (1-3). Read/written synchronously when
  // picking the next question — doesn't need to trigger a re-render on its own,
  // so it's a ref rather than state.
  const difficultyByTopic = useRef<Map<string, number>>(new Map());

  // Difficulty-tiered pool of unused candidate questions for every topic in this test.
  const poolRef = useRef<Pool>(new Map());

  // Topic planned for each question-slot, in original order, e.g.
  // ['Fractions','Fractions','Fractions','Grammar','Grammar', ...]
  // Tells us which topic's pool to draw from at each step, while the
  // *difficulty* of the actual question drawn adapts based on the live score.
  const plannedTopicOrderRef = useRef<string[]>([]);

  // The original, non-adaptive sequence (from generate_child_test, or the
  // shuffled fallback query). Used as a last-resort fallback for any slot
  // where the pool has run out of fresh questions at every difficulty tier —
  // far better to reuse a planned question than to crash on an undefined slot.
  const plannedSequenceRef = useRef<Question[]>([]);

  const topicOf = (q: Question) => q.topic ?? q.category;

  const loadQuestions = useCallback(async () => {
    setPhase('loading');
    let child: ChildRecord | null = null;

    if (childId) {
      const { data } = await supabase.from('children').select('*').eq('id', childId).single();
      child = data as ChildRecord | null;
      setChild(child);
    }

    let initialSequence: Question[] = [];

    if (questionIds && questionIds.length > 0) {
      const { data } = await supabase.from('questions').select('*').in('id', questionIds);
      const byId = new Map(((data ?? []) as Question[]).map(question => [question.id, question]));
      // .in() does not preserve order — restore the adaptive engine's weak→medium→strong sequence.
      initialSequence = questionIds.map(id => byId.get(id)).filter((question): question is Question => !!question);
    } else {
      let query = supabase.from('questions').select('*');

      if (child) {
        query = query
          .contains('year_groups', [child.year_group])
          .contains('exam_types', [child.target_exam_type]);
      }
      if (category) {
        query = query.eq('category', category);
      }

      const limit = isWeeklyTest ? 30 : 10;
      const { data } = await query.limit(limit * 3); // fetch extra, then shuffle
      const pool = (data ?? []) as Question[];
      initialSequence = pool.sort(() => Math.random() - 0.5).slice(0, limit);
    }

    if (initialSequence.length === 0) {
      // Fallback: any questions in category
      const { data } = await supabase.from('questions').select('*')
        .eq('category', category ?? 'math').limit(10);
      initialSequence = (data ?? []) as Question[];
    }

    const plannedTotal = initialSequence.length;

    // ── Fetch a difficulty-tiered pool for every topic appearing in this test ──
    // One extra query upfront lets us swap the *next* question in real time
    // based on whether the previous answer (in that topic) was right or wrong,
    // with no network call needed mid-quiz.
    const topicsInPlay = Array.from(new Set(initialSequence.map(topicOf)));
    const usedIds = new Set(initialSequence.map(q => q.id));

    if (topicsInPlay.length > 0) {
      let poolQuery = supabase.from('questions').select('*').in('topic', topicsInPlay);
      if (child) {
        poolQuery = poolQuery
          .contains('year_groups', [child.year_group])
          .contains('exam_types', [child.target_exam_type]);
      }
      const { data: poolData } = await poolQuery.limit(500);
      const candidates = ((poolData ?? []) as Question[]).filter(q => !usedIds.has(q.id));

      const newPool: Pool = new Map();
      for (const q of candidates) {
        const key = poolKey(topicOf(q), q.difficulty);
        const bucket = newPool.get(key) ?? [];
        bucket.push(q);
        newPool.set(key, bucket);
      }
      // Shuffle each bucket so repeated tiers don't always serve the same question first.
      for (const bucket of newPool.values()) {
        bucket.sort(() => Math.random() - 0.5);
      }
      poolRef.current = newPool;
    } else {
      poolRef.current = new Map();
    }

    // Seed each topic's starting difficulty from the first question of that
    // topic in the planned sequence (preserves generate_child_test's original intent).
    const diffMap = new Map<string, number>();
    for (const q of initialSequence) {
      const t = topicOf(q);
      if (!diffMap.has(t)) diffMap.set(t, q.difficulty || 2);
    }
    difficultyByTopic.current = diffMap;

    // Set these refs BEFORE setPhase, so they're guaranteed ready the moment
    // the user can interact with the quiz.
    plannedTopicOrderRef.current = initialSequence.map(topicOf);
    plannedSequenceRef.current = initialSequence;

    setQuestions([initialSequence[0]].filter(Boolean) as Question[]);
    setTotalPlanned(plannedTotal);
    setIdx(0);
    setCorrectCount(0);
    setAnswers([]);
    savedRef.current = false;
    setPhase(initialSequence.length > 0 ? 'question' : 'results');
  }, [childId, category, isWeeklyTest, questionIds]);

  useEffect(() => { loadQuestions(); }, [loadQuestions]);

  const current = questions[idx];

  const handleSelect = (option: string) => {
    if (phase !== 'question' && phase !== 'selected') return;
    setSelected(option);
    setPhase('selected');
  };

  const handleSubmit = () => {
    if (selected === null || phase !== 'selected') return;
    const isCorrect = isCorrectOption(current, selected);
    if (isCorrect) setCorrectCount(c => c + 1);
    setAnswers(prev => [...prev, { question: current, chosen: selected, correct: isCorrect }]);

    // ── Step difficulty for this question's topic ──
    // Wrong answer: drop one tier (floor 1) to rebuild confidence.
    // Correct answer: climb one tier (ceiling 3).
    const topic = topicOf(current);
    const prevDifficulty = difficultyByTopic.current.get(topic) ?? current.difficulty ?? 2;
    const nextDifficulty = isCorrect
      ? Math.min(3, prevDifficulty + 1)
      : Math.max(1, prevDifficulty - 1);
    difficultyByTopic.current.set(topic, nextDifficulty);

    setPhase('feedback');
  };

  const handleNext = () => {
    setSelected(null);
    const nextSlot = idx + 1;

    if (nextSlot >= totalPlanned) {
      setPhase('results');
      return;
    }

    // Which topic was originally planned for this slot?
    const nextTopic = plannedTopicOrderRef.current[nextSlot] ?? topicOf(current);
    const targetDifficulty = difficultyByTopic.current.get(nextTopic) ?? 2;

    const picked = takeFromPool(poolRef.current, nextTopic, targetDifficulty);

    // Fallback chain if the pool has nothing left for this topic at any tier:
    // use whatever was originally planned for this exact slot. Should be rare
    // given the size of the question bank, but a fallback to a known-good
    // question is required here — leaving the slot empty would crash the
    // question screen on `current.question_text` etc. being undefined.
    const fallback = plannedSequenceRef.current[nextSlot] ?? plannedSequenceRef.current[0];
    const nextQuestion = picked ?? fallback;

    if (!nextQuestion) {
      // Should be unreachable (plannedSequenceRef always has at least the
      // questions the quiz started with), but guard anyway rather than ever
      // render an undefined question.
      setPhase('results');
      return;
    }

    setQuestions(prev => {
      const copy = [...prev];
      copy[nextSlot] = nextQuestion;
      return copy;
    });

    setIdx(nextSlot);
    setPhase('question');
  };

  // Save results when reaching results phase
  useEffect(() => {
    if (phase !== 'results' || savedRef.current || !user) return;
    savedRef.current = true;

    (async () => {
    const total = questions.length;
    const score = correctCount;
    const isPerfect = score === total && total > 0;

    const xpGained = XP_AWARDS.quizCompletion + (isPerfect ? XP_AWARDS.perfectScore : 0);

    // Save quiz attempt — awaited because achievement checks below count this row
    await supabase.from('quiz_attempts').insert({
      user_id: user.id,
      child_id: childId ?? null,
      category: category ?? 'mixed',
      total_questions: total,
      correct_answers: score,
      completed_at: new Date().toISOString(),
      is_weekly_test: isWeeklyTest,
      week_number: null,
    });

    // Mark the AI-generated weekly test as completed with its score
    if (weeklyTestId) {
      const pct = total > 0 ? Math.round((score / total) * 100) : 0;
      supabase.from('ai_weekly_tests').update({
        score: pct,
        completed_at: new Date().toISOString(),
      }).eq('id', weeklyTestId);
    }

    // Award coins for completing a weekly quest, with a bonus for a perfect score
    if (childId && isWeeklyTest) {
      const coinAmount = COIN_AWARDS.weeklyTestComplete + (isPerfect ? COIN_AWARDS.weeklyTestPerfect : 0);
      const reason = isPerfect ? 'Perfect weekly quest score!' : 'Weekly quest completed';
      supabase.rpc('award_coins', {
        p_child_id: childId,
        p_amount: coinAmount,
        p_reason: reason,
        p_source_type: 'weekly_test',
        p_source_id: weeklyTestId ?? null,
      });
    }

    // Check for newly-earned achievements (coins for these are awarded server-side
    // inside the function, alongside the badge insert, so they stay in sync).
    if (childId) {
      supabase.rpc('check_and_award_achievements', { p_child_id: childId }).then(({ data }) => {
        const earned = (data as { newly_earned?: string[] } | null)?.newly_earned;
        if (earned && earned.length > 0) setNewAchievements(earned);
      });
    }

    // Update child XP
    if (childId && child) {
      supabase.from('children').update({
        xp_points: (child.xp_points ?? 0) + xpGained,
        level: Math.floor(((child.xp_points ?? 0) + xpGained) / 100) + 1,
      }).eq('id', childId);
    }

    // Upsert skill mastery for each skill in answers
    if (childId && answers.length > 0) {
      const skillMap = new Map<string, { correct: number; total: number }>();
      for (const a of answers) {
        const skill = a.question.topic ?? a.question.category;
        const prev = skillMap.get(skill) ?? { correct: 0, total: 0 };
        skillMap.set(skill, { correct: prev.correct + (a.correct ? 1 : 0), total: prev.total + 1 });
      }
      for (const [skill, { correct, total }] of skillMap.entries()) {
        const { error: masteryError } = await supabase.rpc('upsert_skill_mastery', {
          p_child_id: childId,
          p_skill_name: skill,
          p_correct: correct,
          p_total: total,
        });
        if (masteryError) {
          console.error(`Failed to update mastery for skill "${skill}":`, masteryError.message);
        }
      }
    }

    // Award a mystery chest for completing this quiz — the surprise-reward moment
    // that makes finishing a quiz feel exciting beyond just the predictable XP/coin
    // numbers. The dashboard (shown right after onComplete fires) checks for and
    // displays any unopened chests, so the actual "opening" experience lives there,
    // not on this screen.
    if (childId) {
      supabase.rpc('award_mystery_chest', {
        p_child_id: childId,
        p_source_type: isWeeklyTest ? 'weekly_test' : 'quiz_complete',
        p_source_id: weeklyTestId ?? null,
      });
    }

    onComplete(score, total);
    })();
  }, [phase, correctCount, questions.length, user, childId, child, category, isWeeklyTest, weeklyTestId, answers, onComplete]);

  if (phase === 'loading') {
    return (
      <div className="min-h-screen bg-gradient-to-br from-twilight-deep via-twilight to-twilight-deep flex items-center justify-center">
        <div className="text-parchment-dim text-lg font-display animate-pulse">Preparing your quest...</div>
      </div>
    );
  }

  if (phase === 'results') {
    const pct = questions.length > 0 ? Math.round((correctCount / questions.length) * 100) : 0;
    const colour = pct >= 80 ? 'text-realm-emerald' : pct >= 50 ? 'text-quest-gold' : 'text-realm-coral';
    return (
      <div className="min-h-screen bg-gradient-to-br from-twilight-deep via-twilight to-twilight-deep flex flex-col items-center justify-center px-4">
        <div className="max-w-sm w-full text-center animate-fadeIn">
          <div className="text-7xl mb-4 animate-chestPop">{pct >= 80 ? '🏆' : pct >= 50 ? '🗝️' : '🛡️'}</div>
          <h1 className="text-parchment text-3xl font-display font-black mb-2">
            {pct >= 80 ? 'Legendary!' : pct >= 50 ? 'Well fought!' : 'Onward, hero!'}
          </h1>
          <p className="text-parchment-dim mb-6">You scored</p>
          <div className={`text-7xl font-display font-black ${colour} mb-2`}>{pct}%</div>
          <p className="text-parchment-dim/60 mb-8 font-ledger">{correctCount} / {questions.length} correct</p>

          {newAchievements.length > 0 && (
            <div className="bg-quest-gold/10 border-2 border-quest-gold/30 rounded-scroll px-5 py-4 mb-6 animate-chestPop">
              <p className="text-quest-gold font-display font-bold text-sm mb-1">🎉 New Achievement{newAchievements.length > 1 ? 's' : ''}!</p>
              {newAchievements.map(name => (
                <p key={name} className="text-parchment text-sm font-semibold">{name}</p>
              ))}
              <p className="text-parchment-dim/60 text-xs mt-1">+25 coins each — spend them at the Outfitter!</p>
            </div>
          )}

          <div className="space-y-3">
            <button onClick={loadQuestions}
              className="w-full py-4 bg-gradient-to-r from-quest-goldDim to-quest-gold text-twilight-deep rounded-2xl font-bold font-display text-lg hover:shadow-glow transition-all active:scale-95 shadow-lg">
              Try Again
            </button>
            <button onClick={onBack}
              className="w-full py-4 bg-white/5 text-parchment-dim rounded-2xl font-semibold hover:bg-white/10 transition-all">
              Back to Dashboard
            </button>
          </div>
        </div>
      </div>
    );
  }

  const progress = ((idx + (phase === 'feedback' ? 1 : 0)) / totalPlanned) * 100;

  return (
    <div className="min-h-screen bg-gradient-to-br from-twilight-deep via-twilight to-twilight-deep flex flex-col">
      {/* Header */}
      <div className="px-4 pt-6 pb-3">
        <div className="max-w-lg mx-auto">
          <div className="flex items-center gap-3 mb-4">
            <button onClick={onBack}
              className="w-10 h-10 rounded-xl bg-white/5 hover:bg-white/10 flex items-center justify-center transition-all">
              <ArrowLeft className="w-5 h-5 text-parchment-dim" />
            </button>
            <div className="flex-1">
              <div className="h-2 bg-white/8 rounded-full overflow-hidden">
                <div className="h-full bg-gradient-to-r from-quest-goldDim to-quest-gold rounded-full transition-all duration-500"
                  style={{ width: `${progress}%` }} />
              </div>
            </div>
            <span className="text-parchment-dim/70 text-sm font-semibold font-ledger">{idx + 1}/{totalPlanned}</span>
          </div>

          {isWeeklyTest && (
            <div className="flex items-center gap-2 mb-3">
              <Trophy className="w-4 h-4 text-quest-gold" />
              <span className="text-quest-gold text-sm font-semibold font-display">Weekly Quest</span>
            </div>
          )}
        </div>
      </div>

      {/* Question */}
      <div className="flex-1 px-4 pb-8">
        <div className="max-w-lg mx-auto" key={idx}>
          <div className="bg-twilight-surface border border-quest-gold/15 rounded-scroll p-6 mb-4 animate-fadeIn">
            {current.topic && (
              <p className="text-quest-gold/60 text-xs font-semibold uppercase tracking-wide mb-3">{current.topic}</p>
            )}
            <p className="text-parchment text-xl font-bold leading-relaxed">{current.question_text}</p>
          </div>

          <div className="space-y-3">
            {current.options.map((option, i) => {
              const isSelected = selected === option;
              const isCorrect  = option === getCorrectOptionText(current);
              let style = 'border-white/10 bg-white/5 text-parchment hover:border-white/25 hover:bg-white/8';
              if (phase === 'selected' && isSelected) {
                style = 'border-quest-gold bg-quest-gold/15 text-parchment';
              } else if (phase === 'feedback') {
                if (isCorrect)       style = 'border-realm-emerald bg-realm-emerald/15 text-parchment';
                else if (isSelected) style = 'border-realm-coral bg-realm-coral/15 text-parchment';
                else                 style = 'border-white/5 bg-white/3 text-parchment-dim/40';
              }

              return (
                <button key={i} onClick={() => handleSelect(option)} disabled={phase === 'feedback'}
                  className={`w-full flex items-center gap-3 px-4 py-4 rounded-2xl border-2 transition-all text-left ${style}`}>
                  <span className="w-8 h-8 rounded-full border-2 border-current flex items-center justify-center text-sm font-bold shrink-0">
                    {phase === 'feedback' && isCorrect  ? <CheckCircle className="w-5 h-5 text-realm-emerald" /> :
                     phase === 'feedback' && isSelected ? <XCircle className="w-5 h-5 text-realm-coral" /> :
                     phase === 'selected' && isSelected ? <Check className="w-5 h-5 text-quest-gold" /> :
                     String.fromCharCode(65 + i)}
                  </span>
                  <span className="font-semibold">{option}</span>
                </button>
              );
            })}
          </div>

          {/* Submit button — confirms the tentative selection before revealing feedback */}
          {phase === 'selected' && (
            <button onClick={handleSubmit}
              className="w-full mt-4 flex items-center justify-center gap-2 py-4 bg-gradient-to-r from-quest-goldDim to-quest-gold text-twilight-deep rounded-2xl font-bold font-display text-lg hover:shadow-glow transition-all active:scale-95 shadow-lg animate-fadeIn">
              <Check className="w-5 h-5" />
              Submit Answer
            </button>
          )}

          {/* Explanation + Next */}
          {phase === 'feedback' && (
            <div className="mt-4 animate-fadeIn">
              {current.explanation && (
                <div className="bg-realm-emerald/10 border border-realm-emerald/20 rounded-2xl px-4 py-3 mb-3">
                  <p className="text-realm-emerald text-sm">{current.explanation}</p>
                </div>
              )}
              <button onClick={handleNext}
                className="w-full flex items-center justify-center gap-2 py-4 bg-gradient-to-r from-quest-goldDim to-quest-gold text-twilight-deep rounded-2xl font-bold font-display text-lg hover:shadow-glow transition-all active:scale-95 shadow-lg">
                {idx + 1 >= totalPlanned ? 'See Results' : 'Next Question'}
                <ChevronRight className="w-5 h-5" />
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
