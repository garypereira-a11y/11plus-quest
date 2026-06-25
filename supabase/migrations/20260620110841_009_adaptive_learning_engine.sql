-- ── 1. Add topic column to questions ────────────────────────────────────────
ALTER TABLE questions ADD COLUMN IF NOT EXISTS topic text;

WITH ranked AS (
  SELECT id, category,
         ROW_NUMBER() OVER (PARTITION BY category ORDER BY id) AS rn
  FROM questions
)
UPDATE questions q
SET topic = CASE q.category
  WHEN 'math' THEN
    (ARRAY['Arithmetic','Fractions','Percentages','Algebra','Geometry','Word Problems','Sequences','Data Handling'])
    [((ranked.rn - 1) % 8) + 1]
  WHEN 'english' THEN
    (ARRAY['Grammar','Comprehension','Punctuation','Spelling','Sentence Structure','Reading','Creative Writing'])
    [((ranked.rn - 1) % 7) + 1]
  WHEN 'verbal_reasoning' THEN
    (ARRAY['Analogies','Sequences','Word Relationships','Code Breaking','Logic','Classification','Word Patterns'])
    [((ranked.rn - 1) % 7) + 1]
  WHEN 'vocabulary' THEN
    (ARRAY['Definitions','Synonyms','Antonyms','Context Clues','Word Families','Spelling','Word Usage'])
    [((ranked.rn - 1) % 7) + 1]
  WHEN 'odd_one_out' THEN
    (ARRAY['Word Categories','Number Patterns','Visual Patterns','Mixed Patterns','Shape Sequences','Letter Patterns','Concept Groups'])
    [((ranked.rn - 1) % 7) + 1]
  ELSE 'General'
END
FROM ranked
WHERE ranked.id = q.id;

-- ── 2. Topic mastery view ─────────────────────────────────────────────────────
CREATE OR REPLACE VIEW topic_mastery AS
SELECT
  ah.user_id,
  q.category,
  q.topic,
  COUNT(*)                                                          AS total_attempts,
  SUM(CASE WHEN ah.is_correct THEN 1 ELSE 0 END)                   AS correct_answers,
  ROUND(SUM(CASE WHEN ah.is_correct THEN 1 ELSE 0 END)::numeric / COUNT(*) * 100) AS mastery_pct
FROM answer_history ah
JOIN questions q ON ah.question_id = q.id
WHERE q.topic IS NOT NULL
GROUP BY ah.user_id, q.category, q.topic;

-- ── 3. AI-generated challenges table ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS ai_challenges (
  id              uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  title           text NOT NULL,
  description     text NOT NULL,
  focus_topics    text[] NOT NULL DEFAULT '{}',
  focus_category  text,
  question_ids    uuid[] NOT NULL DEFAULT '{}',
  xp_reward       integer NOT NULL DEFAULT 150,
  is_completed    boolean NOT NULL DEFAULT false,
  score           integer,
  total_questions integer NOT NULL DEFAULT 10,
  created_at      timestamptz NOT NULL DEFAULT now(),
  completed_at    timestamptz
);

ALTER TABLE ai_challenges ENABLE ROW LEVEL SECURITY;

CREATE POLICY "select_own_challenges" ON ai_challenges FOR SELECT
  TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "insert_own_challenges" ON ai_challenges FOR INSERT
  TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY "update_own_challenges" ON ai_challenges FOR UPDATE
  TO authenticated USING (auth.uid() = user_id) WITH CHECK (auth.uid() = user_id);

-- ── 4. Curriculum weeks ───────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS curriculum_weeks (
  week_number      integer PRIMARY KEY,
  title            text NOT NULL,
  description      text NOT NULL,
  focus_subjects   text[] NOT NULL DEFAULT '{}',
  focus_topics     text[] NOT NULL DEFAULT '{}',
  target_score     integer NOT NULL DEFAULT 70,
  unlock_threshold integer NOT NULL DEFAULT 85,
  xp_reward        integer NOT NULL DEFAULT 200
);

INSERT INTO curriculum_weeks (week_number, title, description, focus_subjects, focus_topics, target_score, unlock_threshold, xp_reward) VALUES
  (1,  'Foundation Week',      'Build your basics across all subjects',                                     ARRAY['math','english'],                                    ARRAY['Arithmetic','Grammar','Spelling'],                                     60, 80, 150),
  (2,  'Numbers & Operations', 'Master arithmetic, fractions and percentages',                              ARRAY['math'],                                              ARRAY['Arithmetic','Fractions','Percentages'],                                65, 80, 175),
  (3,  'English Foundations',  'Strengthen grammar, punctuation and reading',                               ARRAY['english'],                                           ARRAY['Grammar','Punctuation','Comprehension'],                               65, 80, 175),
  (4,  'Verbal Reasoning I',   'Tackle analogies, sequences and word relationships',                        ARRAY['verbal_reasoning'],                                  ARRAY['Analogies','Sequences','Word Relationships'],                          65, 85, 200),
  (5,  'Vocabulary Builder',   'Expand your vocabulary and word knowledge',                                 ARRAY['vocabulary'],                                        ARRAY['Synonyms','Antonyms','Definitions'],                                   65, 85, 200),
  (6,  'Mixed Assessment I',   'Test yourself across all five subjects',                                    ARRAY['math','english','verbal_reasoning','vocabulary','odd_one_out'], ARRAY['Arithmetic','Grammar','Analogies','Definitions','Word Categories'],    70, 85, 250),
  (7,  'Advanced Mathematics', 'Algebra, geometry and data handling',                                       ARRAY['math'],                                              ARRAY['Algebra','Geometry','Data Handling','Word Problems'],                  70, 85, 225),
  (8,  'Advanced English',     'Sentence structure, creative writing and reading',                          ARRAY['english'],                                           ARRAY['Sentence Structure','Creative Writing','Reading'],                     70, 85, 225),
  (9,  'Verbal Reasoning II',  'Code breaking, logic and classification',                                   ARRAY['verbal_reasoning'],                                  ARRAY['Code Breaking','Logic','Classification'],                              70, 90, 250),
  (10, 'Pattern Recognition',  'Spot patterns across words, numbers and shapes',                            ARRAY['odd_one_out'],                                       ARRAY['Number Patterns','Visual Patterns','Shape Sequences'],                 70, 90, 250),
  (11, 'Mixed Assessment II',  'Advanced mixed practice — raise your game',                                 ARRAY['math','english','verbal_reasoning','vocabulary','odd_one_out'], ARRAY['Algebra','Sentence Structure','Logic','Antonyms','Mixed Patterns'],    75, 90, 300),
  (12, 'Mock 11+ Challenge',   'Full mock paper — simulate exam conditions',                                ARRAY['math','english','verbal_reasoning','vocabulary','odd_one_out'], ARRAY['Arithmetic','Fractions','Grammar','Analogies','Definitions'],          75, 90, 400)
ON CONFLICT (week_number) DO NOTHING;

-- ── 5. Week unlocks per user ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS week_unlocks (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  week_number   integer NOT NULL REFERENCES curriculum_weeks(week_number),
  unlocked_at   timestamptz NOT NULL DEFAULT now(),
  unlock_reason text NOT NULL DEFAULT 'default',
  UNIQUE(user_id, week_number)
);

ALTER TABLE week_unlocks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "select_own_week_unlocks" ON week_unlocks FOR SELECT
  TO authenticated USING (auth.uid() = user_id);
CREATE POLICY "insert_own_week_unlocks" ON week_unlocks FOR INSERT
  TO authenticated WITH CHECK (auth.uid() = user_id);

-- ── 6. Add week_number to quiz_attempts ──────────────────────────────────────
ALTER TABLE quiz_attempts ADD COLUMN IF NOT EXISTS week_number integer REFERENCES curriculum_weeks(week_number);

-- ── 7. RPC: generate_adaptive_challenge ──────────────────────────────────────
CREATE OR REPLACE FUNCTION generate_adaptive_challenge(p_user_id uuid)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_focus_topics    text[];
  v_focus_category  text;
  v_question_ids    uuid[];
  v_challenge_id    uuid;
  v_title           text;
  v_description     text;
  v_xp_reward       integer := 150;
BEGIN
  IF auth.uid() != p_user_id THEN
    RETURN jsonb_build_object('error', 'Unauthorized');
  END IF;

  -- Find weakest topics (below 70% mastery)
  SELECT ARRAY_AGG(topic) INTO v_focus_topics
  FROM (
    SELECT topic
    FROM topic_mastery
    WHERE user_id = p_user_id AND mastery_pct < 70
    ORDER BY mastery_pct ASC
    LIMIT 4
  ) sub;

  -- If no weak topics, grab topics never attempted
  IF v_focus_topics IS NULL OR array_length(v_focus_topics, 1) = 0 THEN
    SELECT ARRAY_AGG(topic) INTO v_focus_topics
    FROM (
      SELECT DISTINCT q.topic
      FROM questions q
      WHERE q.topic IS NOT NULL
        AND q.topic NOT IN (
          SELECT DISTINCT q2.topic
          FROM answer_history ah
          JOIN questions q2 ON ah.question_id = q2.id
          WHERE ah.user_id = p_user_id
        )
      ORDER BY RANDOM()
      LIMIT 4
    ) sub;
  END IF;

  -- Fallback: lowest mastery topics
  IF v_focus_topics IS NULL OR array_length(v_focus_topics, 1) = 0 THEN
    SELECT ARRAY_AGG(topic) INTO v_focus_topics
    FROM (
      SELECT topic FROM topic_mastery
      WHERE user_id = p_user_id
      ORDER BY mastery_pct ASC
      LIMIT 3
    ) sub;
  END IF;

  -- Last resort: random topics
  IF v_focus_topics IS NULL OR array_length(v_focus_topics, 1) = 0 THEN
    SELECT ARRAY_AGG(topic) INTO v_focus_topics
    FROM (
      SELECT DISTINCT topic FROM questions
      WHERE topic IS NOT NULL
      ORDER BY RANDOM()
      LIMIT 3
    ) sub;
  END IF;

  -- Dominant category among focus topics
  SELECT q.category INTO v_focus_category
  FROM questions q
  WHERE q.topic = ANY(v_focus_topics)
  GROUP BY q.category
  ORDER BY COUNT(*) DESC
  LIMIT 1;

  -- Select 10 questions from focus topics
  SELECT ARRAY_AGG(qid) INTO v_question_ids
  FROM (
    SELECT id AS qid FROM questions
    WHERE topic = ANY(v_focus_topics)
    ORDER BY RANDOM()
    LIMIT 10
  ) sub;

  -- Top up if fewer than 10
  IF v_question_ids IS NULL OR array_length(v_question_ids, 1) < 10 THEN
    SELECT ARRAY_AGG(qid) INTO v_question_ids
    FROM (
      SELECT id AS qid FROM questions
      WHERE category = v_focus_category
      ORDER BY RANDOM()
      LIMIT 10
    ) sub;
  END IF;

  v_title       := 'AI Challenge: ' || v_focus_topics[1] || ' Focus';
  v_description := 'Personalised quiz targeting: ' || array_to_string(v_focus_topics[1:3], ', ');
  v_xp_reward   := 150 + (array_length(v_focus_topics, 1) * 10);

  INSERT INTO ai_challenges (user_id, title, description, focus_topics, focus_category, question_ids, xp_reward, total_questions)
  VALUES (p_user_id, v_title, v_description, v_focus_topics, v_focus_category, v_question_ids, v_xp_reward, COALESCE(array_length(v_question_ids, 1), 10))
  RETURNING id INTO v_challenge_id;

  RETURN jsonb_build_object(
    'success', true,
    'challenge_id', v_challenge_id,
    'title', v_title,
    'focus_topics', v_focus_topics,
    'question_count', COALESCE(array_length(v_question_ids, 1), 0),
    'xp_reward', v_xp_reward
  );
END;
$$;

REVOKE EXECUTE ON FUNCTION generate_adaptive_challenge(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION generate_adaptive_challenge(uuid) TO authenticated;

-- ── 8. RPC: record_week_result ────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION record_week_result(
  p_user_id uuid, p_week integer, p_score integer, p_total integer
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_pct           integer;
  v_threshold     integer;
  v_next_week     integer := p_week + 1;
  v_unlocked_next boolean := false;
BEGIN
  IF auth.uid() != p_user_id THEN
    RETURN jsonb_build_object('error', 'Unauthorized');
  END IF;

  v_pct := ROUND((p_score::numeric / p_total) * 100);

  INSERT INTO week_unlocks (user_id, week_number, unlock_reason)
  VALUES (p_user_id, p_week, 'attempted')
  ON CONFLICT (user_id, week_number) DO NOTHING;

  SELECT unlock_threshold INTO v_threshold FROM curriculum_weeks WHERE week_number = p_week;

  IF EXISTS (SELECT 1 FROM curriculum_weeks WHERE week_number = v_next_week) THEN
    IF NOT EXISTS (SELECT 1 FROM week_unlocks WHERE user_id = p_user_id AND week_number = v_next_week)
       AND v_pct >= COALESCE(v_threshold, 85) THEN
      INSERT INTO week_unlocks (user_id, week_number, unlock_reason)
      VALUES (p_user_id, v_next_week, 'scored_above_threshold');
      v_unlocked_next := true;
    END IF;
  END IF;

  RETURN jsonb_build_object(
    'success', true,
    'score_pct', v_pct,
    'unlocked_next_week', v_unlocked_next,
    'needs_remediation', v_pct < 70
  );
END;
$$;

REVOKE EXECUTE ON FUNCTION record_week_result(uuid, integer, integer, integer) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION record_week_result(uuid, integer, integer, integer) TO authenticated;
