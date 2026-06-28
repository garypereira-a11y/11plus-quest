import { useState, useEffect, useCallback } from 'react';
import { supabase } from '../lib/supabase';
import { Sparkles } from 'lucide-react';

export interface CompanionSpecies {
  id: string;
  name: string;
  description: string;
  rarity: 'common' | 'rare' | 'epic' | 'legendary';
  stage_emojis: string[];
  stage_names: string[];
  unlock_method: 'starter' | 'mystery_chest' | 'shop';
  shop_cost: number | null;
}

export interface ChildCompanion {
  child_id: string;
  species_id: string;
  current_stage: number;
  nickname: string | null;
  species?: CompanionSpecies;
}

interface Props {
  childId: string;
  /** Compact mode renders just the creature + name, for embedding in headers/dashboards. */
  compact?: boolean;
  /** Called once data loads, so parent screens can react (e.g. show a "choose companion" prompt). */
  onLoaded?: (companion: ChildCompanion | null) => void;
}

const RARITY_GLOW: Record<CompanionSpecies['rarity'], string> = {
  common:    '',
  rare:      'shadow-glow-emerald',
  epic:      'shadow-glow',
  legendary: 'shadow-glow animate-pulse-ring',
};

export function CompanionCard({ childId, compact = false, onLoaded }: Props) {
  const [companion, setCompanion] = useState<ChildCompanion | null>(null);
  const [loading, setLoading]     = useState(true);
  const [justEvolved, setJustEvolved] = useState(false);

  const load = useCallback(async () => {
    setLoading(true);
    const { data } = await supabase
      .from('child_companion')
      .select('*, species:companion_species(*)')
      .eq('child_id', childId)
      .maybeSingle();

    const result = data as ChildCompanion | null;
    setCompanion(result);
    setLoading(false);
    onLoaded?.(result);
  }, [childId, onLoaded]);

  useEffect(() => { load(); }, [load]);

  // Re-check evolution whenever this card mounts (e.g. after returning from a quiz,
  // where XP/level may have just gone up). This is a cheap, idempotent check —
  // evolve_companion() only updates anything if the level threshold was actually crossed.
  useEffect(() => {
    if (!childId) return;
    supabase.rpc('evolve_companion', { p_child_id: childId }).then(({ data }) => {
      const result = data as { evolved?: boolean } | null;
      if (result?.evolved) {
        setJustEvolved(true);
        load();
        setTimeout(() => setJustEvolved(false), 3000);
      }
    });
  }, [childId, load]);

  if (loading) {
    return <div className={compact ? 'w-12 h-12' : 'w-32 h-32'} />;
  }

  if (!companion || !companion.species) {
    return null; // parent screen should handle "no companion chosen yet" via onLoaded
  }

  const { species, current_stage, nickname } = companion;
  const emoji = species.stage_emojis[current_stage] ?? species.stage_emojis[0];
  const stageName = species.stage_names[current_stage] ?? species.stage_names[0];
  const displayName = nickname || species.name;

  if (compact) {
    return (
      <div className="flex items-center gap-2">
        <span className={`text-3xl transition-transform ${justEvolved ? 'animate-chestPop' : ''}`}>{emoji}</span>
        <div className="min-w-0">
          <p className="text-parchment text-xs font-bold font-display truncate">{displayName}</p>
          <p className="text-parchment-dim/50 text-[10px] truncate">{stageName}</p>
        </div>
      </div>
    );
  }

  return (
    <div className="relative flex flex-col items-center">
      {justEvolved && (
        <div className="absolute -top-8 left-1/2 -translate-x-1/2 flex items-center gap-1 px-3 py-1 bg-quest-gold/20 border border-quest-gold/40 rounded-full animate-fadeIn whitespace-nowrap">
          <Sparkles className="w-3.5 h-3.5 text-quest-gold" />
          <span className="text-quest-gold text-xs font-bold font-display">Evolved!</span>
        </div>
      )}
      <div className={`w-28 h-28 rounded-full bg-twilight-surface border-2 border-quest-gold/20 flex items-center justify-center text-6xl transition-all ${RARITY_GLOW[species.rarity]} ${justEvolved ? 'animate-chestPop' : ''}`}>
        {emoji}
      </div>
      <p className="text-parchment font-display font-bold mt-3">{displayName}</p>
      <p className="text-parchment-dim/60 text-xs">{stageName}</p>
      {species.rarity !== 'common' && (
        <span className={`mt-1 px-2 py-0.5 rounded-full text-[10px] font-bold uppercase tracking-wide ${
          species.rarity === 'legendary' ? 'bg-quest-gold/20 text-quest-gold' :
          species.rarity === 'epic'      ? 'bg-realm-coral/20 text-realm-coral' :
                                            'bg-realm-emerald/20 text-realm-emerald'
        }`}>
          {species.rarity}
        </span>
      )}
    </div>
  );
}
