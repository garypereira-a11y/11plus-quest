-- ─────────────────────────────────────────────────────────────────────────────
-- Migration 010: Fix all outstanding security advisor warnings
-- ─────────────────────────────────────────────────────────────────────────────

-- ── 1. topic_mastery: recreate as SECURITY INVOKER view ──────────────────────
-- PostgreSQL views created by a superuser/privileged role run as SECURITY
-- DEFINER by default. Explicitly mark it SECURITY INVOKER so it queries data
-- as the calling user, which means RLS on the underlying tables is honoured.
DROP VIEW IF EXISTS public.topic_mastery;

CREATE VIEW public.topic_mastery
WITH (security_invoker = true)
AS
SELECT
  ah.user_id,
  q.category,
  q.topic,
  COUNT(*)                                                          AS total_attempts,
  SUM(CASE WHEN ah.is_correct THEN 1 ELSE 0 END)                   AS correct_answers,
  ROUND(SUM(CASE WHEN ah.is_correct THEN 1 ELSE 0 END)::numeric
        / COUNT(*) * 100)                                          AS mastery_pct
FROM public.answer_history ah
JOIN public.questions      q  ON ah.question_id = q.id
WHERE q.topic IS NOT NULL
GROUP BY ah.user_id, q.category, q.topic;

-- ── 2. curriculum_weeks: enable RLS + public SELECT policy ───────────────────
-- This table contains static curriculum content. It is safe to read publicly
-- but must have RLS enabled to satisfy Supabase security policies.
ALTER TABLE public.curriculum_weeks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "curriculum_weeks_select_all"
  ON public.curriculum_weeks
  FOR SELECT
  USING (true);

-- ── 3. Revoke anon EXECUTE on all SECURITY DEFINER RPCs ──────────────────────
-- PostgreSQL grants EXECUTE to PUBLIC by default; anon inherits that grant
-- unless explicitly revoked. None of these functions should be callable by
-- unauthenticated users.
REVOKE EXECUTE ON FUNCTION public.add_xp(uuid, integer)                           FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.add_treasure_keys(uuid, integer)                FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.generate_adaptive_challenge(uuid)               FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.record_week_result(uuid, integer, integer, integer) FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.add_stars(uuid, integer)                        FROM anon, PUBLIC;
REVOKE EXECUTE ON FUNCTION public.link_to_parent(text)                            FROM anon, PUBLIC;

-- Re-grant to authenticated only (REVOKE FROM PUBLIC removes it for everyone)
GRANT EXECUTE ON FUNCTION public.add_xp(uuid, integer)                            TO authenticated;
GRANT EXECUTE ON FUNCTION public.add_treasure_keys(uuid, integer)                 TO authenticated;
GRANT EXECUTE ON FUNCTION public.generate_adaptive_challenge(uuid)                TO authenticated;
GRANT EXECUTE ON FUNCTION public.record_week_result(uuid, integer, integer, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION public.add_stars(uuid, integer)                         TO authenticated;
GRANT EXECUTE ON FUNCTION public.link_to_parent(text)                             TO authenticated;

-- ── 4. Harden add_xp and add_treasure_keys search_path ───────────────────────
-- These functions already have auth.uid() guards but were created with
-- SET search_path = public. Recreate them with SET search_path = '' (empty)
-- to fully prevent search-path injection attacks.
CREATE OR REPLACE FUNCTION public.add_xp(
  p_user_id  uuid,
  p_xp_to_add integer
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
DECLARE
  v_current_xp    integer;
  v_current_level integer;
  v_new_xp        integer;
  v_new_level     integer;
BEGIN
  IF auth.uid() IS DISTINCT FROM p_user_id THEN
    RETURN jsonb_build_object('error', 'Unauthorized');
  END IF;

  SELECT xp, level INTO v_current_xp, v_current_level
    FROM public.profiles WHERE id = p_user_id;

  v_new_xp    := COALESCE(v_current_xp, 0) + p_xp_to_add;
  v_new_level := LEAST(50, FLOOR(v_new_xp::float / 100)::integer + 1);

  UPDATE public.profiles SET xp = v_new_xp, level = v_new_level WHERE id = p_user_id;

  RETURN jsonb_build_object(
    'success', true,
    'xp', v_new_xp,
    'level', v_new_level,
    'leveled_up', v_new_level > COALESCE(v_current_level, 1)
  );
END;
$$;

CREATE OR REPLACE FUNCTION public.add_treasure_keys(
  p_user_id    uuid,
  p_keys_to_add integer
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF auth.uid() IS DISTINCT FROM p_user_id THEN
    RETURN jsonb_build_object('error', 'Unauthorized');
  END IF;

  UPDATE public.profiles
     SET treasure_keys = GREATEST(0, COALESCE(treasure_keys, 0) + p_keys_to_add)
   WHERE id = p_user_id;

  RETURN jsonb_build_object('success', true);
END;
$$;

-- Re-apply grants after CREATE OR REPLACE (resets them)
REVOKE ALL ON FUNCTION public.add_xp(uuid, integer)            FROM PUBLIC, anon;
REVOKE ALL ON FUNCTION public.add_treasure_keys(uuid, integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.add_xp(uuid, integer)            TO authenticated;
GRANT EXECUTE ON FUNCTION public.add_treasure_keys(uuid, integer) TO authenticated;
