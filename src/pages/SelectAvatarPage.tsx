import { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { supabase } from '../lib/supabase';
import { ArrowLeft, Check } from 'lucide-react';

const AVATARS = ['🧒', '👦', '👧', '🧑', '🎓', '🦊', '🐉', '🦁', '🌟', '⚡', '🦅', '🧙'];

interface Props {
  onBack: () => void;
}

export function SelectAvatarPage({ onBack }: Props) {
  const { user, profile, refreshProfile } = useAuth();
  const [selected, setSelected] = useState(profile?.avatar ?? '🎓');
  const [saving, setSaving]     = useState(false);

  const save = async () => {
    if (!user) return;
    setSaving(true);
    await supabase.from('profiles').update({ avatar: selected }).eq('id', user.id);
    await refreshProfile();
    setSaving(false);
    onBack();
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#0f172a] via-[#1e2d3d] to-[#0f172a] pb-8">
      <div className="px-4 pt-6">
        <div className="max-w-sm mx-auto">
          <button onClick={onBack}
            className="flex items-center gap-2 text-white/50 hover:text-white/80 transition-colors mb-6 text-sm font-medium">
            <ArrowLeft className="w-4 h-4" /> Back
          </button>
          <h1 className="text-white text-2xl font-bold mb-2">Choose Avatar</h1>
          <p className="text-white/40 text-sm mb-6">Pick your profile image</p>

          <div className="grid grid-cols-4 gap-3 mb-8">
            {AVATARS.map(av => (
              <button key={av} onClick={() => setSelected(av)}
                className={`aspect-square rounded-2xl flex items-center justify-center text-4xl border-2 transition-all ${
                  selected === av
                    ? 'border-amber-400 bg-amber-400/15 scale-110 shadow-lg'
                    : 'border-white/10 bg-white/5 hover:border-white/30'
                }`}>
                {av}
              </button>
            ))}
          </div>

          <button onClick={save} disabled={saving}
            className="w-full flex items-center justify-center gap-2 py-4 bg-gradient-to-r from-amber-500 to-yellow-400 text-amber-900 rounded-2xl font-bold text-lg hover:from-amber-400 transition-all active:scale-95 disabled:opacity-50 shadow-lg">
            <Check className="w-5 h-5" />
            {saving ? 'Saving...' : 'Save Avatar'}
          </button>
        </div>
      </div>
    </div>
  );
}
