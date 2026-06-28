import { useState, useEffect, useCallback } from 'react';
import { AuthProvider, useAuth } from './context/AuthContext';
import { supabase } from './lib/supabase';
import { AuthPage }           from './pages/AuthPage';
import { ChildProfileWizard } from './pages/ChildProfileWizard';
import { ParentDashboard }    from './pages/ParentDashboard';
import { ChildDashboard }     from './pages/ChildDashboard';
import { QuizPage }           from './pages/QuizPage';
import { WeekChooserPage }    from './pages/WeekChooserPage';
import { LeaderboardPage }    from './pages/LeaderboardPage';
import { SelectAvatarPage }   from './pages/SelectAvatarPage';
import { CharacterShopPage }  from './pages/CharacterShopPage';
import { PrivacyPolicyPage }  from './pages/PrivacyPolicyPage';
import { PWAInstallPrompt }   from './components/PWAInstallPrompt';
import { NotificationPrompt } from './components/PushNotifications';

type Page =
  | { name: 'auth' }
  | { name: 'parent-dashboard' }
  | { name: 'child-wizard'; isFirst: boolean }
  | { name: 'child-dashboard'; childId: string }
  | { name: 'quiz'; childId: string; category?: string; isWeekly?: boolean; questionIds?: string[]; weeklyTestId?: string }
  | { name: 'week-chooser'; childId: string }
  | { name: 'leaderboard'; childId: string }
  | { name: 'select-avatar' }
  | { name: 'character-shop'; childId: string }
  | { name: 'privacy' };

const LAST_PAGE_KEY = 'quest_last_page';

// Pages worth returning to after a reload/re-login. Deliberately excludes:
// - 'auth' / 'child-wizard' — transient onboarding states, not "places"
// - 'quiz' — a quiz's actual question set lives in component state, not the
//   page descriptor, so "restoring" this would silently start a brand-new
//   quiz while looking like it resumed the old one. Far better to land one
//   screen back (child-dashboard) than to fake a resume that doesn't happen.
const RESTORABLE_PAGE_NAMES = new Set<Page['name']>([
  'parent-dashboard', 'child-dashboard', 'week-chooser', 'leaderboard', 'character-shop',
]);

function saveLastPage(page: Page) {
  if (!RESTORABLE_PAGE_NAMES.has(page.name)) return;
  try {
    localStorage.setItem(LAST_PAGE_KEY, JSON.stringify(page));
  } catch {
    // localStorage can throw in some private-browsing modes — losing the
    // "resume where I left off" convenience is fine, just don't crash the app over it.
  }
}

function loadLastPage(): Page | null {
  try {
    const raw = localStorage.getItem(LAST_PAGE_KEY);
    if (!raw) return null;
    const parsed = JSON.parse(raw);
    if (!parsed || typeof parsed.name !== 'string' || !RESTORABLE_PAGE_NAMES.has(parsed.name)) return null;
    return parsed as Page;
  } catch {
    return null;
  }
}

function AppInner() {
  const { user, profile, loading } = useAuth();
  const [page, setPage]            = useState<Page>({ name: 'auth' });
  const [childCount, setChildCount] = useState<number | null>(null);
  // Tri-state restore tracking:
  //   'pending'   — haven't tried to restore the saved page yet this session
  //   'in-flight' — currently validating a saved childId against the database
  //   'done'      — restore finished (whether or not it found anything usable)
  // This exists specifically so the routing effect below can tell "still checking,
  // don't fall through to default routing yet" apart from "finished checking,
  // safe to apply default routing now" — collapsing these into one boolean caused
  // a race where default routing could fire concurrently with an in-flight restore.
  const [restoreState, setRestoreState] = useState<'pending' | 'in-flight' | 'done'>('pending');

  // Persist the current page on every change, so a reload or re-login can return
  // here instead of always restarting at the dashboard/picker.
  useEffect(() => {
    saveLastPage(page);
  }, [page]);

  const checkChildren = useCallback(async () => {
    if (!user) return;
    const { count } = await supabase
      .from('children')
      .select('id', { count: 'exact', head: true });
    setChildCount(count ?? 0);
  }, [user]);

  useEffect(() => {
    if (loading) return;
    if (!user) {
      setPage({ name: 'auth' });
      // Clear any saved page on sign-out so a different account signing in next
      // never attempts to restore this account's page — the child-ownership
      // check in the routing effect below would catch it anyway, but this avoids
      // the extra validation query and any visible flash entirely.
      try { localStorage.removeItem(LAST_PAGE_KEY); } catch { /* ignore */ }
      return;
    }

    checkChildren().then(() => {
      // Routing will be handled in the next effect once childCount is set
    });
  }, [user, loading, checkChildren]);

  useEffect(() => {
    if (loading || !user || childCount === null) return;

    // Already navigated away from auth page
    if (page.name !== 'auth') return;

    const isParent = profile?.is_parent ?? profile?.role === 'parent';

    // The normal default routing (no saved page, or restore wasn't possible):
    // parent with no children -> wizard, parent with children -> dashboard,
    // legacy child account -> look up their own child record.
    const routeToDefault = () => {
      if (isParent) {
        if (childCount === 0) {
          setPage({ name: 'child-wizard', isFirst: true });
        } else {
          setPage({ name: 'parent-dashboard' });
        }
      } else {
        supabase
          .from('children')
          .select('id')
          .eq('profile_id', user.id)
          .maybeSingle()
          .then(({ data }) => {
            if (data?.id) {
              setPage({ name: 'child-dashboard', childId: data.id });
            } else {
              setPage({ name: 'child-wizard', isFirst: true });
            }
          });
      }
    };

    // First chance to restore — try this before falling through to the default
    // dashboard/wizard routing above. 'pending' means we haven't tried yet this
    // session; 'in-flight' means an async validation is already running (skip
    // entirely, don't re-trigger or fall through); 'done' means we already tried
    // and should proceed to default routing if we're still on 'auth'.
    if (restoreState === 'pending') {
      const saved = loadLastPage();
      if (!saved) {
        setRestoreState('done');
        return; // let the next effect run (triggered by restoreState change) handle routing
      }

      const savedChildId = 'childId' in saved ? saved.childId : null;
      if (!savedChildId) {
        // Pages with no childId (parent-dashboard) are always safe to restore directly.
        setRestoreState('done');
        setPage(saved);
        return;
      }

      setRestoreState('in-flight');
      // Validate the saved child still exists and is actually accessible to this
      // account — protects against a stale entry from a deleted child or a
      // different account on a shared device, rather than trusting it blindly.
      supabase.from('children').select('id').eq('id', savedChildId).maybeSingle()
        .then(({ data }) => {
          if (data?.id) {
            setPage(saved);
          }
          // Whether it matched or not, mark done — if it didn't match, this triggers
          // the effect to re-run and fall through to routeToDefault() below.
          setRestoreState('done');
        });
      return;
    }

    if (restoreState === 'in-flight') {
      // Validation query is still running — do nothing until it resolves and
      // flips restoreState to 'done' (which will re-trigger this effect).
      return;
    }

    // restoreState === 'done': either there was nothing to restore, or restoring
    // failed validation, or page already moved on. If we're still on 'auth' at
    // this point, apply the normal default routing.
    routeToDefault();
  }, [user, loading, profile, childCount, page.name, restoreState]);

  if (loading) {
    return (
      <div className="min-h-screen bg-twilight-deep flex items-center justify-center">
        <div className="text-center">
          <div className="text-5xl mb-4 animate-shimmer">🏰</div>
          <p className="text-parchment-dim text-sm font-display animate-pulse">Entering the realm...</p>
        </div>
      </div>
    );
  }

  // ── Route rendering ────────────────────────────────────────────────────────

  if (page.name === 'auth') {
    return <AuthPage onSuccess={() => {
      setChildCount(null);
      checkChildren();
    }} />;
  }

  if (page.name === 'child-wizard') {
    return (
      <ChildProfileWizard
        isFirstChild={page.isFirst}
        onComplete={async (childId) => {
          await checkChildren();
          setPage({ name: 'child-dashboard', childId });
        }}
        onSkip={page.isFirst ? () => setPage({ name: 'parent-dashboard' }) : undefined}
      />
    );
  }

  if (page.name === 'parent-dashboard') {
    return (
      <>
        <ParentDashboard
          onSelectChild={(childId) => setPage({ name: 'child-dashboard', childId })}
          onAddChild={() => setPage({ name: 'child-wizard', isFirst: false })}
        />
        <PWAInstallPrompt />
        <NotificationPrompt />
      </>
    );
  }

  if (page.name === 'child-dashboard') {
    const isParent = profile?.is_parent ?? profile?.role === 'parent';
    return (
      <>
        <ChildDashboard
          childId={page.childId}
          onBack={isParent ? () => setPage({ name: 'parent-dashboard' }) : undefined}
          onStartQuiz={(category) => setPage({ name: 'quiz', childId: page.childId, category })}
          onStartWeeklyTest={() => setPage({ name: 'week-chooser', childId: page.childId })}
          onViewLeaderboard={() => setPage({ name: 'leaderboard', childId: page.childId })}
          onOpenShop={() => setPage({ name: 'character-shop', childId: page.childId })}
        />
        <PWAInstallPrompt />
        <NotificationPrompt />
      </>
    );
  }

  if (page.name === 'character-shop') {
    return (
      <CharacterShopPage
        childId={page.childId}
        onBack={() => setPage({ name: 'child-dashboard', childId: page.childId })}
      />
    );
  }

  if (page.name === 'week-chooser') {
    return (
      <WeekChooserPage
        childId={page.childId}
        onStartWeek={(_week, questionIds, testId) =>
          setPage({ name: 'quiz', childId: page.childId, isWeekly: true, questionIds, weeklyTestId: testId })
        }
        onBack={() => setPage({ name: 'child-dashboard', childId: page.childId })}
      />
    );
  }

  if (page.name === 'quiz') {
    return (
      <QuizPage
        childId={page.childId}
        category={page.category}
        isWeeklyTest={page.isWeekly}
        questionIds={page.questionIds}
        weeklyTestId={page.weeklyTestId}
        onComplete={(_score, _total) => setPage({ name: 'child-dashboard', childId: page.childId })}
        onBack={() => setPage({ name: 'child-dashboard', childId: page.childId })}
      />
    );
  }

  if (page.name === 'leaderboard') {
    return <LeaderboardPage onBack={() => setPage({ name: 'child-dashboard', childId: page.childId })} />;
  }

  if (page.name === 'select-avatar') {
    return <SelectAvatarPage onBack={() => setPage({ name: 'parent-dashboard' })} />;
  }

  if (page.name === 'privacy') {
    return <PrivacyPolicyPage onBack={() => setPage({ name: 'auth' })} />;
  }

  return null;
}

export default function App() {
  return (
    <AuthProvider>
      <AppInner />
    </AuthProvider>
  );
}
