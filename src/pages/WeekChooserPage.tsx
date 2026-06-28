import { useState, useEffect, useRef } from 'react';
import { supabase } from '../lib/supabase';
import { ChildRecord } from '../lib/supabase';
import { getExamProfile } from '../lib/examProfiles';
import { ArrowLeft, Lock, Star } from 'lucide-react';

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

// Waypoint icons cycle through a small set of fantasy landmarks for visual variety along the path.
const LANDMARK_ICONS = ['🏰', '🗼', '⛺', '🌉', '🏯', '🛖'];

export function WeekChooserPage({ childId, onStartWeek, onBack }: Props) {
  const [child, setChild]       = useState<ChildRecord | null>(null);
  const [tests, setTests]       = useState<WeeklyTestRecord[]>([]);
  // Maps week_number -> unlock_threshold (the score % needed to unlock the next week),
  // sourced from curriculum_weeks so the map can show pass/fail at a glance rather than
  // just a bare score number.
  const [thresholds, setThresholds] = useState<Map<number, number>>(new Map());
  const [loading, setLoading]   = useState(true);
  const [generatingWeek, setGeneratingWeek] = useState<number | null>(null);
  const [error, setError]       = useState('');
  const currentRef = useRef<HTMLDivElement>(null);

  const load = () => {
    setLoading(true);
    Promise.all([
      supabase.from('children').select('*').eq('id', childId).single(),
      supabase.from('ai_weekly_tests').select('id,week_number,question_ids,completed_at,score').eq('child_id', childId),
      supabase.from('curriculum_weeks').select('week_number,unlock_threshold'),
    ]).then(([childRes, testsRes, weeksRes]) => {
      setChild(childRes.data as ChildRecord | null);
      setTests((testsRes.data ?? []) as WeeklyTestRecord[]);
      const map = new Map<number, number>();
      for (const w of (weeksRes.data ?? []) as { week_number: number; unlock_threshold: number }[]) {
        map.set(w.week_number, w.unlock_threshold);
      }
      setThresholds(map);
      setLoading(false);
    });
  };

  useEffect(() => { load(); }, [childId]);

  // Scroll the current/next week into view once loaded.
  useEffect(() => {
    if (!loading && currentRef.current) {
      currentRef.current.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
  }, [loading]);

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

  // ── Path geometry ──────────────────────────────────────────────────────────
  // Generate a winding zigzag path: alternating left/center/right x-positions per week,
  // descending down the screen. SVG viewBox uses a fixed width (320) with proportional
  // height per row so it scales cleanly inside the max-w-lg container.
  const ROW_HEIGHT = 132;
  const VB_WIDTH = 320;
  const xForIndex = (i: number) => {
    const pattern = [0.5, 0.78, 0.5, 0.22]; // center, right, center, left — repeats
    return pattern[i % pattern.length] * VB_WIDTH;
  };
  const weeks = Array.from({ length: profile.totalWeeks }, (_, i) => i);
  const points = weeks.map((i) => ({ x: xForIndex(i), y: i * ROW_HEIGHT + 70 }));
  const vbHeight = weeks.length * ROW_HEIGHT + 100;

  // Smooth path string through all waypoints using quadratic curves between midpoints.
  const pathD = points.reduce((acc, p, i) => {
    if (i === 0) return `M ${p.x} ${p.y}`;
    const prev = points[i - 1];
    const midY = (prev.y + p.y) / 2;
    return `${acc} C ${prev.x} ${midY}, ${p.x} ${midY}, ${p.x} ${p.y}`;
  }, '');

  return (
    <div className="min-h-screen bg-gradient-to-br from-twilight-deep via-twilight to-twilight-deep pb-8">
      {/* Header */}
      <div className="px-4 pt-6 pb-4 sticky top-0 z-20 bg-gradient-to-b from-twilight-deep via-twilight-deep/95 to-transparent">
        <div className="max-w-lg mx-auto flex items-center gap-3">
          <button onClick={onBack}
            className="w-10 h-10 rounded-xl bg-white/5 hover:bg-white/10 flex items-center justify-center transition-all shrink-0">
            <ArrowLeft className="w-5 h-5 text-parchment-dim" />
          </button>
          <div>
            <p className="text-parchment-dim/60 text-xs font-semibold uppercase tracking-wide">{child.target_exam_type}</p>
            <h1 className="text-parchment text-xl font-display font-bold">{profile.totalWeeks}-Week Quest Map</h1>
          </div>
        </div>

        {error && (
          <div className="max-w-lg mx-auto mt-3 px-4 py-3 bg-realm-coral/10 border border-realm-coral/25 rounded-xl">
            <p className="text-realm-coral text-sm">{error}</p>
          </div>
        )}
      </div>

      {/* Map */}
      <div className="px-4">
        <div className="max-w-lg mx-auto relative" style={{ height: vbHeight }}>
          {/* Decorative background path (SVG) */}
          <svg
            viewBox={`0 0 ${VB_WIDTH} ${vbHeight}`}
            className="absolute inset-0 w-full h-full pointer-events-none"
            preserveAspectRatio="xMidYMin meet"
          >
            <path d={pathD} fill="none" stroke="rgba(217,164,99,0.18)" strokeWidth="6" strokeLinecap="round" />
            <path d={pathD} fill="none" stroke="rgba(217,164,99,0.35)" strokeWidth="2" strokeDasharray="2 10" strokeLinecap="round" />
          </svg>

          {/* Waypoint nodes */}
          {weeks.map((i) => {
            const week       = i + 1;
            const done       = completedWeeks.has(week);
            const unlocked   = week <= maxUnlocked;
            const isCurrent  = unlocked && !done;
            const testRow    = tests.find(t => t.week_number === week);
            // A row exists (generate_child_test already ran for this week) but has no
            // completed_at yet — the child started this week's quiz and didn't finish it.
            const inProgress = unlocked && !done && !!testRow && !testRow.completed_at;
            const generating = generatingWeek === week;
            const difficulty = profile.difficultyProgression[i]?.difficulty ?? 5;
            const score      = testRow?.score;
            const threshold  = thresholds.get(week) ?? 85; // fallback matches curriculum_weeks' own column default
            const passedThreshold = score != null && score >= threshold;
            const { x, y }   = points[i];
            const icon       = LANDMARK_ICONS[i % LANDMARK_ICONS.length];

            return (
              <div key={week}
                ref={isCurrent && week === maxUnlocked ? currentRef : undefined}
                className="absolute flex flex-col items-center"
                style={{ left: `${(x / VB_WIDTH) * 100}%`, top: y, transform: 'translate(-50%, -50%)' }}>

                <button
                  onClick={() => unlocked && !generating && handleWeekTap(week)}
                  disabled={!unlocked || generating}
                  className={`relative w-20 h-20 rounded-full flex items-center justify-center text-3xl transition-all border-[3px] ${
                    done       ? 'bg-realm-emerald/20 border-realm-emerald shadow-glow-emerald' :
                    inProgress ? 'bg-quest-gold/10 border-quest-gold/60 border-dashed shadow-glow' :
                    isCurrent  ? 'bg-quest-gold/20 border-quest-gold shadow-glow animate-pulse-ring' :
                                 'bg-white/5 border-white/10 opacity-60'
                  } ${unlocked && !generating ? 'active:scale-90 hover:scale-105' : 'cursor-not-allowed'}`}
                >
                  {generating ? (
                    <div className="w-7 h-7 border-2 border-quest-gold border-t-transparent rounded-full animate-spin" />
                  ) : unlocked ? (
                    <span className={!done && !isCurrent && !inProgress ? 'opacity-50' : ''}>{icon}</span>
                  ) : (
                    <Lock className="w-7 h-7 text-white/25" />
                  )}

                  {/* Score badge for completed weeks — green if it cleared the unlock
                      threshold, coral if it didn't (so a child can tell at a glance
                      whether a past attempt actually passed, not just see a number) */}
                  {done && score != null && (
                    <div className={`absolute -bottom-1.5 -right-1.5 text-twilight-deep text-[10px] font-bold font-ledger px-1.5 py-0.5 rounded-full border-2 border-twilight-deep ${
                      passedThreshold ? 'bg-realm-emerald' : 'bg-realm-coral'
                    }`}>
                      {score}%
                    </div>
                  )}

                  {/* Star ring for current week's difficulty */}
                  {isCurrent && (
                    <div className="absolute -top-2 -right-1 flex">
                      <Star className="w-4 h-4 text-quest-gold fill-quest-gold" />
                    </div>
                  )}

                  {/* Paused-progress indicator for a started-but-unfinished week */}
                  {inProgress && (
                    <div className="absolute -bottom-1.5 -right-1.5 bg-quest-gold text-twilight-deep text-[9px] font-bold font-ledger px-1.5 py-0.5 rounded-full border-2 border-twilight-deep">
                      ⏸
                    </div>
                  )}
                </button>

                <div className="mt-2 text-center max-w-[88px]">
                  <p className={`text-xs font-bold font-display leading-tight ${
                    done ? 'text-realm-emerald' : inProgress ? 'text-quest-gold' : unlocked ? 'text-parchment' : 'text-parchment-dim/30'
                  }`}>
                    Week {week}
                  </p>
                  {generating && (
                    <p className="text-quest-gold/70 text-[10px] mt-0.5">Building...</p>
                  )}
                  {!generating && inProgress && (
                    <p className="text-quest-gold/80 text-[10px] mt-0.5 font-semibold">Continue</p>
                  )}
                  {!generating && unlocked && !done && !inProgress && (
                    <p className="text-parchment-dim/50 text-[10px] mt-0.5">Lvl {difficulty}/10</p>
                  )}
                </div>
              </div>
            );
          })}

          {/* Finish line flag beyond the last week */}
          <div
            className="absolute flex flex-col items-center pointer-events-none"
            style={{
              left: `${(xForIndex(weeks.length) / VB_WIDTH) * 100}%`,
              top: weeks.length * ROW_HEIGHT + 70,
              transform: 'translate(-50%, -50%)',
            }}
          >
            <div className={`text-4xl ${highestCompleted >= profile.totalWeeks ? '' : 'opacity-30'}`}>🏆</div>
            <p className="text-parchment-dim/50 text-[10px] mt-1 font-display font-bold">Exam Day</p>
          </div>
        </div>
      </div>
    </div>
  );
}
