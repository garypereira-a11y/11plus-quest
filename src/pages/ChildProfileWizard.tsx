import { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { supabase } from '../lib/supabase';
import { ALL_EXAM_TYPES, ALL_TARGET_SCHOOLS, ALL_YEAR_GROUPS } from '../lib/examProfiles';
import { ChevronRight, ChevronLeft, Check, User, GraduationCap, School, Calendar, Target } from 'lucide-react';

interface Props {
  onComplete: (childId: string) => void;
  onSkip?: () => void;
  isFirstChild?: boolean;
}

interface WizardData {
  firstName: string;
  yearGroup: string;
  targetSchool: string;
  examMonth: string;
  examYear: string;
  examType: string;
  avatar: string;
}

const STEP_CONFIG = [
  { icon: User,          label: "Child's Name",  description: "What is your child's first name?" },
  { icon: GraduationCap, label: 'School Year',    description: 'Which year group are they in?' },
  { icon: School,        label: 'Target School',  description: 'Which school are they aiming for?' },
  { icon: Calendar,      label: 'Exam Date',      description: 'When is the entrance exam?' },
  { icon: Target,        label: 'Exam Type',      description: 'Which exam are they sitting?' },
];

const AVATARS = ['🧒', '👦', '👧', '🧑', '🎓', '🦊', '🐉', '🦁', '🌟', '⚡', '🦅', '🧙'];

const MONTHS = [
  'January','February','March','April','May','June',
  'July','August','September','October','November','December',
];
const CURRENT_YEAR = new Date().getFullYear();
const YEARS = Array.from({ length: 5 }, (_, i) => String(CURRENT_YEAR + i));

export function ChildProfileWizard({ onComplete, onSkip, isFirstChild = false }: Props) {
  const { user } = useAuth();
  const [step, setStep]   = useState(0);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');
  const [data, setData]   = useState<WizardData>({
    firstName: '', yearGroup: 'Year 5', targetSchool: '', examMonth: '', examYear: '', examType: 'GL Assessment', avatar: '🧒',
  });

  const set = (key: keyof WizardData, value: string) => setData(d => ({ ...d, [key]: value }));

  const canAdvance = () => {
    if (step === 0) return data.firstName.trim().length >= 2;
    if (step === 1) return !!data.yearGroup;
    if (step === 2) return !!data.targetSchool;
    if (step === 3) return true; // exam date is optional
    if (step === 4) return !!data.examType;
    return true;
  };

  const handleSave = async () => {
    if (!user) return;
    setSaving(true); setError('');
    try {
      const examDate = data.examMonth && data.examYear
        ? `${data.examYear}-${String(MONTHS.indexOf(data.examMonth) + 1).padStart(2, '0')}-01`
        : null;

      const { data: child, error: err } = await supabase.from('children').insert({
        parent_id:       user.id,
        first_name:      data.firstName.trim(),
        year_group:      data.yearGroup,
        target_school:   data.targetSchool || null,
        exam_date:       examDate,
        target_exam_type: data.examType,
        avatar:          data.avatar,
        xp_points:       0,
        level:           1,
      }).select('id').single();

      if (err || !child) { setError(err?.message ?? 'Failed to save profile. Please try again.'); return; }
      onComplete(child.id);
    } finally {
      setSaving(false);
    }
  };

  const isLast = step === STEP_CONFIG.length - 1;

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#0f172a] via-[#1e2d3d] to-[#0f172a] flex flex-col">
      {/* Top bar */}
      <div className="px-4 pt-6 pb-4">
        <div className="max-w-md mx-auto">
          {isFirstChild && (
            <div className="text-center mb-6">
              <div className="text-4xl mb-2">🎉</div>
              <h1 className="text-2xl font-bold text-white">Welcome to 11+ Quest!</h1>
              <p className="text-white/50 text-sm mt-1">Let's set up your child's profile</p>
            </div>
          )}

          {/* Step indicator */}
          <div className="flex items-center gap-2 justify-center mb-6">
            {STEP_CONFIG.map((_s, i) => (
              <div key={i} className="flex items-center gap-1">
                <div className={`w-8 h-8 rounded-full flex items-center justify-center transition-all ${
                  i < step  ? 'bg-emerald-500 text-white' :
                  i === step ? 'bg-amber-400 text-amber-900 animate-pulse-ring' :
                  'bg-white/10 text-white/30'
                }`}>
                  {i < step ? <Check className="w-4 h-4" /> : <span className="text-xs font-bold">{i + 1}</span>}
                </div>
                {i < STEP_CONFIG.length - 1 && (
                  <div className={`h-0.5 w-6 rounded transition-all ${i < step ? 'bg-emerald-500' : 'bg-white/10'}`} />
                )}
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Step content */}
      <div className="flex-1 px-4 pb-4">
        <div className="max-w-md mx-auto">
          <div className="bg-[#1e2d3d] rounded-3xl border border-white/10 p-6 animate-fadeIn" key={step}>
            <div className="flex items-center gap-3 mb-6">
              <div className="w-12 h-12 rounded-2xl bg-amber-400/15 flex items-center justify-center">
                {(() => { const Icon = STEP_CONFIG[step].icon; return <Icon className="w-6 h-6 text-amber-400" />; })()}
              </div>
              <div>
                <p className="text-white/40 text-xs font-semibold uppercase tracking-wide">Step {step + 1} of {STEP_CONFIG.length}</p>
                <h2 className="text-white font-bold text-lg leading-tight">{STEP_CONFIG[step].label}</h2>
              </div>
            </div>

            <p className="text-white/60 text-sm mb-5">{STEP_CONFIG[step].description}</p>

            {/* Step 0: Name + Avatar */}
            {step === 0 && (
              <div className="space-y-4">
                <input
                  type="text" value={data.firstName} onChange={e => set('firstName', e.target.value)}
                  placeholder="First name" autoFocus maxLength={30}
                  className="w-full px-4 py-4 rounded-2xl bg-white/5 border-2 border-white/10 focus:border-amber-400 focus:outline-none text-white text-lg font-semibold placeholder-white/20"
                />
                <div>
                  <p className="text-white/50 text-xs font-semibold mb-3">Choose an avatar</p>
                  <div className="grid grid-cols-6 gap-2">
                    {AVATARS.map(av => (
                      <button key={av} onClick={() => set('avatar', av)}
                        className={`aspect-square rounded-xl flex items-center justify-center text-2xl border-2 transition-all ${data.avatar === av ? 'border-amber-400 bg-amber-400/15 scale-110' : 'border-white/10 bg-white/5 hover:border-white/30'}`}>
                        {av}
                      </button>
                    ))}
                  </div>
                </div>
              </div>
            )}

            {/* Step 1: Year Group */}
            {step === 1 && (
              <div className="grid grid-cols-2 gap-3">
                {ALL_YEAR_GROUPS.map(yg => (
                  <button key={yg} onClick={() => set('yearGroup', yg)}
                    className={`py-5 rounded-2xl border-2 font-bold text-lg transition-all ${data.yearGroup === yg ? 'border-amber-400 bg-amber-400/15 text-amber-300' : 'border-white/10 bg-white/5 text-white hover:border-white/30'}`}>
                    {yg}
                  </button>
                ))}
              </div>
            )}

            {/* Step 2: Target School */}
            {step === 2 && (
              <div className="space-y-2">
                {ALL_TARGET_SCHOOLS.map(school => (
                  <button key={school} onClick={() => set('targetSchool', school)}
                    className={`w-full flex items-center justify-between px-4 py-3.5 rounded-2xl border-2 transition-all text-left ${data.targetSchool === school ? 'border-amber-400 bg-amber-400/10 text-white' : 'border-white/10 bg-white/5 text-white/70 hover:border-white/25 hover:bg-white/8'}`}>
                    <span className="font-semibold text-sm">{school}</span>
                    {data.targetSchool === school && <Check className="w-4 h-4 text-amber-400 shrink-0" />}
                  </button>
                ))}
              </div>
            )}

            {/* Step 3: Exam Date */}
            {step === 3 && (
              <div className="space-y-4">
                <p className="text-white/40 text-xs">Optional — leave blank if not yet confirmed</p>
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <p className="text-white/50 text-xs font-semibold mb-2">Month</p>
                    <select value={data.examMonth} onChange={e => set('examMonth', e.target.value)}
                      className="w-full px-4 py-3 rounded-xl bg-white/5 border-2 border-white/10 focus:border-amber-400 focus:outline-none text-white appearance-none">
                      <option value="">Month</option>
                      {MONTHS.map(m => <option key={m} value={m}>{m}</option>)}
                    </select>
                  </div>
                  <div>
                    <p className="text-white/50 text-xs font-semibold mb-2">Year</p>
                    <select value={data.examYear} onChange={e => set('examYear', e.target.value)}
                      className="w-full px-4 py-3 rounded-xl bg-white/5 border-2 border-white/10 focus:border-amber-400 focus:outline-none text-white appearance-none">
                      <option value="">Year</option>
                      {YEARS.map(y => <option key={y} value={y}>{y}</option>)}
                    </select>
                  </div>
                </div>
                {data.examMonth && data.examYear && (
                  <div className="bg-emerald-900/20 border border-emerald-500/20 rounded-xl px-4 py-3 flex items-center gap-2">
                    <Calendar className="w-4 h-4 text-emerald-400" />
                    <p className="text-emerald-300 text-sm font-semibold">Exam: {data.examMonth} {data.examYear}</p>
                  </div>
                )}
              </div>
            )}

            {/* Step 4: Exam Type */}
            {step === 4 && (
              <div className="space-y-2">
                {ALL_EXAM_TYPES.map(type => (
                  <button key={type} onClick={() => set('examType', type)}
                    className={`w-full flex items-center justify-between px-4 py-3.5 rounded-2xl border-2 transition-all text-left ${data.examType === type ? 'border-amber-400 bg-amber-400/10 text-white' : 'border-white/10 bg-white/5 text-white/70 hover:border-white/25'}`}>
                    <span className="font-semibold text-sm">{type}</span>
                    {data.examType === type && <Check className="w-4 h-4 text-amber-400 shrink-0" />}
                  </button>
                ))}
              </div>
            )}

            {error && <p className="mt-4 text-red-400 text-sm text-center">{error}</p>}
          </div>

          {/* Navigation */}
          <div className="flex gap-3 mt-4">
            {step > 0 && (
              <button onClick={() => setStep(s => s - 1)}
                className="flex items-center gap-2 px-5 py-3.5 bg-white/5 hover:bg-white/10 text-white/70 rounded-2xl font-semibold transition-all">
                <ChevronLeft className="w-5 h-5" /> Back
              </button>
            )}
            {onSkip && step === 0 && (
              <button onClick={onSkip} className="px-5 py-3.5 text-white/30 hover:text-white/50 rounded-2xl font-medium transition-colors text-sm">
                Skip for now
              </button>
            )}
            <button
              onClick={isLast ? handleSave : () => setStep(s => s + 1)}
              disabled={!canAdvance() || saving}
              className="flex-1 flex items-center justify-center gap-2 py-3.5 bg-gradient-to-r from-amber-500 to-yellow-400 text-amber-900 rounded-2xl font-bold text-lg hover:from-amber-400 transition-all active:scale-95 disabled:opacity-40 shadow-lg"
            >
              {saving ? 'Saving...' : isLast ? `Save ${data.firstName || 'Profile'}!` : 'Continue'}
              {!saving && !isLast && <ChevronRight className="w-5 h-5" />}
              {!saving && isLast && <Check className="w-5 h-5" />}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
