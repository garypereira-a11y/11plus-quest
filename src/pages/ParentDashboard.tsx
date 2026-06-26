import { useState, useEffect, useCallback } from 'react';
import { useAuth } from '../context/AuthContext';
import { supabase, ChildRecord, QuizAttempt, SkillMastery } from '../lib/supabase';
import { calculateReadiness, daysUntilExam, formatCountdown } from '../lib/readiness';
import { Plus, LogOut, ChevronRight, Flame, Star, Trophy, TrendingUp, Clock } from 'lucide-react';

interface Props {
  onSelectChild: (childId: string) => void;
  onAddChild: () => void;
}

interface ChildSummary {
  child: ChildRecord;
  readiness: number;
  readinessLabel: string;
  readinessColour: string;
  streak: number;
  weeklyScore: number | null;
  weakestSkill: string | null;
  daysUntil: number | null;
}

async function loadChildSummary(child: ChildRecord): Promise<ChildSummary> {
  const [attemptsResult, masteryResult] = await Promise.all([
    supabase
      .from('quiz_attempts')
      .select('correct_answers,total_questions,is_weekly_test,completed_at')
      .eq('child_id', child.id)
      .order('completed_at', { ascending: false })
      .limit(60),
    supabase
      .from('skill_mastery')
      .select('skill_name,mastery_score')
      .eq('child_id', child.id)
      .order('mastery_score', { ascending: true }),
  ]);

  const attempts = (attemptsResult.data ?? []) as Pick<QuizAttempt, 'correct_answers' | 'total_questions' | 'is_weekly_test' | 'completed_at'>[];
  const masteries = (masteryResult.data ?? []) as SkillMastery[];

  const weeklyCount = (await supabase
    .from('ai_weekly_tests')
    .select('id', { count: 'exact', head: true })
    .eq('child_id', child.id)).count ?? 0;

  const result = calculateReadiness(masteries, attempts, weeklyCount);

  // Last weekly test score
  const lastWeekly = attempts.find(a => a.is_weekly_test);
  const weeklyScore = lastWeekly
    ? Math.round((lastWeekly.correct_answers / Math.max(lastWeekly.total_questions, 1)) * 100)
    : null;

  // Streak
  const daySet = new Set<string>();
  for (const a of attempts) daySet.add(new Date(a.completed_at).toISOString().slice(0, 10));
  const days = [...daySet].sort().reverse();
  let streak = 0;
  let check = new Date(); check.setHours(0, 0, 0, 0);
  for (const d of days) {
    const dayDate = new Date(d);
    const diff = Math.round((check.getTime() - dayDate.getTime()) / 86400000);
    if (diff <= 1) { streak++; check = dayDate; } else break;
  }

  const weakestSkill = masteries.length > 0 ? masteries[0].skill_name : null;

  return {
    child,
    readiness: result.percentage,
    readinessLabel: result.label,
    readinessColour: result.colour,
    streak,
    weeklyScore,
    weakestSkill,
    daysUntil: daysUntilExam(child.exam_date),
  };
}

export function ParentDashboard({ onSelectChild, onAddChild }: Props) {
  const { profile, signOut } = useAuth();
  const [summaries, setSummaries] = useState<ChildSummary[]>([]);
  const [loading, setLoading] = useState(true);

  const loadChildren = useCallback(async () => {
    setLoading(true);
    const { data } = await supabase
      .from('children')
      .select('*')
      .order('created_at', { ascending: true });

    if (!data || data.length === 0) { setLoading(false); setSummaries([]); return; }

    const results = await Promise.all((data as ChildRecord[]).map(loadChildSummary));
    setSummaries(results);
    setLoading(false);
  }, []);

  useEffect(() => { loadChildren(); }, [loadChildren]);

  const readinessRing = (pct: number, colour: string) => {
    const r = 28;
    const circ = 2 * Math.PI * r;
    const dash = (pct / 100) * circ;
    return (
      <svg width="72" height="72" className="rotate-[-90deg]">
        <circle cx="36" cy="36" r={r} fill="none" stroke="rgba(217,164,99,0.12)" strokeWidth="5" />
        <circle cx="36" cy="36" r={r} fill="none" stroke={colour} strokeWidth="5"
          strokeDasharray={`${dash} ${circ}`} strokeLinecap="round" />
      </svg>
    );
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-twilight-deep via-twilight to-twilight-deep">
      {/* Header */}
      <div className="px-4 pt-8 pb-4">
        <div className="max-w-lg mx-auto flex items-center justify-between">
          <div>
            <p className="text-quest-gold/70 text-xs font-semibold uppercase tracking-widest">Your Realm</p>
            <h1 className="text-parchment text-2xl font-display font-bold mt-0.5">
              {profile?.name ? `Hi, ${profile.name.split(' ')[0]}` : 'Parent View'}
            </h1>
          </div>
          <button onClick={signOut}
            className="flex items-center gap-2 px-4 py-2 bg-white/5 hover:bg-white/10 text-parchment-dim hover:text-parchment rounded-xl text-sm font-medium transition-all">
            <LogOut className="w-4 h-4" /> Sign out
          </button>
        </div>
      </div>

      {/* Children list */}
      <div className="px-4 pb-8">
        <div className="max-w-lg mx-auto space-y-4">
          {loading ? (
            <div className="space-y-4">
              {[1, 2].map(i => (
                <div key={i} className="bg-white/5 rounded-scroll h-40 animate-pulse" />
              ))}
            </div>
          ) : summaries.length === 0 ? (
            <div className="text-center py-16">
              <div className="text-6xl mb-4">🏰</div>
              <h2 className="text-parchment text-xl font-display font-bold mb-2">No adventurers yet</h2>
              <p className="text-parchment-dim text-sm mb-6">Add your first child to begin their quest</p>
            </div>
          ) : (
            summaries.map(({ child, readiness, readinessLabel, readinessColour, streak, weeklyScore, weakestSkill, daysUntil }) => (
              <button key={child.id} onClick={() => onSelectChild(child.id)}
                className="w-full bg-twilight-surface hover:bg-twilight-raised border border-quest-gold/15 hover:border-quest-gold/30 rounded-scroll p-5 text-left transition-all active:scale-[0.98] group">

                {/* Top row */}
                <div className="flex items-start gap-4">
                  {/* Avatar + readiness ring */}
                  <div className="relative shrink-0">
                    {readinessRing(readiness, readinessColour)}
                    <div className="absolute inset-0 flex items-center justify-center">
                      <span className="text-2xl">{child.avatar}</span>
                    </div>
                  </div>

                  {/* Name / school / exam */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between">
                      <h2 className="text-parchment font-display font-bold text-lg leading-tight">{child.first_name}</h2>
                      <ChevronRight className="w-5 h-5 text-white/20 group-hover:text-quest-gold/50 transition-colors" />
                    </div>
                    <p className="text-parchment-dim/70 text-xs mt-0.5 truncate">{child.target_school ?? child.target_exam_type}</p>
                    <div className="flex items-center gap-2 mt-2">
                      <span className="px-2 py-0.5 rounded-full text-xs font-bold"
                        style={{ background: readinessColour + '22', color: readinessColour }}>
                        {readiness}% · {readinessLabel}
                      </span>
                      <span className="text-parchment-dim/50 text-xs">{child.year_group}</span>
                    </div>
                  </div>
                </div>

                {/* Stats row */}
                <div className="grid grid-cols-4 gap-2 mt-4 pt-4 border-t border-white/5">
                  <div className="text-center">
                    <div className="flex items-center justify-center gap-1 text-realm-coral">
                      <Flame className="w-3.5 h-3.5" />
                      <span className="font-bold text-sm font-ledger">{streak}</span>
                    </div>
                    <p className="text-parchment-dim/50 text-[10px] mt-0.5">Streak</p>
                  </div>
                  <div className="text-center">
                    <div className="flex items-center justify-center gap-1 text-quest-gold">
                      <Star className="w-3.5 h-3.5" />
                      <span className="font-bold text-sm font-ledger">{child.xp_points}</span>
                    </div>
                    <p className="text-parchment-dim/50 text-[10px] mt-0.5">XP</p>
                  </div>
                  <div className="text-center">
                    <div className="flex items-center justify-center gap-1 text-realm-emerald">
                      <Trophy className="w-3.5 h-3.5" />
                      <span className="font-bold text-sm font-ledger">{weeklyScore !== null ? `${weeklyScore}%` : '—'}</span>
                    </div>
                    <p className="text-parchment-dim/50 text-[10px] mt-0.5">Weekly</p>
                  </div>
                  <div className="text-center">
                    <div className="flex items-center justify-center gap-1 text-parchment-dim">
                      <Clock className="w-3.5 h-3.5" />
                      <span className="font-bold text-sm font-ledger">{daysUntil !== null ? daysUntil : '—'}</span>
                    </div>
                    <p className="text-parchment-dim/50 text-[10px] mt-0.5">Days left</p>
                  </div>
                </div>

                {/* Weakest skill */}
                {weakestSkill && (
                  <div className="mt-3 flex items-center gap-2 bg-realm-coral/10 border border-realm-coral/20 rounded-xl px-3 py-2">
                    <TrendingUp className="w-3.5 h-3.5 text-realm-coral shrink-0" />
                    <p className="text-realm-coral text-xs">Focus area: <span className="font-semibold">{weakestSkill}</span></p>
                  </div>
                )}

                {/* Exam countdown chip */}
                {daysUntil !== null && (
                  <div className="mt-2 text-center">
                    <span className="text-parchment-dim/40 text-xs">{formatCountdown(daysUntil)}</span>
                  </div>
                )}
              </button>
            ))
          )}

          {/* Add child button */}
          <button onClick={onAddChild}
            className="w-full flex items-center justify-center gap-3 py-5 border-2 border-dashed border-quest-gold/20 hover:border-quest-gold/50 rounded-scroll text-parchment-dim/60 hover:text-quest-gold transition-all group">
            <div className="w-10 h-10 rounded-full border-2 border-current flex items-center justify-center group-hover:scale-110 transition-transform">
              <Plus className="w-5 h-5" />
            </div>
            <span className="font-semibold font-display">Add another child</span>
          </button>
        </div>
      </div>
    </div>
  );
}
