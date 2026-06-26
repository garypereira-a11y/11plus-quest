import { ChildEquipped, ShopSlot } from '../lib/supabase';

interface Props {
  baseAvatar: string;
  equipped: ChildEquipped[];
  size?: 'sm' | 'md' | 'lg' | 'xl';
}

const SIZE_MAP = {
  sm: { box: 'w-12 h-12', base: 'text-2xl', accent: 'text-base', hat: '-top-2', face: 'top-1/2 -translate-y-1/2' },
  md: { box: 'w-16 h-16', base: 'text-3xl', accent: 'text-lg',   hat: '-top-2.5', face: 'top-1/2 -translate-y-1/2' },
  lg: { box: 'w-24 h-24', base: 'text-5xl', accent: 'text-2xl',  hat: '-top-3.5', face: 'top-1/2 -translate-y-1/2' },
  xl: { box: 'w-32 h-32', base: 'text-6xl', accent: 'text-3xl',  hat: '-top-5',   face: 'top-1/2 -translate-y-1/2' },
} as const;

/**
 * Renders a child's avatar with any equipped accessories layered on top.
 * `background` renders as a subtle full-tile tint behind the character;
 * `outfit` sits as a small badge at bottom-right; `face` overlays center;
 * `hat` sits above the character's head.
 */
export function AvatarDisplay({ baseAvatar, equipped, size = 'md' }: Props) {
  const s = SIZE_MAP[size];
  const bySlot = (slot: ShopSlot) => equipped.find(e => e.slot === slot)?.shop_item;

  const background = bySlot('background');
  const outfit = bySlot('outfit');
  const face = bySlot('face');
  const hat = bySlot('hat');

  return (
    <div className={`relative ${s.box} shrink-0`}>
      {/* Background tint layer */}
      <div className={`absolute inset-0 rounded-2xl bg-twilight-raised border-2 border-quest-gold/30 flex items-center justify-center overflow-hidden`}>
        {background && (
          <span className="absolute inset-0 flex items-center justify-center text-3xl opacity-25 scale-150">
            {background.emoji}
          </span>
        )}
        <span className={`relative ${s.base}`}>{baseAvatar}</span>
        {face && (
          <span className={`absolute ${s.face} left-1/2 -translate-x-1/2 ${s.accent} opacity-90`}>
            {face.emoji}
          </span>
        )}
      </div>

      {/* Hat layer — sits above the box */}
      {hat && (
        <span className={`absolute ${s.hat} left-1/2 -translate-x-1/2 ${s.accent} drop-shadow-md`}>
          {hat.emoji}
        </span>
      )}

      {/* Outfit accent badge — bottom-right corner */}
      {outfit && (
        <span className="absolute -bottom-1 -right-1 text-sm bg-twilight-deep rounded-full p-0.5 border border-quest-gold/30">
          {outfit.emoji}
        </span>
      )}
    </div>
  );
}
