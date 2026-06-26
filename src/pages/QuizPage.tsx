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

export function QuizPage({ childId, category, isWeeklyTest = false, questionIds, weeklyTestId, onComplete, onBack }: Props) {
  const { user } = useAuth();
  const [questions, setQuestions]     = useState<Question[]>([]);
  const [child, setChild]             = useState<ChildRecord | null>(null);
  const [idx, setIdx]                 = useState(0);
  const [selected, setSelected]       = useState<string | null>(null);
  const [phase, setPhase]             = useState<Phase>('loading');
  const [correctCount, setCorrectCount] = useState(0);
  const [answers, setAnswers]         = useState<{ question: Question; chosen: string; correct: boolean }[]>([]);
  const [newAchievements, setNewAchievements] = useState<string[]>([]);
  const savedRef                      = useRef(false);

  const loadQuestions = useCallback(async () => {
    setPhase('loading');
    let child: ChildRecord | null = null;

    if (childId) {
      const { data } = await supabase.from('children').select('*').eq('id', childId).single();
      child = data as ChildRecord | null;
      setChild(child);
    }

    let q: Question[] = [];

    if (questionIds && questionIds.length > 0) {
      const { data } = await supabase.from('questions').select('*').in('id', questionIds);
      const byId = new Map(((data ?? []) as Question[]).map(question => [question.id, question]));
      // .in() does not preserve order — restore the adaptive engine's weak→medium→strong sequence.
      q = questionIds.map(id => byId.get(id)).filter((question): question is Question => !!question);
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
      // Shuffle and take
      q = pool.sort(() => Math.random() - 0.5).slice(0, limit);
    }

    if (q.length === 0) {
      // Fallback: any questions in category
      const { data } = await supabase.from('questions').select('*')
        .eq('category', category ?? 'math').limit(10);
      q = (data ?? []) as Question[];
    }

    setQuestions(q);
    setIdx(0);
    setCorrectCount(0);
    setAnswers([]);
    savedRef.current = false;
    setPhase(q.length > 0 ? 'question' : 'results');
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
    setPhase('feedback');
  };

  const handleNext = () => {
    setSelected(null);
    if (idx + 1 >= questions.length) {
      setPhase('results');
    } else {
      setIdx(i => i + 1);
      setPhase('question');
    }
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
        const newScore = (correct / total) * 100;
        supabase.rpc('upsert_skill_mastery', {
          p_child_id: childId,
          p_skill_name: skill,
          p_new_score: newScore,
        });
      }
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

  const progress = ((idx + (phase === 'feedback' ? 1 : 0)) / questions.length) * 100;

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
            <span className="text-parchment-dim/70 text-sm font-semibold font-ledger">{idx + 1}/{questions.length}</span>
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
                {idx + 1 >= questions.length ? 'See Results' : 'Next Question'}
                <ChevronRight className="w-5 h-5" />
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
