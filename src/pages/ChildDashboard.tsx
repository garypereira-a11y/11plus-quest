import { useState, useEffect, useCallback } from 'react';
import { supabase, ChildRecord, SkillMastery, Achievement, QuizAttempt, XP_AWARDS } from '../lib/supabase';
import { calculateReadiness, daysUntilExam, formatCountdown } from '../lib/readiness';
import { getExamProfile } from '../lib/examProfiles';
import { ArrowLeft, Flame, Star, Trophy, Zap, Target, BookOpen, ChevronRight, Calendar, Award, TrendingUp, Play, ChartBar as BarChart2 } from 'lucide-react';

interface Props {
  childId: string;
  onBack?: () => void;
  onStartQuiz: (category: string) => void;
  onStartWeeklyTest: () => void;
  onViewLeaderboard: () => void;
}

export function ChildDashboard({ childId, onBack, onStartQuiz, onStartWeeklyTest, onViewLeaderboard }: Props) {
  const [child, setChild]             = useState<ChildRecord | null>(null);
  const [masteries, setMasteries]     = useState<SkillMastery[]>([]);
  const [achievements, setAchievements] = useState<Achievement[]>([]);
  const [attempts, setAttempts]       = useState<Pick<QuizAttempt, 'correct_answers' | 'total_questions' | 'is_weekly_test' | 'completed_at'>[]>([]);
  const [weeklyCount, setWeeklyCount] = useState(0);
  const [loading, setLoading]         = useState(true);
  const [awardingLogin, setAwardingLogin] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    const [childRes, masteryRes, achieveRes, attemptsRes, weeklyRes] = await Promise.all([
      supabase.from('children').select('*').eq('id', childId).single(),
      supabase.from('skill_mastery').select('*').eq('child_id', childId).order('mastery_score', { ascending: true }),
      supabase.from('achievements').select('*').eq('child_id', childId).order('earned_date', { ascending: false }).limit(10),
      supabase.from('quiz_attempts').select('correct_answers,total_questions,is_weekly_test,completed_at').eq('child_id', childId).order('completed_at', { ascending: false }).limit(60),
      supabase.from('ai_weekly_tests').select('id', { count: 'exact', head: true }).eq('child_id', childId),
    ]);
    setChild(childRes.data as ChildRecord | null);
    setMasteries((masteryRes.data ?? []) as SkillMastery[]);
    setAchievements((achieveRes.data ?? []) as Achievement[]);
    setAttempts((attemptsRes.data ?? []) as typeof attempts);
    setWeeklyCount(weeklyRes.count ?? 0);
    setLoading(false);
  }, [childId]);

  useEffect(() => { load(); }, [load]);

  // Award daily login XP once per day
  useEffect(() => {
    if (!child || awardingLogin) return;
    const key = `login_xp_${childId}_${new Date().toISOString().slice(0, 10)}`;
    if (localStorage.getItem(key)) return;
    setAwardingLogin(true);
    supabase.rpc('add_xp', { target_user_id: child.profile_id ?? child.parent_id, xp_amount: XP_AWARDS.dailyLogin })
      .then(() => {
        supabase.from('children').update({ xp_points: (child.xp_points ?? 0) + XP_AWARDS.dailyLogin }).eq('id', childId);
        localStorage.setItem(key, '1');
      });
  }, [child, childId, awardingLogin]);

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-twilight-deep via-twilight to-twilight-deep flex items-center justify-center">
        <div className="text-parchment-dim text-lg font-display animate-pulse">Charting your quest...</div>
      </div>
    );
  }

  if (!child) return null;

  const readinessResult = calculateReadiness(masteries, attempts, weeklyCount);
  const profile = getExamProfile(child.target_exam_type);
  const daysUntil = daysUntilExam(child.exam_date);
  const xpInLevel = child.xp_points % 100;
  const streak = (() => {
    const daySet = new Set<string>();
    for (const a of attempts) daySet.add(new Date(a.completed_at).toISOString().slice(0, 10));
    const days = [...daySet].sort().reverse();
    let s = 0; let check = new Date(); check.setHours(0, 0, 0, 0);
    for (const d of days) {
      const dd = new Date(d);
      const diff = Math.round((check.getTime() - dd.getTime()) / 86400000);
      if (diff <= 1) { s++; check = dd; } else break;
    }
    return s;
  })();

  const readinessGradient =
    readinessResult.level === 'exam-ready' ? 'from-realm-emerald to-teal-500' :
    readinessResult.level === 'on-track'   ? 'from-quest-goldDim to-quest-gold' :
                                             'from-realm-coral to-rose-500';

  const topSubjects = masteries.slice(-3).reverse(); // best 3
  const weakSubjects = masteries.slice(0, 2);        // worst 2

  return (
    <div className="min-h-screen bg-gradient-to-br from-twilight-deep via-twilight to-twilight-deep pb-8">
      {/* Header */}
      <div className="px-4 pt-6 pb-2">
        <div className="max-w-lg mx-auto">
          <div className="flex items-center gap-3 mb-6">
            {onBack && (
              <button onClick={onBack}
                className="w-10 h-10 rounded-xl bg-white/5 hover:bg-white/10 flex items-center justify-center transition-all">
                <ArrowLeft className="w-5 h-5 text-parchment-dim" />
              </button>
            )}
            <div className="flex-1" />
            <button onClick={onViewLeaderboard}
              className="w-10 h-10 rounded-xl bg-white/5 hover:bg-white/10 flex items-center justify-center transition-all">
              <Trophy className="w-5 h-5 text-quest-gold/80" />
            </button>
            <div className="flex items-center gap-2 bg-realm-coral/15 rounded-full px-3 py-1.5">
              <Flame className="w-4 h-4 text-realm-coral" />
              <span className="text-realm-coral font-bold text-sm font-ledger">{streak} day streak</span>
            </div>
          </div>

          {/* Child identity */}
          <div className="flex items-center gap-4 mb-2">
            <div className="w-16 h-16 rounded-2xl bg-twilight-raised border-2 border-quest-gold/30 flex items-center justify-center text-4xl shadow-glow">
              {child.avatar}
            </div>
            <div>
              <h1 className="text-parchment text-2xl font-display font-bold">{child.first_name}</h1>
              <p className="text-parchment-dim text-sm">{child.target_school ?? child.target_exam_type} · {child.year_group}</p>
            </div>
          </div>

          {/* XP bar */}
          <div className="mt-4">
            <div className="flex justify-between text-xs mb-1.5">
              <span className="text-quest-gold font-bold flex items-center gap-1 font-display"><Star className="w-3 h-3" /> Level {child.level}</span>
              <span className="text-parchment-dim font-ledger">{xpInLevel}/100 XP</span>
            </div>
            <div className="h-2.5 bg-white/8 rounded-full overflow-hidden">
              <div className="h-full bg-gradient-to-r from-quest-goldDim to-quest-gold rounded-full transition-all"
                style={{ width: `${xpInLevel}%` }} />
            </div>
          </div>
        </div>
      </div>

      <div className="px-4 space-y-4 mt-4">
        <div className="max-w-lg mx-auto space-y-4">

          {/* Readiness card */}
          <div className={`relative overflow-hidden rounded-scroll p-5 bg-gradient-to-br ${readinessGradient}`}>
            <div className="absolute inset-0 opacity-20 bg-[radial-gradient(circle_at_70%_50%,white,transparent)]" />
            <div className="relative flex items-center justify-between">
              <div>
                <p className="text-white/70 text-xs font-semibold uppercase tracking-wide">Quest Readiness</p>
                <div className="flex items-baseline gap-2 mt-1">
                  <span className="text-white text-5xl font-display font-black">{readinessResult.percentage}%</span>
                </div>
                <p className="text-white/80 font-bold mt-1">{readinessResult.label}</p>
                {daysUntil !== null && (
                  <div className="flex items-center gap-1.5 mt-2">
                    <Calendar className="w-3.5 h-3.5 text-white/60" />
                    <span className="text-white/70 text-xs">{formatCountdown(daysUntil)}</span>
                  </div>
                )}
              </div>
              <div className="text-right">
                <div className="text-6xl opacity-30">🏰</div>
              </div>
            </div>

            {/* Readiness breakdown */}
            <div className="grid grid-cols-2 gap-2 mt-4">
              {[
                { label: 'Skill Mastery',    value: readinessResult.components.skillMastery },
                { label: 'Weekly Tests',     value: readinessResult.components.weeklyTests },
                { label: 'Consistency',      value: readinessResult.components.consistency },
                { label: 'Completion Rate',  value: readinessResult.components.completionRate },
              ].map(({ label, value }) => (
                <div key={label} className="bg-black/20 rounded-xl px-3 py-2">
                  <div className="h-1.5 bg-white/20 rounded-full overflow-hidden mb-1.5">
                    <div className="h-full bg-white/70 rounded-full" style={{ width: `${value}%` }} />
                  </div>
                  <div className="flex justify-between text-[10px]">
                    <span className="text-white/60">{label}</span>
                    <span className="text-white font-bold">{value}%</span>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Quick actions */}
          <div className="grid grid-cols-2 gap-3">
            <button onClick={onStartWeeklyTest}
              className="flex flex-col items-center justify-center gap-2 py-5 bg-gradient-to-br from-quest-goldDim to-quest-gold rounded-2xl font-bold text-twilight-deep hover:shadow-glow transition-all active:scale-95 shadow-lg">
              <Play className="w-6 h-6" />
              <span className="text-sm font-display">Weekly Quest</span>
            </button>
            <button onClick={() => onStartQuiz(profile.subjects[0]?.id ?? 'math')}
              className="flex flex-col items-center justify-center gap-2 py-5 bg-twilight-surface border border-quest-gold/15 rounded-2xl font-bold text-parchment hover:bg-twilight-raised transition-all active:scale-95">
              <BookOpen className="w-6 h-6 text-realm-emerald" />
              <span className="text-sm font-display">Practice</span>
            </button>
          </div>

          {/* Skill mastery */}
          {masteries.length > 0 && (
            <div className="bg-twilight-surface border border-quest-gold/15 rounded-scroll p-5">
              <div className="flex items-center gap-2 mb-4">
                <BarChart2 className="w-5 h-5 text-realm-emerald" />
                <h2 className="text-parchment font-display font-bold">Skill Mastery</h2>
              </div>
              <div className="space-y-2.5">
                {masteries.map(m => (
                  <div key={m.id}>
                    <div className="flex justify-between text-xs mb-1">
                      <span className="text-parchment-dim font-medium">{m.skill_name}</span>
                      <span className={`font-bold font-ledger ${m.mastery_score >= 70 ? 'text-realm-emerald' : m.mastery_score >= 40 ? 'text-quest-gold' : 'text-realm-coral'}`}>
                        {Math.round(m.mastery_score)}%
                      </span>
                    </div>
                    <div className="h-2 bg-white/8 rounded-full overflow-hidden">
                      <div className={`h-full rounded-full transition-all ${m.mastery_score >= 70 ? 'bg-realm-emerald' : m.mastery_score >= 40 ? 'bg-quest-gold' : 'bg-realm-coral'}`}
                        style={{ width: `${m.mastery_score}%` }} />
                    </div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Practice subjects */}
          <div className="bg-twilight-surface border border-quest-gold/15 rounded-scroll p-5">
            <div className="flex items-center gap-2 mb-4">
              <Target className="w-5 h-5 text-quest-gold" />
              <h2 className="text-parchment font-display font-bold">Practice by Subject</h2>
            </div>
            <div className="space-y-2">
              {profile.subjects.map(subject => {
                const mastery = masteries.find(m => m.skill_name.toLowerCase().includes(subject.name.toLowerCase()));
                const pct = mastery ? Math.round(mastery.mastery_score) : null;
                return (
                  <button key={subject.id} onClick={() => onStartQuiz(subject.id)}
                    className="w-full flex items-center gap-3 px-4 py-3 bg-white/5 hover:bg-white/8 rounded-2xl transition-all group">
                    <span className="text-2xl">{subject.emoji}</span>
                    <div className="flex-1 text-left">
                      <p className="text-parchment font-semibold text-sm">{subject.name}</p>
                      <p className="text-parchment-dim/70 text-xs">{subject.description}</p>
                    </div>
                    {pct !== null && (
                      <span className={`text-xs font-bold font-ledger ${pct >= 70 ? 'text-realm-emerald' : pct >= 40 ? 'text-quest-gold' : 'text-realm-coral'}`}>
                        {pct}%
                      </span>
                    )}
                    <ChevronRight className="w-4 h-4 text-white/20 group-hover:text-quest-gold/60 transition-colors" />
                  </button>
                );
              })}
            </div>
          </div>

          {/* Focus areas */}
          {weakSubjects.length > 0 && (
            <div className="bg-realm-coral/10 border border-realm-coral/25 rounded-scroll p-5">
              <div className="flex items-center gap-2 mb-3">
                <TrendingUp className="w-5 h-5 text-realm-coral" />
                <h2 className="text-parchment font-display font-bold">Focus Areas</h2>
              </div>
              <div className="space-y-2">
                {weakSubjects.map(m => (
                  <div key={m.id} className="flex items-center justify-between">
                    <span className="text-parchment-dim text-sm">{m.skill_name}</span>
                    <span className="text-realm-coral font-bold text-sm font-ledger">{Math.round(m.mastery_score)}%</span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Top skills */}
          {topSubjects.length > 0 && (
            <div className="bg-realm-emerald/10 border border-realm-emerald/25 rounded-scroll p-5">
              <div className="flex items-center gap-2 mb-3">
                <Zap className="w-5 h-5 text-realm-emerald" />
                <h2 className="text-parchment font-display font-bold">Top Skills</h2>
              </div>
              <div className="space-y-2">
                {topSubjects.map(m => (
                  <div key={m.id} className="flex items-center justify-between">
                    <span className="text-parchment-dim text-sm">{m.skill_name}</span>
                    <span className="text-realm-emerald font-bold text-sm font-ledger">{Math.round(m.mastery_score)}%</span>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Achievements */}
          {achievements.length > 0 && (
            <div className="bg-twilight-surface border border-quest-gold/15 rounded-scroll p-5">
              <div className="flex items-center gap-2 mb-4">
                <Award className="w-5 h-5 text-quest-gold" />
                <h2 className="text-parchment font-display font-bold">Achievements</h2>
              </div>
              <div className="flex flex-wrap gap-2">
                {achievements.map(a => (
                  <div key={a.id}
                    className="flex items-center gap-2 bg-quest-gold/10 border border-quest-gold/25 rounded-xl px-3 py-2">
                    <Trophy className="w-3.5 h-3.5 text-quest-gold" />
                    <span className="text-quest-gold text-xs font-semibold">{a.badge_name}</span>
                  </div>
                ))}
              </div>
            </div>
          )}

        </div>
      </div>
    </div>
  );
}
