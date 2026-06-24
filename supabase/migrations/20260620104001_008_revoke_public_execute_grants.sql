-- Revoke default PUBLIC execute grant from all SECURITY DEFINER RPCs
-- (PostgreSQL grants EXECUTE to PUBLIC by default; must be explicitly revoked)
REVOKE EXECUTE ON FUNCTION add_stars(uuid, integer) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION add_xp(uuid, integer) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION add_treasure_keys(uuid, integer) FROM PUBLIC;
REVOKE EXECUTE ON FUNCTION link_to_parent(text) FROM PUBLIC;

-- Ensure only authenticated users can call these functions
GRANT EXECUTE ON FUNCTION add_stars(uuid, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION add_xp(uuid, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION add_treasure_keys(uuid, integer) TO authenticated;
GRANT EXECUTE ON FUNCTION link_to_parent(text) TO authenticated;

-- Recreate link_to_parent with fixed search_path (idempotent)
CREATE OR REPLACE FUNCTION link_to_parent(p_code text)
RETURNS json
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_parent_id uuid;
  v_child_id  uuid := auth.uid();
BEGIN
  IF v_child_id IS NULL THEN
    RETURN json_build_object('error', 'Not authenticated');
  END IF;

  p_code := upper(trim(p_code));

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

  IF EXISTS (SELECT 1 FROM parent_child_links WHERE child_user_id = v_child_id) THEN
    RETURN json_build_object('error', 'You are already linked to a parent account.');
  END IF;

  INSERT INTO parent_child_links (parent_user_id, child_user_id, verification_code)
  VALUES (v_parent_id, v_child_id, p_code);

  UPDATE profiles SET parent_id = v_parent_id WHERE id = v_child_id;

  RETURN json_build_object('success', true);
END;
$$;

-- Re-apply grant after CREATE OR REPLACE (resets grants)
REVOKE EXECUTE ON FUNCTION link_to_parent(text) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION link_to_parent(text) TO authenticated;
