
-- Add XP, level, treasure_keys to profiles
ALTER TABLE profiles
  ADD COLUMN IF NOT EXISTS xp integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS level integer NOT NULL DEFAULT 1,
  ADD COLUMN IF NOT EXISTS treasure_keys integer NOT NULL DEFAULT 0;

-- Daily missions table
CREATE TABLE IF NOT EXISTS daily_missions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  mission_date date NOT NULL DEFAULT CURRENT_DATE,
  title text NOT NULL,
  description text NOT NULL,
  icon text NOT NULL DEFAULT '⭐',
  mission_type text NOT NULL,
  target_value integer NOT NULL DEFAULT 1,
  current_value integer NOT NULL DEFAULT 0,
  completed boolean NOT NULL DEFAULT false,
  xp_reward integer NOT NULL DEFAULT 50,
  keys_reward integer NOT NULL DEFAULT 0,
  subject_filter text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE(user_id, mission_date, mission_type)
);

ALTER TABLE daily_missions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "select_own_missions" ON daily_missions FOR SELECT
  TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "insert_own_missions" ON daily_missions FOR INSERT
  TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "update_own_missions" ON daily_missions FOR UPDATE
  TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);
CREATE POLICY "delete_own_missions" ON daily_missions FOR DELETE
  TO authenticated USING (auth.uid() = user_id);

-- New badges using gen_random_uuid()
INSERT INTO badges (name, description, icon, requirement_type, requirement_value, category) VALUES
  ('Quiz Whiz', 'Complete 20 quizzes across any subject', '🎓', 'quiz_complete', 20, null),
  ('Streak Star', 'Maintain a 7-day learning streak', '⭐', 'streak', 7, null),
  ('Fraction Master', 'Score 90%+ on 5 Maths quizzes', '🔢', 'category_perfect', 5, 'math'),
  ('Vocabulary Hero', 'Complete 10 Vocabulary quizzes', '📖', 'quiz_complete', 10, 'vocabulary'),
  ('Maths Champion', 'Reach level 10', '🏆', 'level_up', 10, null),
  ('Bournemouth Challenger', 'Complete all 5 subject areas', '🎯', 'all_subjects', 5, null)
ON CONFLICT DO NOTHING;

-- add_xp RPC
CREATE OR REPLACE FUNCTION add_xp(
  p_user_id uuid,
  p_xp_to_add integer
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_current_xp integer;
  v_current_level integer;
  v_new_xp integer;
  v_new_level integer;
BEGIN
  IF auth.uid() != p_user_id THEN
    RETURN jsonb_build_object('error', 'Unauthorized');
  END IF;

  SELECT xp, level INTO v_current_xp, v_current_level
  FROM profiles WHERE id = p_user_id;

  v_new_xp := COALESCE(v_current_xp, 0) + p_xp_to_add;
  v_new_level := LEAST(50, FLOOR(v_new_xp::float / 100)::integer + 1);

  UPDATE profiles SET xp = v_new_xp, level = v_new_level WHERE id = p_user_id;

  RETURN jsonb_build_object(
    'success', true,
    'xp', v_new_xp,
    'level', v_new_level,
    'leveled_up', v_new_level > COALESCE(v_current_level, 1)
  );
END;
$$;

GRANT EXECUTE ON FUNCTION add_xp(uuid, integer) TO authenticated;

-- add_treasure_keys RPC
CREATE OR REPLACE FUNCTION add_treasure_keys(
  p_user_id uuid,
  p_keys_to_add integer
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() != p_user_id THEN
    RETURN jsonb_build_object('error', 'Unauthorized');
  END IF;

  UPDATE profiles
  SET treasure_keys = GREATEST(0, COALESCE(treasure_keys, 0) + p_keys_to_add)
  WHERE id = p_user_id;

  RETURN jsonb_build_object('success', true);
END;
$$;

GRANT EXECUTE ON FUNCTION add_treasure_keys(uuid, integer) TO authenticated;
