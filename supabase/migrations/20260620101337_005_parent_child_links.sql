/*
# Parent-Child Linking System

1. Changes to `profiles`
   - Add `verification_code` (text, unique, nullable) — 6-char uppercase code for parents.

2. New Table: `parent_child_links`
   - `id` (uuid, pk)
   - `parent_user_id` (uuid, FK → profiles)
   - `child_user_id` (uuid, UNIQUE FK → profiles — one parent per child)
   - `verification_code` (text) — the code used at link time
   - `linked_at` (timestamptz)

3. Security
   - RLS enabled on `parent_child_links`.
   - SELECT: authenticated users can see rows where they are the parent or the child.
   - INSERT: children can create their own link (child_user_id = auth.uid()).
     The `link_to_parent` RPC is SECURITY DEFINER so it can also bypass RLS.

4. New RPC: `link_to_parent(p_code text) → json`
   - SECURITY DEFINER so it can read the hidden verification_code.
   - Validates the code, checks for duplicate links, creates the record, and
     backfills `profiles.parent_id` for backward compatibility.
   - Returns `{"success": true}` or `{"error": "message"}`.
*/

-- ── profiles: add verification_code ──────────────────────────────────────────
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS verification_code text;

CREATE UNIQUE INDEX IF NOT EXISTS profiles_verification_code_idx
  ON profiles (verification_code)
  WHERE verification_code IS NOT NULL;

-- ── parent_child_links table ─────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS parent_child_links (
  id               uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  parent_user_id   uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  child_user_id    uuid NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
  verification_code text NOT NULL,
  linked_at        timestamptz DEFAULT now()
);

ALTER TABLE parent_child_links ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "read_own_links"   ON parent_child_links;
DROP POLICY IF EXISTS "insert_own_link"  ON parent_child_links;
DROP POLICY IF EXISTS "delete_own_link"  ON parent_child_links;

CREATE POLICY "read_own_links" ON parent_child_links FOR SELECT
  TO authenticated
  USING (auth.uid() = parent_user_id OR auth.uid() = child_user_id);

CREATE POLICY "insert_own_link" ON parent_child_links FOR INSERT
  TO authenticated
  WITH CHECK (auth.uid() = child_user_id);

CREATE POLICY "delete_own_link" ON parent_child_links FOR DELETE
  TO authenticated
  USING (auth.uid() = child_user_id);

-- ── RPC: link_to_parent ───────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION link_to_parent(p_code text)
RETURNS json LANGUAGE plpgsql SECURITY DEFINER AS $$
DECLARE
  v_parent_id uuid;
  v_child_id  uuid := auth.uid();
BEGIN
  IF v_child_id IS NULL THEN
    RETURN json_build_object('error', 'Not authenticated');
  END IF;

  -- Normalise: uppercase, strip whitespace
  p_code := upper(trim(p_code));

  -- Find matching parent
  SELECT id INTO v_parent_id
    FROM profiles
   WHERE verification_code = p_code
     AND is_parent = true;

  IF v_parent_id IS NULL THEN
    RETURN json_build_object('error', 'Invalid verification code. Please check and try again.');
  END IF;

  IF v_parent_id = v_child_id THEN
    RETURN json_build_object('error', 'You cannot link to your own account.');
  END IF;

  -- Prevent duplicate link
  IF EXISTS (SELECT 1 FROM parent_child_links WHERE child_user_id = v_child_id) THEN
    RETURN json_build_object('error', 'You are already linked to a parent account.');
  END IF;

  -- Create the link record
  INSERT INTO parent_child_links (parent_user_id, child_user_id, verification_code)
  VALUES (v_parent_id, v_child_id, p_code);

  -- Back-fill profiles.parent_id for the existing dashboard query
  UPDATE profiles SET parent_id = v_parent_id WHERE id = v_child_id;

  RETURN json_build_object('success', true);
END;
$$;
