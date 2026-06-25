-- ═══════════════════════════════════════════════════════════════════════════
-- Migration 011: Multi-child platform restructure
-- Safe additive migration — no existing data is removed.
-- ═══════════════════════════════════════════════════════════════════════════

-- ── 1. Add role column to profiles ──────────────────────────────────────────
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS role text NOT NULL DEFAULT 'child';
UPDATE public.profiles SET role = 'parent' WHERE is_parent = true;
UPDATE public.profiles SET role = 'child'  WHERE is_parent = false;

-- ── 2. Augment questions with exam_type and year_group arrays ────────────────
ALTER TABLE public.questions
  ADD COLUMN IF NOT EXISTS exam_types  text[] NOT NULL DEFAULT ARRAY['GL Assessment','CEM','BSG','Poole Grammar','CSSE','Independent School','Other'],
  ADD COLUMN IF NOT EXISTS year_groups text[] NOT NULL DEFAULT ARRAY['Year 3','Year 4','Year 5','Year 6'];

-- ── 3. children table ────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.children (
  id                uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_id         uuid        REFERENCES public.profiles(id) ON DELETE SET NULL,
  profile_id        uuid        REFERENCES public.profiles(id) ON DELETE SET NULL, -- legacy link
  first_name        text        NOT NULL,
  year_group        text        NOT NULL DEFAULT 'Year 5',
  target_exam_type  text        NOT NULL DEFAULT 'GL Assessment',
  target_school     text,
  exam_date         date,
  avatar            text        NOT NULL DEFAULT '🎓',
  xp_points         integer     NOT NULL DEFAULT 0,
  level             integer     NOT NULL DEFAULT 1,
  created_at        timestamptz NOT NULL DEFAULT now()
);

-- ── 4. skill_mastery table ───────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.skill_mastery (
  id            uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id      uuid        NOT NULL REFERENCES public.children(id) ON DELETE CASCADE,
  skill_name    text        NOT NULL,
  mastery_score numeric     NOT NULL DEFAULT 0 CHECK (mastery_score BETWEEN 0 AND 100),
  last_updated  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (child_id, skill_name)
);

-- ── 5. achievements table ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.achievements (
  id           uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id     uuid        NOT NULL REFERENCES public.children(id) ON DELETE CASCADE,
  badge_name   text        NOT NULL,
  description  text,
  earned_date  timestamptz NOT NULL DEFAULT now()
);

-- ── 6. ai_weekly_tests table ─────────────────────────────────────────────────
-- Separate from the existing weekly_tests table to avoid breaking existing code.
CREATE TABLE IF NOT EXISTS public.ai_weekly_tests (
  id              uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
  child_id        uuid        NOT NULL REFERENCES public.children(id) ON DELETE CASCADE,
  week_number     integer     NOT NULL,
  exam_type       text        NOT NULL,
  question_ids    uuid[]      NOT NULL DEFAULT '{}',
  generated_by_ai boolean     NOT NULL DEFAULT true,
  score           integer,
  total_questions integer     NOT NULL DEFAULT 30,
  completed_at    timestamptz,
  created_at      timestamptz NOT NULL DEFAULT now()
);

-- ── 7. Add child_id to quiz_attempts (nullable for backward compat) ──────────
ALTER TABLE public.quiz_attempts ADD COLUMN IF NOT EXISTS child_id uuid REFERENCES public.children(id) ON DELETE SET NULL;

-- ── 8. Indexes ────────────────────────────────────────────────────────────────
CREATE INDEX IF NOT EXISTS idx_children_parent_id        ON public.children(parent_id);
CREATE INDEX IF NOT EXISTS idx_children_profile_id       ON public.children(profile_id);
CREATE INDEX IF NOT EXISTS idx_children_exam_type        ON public.children(target_exam_type);
CREATE INDEX IF NOT EXISTS idx_skill_mastery_child_id    ON public.skill_mastery(child_id);
CREATE INDEX IF NOT EXISTS idx_achievements_child_id     ON public.achievements(child_id);
CREATE INDEX IF NOT EXISTS idx_ai_weekly_tests_child_id  ON public.ai_weekly_tests(child_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_child_id    ON public.quiz_attempts(child_id);

-- ── 9. RLS ────────────────────────────────────────────────────────────────────
ALTER TABLE public.children       ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.skill_mastery  ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.achievements   ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.ai_weekly_tests ENABLE ROW LEVEL SECURITY;

-- children: visible/editable by the parent OR by the legacy child user themselves
CREATE POLICY "children_select" ON public.children FOR SELECT TO authenticated
  USING (parent_id = auth.uid() OR profile_id = auth.uid());

CREATE POLICY "children_insert" ON public.children FOR INSERT TO authenticated
  WITH CHECK (parent_id = auth.uid() OR profile_id = auth.uid());

CREATE POLICY "children_update" ON public.children FOR UPDATE TO authenticated
  USING (parent_id = auth.uid() OR profile_id = auth.uid())
  WITH CHECK (parent_id = auth.uid() OR profile_id = auth.uid());

CREATE POLICY "children_delete" ON public.children FOR DELETE TO authenticated
  USING (parent_id = auth.uid());

-- Helper: returns child_ids accessible to the current user
-- Used in nested policies to avoid repeated subqueries.
CREATE OR REPLACE FUNCTION public.my_child_ids()
RETURNS SETOF uuid
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = ''
AS $$
  SELECT id FROM public.children
  WHERE parent_id = auth.uid() OR profile_id = auth.uid()
$$;
REVOKE ALL ON FUNCTION public.my_child_ids() FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.my_child_ids() TO authenticated;

-- skill_mastery
CREATE POLICY "skill_mastery_select" ON public.skill_mastery FOR SELECT TO authenticated
  USING (child_id IN (SELECT public.my_child_ids()));
CREATE POLICY "skill_mastery_insert" ON public.skill_mastery FOR INSERT TO authenticated
  WITH CHECK (child_id IN (SELECT public.my_child_ids()));
CREATE POLICY "skill_mastery_update" ON public.skill_mastery FOR UPDATE TO authenticated
  USING (child_id IN (SELECT public.my_child_ids()))
  WITH CHECK (child_id IN (SELECT public.my_child_ids()));
CREATE POLICY "skill_mastery_delete" ON public.skill_mastery FOR DELETE TO authenticated
  USING (child_id IN (SELECT public.my_child_ids()));

-- achievements
CREATE POLICY "achievements_select" ON public.achievements FOR SELECT TO authenticated
  USING (child_id IN (SELECT public.my_child_ids()));
CREATE POLICY "achievements_insert" ON public.achievements FOR INSERT TO authenticated
  WITH CHECK (child_id IN (SELECT public.my_child_ids()));
CREATE POLICY "achievements_delete" ON public.achievements FOR DELETE TO authenticated
  USING (child_id IN (SELECT public.my_child_ids()));

-- ai_weekly_tests
CREATE POLICY "ai_tests_select" ON public.ai_weekly_tests FOR SELECT TO authenticated
  USING (child_id IN (SELECT public.my_child_ids()));
CREATE POLICY "ai_tests_insert" ON public.ai_weekly_tests FOR INSERT TO authenticated
  WITH CHECK (child_id IN (SELECT public.my_child_ids()));
CREATE POLICY "ai_tests_update" ON public.ai_weekly_tests FOR UPDATE TO authenticated
  USING (child_id IN (SELECT public.my_child_ids()))
  WITH CHECK (child_id IN (SELECT public.my_child_ids()));

-- ── 10. Data migration ────────────────────────────────────────────────────────
-- Create child records for every existing non-parent user.
-- If they have a linked parent, use that parent's id; otherwise use their own id
-- as parent_id so they remain accessible via "OR parent_id = auth.uid()" too.
INSERT INTO public.children (parent_id, profile_id, first_name, year_group, target_exam_type, avatar, xp_points, level)
SELECT
  COALESCE(pcl.parent_user_id, p.id) AS parent_id,
  p.id                               AS profile_id,
  COALESCE(NULLIF(p.name, ''), 'Explorer') AS first_name,
  'Year 5'                           AS year_group,
  'Bournemouth School for Girls'     AS target_exam_type,
  COALESCE(p.avatar, '🎓')           AS avatar,
  COALESCE(p.xp, 0)                  AS xp_points,
  COALESCE(p.level, 1)               AS level
FROM public.profiles p
LEFT JOIN public.parent_child_links pcl ON pcl.child_user_id = p.id
WHERE p.is_parent = false
  AND NOT EXISTS (SELECT 1 FROM public.children c WHERE c.profile_id = p.id);

-- Back-fill child_id on existing quiz_attempts for migrated children
UPDATE public.quiz_attempts qa
SET child_id = c.id
FROM public.children c
WHERE c.profile_id = qa.user_id
  AND qa.child_id IS NULL;

-- ── 11. RPC: generate_child_test ─────────────────────────────────────────────
-- Generates a balanced AI test for a child based on their profile.
CREATE OR REPLACE FUNCTION public.generate_child_test(p_child_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_child          record;
  v_weak_ids       uuid[];
  v_med_ids        uuid[];
  v_strong_ids     uuid[];
  v_question_ids   uuid[];
  v_test_id        uuid;
  v_week_number    integer;
BEGIN
  -- Auth check
  IF NOT EXISTS (
    SELECT 1 FROM public.children
    WHERE id = p_child_id
      AND (parent_id = auth.uid() OR profile_id = auth.uid())
  ) THEN
    RETURN jsonb_build_object('error', 'Unauthorized');
  END IF;

  SELECT * INTO v_child FROM public.children WHERE id = p_child_id;

  -- Next week number for this child
  SELECT COALESCE(MAX(week_number), 0) + 1 INTO v_week_number
  FROM public.ai_weekly_tests WHERE child_id = p_child_id;

  -- Weak skills (mastery < 50) → 70% of 30 = 21 questions
  SELECT ARRAY_AGG(q.id) INTO v_weak_ids
  FROM (
    SELECT q.id
    FROM public.questions q
    JOIN public.skill_mastery sm ON sm.skill_name = q.topic AND sm.child_id = p_child_id
    WHERE sm.mastery_score < 50
      AND v_child.target_exam_type = ANY(q.exam_types)
      AND v_child.year_group = ANY(q.year_groups)
    ORDER BY RANDOM() LIMIT 21
  ) q;

  -- Medium skills (mastery 50-75) → 20% = 6 questions
  SELECT ARRAY_AGG(q.id) INTO v_med_ids
  FROM (
    SELECT q.id
    FROM public.questions q
    JOIN public.skill_mastery sm ON sm.skill_name = q.topic AND sm.child_id = p_child_id
    WHERE sm.mastery_score BETWEEN 50 AND 75
      AND v_child.target_exam_type = ANY(q.exam_types)
      AND v_child.year_group = ANY(q.year_groups)
    ORDER BY RANDOM() LIMIT 6
  ) q;

  -- Strong / random top-up → 10% = 3 questions
  SELECT ARRAY_AGG(q.id) INTO v_strong_ids
  FROM (
    SELECT q.id
    FROM public.questions q
    WHERE v_child.target_exam_type = ANY(q.exam_types)
      AND v_child.year_group = ANY(q.year_groups)
      AND q.id != ALL(COALESCE(v_weak_ids, '{}'))
      AND q.id != ALL(COALESCE(v_med_ids,  '{}'))
    ORDER BY RANDOM() LIMIT 3
  ) q;

  -- Fallback: top up from any matching questions if not enough
  v_question_ids := ARRAY(
    SELECT unnest(COALESCE(v_weak_ids, '{}'))
    UNION ALL SELECT unnest(COALESCE(v_med_ids, '{}'))
    UNION ALL SELECT unnest(COALESCE(v_strong_ids, '{}'))
  );

  -- If still empty, grab any questions
  IF array_length(v_question_ids, 1) IS NULL OR array_length(v_question_ids, 1) < 10 THEN
    SELECT ARRAY_AGG(id) INTO v_question_ids
    FROM (SELECT id FROM public.questions ORDER BY RANDOM() LIMIT 30) q;
  END IF;

  INSERT INTO public.ai_weekly_tests (child_id, week_number, exam_type, question_ids, total_questions)
  VALUES (p_child_id, v_week_number, v_child.target_exam_type, v_question_ids, COALESCE(array_length(v_question_ids, 1), 10))
  RETURNING id INTO v_test_id;

  RETURN jsonb_build_object(
    'success',       true,
    'test_id',       v_test_id,
    'week_number',   v_week_number,
    'question_count', COALESCE(array_length(v_question_ids, 1), 0)
  );
END;
$$;
REVOKE ALL ON FUNCTION public.generate_child_test(uuid) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.generate_child_test(uuid) TO authenticated;

-- ── 12. RPC: upsert_skill_mastery ────────────────────────────────────────────
-- Updates skill mastery after a quiz attempt.
CREATE OR REPLACE FUNCTION public.upsert_skill_mastery(
  p_child_id    uuid,
  p_skill_name  text,
  p_correct     integer,
  p_total       integer
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER SET search_path = ''
AS $$
DECLARE
  v_score     numeric;
  v_existing  numeric;
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM public.children
    WHERE id = p_child_id AND (parent_id = auth.uid() OR profile_id = auth.uid())
  ) THEN RAISE EXCEPTION 'Unauthorized'; END IF;

  v_score := ROUND((p_correct::numeric / GREATEST(p_total, 1)) * 100);

  SELECT mastery_score INTO v_existing FROM public.skill_mastery
  WHERE child_id = p_child_id AND skill_name = p_skill_name;

  IF v_existing IS NULL THEN
    INSERT INTO public.skill_mastery (child_id, skill_name, mastery_score)
    VALUES (p_child_id, p_skill_name, v_score);
  ELSE
    -- Weighted average: 70% existing, 30% new attempt
    UPDATE public.skill_mastery
    SET mastery_score = ROUND(v_existing * 0.7 + v_score * 0.3),
        last_updated  = now()
    WHERE child_id = p_child_id AND skill_name = p_skill_name;
  END IF;
END;
$$;
REVOKE ALL ON FUNCTION public.upsert_skill_mastery(uuid, text, integer, integer) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.upsert_skill_mastery(uuid, text, integer, integer) TO authenticated;
