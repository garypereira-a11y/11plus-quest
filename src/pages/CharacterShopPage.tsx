import { useState, useEffect, useCallback } from 'react';
import { supabase, ChildRecord, ShopItem, ShopSlot, ChildInventoryItem, ChildEquipped, SHOP_SLOT_ORDER, SHOP_SLOT_LABELS } from '../lib/supabase';
import { AvatarDisplay } from '../components/AvatarDisplay';
import { ArrowLeft, Coins, Check, Lock } from 'lucide-react';

interface Props {
  childId: string;
  onBack: () => void;
}

const RARITY_STYLE: Record<ShopItem['rarity'], string> = {
  common:    'border-white/15',
  rare:      'border-realm-emerald/40',
  epic:      'border-quest-gold/50',
  legendary: 'border-realm-coral/60',
};

export function CharacterShopPage({ childId, onBack }: Props) {
  const [child, setChild]         = useState<ChildRecord | null>(null);
  const [items, setItems]         = useState<ShopItem[]>([]);
  const [owned, setOwned]         = useState<ChildInventoryItem[]>([]);
  const [equipped, setEquipped]   = useState<ChildEquipped[]>([]);
  const [balance, setBalance]     = useState(0);
  const [activeSlot, setActiveSlot] = useState<ShopSlot>('hat');
  const [loading, setLoading]     = useState(true);
  const [busyItemId, setBusyItemId] = useState<string | null>(null);
  const [message, setMessage]     = useState('');

  const load = useCallback(async () => {
    setLoading(true);
    const [childRes, itemsRes, ownedRes, equippedRes, coinsRes] = await Promise.all([
      supabase.from('children').select('*').eq('id', childId).single(),
      supabase.from('shop_items').select('*').order('slot').order('sort_order'),
      supabase.from('child_inventory').select('*, shop_item:shop_items(*)').eq('child_id', childId),
      supabase.from('child_equipped').select('*, shop_item:shop_items(*)').eq('child_id', childId),
      supabase.from('child_coins').select('balance').eq('child_id', childId).maybeSingle(),
    ]);
    setChild(childRes.data as ChildRecord | null);
    setItems((itemsRes.data ?? []) as ShopItem[]);
    setOwned((ownedRes.data ?? []) as ChildInventoryItem[]);
    setEquipped((equippedRes.data ?? []) as ChildEquipped[]);
    setBalance(coinsRes.data?.balance ?? 0);
    setLoading(false);
  }, [childId]);

  useEffect(() => { load(); }, [load]);

  const ownedItemIds = new Set(owned.map(o => o.shop_item_id));
  const equippedInSlot = (slot: ShopSlot) => equipped.find(e => e.slot === slot);

  const handleBuy = async (item: ShopItem) => {
    setMessage('');
    setBusyItemId(item.id);
    const { data, error } = await supabase.rpc('purchase_item', { p_child_id: childId, p_shop_item_id: item.id });
    setBusyItemId(null);
    const result = data as { success: boolean; error?: string; new_balance?: number } | null;
    if (error || !result?.success) {
      const reason = result?.error === 'insufficient_coins' ? 'Not enough coins yet \u2014 keep questing!' : 'Could not complete purchase.';
      setMessage(reason);
      return;
    }
    setBalance(result.new_balance ?? balance);
    await load();
  };

  const handleEquip = async (item: ShopItem) => {
    setMessage('');
    setBusyItemId(item.id);
    const isEquipped = equippedInSlot(item.slot)?.shop_item_id === item.id;
    if (isEquipped) {
      await supabase.rpc('unequip_slot', { p_child_id: childId, p_slot: item.slot });
    } else {
      await supabase.rpc('equip_item', { p_child_id: childId, p_shop_item_id: item.id });
    }
    setBusyItemId(null);
    await load();
  };

  if (loading || !child) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-twilight-deep via-twilight to-twilight-deep flex items-center justify-center">
        <div className="text-parchment-dim font-display animate-pulse">Opening the bazaar...</div>
      </div>
    );
  }

  const slotItems = items.filter(i => i.slot === activeSlot);

  return (
    <div className="min-h-screen bg-gradient-to-br from-twilight-deep via-twilight to-twilight-deep pb-8">
      {/* Header */}
      <div className="px-4 pt-6 pb-4">
        <div className="max-w-lg mx-auto flex items-center gap-3 mb-4">
          <button onClick={onBack}
            className="w-10 h-10 rounded-xl bg-white/5 hover:bg-white/10 flex items-center justify-center transition-all shrink-0">
            <ArrowLeft className="w-5 h-5 text-parchment-dim" />
          </button>
          <div className="flex-1">
            <p className="text-parchment-dim/60 text-xs font-semibold uppercase tracking-wide">Character Bazaar</p>
            <h1 className="text-parchment text-xl font-display font-bold">{child.first_name}'s Outfitter</h1>
          </div>
          <div className="flex items-center gap-1.5 bg-quest-gold/15 border border-quest-gold/30 rounded-full px-3 py-1.5">
            <Coins className="w-4 h-4 text-quest-gold" />
            <span className="text-quest-gold font-bold text-sm font-ledger">{balance}</span>
          </div>
        </div>

        {/* Avatar preview */}
        <div className="max-w-lg mx-auto flex justify-center mb-4">
          <AvatarDisplay baseAvatar={child.avatar} equipped={equipped} size="xl" />
        </div>

        {message && (
          <div className="max-w-lg mx-auto px-4 py-2.5 bg-realm-coral/10 border border-realm-coral/25 rounded-xl mb-3">
            <p className="text-realm-coral text-sm text-center">{message}</p>
          </div>
        )}

        {/* Slot tabs */}
        <div className="max-w-lg mx-auto flex gap-2 overflow-x-auto pb-1">
          {SHOP_SLOT_ORDER.map(slot => (
            <button key={slot} onClick={() => setActiveSlot(slot)}
              className={`px-4 py-2 rounded-xl text-sm font-bold font-display whitespace-nowrap transition-all ${
                activeSlot === slot ? 'bg-quest-gold text-twilight-deep' : 'bg-white/5 text-parchment-dim hover:bg-white/10'
              }`}>
              {SHOP_SLOT_LABELS[slot]}
            </button>
          ))}
        </div>
      </div>

      {/* Item grid */}
      <div className="px-4">
        <div className="max-w-lg mx-auto grid grid-cols-2 gap-3">
          {slotItems.map(item => {
            const own = ownedItemIds.has(item.id);
            const isEquipped = equippedInSlot(item.slot)?.shop_item_id === item.id;
            const canAfford = balance >= item.cost;
            const busy = busyItemId === item.id;

            return (
              <div key={item.id}
                className={`bg-twilight-surface border-2 ${RARITY_STYLE[item.rarity]} rounded-scroll p-4 flex flex-col items-center gap-2 ${isEquipped ? 'shadow-glow' : ''}`}>
                <span className="text-4xl">{item.emoji}</span>
                <p className="text-parchment font-display font-bold text-sm text-center leading-tight">{item.name}</p>
                <p className="text-parchment-dim/50 text-[10px] uppercase tracking-wide">{item.rarity}</p>

                {own ? (
                  <button onClick={() => handleEquip(item)} disabled={busy}
                    className={`w-full mt-1 py-2 rounded-xl text-xs font-bold font-display transition-all flex items-center justify-center gap-1 ${
                      isEquipped ? 'bg-realm-emerald text-twilight-deep' : 'bg-white/10 text-parchment hover:bg-white/15'
                    }`}>
                    {isEquipped ? <><Check className="w-3.5 h-3.5" /> Equipped</> : 'Equip'}
                  </button>
                ) : (
                  <button onClick={() => handleBuy(item)} disabled={busy || !canAfford}
                    className={`w-full mt-1 py-2 rounded-xl text-xs font-bold font-display transition-all flex items-center justify-center gap-1.5 ${
                      canAfford ? 'bg-quest-gold text-twilight-deep hover:shadow-glow' : 'bg-white/5 text-parchment-dim/40 cursor-not-allowed'
                    }`}>
                    {canAfford ? <><Coins className="w-3.5 h-3.5" /> {item.cost}</> : <><Lock className="w-3.5 h-3.5" /> {item.cost}</>}
                  </button>
                )}
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
}
