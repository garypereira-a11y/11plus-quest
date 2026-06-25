import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { ChildRecord } from '../lib/supabase';
import { getExamProfile } from '../lib/examProfiles';
import { ArrowLeft, Play, Lock, CircleCheck as CheckCircle } from 'lucide-react';

interface Props {
  childId: string;
  onStartWeek: (weekNumber: number, questionIds: string[], testId: string) => void;
  onBack: () => void;
}

interface WeeklyTestRecord {
  id: string;
  week_number: number;
  question_ids: string[];
  completed_at: string | null;
  score: number | null;
}

export function WeekChooserPage({ childId, onStartWeek, onBack }: Props) {
  const [child, setChild]       = useState<ChildRecord | null>(null);
  const [tests, setTests]       = useState<WeeklyTestRecord[]>([]);
  const [loading, setLoading]   = useState(true);
  const [generatingWeek, setGeneratingWeek] = useState<number | null>(null);
  const [error, setError]       = useState('');

  const load = () => {
    setLoading(true);
    Promise.all([
      supabase.from('children').select('*').eq('id', childId).single(),
      supabase.from('ai_weekly_tests').select('id,week_number,question_ids,completed_at,score').eq('child_id', childId),
    ]).then(([childRes, testsRes]) => {
      setChild(childRes.data as ChildRecord | null);
      setTests((testsRes.data ?? []) as WeeklyTestRecord[]);
      setLoading(false);
    });
  };

  useEffect(() => { load(); }, [childId]);

  if (loading || !child) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-twilight-deep via-twilight to-twilight-deep flex items-center justify-center">
        <div className="text-parchment-dim font-display animate-pulse">Charting the realm...</div>
      </div>
    );
  }

  const profile = getExamProfile(child.target_exam_type);
  const completedWeeks = new Set(tests.filter(t => t.completed_at).map(t => t.week_number));
  const highestCompleted = completedWeeks.size > 0 ? Math.max(...completedWeeks) : 0;
  const maxUnlocked = highestCompleted + 1;

  const handleWeekTap = async (week: number) => {
    setError('');
    // Replay an existing test for this week (completed or in-progress) using its stored questions.
    const existing = tests.find(t => t.week_number === week);
    if (existing && existing.question_ids.length > 0) {
      onStartWeek(week, existing.question_ids, existing.id);
      return;
    }

    // Generate a fresh adaptive test for the next week via the SQL adaptive engine.
    setGeneratingWeek(week);
    const { data, error: rpcError } = await supabase.rpc('generate_child_test', { p_child_id: childId });
    if (rpcError || !data || (data as { error?: string }).error) {
      setError('Could not generate this week\u2019s test. Please try again.');
      setGeneratingWeek(null);
      return;
    }

    const result = data as { success: boolean; test_id: string; week_number: number; question_count: number };
    const { data: testRow } = await supabase
      .from('ai_weekly_tests')
      .select('id,week_number,question_ids,completed_at,score')
      .eq('id', result.test_id)
      .single();

    setGeneratingWeek(null);
    if (testRow) {
      onStartWeek(testRow.week_number, testRow.question_ids, testRow.id);
    } else {
      setError('Something went wrong loading this week\u2019s test.');
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-twilight-deep via-twilight to-twilight-deep pb-8">
      <div className="px-4 pt-6 pb-4">
        <div className="max-w-lg mx-auto flex items-center gap-3 mb-6">
          <button onClick={onBack}
            className="w-10 h-10 rounded-xl bg-white/5 hover:bg-white/10 flex items-center justify-center transition-all">
            <ArrowLeft className="w-5 h-5 text-parchment-dim" />
          </button>
          <div>
            <p className="text-parchment-dim/60 text-xs font-semibold uppercase tracking-wide">{child.target_exam_type}</p>
            <h1 className="text-parchment text-xl font-display font-bold">{profile.totalWeeks}-Week Quest</h1>
          </div>
        </div>

        {error && (
          <div className="max-w-lg mx-auto mb-4 px-4 py-3 bg-realm-coral/10 border border-realm-coral/25 rounded-xl">
            <p className="text-realm-coral text-sm">{error}</p>
          </div>
        )}
      </div>

      <div className="px-4">
        <div className="max-w-lg mx-auto space-y-3">
          {Array.from({ length: profile.totalWeeks }, (_, i) => {
            const week      = i + 1;
            const done      = completedWeeks.has(week);
            const unlocked  = week <= maxUnlocked;
            const generating = generatingWeek === week;
            const difficulty = profile.difficultyProgression[i]?.difficulty ?? 5;

            return (
              <button key={week} onClick={() => unlocked && !generating && handleWeekTap(week)} disabled={!unlocked || generating}
                className={`w-full flex items-center gap-4 px-5 py-4 rounded-2xl border-2 transition-all ${
                  done      ? 'border-realm-emerald/40 bg-realm-emerald/10' :
                  unlocked  ? 'border-quest-gold/30 bg-quest-gold/8 hover:border-quest-gold/50 hover:bg-quest-gold/12 active:scale-[0.98]' :
                              'border-white/8 bg-white/3 opacity-50 cursor-not-allowed'
                }`}>

                <div className={`w-12 h-12 rounded-2xl flex items-center justify-center text-xl shrink-0 ${
                  done ? 'bg-realm-emerald/20' : unlocked ? 'bg-quest-gold/15' : 'bg-white/5'
                }`}>
                  {generating ? <div className="w-5 h-5 border-2 border-quest-gold border-t-transparent rounded-full animate-spin" /> :
                   done ? <CheckCircle className="w-6 h-6 text-realm-emerald" /> :
                   unlocked ? <Play className="w-6 h-6 text-quest-gold" /> :
                   <Lock className="w-5 h-5 text-white/20" />}
                </div>

                <div className="flex-1 text-left">
                  <p className={`font-bold font-display ${done ? 'text-realm-emerald' : unlocked ? 'text-parchment' : 'text-parchment-dim/30'}`}>
                    Week {week}
                  </p>
                  <p className="text-parchment-dim/60 text-xs mt-0.5">
                    {generating ? 'Building your adaptive test\u2026' :
                     done ? `Completed${tests.find(t => t.week_number === week)?.score != null ? ` \u00b7 ${tests.find(t => t.week_number === week)?.score}%` : ''}` :
                     `${profile.weeklyTestQuestions} questions \u00b7 Difficulty ${difficulty}/10`}
                  </p>
                </div>

                <div className="flex items-center gap-1">
                  {Array.from({ length: Math.min(difficulty, 5) }).map((_, j) => (
                    <div key={j} className={`w-1.5 h-1.5 rounded-full ${
                      done ? 'bg-realm-emerald' : unlocked ? 'bg-quest-gold' : 'bg-white/20'
                    }`} />
                  ))}
                </div>
              </button>
            );
          })}
        </div>
      </div>
    </div>
  );
}
