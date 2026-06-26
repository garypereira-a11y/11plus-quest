/*
# 11+ Quest: Achievement Checking & Coin Rewards

Previously, the `achievements` table (migration 011) was read by the frontend
but nothing ever inserted into it — there was no achievement-earning logic
anywhere in the system. This migration adds that logic, and awards coins
(via `award_coins` from migration 012) at the same time a badge is earned,
so the two stay in sync rather than being wired separately.

## Function Added
- **check_and_award_achievements(child_id)** — call after any quiz/weekly-test
  completion. Checks a small set of milestone conditions against the child's
  quiz_attempts history and existing achievements, inserts any newly-earned
  badges, and awards coins for each one via award_coins(). Idempotent: skips
  badges already earned for that child. Returns the list of newly-earned
  badges (if any) so the frontend can show a celebratory toast.

## Badges checked (kept intentionally small and clear; easy to extend later)
- "First Quest"        — completed their very first quiz/test
- "Perfect Score"       — got 100% on any quiz/test
- "Weekly Warrior"      — completed 5 weekly quests
- "Dedicated Scholar"   — completed 25 quizzes/tests total
- "Quest Master"        — completed 10 weekly quests
*/

CREATE OR REPLACE FUNCTION public.check_and_award_achievements(p_child_id uuid)
RETURNS jsonb
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_caller_owns     boolean;
  v_total_attempts  integer;
  v_weekly_attempts integer;
  v_has_perfect     boolean;
  v_newly_earned    text[] := ARRAY[]::text[];
  v_already         text[];
BEGIN
  SELECT p_child_id IN (SELECT public.my_child_ids()) INTO v_caller_owns;
  IF NOT v_caller_owns THEN
    RETURN jsonb_build_object('success', false, 'error', 'not_authorized');
  END IF;

  SELECT array_agg(badge_name) INTO v_already
    FROM public.achievements WHERE child_id = p_child_id;
  v_already := COALESCE(v_already, ARRAY[]::text[]);

  SELECT count(*) INTO v_total_attempts
    FROM public.quiz_attempts WHERE child_id = p_child_id;

  SELECT count(*) INTO v_weekly_attempts
    FROM public.quiz_attempts WHERE child_id = p_child_id AND is_weekly_test = true;

  SELECT EXISTS (
    SELECT 1 FROM public.quiz_attempts
    WHERE child_id = p_child_id AND total_questions > 0 AND correct_answers = total_questions
  ) INTO v_has_perfect;

  -- "First Quest"
  IF v_total_attempts >= 1 AND NOT ('First Quest' = ANY(v_already)) THEN
    INSERT INTO public.achievements (child_id, badge_name, description)
      VALUES (p_child_id, 'First Quest', 'Completed your very first quiz!');
    PERFORM public.award_coins(p_child_id, 25, 'Achievement: First Quest', 'achievement', NULL);
    v_newly_earned := array_append(v_newly_earned, 'First Quest');
  END IF;

  -- "Perfect Score"
  IF v_has_perfect AND NOT ('Perfect Score' = ANY(v_already)) THEN
    INSERT INTO public.achievements (child_id, badge_name, description)
      VALUES (p_child_id, 'Perfect Score', 'Scored 100% on a quiz!');
    PERFORM public.award_coins(p_child_id, 25, 'Achievement: Perfect Score', 'achievement', NULL);
    v_newly_earned := array_append(v_newly_earned, 'Perfect Score');
  END IF;

  -- "Weekly Warrior" (5 weekly quests)
  IF v_weekly_attempts >= 5 AND NOT ('Weekly Warrior' = ANY(v_already)) THEN
    INSERT INTO public.achievements (child_id, badge_name, description)
      VALUES (p_child_id, 'Weekly Warrior', 'Completed 5 weekly quests!');
    PERFORM public.award_coins(p_child_id, 25, 'Achievement: Weekly Warrior', 'achievement', NULL);
    v_newly_earned := array_append(v_newly_earned, 'Weekly Warrior');
  END IF;

  -- "Dedicated Scholar" (25 total quizzes/tests)
  IF v_total_attempts >= 25 AND NOT ('Dedicated Scholar' = ANY(v_already)) THEN
    INSERT INTO public.achievements (child_id, badge_name, description)
      VALUES (p_child_id, 'Dedicated Scholar', 'Completed 25 quizzes!');
    PERFORM public.award_coins(p_child_id, 25, 'Achievement: Dedicated Scholar', 'achievement', NULL);
    v_newly_earned := array_append(v_newly_earned, 'Dedicated Scholar');
  END IF;

  -- "Quest Master" (10 weekly quests)
  IF v_weekly_attempts >= 10 AND NOT ('Quest Master' = ANY(v_already)) THEN
    INSERT INTO public.achievements (child_id, badge_name, description)
      VALUES (p_child_id, 'Quest Master', 'Completed 10 weekly quests!');
    PERFORM public.award_coins(p_child_id, 25, 'Achievement: Quest Master', 'achievement', NULL);
    v_newly_earned := array_append(v_newly_earned, 'Quest Master');
  END IF;

  RETURN jsonb_build_object('success', true, 'newly_earned', to_jsonb(v_newly_earned));
END;
$$;

REVOKE ALL ON FUNCTION public.check_and_award_achievements FROM public;
GRANT EXECUTE ON FUNCTION public.check_and_award_achievements TO authenticated;

-- Awards a streak milestone bonus (called from the frontend once it computes
-- the current streak locally). Idempotent per milestone via a dedicated table
-- so the same 7-day streak can't be paid out twice.
CREATE TABLE IF NOT EXISTS public.streak_milestones_claimed (
  child_id   uuid    NOT NULL REFERENCES public.children(id) ON DELETE CASCADE,
  milestone  integer NOT NULL,  -- e.g. 7, 14, 30
  claimed_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (child_id, milestone)
);

ALTER TABLE public.streak_milestones_claimed ENABLE ROW LEVEL SECURITY;

CREATE POLICY "streak_milestones_select" ON public.streak_milestones_claimed FOR SELECT TO authenticated
  USING (child_id IN (SELECT public.my_child_ids()));

CREATE OR REPLACE FUNCTION public.claim_streak_milestone(p_child_id uuid, p_milestone integer)
RETURNS jsonb
SECURITY DEFINER
SET search_path = public
LANGUAGE plpgsql
AS $$
DECLARE
  v_caller_owns boolean;
  v_already     boolean;
BEGIN
  SELECT p_child_id IN (SELECT public.my_child_ids()) INTO v_caller_owns;
  IF NOT v_caller_owns THEN
    RETURN jsonb_build_object('success', false, 'error', 'not_authorized');
  END IF;

  SELECT EXISTS (
    SELECT 1 FROM public.streak_milestones_claimed
    WHERE child_id = p_child_id AND milestone = p_milestone
  ) INTO v_already;
  IF v_already THEN
    RETURN jsonb_build_object('success', false, 'error', 'already_claimed');
  END IF;

  INSERT INTO public.streak_milestones_claimed (child_id, milestone)
    VALUES (p_child_id, p_milestone);

  PERFORM public.award_coins(p_child_id, 30, p_milestone || '-day streak milestone!', 'streak', NULL);

  RETURN jsonb_build_object('success', true);
END;
$$;

REVOKE ALL ON FUNCTION public.claim_streak_milestone FROM public;
GRANT EXECUTE ON FUNCTION public.claim_streak_milestone TO authenticated;
