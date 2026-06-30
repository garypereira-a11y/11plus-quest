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

function AppInner() {
  const { user, profile, loading } = useAuth();
  const [page, setPage]            = useState<Page>({ name: 'auth' });
  const [childCount, setChildCount] = useState<number | null>(null);

  const checkChildren = useCallback(async () => {
    if (!user) return;
    const { count } = await supabase
      .from('children')
      .select('id', { count: 'exact', head: true });
    setChildCount(count ?? 0);
  }, [user]);

  useEffect(() => {
    if (loading) return;
    if (!user) { setPage({ name: 'auth' }); return; }

    checkChildren().then(() => {
      // Routing will be handled in the next effect once childCount is set
    });
  }, [user, loading, checkChildren]);

  useEffect(() => {
    if (loading || !user || childCount === null) return;

    // Already navigated away from auth page
    if (page.name !== 'auth') return;

    const isParent = profile?.is_parent ?? profile?.role === 'parent';

    if (isParent) {
      if (childCount === 0) {
        setPage({ name: 'child-wizard', isFirst: true });
      } else {
        setPage({ name: 'parent-dashboard' });
      }
    } else {
      // Legacy child user — find their children record
      supabase
        .from('children')
        .select('id')
        .eq('profile_id', user.id)
        .maybeSingle()
        .then(({ data }) => {
          if (data?.id) {
            setPage({ name: 'child-dashboard', childId: data.id });
          } else {
            // No record yet — show wizard to complete profile
            setPage({ name: 'child-wizard', isFirst: true });
          }
        });
    }
  }, [user, loading, profile, childCount, page.name]);

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
          onSelectChild={async (childId) => {

    await supabase
        .from("profiles")
        .update({
            last_child_id: childId
        })
        .eq("id", user!.id);

    setPage({
        name:"child-dashboard",
        childId
    });

}}
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
