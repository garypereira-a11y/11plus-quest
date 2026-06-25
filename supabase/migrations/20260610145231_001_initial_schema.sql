/*
# 11+ Adventure: Initial Database Schema

This migration creates the complete schema for the 11+ Adventure educational game app.

## New Tables

1. **profiles** - Stores user profile information
   - `id` (uuid, PK, references auth.users)
   - `name` (text, child's display name)
   - `avatar` (text, selected avatar emoji/image)
   - `is_parent` (boolean, distinguishes parent accounts)
   - `parent_id` (uuid, links child to parent account)
   - `created_at` (timestamp)

2. **questions** - Bank of educational questions
   - `id` (uuid, PK)
   - `category` (text: math, verbal_reasoning, english, odd_one_out, vocabulary)
   - `question_text` (text)
   - `options` (jsonb array of 4 options)
   - `correct_answer` (integer, index of correct option)
   - `explanation` (text, shown for incorrect answers)
   - `difficulty` (integer, 1-3)
   - `age_range` (text, e.g., "8-9", "9-10")
   - `created_at` (timestamp)

3. **quiz_attempts** - Records of quiz/test attempts
   - `id` (uuid, PK)
   - `user_id` (uuid, references profiles)
   - `category` (text)
   - `score` (integer)
   - `total_questions` (integer)
   - `correct_answers` (integer)
   - `is_weekly_test` (boolean)
   - `completed_at` (timestamp)

4. **answer_history** - Individual answer records for learning
   - `id` (uuid, PK)
   - `attempt_id` (uuid, references quiz_attempts)
   - `question_id` (uuid, references questions)
   - `user_answer` (integer)
   - `is_correct` (boolean)
   - `answered_at` (timestamp)

5. **badges** - Achievement badges
   - `id` (uuid, PK)
   - `name` (text)
   - `description` (text)
   - `icon` (text, emoji/icon name)
   - `requirement_type` (text, e.g., "correct_streak", "category_mastery")
   - `requirement_value` (integer)
   - `category` (text, optional for category-specific badges)

6. **user_badges** - Badge awards to users
   - `id` (uuid, PK)
   - `user_id` (uuid, references profiles)
   - `badge_id` (uuid, references badges)
   - `earned_at` (timestamp)

7. **treasure_chests** - Treasure chest unlocks
   - `id` (uuid, PK)
   - `user_id` (uuid, references profiles)
   - `correct_count_at_unlock` (integer)
   - `unlocked_at` (timestamp)

8. **weekly_tests** - Weekly test schedule and results
   - `id` (uuid, PK)
   - `week_number` (integer)
   - `year` (integer)
   - `categories` (text array)
   - `active_from` (timestamp)
   - `active_until` (timestamp)

## Security

- RLS enabled on all tables
- Owner-scoped policies for user data (profiles, quiz_attempts, answer_history, user_badges, treasure_chests)
- Public read for questions (all authenticated users can access question bank)
- Public read for badges (all authenticated users can view badge catalog)
*/

-- Profiles table
CREATE TABLE IF NOT EXISTS profiles (
    id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name text NOT NULL,
    avatar text DEFAULT '🎓',
    is_parent boolean DEFAULT false,
    parent_id uuid REFERENCES profiles(id) ON DELETE SET NULL,
    stars integer DEFAULT 0,
    total_correct integer DEFAULT 0,
    created_at timestamptz DEFAULT now()
);

ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "select_own_profile" ON profiles;
CREATE POLICY "select_own_profile" ON profiles FOR SELECT
    TO authenticated USING (auth.uid() = id OR auth.uid() = parent_id);

DROP POLICY IF EXISTS "insert_own_profile" ON profiles;
CREATE POLICY "insert_own_profile" ON profiles FOR INSERT
    TO authenticated WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "update_own_profile" ON profiles;
CREATE POLICY "update_own_profile" ON profiles FOR UPDATE
    TO authenticated USING (auth.uid() = id OR auth.uid() = parent_id) WITH CHECK (auth.uid() = id OR auth.uid() = parent_id);

-- Questions table
CREATE TABLE IF NOT EXISTS questions (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    category text NOT NULL CHECK (category IN ('math', 'verbal_reasoning', 'english', 'odd_one_out', 'vocabulary')),
    question_text text NOT NULL,
    options jsonb NOT NULL,
    correct_answer integer NOT NULL CHECK (correct_answer >= 0 AND correct_answer <= 3),
    explanation text NOT NULL,
    difficulty integer DEFAULT 1 CHECK (difficulty >= 1 AND difficulty <= 3),
    age_range text DEFAULT '8-10',
    created_at timestamptz DEFAULT now()
);

ALTER TABLE questions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "read_questions_authenticated" ON questions;
CREATE POLICY "read_questions_authenticated" ON questions FOR SELECT
    TO authenticated USING (true);

-- Quiz attempts table
CREATE TABLE IF NOT EXISTS quiz_attempts (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    category text NOT NULL,
    score integer DEFAULT 0,
    total_questions integer NOT NULL,
    correct_answers integer DEFAULT 0,
    is_weekly_test boolean DEFAULT false,
    completed_at timestamptz DEFAULT now()
);

ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "select_own_attempts" ON quiz_attempts;
CREATE POLICY "select_own_attempts" ON quiz_attempts FOR SELECT
    TO authenticated USING (auth.uid() = user_id OR EXISTS (SELECT 1 FROM profiles WHERE id = quiz_attempts.user_id AND parent_id = auth.uid()));

DROP POLICY IF EXISTS "insert_own_attempts" ON quiz_attempts;
CREATE POLICY "insert_own_attempts" ON quiz_attempts FOR INSERT
    TO authenticated WITH CHECK (auth.uid() = user_id);

-- Answer history table
CREATE TABLE IF NOT EXISTS answer_history (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    attempt_id uuid NOT NULL REFERENCES quiz_attempts(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    question_id uuid NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
    user_answer integer NOT NULL,
    is_correct boolean NOT NULL,
    answered_at timestamptz DEFAULT now()
);

ALTER TABLE answer_history ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "select_own_answers" ON answer_history;
CREATE POLICY "select_own_answers" ON answer_history FOR SELECT
    TO authenticated USING (auth.uid() = user_id OR EXISTS (SELECT 1 FROM profiles WHERE id = answer_history.user_id AND parent_id = auth.uid()));

DROP POLICY IF EXISTS "insert_own_answers" ON answer_history;
CREATE POLICY "insert_own_answers" ON answer_history FOR INSERT
    TO authenticated WITH CHECK (auth.uid() = user_id);

-- Badges table
CREATE TABLE IF NOT EXISTS badges (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL UNIQUE,
    description text NOT NULL,
    icon text NOT NULL,
    requirement_type text NOT NULL,
    requirement_value integer NOT NULL,
    category text,
    created_at timestamptz DEFAULT now()
);

ALTER TABLE badges ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "read_badges" ON badges;
CREATE POLICY "read_badges" ON badges FOR SELECT
    TO authenticated USING (true);

-- User badges table
CREATE TABLE IF NOT EXISTS user_badges (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    badge_id uuid NOT NULL REFERENCES badges(id) ON DELETE CASCADE,
    earned_at timestamptz DEFAULT now(),
    UNIQUE(user_id, badge_id)
);

ALTER TABLE user_badges ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "select_own_user_badges" ON user_badges;
CREATE POLICY "select_own_user_badges" ON user_badges FOR SELECT
    TO authenticated USING (auth.uid() = user_id OR EXISTS (SELECT 1 FROM profiles WHERE id = user_badges.user_id AND parent_id = auth.uid()));

DROP POLICY IF EXISTS "insert_own_user_badges" ON user_badges;
CREATE POLICY "insert_own_user_badges" ON user_badges FOR INSERT
    TO authenticated WITH CHECK (auth.uid() = user_id);

-- Treasure chests table
CREATE TABLE IF NOT EXISTS treasure_chests (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    correct_count_at_unlock integer NOT NULL,
    unlocked_at timestamptz DEFAULT now()
);

ALTER TABLE treasure_chests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "select_own_treasure" ON treasure_chests;
CREATE POLICY "select_own_treasure" ON treasure_chests FOR SELECT
    TO authenticated USING (auth.uid() = user_id OR EXISTS (SELECT 1 FROM profiles WHERE id = treasure_chests.user_id AND parent_id = auth.uid()));

DROP POLICY IF EXISTS "insert_own_treasure" ON treasure_chests;
CREATE POLICY "insert_own_treasure" ON treasure_chests FOR INSERT
    TO authenticated WITH CHECK (auth.uid() = user_id);

-- Weekly tests table
CREATE TABLE IF NOT EXISTS weekly_tests (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    week_number integer NOT NULL,
    year integer NOT NULL,
    categories text[] NOT NULL,
    active_from timestamptz NOT NULL,
    active_until timestamptz NOT NULL,
    UNIQUE(week_number, year)
);

ALTER TABLE weekly_tests ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "read_weekly_tests" ON weekly_tests;
CREATE POLICY "read_weekly_tests" ON weekly_tests FOR SELECT
    TO authenticated USING (true);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_user ON quiz_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_completed ON quiz_attempts(completed_at DESC);
CREATE INDEX IF NOT EXISTS idx_answer_history_user ON answer_history(user_id);
CREATE INDEX IF NOT EXISTS idx_questions_category ON questions(category);
CREATE INDEX IF NOT EXISTS idx_profiles_parent ON profiles(parent_id);