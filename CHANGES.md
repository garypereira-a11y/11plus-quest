# 11+ Quest — Change Summary

## Phase 3: Quest Map (visual weekly progress path)

Replaced the plain vertical list of weeks in `WeekChooserPage` with an actual
winding path through the realm — the centerpiece "treasure hunt" visual.

**What changed:**
- Weeks are now circular waypoint nodes (rotating through castle/tower/camp/
  bridge/pagoda/hut icons) connected by a curved dotted gold path, laid out in
  a zigzag descending down the screen (classic mobile level-map style)
- **Completed weeks**: emerald glow, score badge (e.g. "84%") pinned to the node
- **Current/next week**: pulsing gold glow with a star marker, shows difficulty
  level underneath
- **Locked weeks**: greyed out with a lock icon, not clickable
- A trophy "Exam Day" flag sits beyond the final week as the ultimate goal
- Auto-scrolls to the child's current week on load, so they land right where
  they left off instead of at the top of a long list
- All existing logic is unchanged underneath — same `generate_child_test` RPC
  call, same replay-completed-week behavior, same error handling. Only the
  presentation layer changed.

**Technical note:** the path is generated programmatically (not a fixed image)
so it correctly adapts to exam types with different week counts (12, 14, or 16
weeks depending on the target exam).

---

## Phase 2: Visual theme — "Realm Quest" (fantasy adventure)

Replaced the generic dark-slate-plus-amber look with a distinctive fantasy theme,
applied consistently across every page.

**New design tokens** (`tailwind.config.js`):
- Colors: `twilight` (deep violet backgrounds), `quest-gold` (rewards/CTAs),
  `realm-emerald` (progress/success), `realm-coral` (streaks/energy),
  `parchment` (light text on dark)
- Fonts: Baloo 2 (headings/display), Nunito (body), JetBrains Mono (stats/numbers)
  — loaded via Google Fonts in `index.html`
- New `rounded-scroll` border radius and `shadow-glow` utilities for a
  hand-crafted, "scroll/banner" card feel instead of uniform flat corners

**Pages restyled:** AuthPage, ChildProfileWizard, ChildDashboard, ParentDashboard,
QuizPage, WeekChooserPage, LeaderboardPage, SelectAvatarPage, PrivacyPolicyPage,
plus the app-level loading screen and both PWA prompt components.

**Other related changes:**
- `lib/readiness.ts` readiness-level colors updated to match the new palette
  (emerald/gold/coral instead of generic emerald/amber/red)
- Avatar choices expanded to fantasy characters (wizard, knight, dragon, etc.)
  in both the child profile wizard and parent avatar picker
- `favicon.svg` redrawn as a faceted gem in the new twilight/gold palette

**Bonus bug fix found during this pass:** the PWA manifest file
(`public/manifest`) had no file extension and was never linked from
`index.html` — meaning "Add to Home Screen" / installability likely wasn't
working at all. Fixed by adding a properly named `manifest.webmanifest` with
corrected theme colors and linking it via `<link rel="manifest">`.

**Not done / needs your input:**
- The 192×192 and 512×512 PNG app icons referenced in the manifest are unchanged
  (still the old design) — I can't generate images in this environment. You'll
  want to swap `public/icons/icon-192.png` and `icon-512.png` for something
  matching the new gem/twilight look when you get a chance.
- Treasure chest rewards (Phase 4, formerly "Phase 3") are not implemented yet —
  the `treasure_chests` table still has no frontend logic behind it.

---

# Earlier fixes (Phase 1: bug fixes)

## 1. Answer checking was broken (`src/lib/supabase.ts`, `src/pages/QuizPage.tsx`)
The `questions` table stores `correct_answer` as an **integer index** (0–3), but the
frontend compared it directly to the option **text** (`option === current.correct_answer`).
A string can never equal a number in JS, so this comparison was unreliable.

**Fix:** Added two helpers in `lib/supabase.ts`:
- `isCorrectOption(question, chosenOption)` — works whether `correct_answer` is a
  number (index) or a string (option text or numeric-string index).
- `getCorrectOptionText(question)` — returns the correct answer's display text for
  highlighting, using the same logic.

`QuizPage.tsx` now uses these everywhere instead of direct comparison.

## 2. "Weekly Test" ignored the adaptive engine (`WeekChooserPage.tsx`, `QuizPage.tsx`, `App.tsx`)
A real adaptive-test generator already existed in the database
(`generate_child_test` — 70% weak-skill questions, 20% medium, 10% strong) but the
UI never called it. Tapping "Weekly Test" just grabbed 30 random questions.

**Fix:**
- `WeekChooserPage` now calls `supabase.rpc('generate_child_test', { p_child_id })`
  when starting a new week, fetches the generated `question_ids`, and passes them
  through.
- Revisiting an already-started/completed week replays its original question set
  (no need to regenerate).
- `QuizPage` preserves the curated weak→medium→strong order (Supabase's `.in()`
  doesn't guarantee order, so it's restored client-side).
- On completion, the matching `ai_weekly_tests` row is updated with `score` and
  `completed_at`, so progress actually persists.
- Added a small loading spinner while a test is being generated, and error
  messaging if generation fails.

## 3. Dead code that would break the build (`src/pages/AdaptiveDashboard.tsx`)
This component was never imported or routed anywhere, and it imported
`SUBJECT_LABELS` from `lib/supabase.ts`, which doesn't exist. Since `tsconfig.app.json`
includes all of `src`, `tsc -b` type-checks every file regardless of whether it's
used — so this alone would fail `npm run build`.

**Fix:** Removed the file. Nothing else referenced it.

## 4. Leaderboard was unreachable (`ChildDashboard.tsx`, `App.tsx`)
`LeaderboardPage` was fully built and worked correctly, but no button anywhere
navigated to it.

**Fix:** Added a trophy icon button to the child dashboard header. Confirmed first
that the existing RLS policy on `children` already scopes results to your own
children only (parent or child themselves) — so this is safe to expose as-is. (A
*global* cross-family leaderboard would need a new public-safe view — that's a
feature add, not a bug fix, and is listed as an option for the next phase.)

## 5. Dead-end "back" button for legacy child logins (`ChildDashboard.tsx`, `App.tsx`)
If a child (not a parent) was logged in directly, the dashboard's "back" button set
the page to the exact same dashboard it was already on — a no-op.

**Fix:** `onBack` is now optional on `ChildDashboard`; the button only renders when
there's somewhere meaningful to go (i.e., back to a parent dashboard). Solo child
logins no longer show a dead button.

## Not changed (flagged for your awareness only)
- **`curriculum_weeks` / `week_unlocks` / `record_week_result`** (from migration
  009) are an older, superseded version of the weekly-test system, replaced by
  `ai_weekly_tests` / `generate_child_test` (migration 011). Nothing in the
  frontend references the old tables/function. I left the schema alone since
  dropping tables is a destructive change I won't make without you explicitly
  confirming it — happy to write that migration if you want it gone.

