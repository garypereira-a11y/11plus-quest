import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { CompanionSpecies } from './CompanionCard';
import { Check } from 'lucide-react';

interface Props {
  childId: string;
  onChosen: () => void;
}

export function CompanionChooserPage({ childId, onChosen }: Props) {
  const [species, setSpecies] = useState<CompanionSpecies[]>([]);
  const [selected, setSelected] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    supabase.from('companion_species').select('*')
      .eq('unlock_method', 'starter').order('sort_order')
      .then(({ data }) => {
        setSpecies((data ?? []) as CompanionSpecies[]);
        setLoading(false);
      });
  }, []);

  const confirm = async () => {
    if (!selected) return;
    setSaving(true);
    await supabase.rpc('choose_companion_species', { p_child_id: childId, p_species_id: selected });
    setSaving(false);
    onChosen();
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-twilight-deep via-twilight to-twilight-deep flex items-center justify-center">
        <div className="text-parchment-dim font-display animate-pulse">Gathering companions...</div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-twilight-deep via-twilight to-twilight-deep flex flex-col">
      <div className="px-4 pt-10 pb-6 text-center">
        <div className="text-5xl mb-3">🥚</div>
        <h1 className="text-parchment text-2xl font-display font-bold">Choose Your Companion</h1>
        <p className="text-parchment-dim text-sm mt-1">They'll grow alongside you as you learn</p>
      </div>

      <div className="flex-1 px-4 pb-4">
        <div className="max-w-md mx-auto grid grid-cols-2 gap-3">
          {species.map(s => {
            const isSelected = selected === s.id;
            return (
              <button key={s.id} onClick={() => setSelected(s.id)}
                className={`flex flex-col items-center gap-2 p-5 rounded-scroll border-2 transition-all ${
                  isSelected ? 'border-quest-gold bg-quest-gold/10 scale-[1.02] shadow-glow' : 'border-white/10 bg-white/5 hover:border-white/25'
                }`}>
                <span className="text-5xl">{s.stage_emojis[0]}</span>
                <p className="text-parchment font-display font-bold text-sm">{s.name}</p>
                <p className="text-parchment-dim/60 text-[11px] text-center leading-tight">{s.description}</p>
                {isSelected && (
                  <span className="flex items-center gap-1 text-quest-gold text-xs font-bold mt-1">
                    <Check className="w-3.5 h-3.5" /> Selected
                  </span>
                )}
              </button>
            );
          })}
        </div>
      </div>

      <div className="px-4 pb-8">
        <div className="max-w-md mx-auto">
          <button onClick={confirm} disabled={!selected || saving}
            className="w-full flex items-center justify-center gap-2 py-4 bg-gradient-to-r from-quest-goldDim to-quest-gold text-twilight-deep rounded-2xl font-bold font-display text-lg hover:shadow-glow transition-all active:scale-95 disabled:opacity-40 shadow-lg">
            {saving ? 'Hatching...' : 'Begin the Quest Together'}
          </button>
        </div>
      </div>
    </div>
  );
}
