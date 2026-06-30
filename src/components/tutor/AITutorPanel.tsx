import { useState } from 'react';
import { supabase } from '../../lib/supabase';
import { Coins, Sparkles } from 'lucide-react';

export interface MysteryChest {
  id: string;
  child_id: string;
  is_opened: boolean;
}

interface RewardResult {
  reward_type: 'coins' | 'shop_item' | 'companion_species';
  coins?: number;
  shop_item_id?: string;
  species_id?: string;
}

interface Props {
  chest: MysteryChest;
  onClose: (reward: RewardResult | null) => void;
}

type Stage = 'closed' | 'opening' | 'revealed';

export function MysteryChestModal({ chest, onClose }: Props) {
  const [stage, setStage] = useState<Stage>('closed');
  const [reward, setReward] = useState<RewardResult | null>(null);
  const [rewardLabel, setRewardLabel] = useState<{ emoji: string; title: string; subtitle: string; rare: boolean } | null>(null);

  const handleTap = async () => {
    if (stage !== 'closed') return;
    setStage('opening');

    const { data } = await supabase.rpc('open_mystery_chest', { p_chest_id: chest.id });
    const result = data as RewardResult & { success?: boolean } | null;

    // Small delay so the "opening" shake animation gets to play before the reveal —
    // makes the moment feel earned rather than instant, without making the child wait long.
    await new Promise(r => setTimeout(r, 700));

    if (!result?.success) {
      setStage('revealed');
      setRewardLabel({ emoji: '📦', title: 'Already opened', subtitle: 'This chest has already been claimed', rare: false });
      return;
    }

    setReward(result);

    if (result.reward_type === 'coins') {
      setRewardLabel({ emoji: '🪙', title: `+${result.coins} Coins!`, subtitle: 'Spend them at the Outfitter', rare: false });
    } else if (result.reward_type === 'shop_item') {
      const { data: item } = await supabase.from('shop_items').select('name, emoji, rarity').eq('id', result.shop_item_id).single();
      setRewardLabel({
        emoji: item?.emoji ?? '🎁',
        title: item?.name ?? 'A new item!',
        subtitle: 'Added to your inventory — free!',
        rare: item?.rarity === 'epic' || item?.rarity === 'legendary',
      });
    } else if (result.reward_type === 'companion_species') {
      const { data: sp } = await supabase.from('companion_species').select('name, stage_emojis, rarity').eq('id', result.species_id).single();
      setRewardLabel({
        emoji: sp?.stage_emojis?.[0] ?? '🥚',
        title: `New companion: ${sp?.name ?? 'Mystery Creature'}!`,
        subtitle: 'Visit your companion screen to meet them',
        rare: true,
      });
    }

    setStage('revealed');
  };

  return (
    <div className="fixed inset-0 z-50 bg-twilight-deep/90 backdrop-blur-sm flex items-center justify-center px-4">
      <div className="max-w-sm w-full text-center">
        {stage !== 'revealed' && (
          <>
            <button
              onClick={handleTap}
              disabled={stage === 'opening'}
              className={`text-8xl mb-6 transition-transform ${stage === 'opening' ? 'animate-shimmer' : 'hover:scale-110 active:scale-95 cursor-pointer'}`}
              aria-label="Open mystery chest"
            >
              📦
            </button>
            <h2 className="text-parchment text-xl font-display font-bold mb-2">
              {stage === 'opening' ? 'Opening...' : 'A Mystery Chest!'}
            </h2>
            <p className="text-parchment-dim text-sm">
              {stage === 'opening' ? 'See what you found...' : 'Tap the chest to see what\'s inside'}
            </p>
          </>
        )}

        {stage === 'revealed' && rewardLabel && (
          <div className="animate-chestPop">
            {rewardLabel.rare && (
              <div className="flex justify-center gap-2 mb-2">
                <Sparkles className="w-5 h-5 text-quest-gold animate-pulse" />
                <Sparkles className="w-5 h-5 text-quest-gold animate-pulse" />
                <Sparkles className="w-5 h-5 text-quest-gold animate-pulse" />
              </div>
            )}
            <div className="text-8xl mb-4">{rewardLabel.emoji}</div>
            <h2 className={`text-2xl font-display font-black mb-2 ${rewardLabel.rare ? 'text-quest-gold' : 'text-parchment'}`}>
              {rewardLabel.title}
            </h2>
            <p className="text-parchment-dim text-sm mb-8">{rewardLabel.subtitle}</p>
            <button
              onClick={() => onClose(reward)}
              className="w-full flex items-center justify-center gap-2 py-4 bg-gradient-to-r from-quest-goldDim to-quest-gold text-twilight-deep rounded-2xl font-bold font-display text-lg hover:shadow-glow transition-all active:scale-95 shadow-lg"
            >
              <Coins className="w-5 h-5" />
              Continue
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
