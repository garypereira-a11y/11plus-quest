/*
# 11+ Adventure: Fix add_stars Security

Fixes three security issues with the `add_stars` function:

1. **Search Path Mutable** — Sets an explicit `search_path` to prevent search-path injection.
2. **Public Can Execute** — Revokes EXECUTE from the `anon` role so unauthenticated users cannot call the function.
3. **Signed-In Users Can Execute SECURITY DEFINER** — Re-creates the function with an ownership check so only the profile owner can add stars to their own account. Keeps `authenticated` access but the function body now validates `auth.uid() = user_id`.

## Changes

- Drop and re-create `add_stars` with:
  - `SECURITY DEFINER` (needed to bypass RLS on profiles for the update)
  - `SET search_path = ''` (prevents search-path injection)
  - Body now checks `auth.uid() = user_id` and raises an exception if the caller is not the profile owner
- Revoke EXECUTE on `add_stars` from `anon`
- Grant EXECUTE on `add_stars` to `authenticated` only
*/

DROP FUNCTION IF EXISTS public.add_stars(uuid, integer);

CREATE FUNCTION public.add_stars(user_id uuid, stars_to_add integer)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  IF auth.uid() IS DISTINCT FROM user_id THEN
    RAISE EXCEPTION 'You can only add stars to your own profile';
  END IF;

  UPDATE public.profiles
  SET stars = stars + stars_to_add
  WHERE id = user_id;
END;
$$;

REVOKE ALL ON FUNCTION public.add_stars(uuid, integer) FROM anon;
GRANT EXECUTE ON FUNCTION public.add_stars(uuid, integer) TO authenticated;