import type { QuizAttempt } from './supabase';

export interface ReadinessComponents {
  skillMastery: number;      // 0–100
  weeklyTests: number;       // 0–100
  consistency: number;       // 0–100
  completionRate: number;    // 0–100
  overall: number;           // 0–100 weighted
}

export type ReadinessLevel = 'needs-improvement' | 'on-track' | 'exam-ready';

export interface ReadinessResult {
  components: ReadinessComponents;
  level: ReadinessLevel;
  colour: string;
  label: string;
  percentage: number;
}

/**
 * Calculates a readiness score from the child's performance data.
 *
 * Weights:
 *   Skill Mastery    40 %
 *   Weekly Tests     30 %
 *   Consistency      20 %
 *   Completion Rate  10 %
 */
export function calculateReadiness(
  skillMasteries: { mastery_score: number }[],
  recentAttempts: Pick<QuizAttempt, 'correct_answers' | 'total_questions' | 'is_weekly_test' | 'completed_at'>[],
  totalWeeksGenerated: number,
): ReadinessResult {

  // ── Skill Mastery (40%) ────────────────────────────────────────────────────
  const skillMastery = skillMasteries.length > 0
    ? Math.round(skillMasteries.reduce((s, m) => s + m.mastery_score, 0) / skillMasteries.length)
    : recentAttempts.length > 0
      ? Math.round(
          recentAttempts.reduce((s, a) => s + (a.correct_answers / Math.max(a.total_questions, 1)) * 100, 0)
          / recentAttempts.length
        )
      : 0;

  // ── Weekly Tests (30%) ─────────────────────────────────────────────────────
  const weeklyAttempts = recentAttempts.filter(a => a.is_weekly_test);
  const last4Weekly    = weeklyAttempts.slice(0, 4);
  const weeklyTests    = last4Weekly.length > 0
    ? Math.round(
        last4Weekly.reduce((s, a) => s + (a.correct_answers / Math.max(a.total_questions, 1)) * 100, 0)
        / last4Weekly.length
      )
    : 0;

  // ── Consistency / Streak (20%) ─────────────────────────────────────────────
  // Count consecutive days (most recent first) up to 30
  const daySet = new Set<string>();
  for (const a of recentAttempts) {
    daySet.add(new Date(a.completed_at).toISOString().slice(0, 10));
  }
  const days = [...daySet].sort().reverse();
  let streak = 0;
  let check  = new Date();
  check.setHours(0, 0, 0, 0);
  for (const d of days) {
    const dayDate = new Date(d);
    const diffDays = Math.round((check.getTime() - dayDate.getTime()) / 86400000);
    if (diffDays <= 1) { streak++; check = dayDate; }
    else break;
    if (streak >= 30) break;
  }
  const consistency = Math.min(100, Math.round((streak / 30) * 100));

  // ── Completion Rate (10%) ──────────────────────────────────────────────────
  const completionRate = totalWeeksGenerated > 0
    ? Math.min(100, Math.round((weeklyAttempts.length / totalWeeksGenerated) * 100))
    : recentAttempts.length > 0 ? 50 : 0;

  // ── Weighted overall ───────────────────────────────────────────────────────
  const overall = Math.round(
    skillMastery   * 0.40 +
    weeklyTests    * 0.30 +
    consistency    * 0.20 +
    completionRate * 0.10,
  );

  const level: ReadinessLevel =
    overall >= 70 ? 'exam-ready'
    : overall >= 40 ? 'on-track'
    : 'needs-improvement';

  const colour =
    level === 'exam-ready'        ? '#4FB8A3'  // realm-emerald (sea-foam teal)
    : level === 'on-track'        ? '#D9A463'  // quest-gold (sand brown)
    : '#E0764B';                               // realm-coral (terracotta)

  const label =
    level === 'exam-ready'        ? 'Exam Ready'
    : level === 'on-track'        ? 'On Track'
    : 'Needs Improvement';

  return {
    components: { skillMastery, weeklyTests, consistency, completionRate, overall },
    level, colour, label, percentage: overall,
  };
}

/** Returns days remaining until exam date (or null if no date set). */
export function daysUntilExam(examDate: string | null | undefined): number | null {
  if (!examDate) return null;
  const diff = new Date(examDate).getTime() - Date.now();
  return Math.max(0, Math.ceil(diff / 86400000));
}

/** Formats days into a human-readable countdown string. */
export function formatCountdown(days: number | null): string {
  if (days === null) return 'No exam date set';
  if (days === 0)    return 'Today!';
  if (days === 1)    return '1 day to go';
  if (days < 30)     return `${days} days to go`;
  const weeks = Math.floor(days / 7);
  if (weeks < 8)     return `${weeks} week${weeks !== 1 ? 's' : ''} to go`;
  const months = Math.floor(days / 30);
  return `${months} month${months !== 1 ? 's' : ''} to go`;
}
