/*
# 11+ Quest: Coins & Character Shop

Adds a coin economy and layered avatar accessory system.

## Tables Added
1. **shop_items** — catalog of purchasable accessories (hat, outfit, background, face)
2. **child_coins** — current coin balance per child
3. **coin_transactions** — audit log of every coin earn/spend event
4. **child_inventory** — items a child owns (purchased)
5. **child_equipped** — which item is currently worn per slot, per child

## Functions Added
- **award_coins(child_id, amount, reason, source_type, source_id)** — credits coins
  and logs the transaction. Used by achievement/streak/weekly-test triggers.
- **purchase_item(child_id, item_id)** — atomically checks balance, deducts coins,
  and adds the item to inventory. Prevents double-purchase and overspending.
- **equip_item(child_id, item_id)** — sets an owned item as equipped in its slot,
  unequipping any previous item in that slot.

All tables are RLS-secured using the existing `my_child_ids()` helper, consistent
with `skill_mastery` / `achievements` from migration 011.
*/

-- ── Shop catalog ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.shop_items (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  slot        text        NOT NULL CHECK (slot IN ('hat', 'outfit', 'face', 'background')),
  name        text        NOT NULL,
  emoji       text        NOT NULL,           -- rendered as a layered accessory over the base avatar
  cost        integer     NOT NULL CHECK (cost >= 0),
  rarity      text        NOT NULL DEFAULT 'common' CHECK (rarity IN ('common', 'rare', 'epic', 'legendary')),
  sort_order  integer     NOT NULL DEFAULT 0,
  created_at  timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.shop_items ENABLE ROW LEVEL SECURITY;

-- Catalog is readable by any authenticated user (it's not child-specific data).
CREATE POLICY "shop_items_select" ON public.shop_items FOR SELECT TO authenticated
  USING (true);

-- ── Coin balance ─────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.child_coins (
  child_id    uuid        PRIMARY KEY REFERENCES public.children(id) ON DELETE CASCADE,
  balance     integer     NOT NULL DEFAULT 0 CHECK (balance >= 0),
  updated_at  timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.child_coins ENABLE ROW LEVEL SECURITY;

CREATE POLICY "child_coins_select" ON public.child_coins FOR SELECT TO authenticated
  USING (child_id IN (SELECT public.my_child_ids()));

-- Inserts/updates to balance go through award_coins()/purchase_item() (SECURITY DEFINER),
-- not direct client writes, so no client-facing INSERT/UPDATE policy is granted here.

-- ── Coin transaction log ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.coin_transactions (
  id          uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id    uuid        NOT NULL REFERENCES public.children(id) ON DELETE CASCADE,
  amount      integer     NOT NULL,           -- positive = earned, negative = spent
  reason      text        NOT NULL,           -- human-readable, e.g. "Achievement: Perfect Week"
  source_type text        NOT NULL CHECK (source_type IN ('achievement', 'streak', 'weekly_test', 'purchase', 'manual')),
  source_id   uuid,                           -- optional FK-like reference (achievement id, test id, etc.)
  created_at  timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.coin_transactions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "coin_transactions_select" ON public.coin_transactions FOR SELECT TO authenticated
  USING (child_id IN (SELECT public.my_child_ids()));

-- ── Inventory (owned items) ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.child_inventory (
  id           uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id     uuid        NOT NULL REFERENCES public.children(id) ON DELETE CASCADE,
  shop_item_id uuid        NOT NULL REFERENCES public.shop_items(id) ON DELETE CASCADE,
  acquired_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (child_id, shop_item_id)
);

ALTER TABLE public.child_inventory ENABLE ROW LEVEL SECURITY;

CREATE POLICY "child_inventory_select" ON public.child_inventory FOR SELECT TO authenticated
  USING (child_id IN (SELECT public.my_child_ids()));

-- ── Equipped items (one per slot per child) ──────────────────────────────────
CREATE TABLE IF NOT EXISTS public.child_equipped (
  child_id     uuid        NOT NULL REFERENCES public.children(id) ON DELETE CASCADE,
  slot         text        NOT NULL CHECK (slot IN ('hat', 'outfit', 'face', 'background')),
  shop_item_id uuid        NOT NULL REFERENCES public.shop_items(id) ON DELETE CASCADE,
  equipped_at  timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (child_id, slot)
);

ALTER TABLE public.child_equipped ENABLE ROW LEVEL SECURITY;

CREATE POLICY "child_equipped_select" ON public.child_equipped FOR SELECT TO authenticated
  USING (child_id IN (SELECT public.my_child_ids()));

-- ══════════════════════════════════════════════════════════════════════════
-- Functions
-- ══════════════════════════════════════════════════════════════════════════

-- Credits coins to a child and logs why. SECURITY DEFINER so it can write to
-- child_coins/coin_transactions without exposing direct INSERT/UPDATE policies
-- to clients (mirrors the pattern used by generate_child_test in migration 011).
CREATE OR REPLACE FUNCTION public.award_coins(
  p_child_id    uuid,
  p_amount      integer,
  p_reason      text,
  p_source_type text,
  p_source_id   uuid DEFAULT NULL
) RETURNS jsonb
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_caller_owns boolean;
  v_new_balance integer;
BEGIN
  SELECT p_child_id IN (SELECT public.my_child_ids()) INTO v_caller_owns;
  IF NOT v_caller_owns THEN
    RETURN jsonb_build_object('success', false, 'error', 'not_authorized');
  END IF;

  IF p_amount = 0 THEN
    RETURN jsonb_build_object('success', false, 'error', 'zero_amount');
  END IF;

  INSERT INTO public.child_coins (child_id, balance, updated_at)
  VALUES (p_child_id, GREATEST(p_amount, 0), now())
  ON CONFLICT (child_id) DO UPDATE
    SET balance = GREATEST(public.child_coins.balance + p_amount, 0),
        updated_at = now()
  RETURNING balance INTO v_new_balance;

  INSERT INTO public.coin_transactions (child_id, amount, reason, source_type, source_id)
  VALUES (p_child_id, p_amount, p_reason, p_source_type, p_source_id);

  RETURN jsonb_build_object('success', true, 'new_balance', v_new_balance);
END;
$$;

REVOKE ALL ON FUNCTION public.award_coins FROM public;
GRANT EXECUTE ON FUNCTION public.award_coins TO authenticated;

-- Atomically purchases a shop item: checks ownership + balance, deducts coins,
-- logs the transaction, and adds to inventory. Returns success/error as jsonb
-- so the client can show a friendly message either way.
CREATE OR REPLACE FUNCTION public.purchase_item(
  p_child_id    uuid,
  p_shop_item_id uuid
) RETURNS jsonb
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_caller_owns boolean;
  v_cost        integer;
  v_balance     integer;
  v_already_own boolean;
BEGIN
  SELECT p_child_id IN (SELECT public.my_child_ids()) INTO v_caller_owns;
  IF NOT v_caller_owns THEN
    RETURN jsonb_build_object('success', false, 'error', 'not_authorized');
  END IF;

  SELECT EXISTS (
    SELECT 1 FROM public.child_inventory
    WHERE child_id = p_child_id AND shop_item_id = p_shop_item_id
  ) INTO v_already_own;
  IF v_already_own THEN
    RETURN jsonb_build_object('success', false, 'error', 'already_owned');
  END IF;

  SELECT cost INTO v_cost FROM public.shop_items WHERE id = p_shop_item_id;
  IF v_cost IS NULL THEN
    RETURN jsonb_build_object('success', false, 'error', 'item_not_found');
  END IF;

  SELECT balance INTO v_balance FROM public.child_coins WHERE child_id = p_child_id;
  v_balance := COALESCE(v_balance, 0);

  IF v_balance < v_cost THEN
    RETURN jsonb_build_object('success', false, 'error', 'insufficient_coins', 'balance', v_balance, 'cost', v_cost);
  END IF;

  UPDATE public.child_coins SET balance = balance - v_cost, updated_at = now()
    WHERE child_id = p_child_id;

  INSERT INTO public.coin_transactions (child_id, amount, reason, source_type, source_id)
  VALUES (p_child_id, -v_cost, 'Shop purchase', 'purchase', p_shop_item_id);

  INSERT INTO public.child_inventory (child_id, shop_item_id)
  VALUES (p_child_id, p_shop_item_id);

  RETURN jsonb_build_object('success', true, 'new_balance', v_balance - v_cost);
END;
$$;

REVOKE ALL ON FUNCTION public.purchase_item FROM public;
GRANT EXECUTE ON FUNCTION public.purchase_item TO authenticated;

-- Equips an owned item, replacing whatever was previously equipped in that slot.
CREATE OR REPLACE FUNCTION public.equip_item(
  p_child_id     uuid,
  p_shop_item_id uuid
) RETURNS jsonb
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_caller_owns boolean;
  v_owns_item   boolean;
  v_slot        text;
BEGIN
  SELECT p_child_id IN (SELECT public.my_child_ids()) INTO v_caller_owns;
  IF NOT v_caller_owns THEN
    RETURN jsonb_build_object('success', false, 'error', 'not_authorized');
  END IF;

  SELECT EXISTS (
    SELECT 1 FROM public.child_inventory
    WHERE child_id = p_child_id AND shop_item_id = p_shop_item_id
  ) INTO v_owns_item;
  IF NOT v_owns_item THEN
    RETURN jsonb_build_object('success', false, 'error', 'not_owned');
  END IF;

  SELECT slot INTO v_slot FROM public.shop_items WHERE id = p_shop_item_id;

  INSERT INTO public.child_equipped (child_id, slot, shop_item_id, equipped_at)
  VALUES (p_child_id, v_slot, p_shop_item_id, now())
  ON CONFLICT (child_id, slot) DO UPDATE
    SET shop_item_id = p_shop_item_id, equipped_at = now();

  RETURN jsonb_build_object('success', true, 'slot', v_slot);
END;
$$;

REVOKE ALL ON FUNCTION public.equip_item FROM public;
GRANT EXECUTE ON FUNCTION public.equip_item TO authenticated;

-- Unequips whatever is currently worn in a given slot (returns to bare avatar for that slot).
CREATE OR REPLACE FUNCTION public.unequip_slot(
  p_child_id uuid,
  p_slot     text
) RETURNS jsonb
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_caller_owns boolean;
BEGIN
  SELECT p_child_id IN (SELECT public.my_child_ids()) INTO v_caller_owns;
  IF NOT v_caller_owns THEN
    RETURN jsonb_build_object('success', false, 'error', 'not_authorized');
  END IF;

  DELETE FROM public.child_equipped WHERE child_id = p_child_id AND slot = p_slot;
  RETURN jsonb_build_object('success', true);
END;
$$;

REVOKE ALL ON FUNCTION public.unequip_slot FROM public;
GRANT EXECUTE ON FUNCTION public.unequip_slot TO authenticated;

-- ══════════════════════════════════════════════════════════════════════════
-- Starter shop catalog
-- ══════════════════════════════════════════════════════════════════════════
INSERT INTO public.shop_items (slot, name, emoji, cost, rarity, sort_order) VALUES
  ('hat', 'Wizard Hat',        '🎩', 50,  'common',    1),
  ('hat', 'Golden Crown',      '👑', 200, 'epic',      2),
  ('hat', 'Party Hat',         '🥳', 30,  'common',    3),
  ('hat', 'Top Hat',           '🎓', 40,  'common',    4),
  ('hat', 'Halo',              '😇', 150, 'rare',      5),
  ('face', 'Cool Glasses',     '😎', 40,  'common',    1),
  ('face', 'Monocle',         '🧐', 60,  'rare',      2),
  ('face', 'Sparkle Eyes',     '✨', 80,  'rare',      3),
  ('outfit', 'Cape of Valor',  '🦸', 120, 'rare',      1),
  ('outfit', 'Royal Robe',     '🥋', 150, 'rare',      2),
  ('outfit', 'Armor',          '🛡️', 180, 'epic',      3),
  ('outfit', 'Wings',          '🪽', 250, 'legendary', 4),
  ('background', 'Starry Sky', '🌌', 100, 'rare',      1),
  ('background', 'Rainbow',    '🌈', 90,  'rare',      2),
  ('background', 'Fireworks',  '🎆', 130, 'epic',      3),
  ('background', 'Sunset Dunes', '🏜️', 70, 'common',   4)
ON CONFLICT DO NOTHING;
