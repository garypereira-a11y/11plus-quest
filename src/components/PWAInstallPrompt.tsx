import { useState, useEffect } from 'react';
import { X, Download, Share } from 'lucide-react';

interface BeforeInstallPromptEvent extends Event {
  prompt: () => Promise<void>;
  userChoice: Promise<{ outcome: 'accepted' | 'dismissed' }>;
}

const DISMISSED_KEY = 'pwa_install_dismissed';

export function PWAInstallPrompt() {
  const [deferredPrompt, setDeferredPrompt] = useState<BeforeInstallPromptEvent | null>(null);
  const [showIOS, setShowIOS]               = useState(false);
  const [visible, setVisible]               = useState(false);

  useEffect(() => {
    if (localStorage.getItem(DISMISSED_KEY)) return;

    const isIOS = /iphone|ipad|ipod/i.test(navigator.userAgent) && !(window.navigator as { standalone?: boolean }).standalone;
    if (isIOS) { setShowIOS(true); setVisible(true); return; }

    const handler = (e: Event) => {
      e.preventDefault();
      setDeferredPrompt(e as BeforeInstallPromptEvent);
      setVisible(true);
    };
    window.addEventListener('beforeinstallprompt', handler);
    return () => window.removeEventListener('beforeinstallprompt', handler);
  }, []);

  const dismiss = () => {
    setVisible(false);
    localStorage.setItem(DISMISSED_KEY, '1');
  };

  const install = async () => {
    if (!deferredPrompt) return;
    await deferredPrompt.prompt();
    const { outcome } = await deferredPrompt.userChoice;
    if (outcome === 'accepted') localStorage.setItem(DISMISSED_KEY, '1');
    setVisible(false);
  };

  if (!visible) return null;

  return (
    <div className="fixed bottom-6 left-4 right-4 z-50 animate-slideUp">
      <div className="bg-twilight-surface border border-quest-gold/20 rounded-2xl p-4 shadow-2xl max-w-sm mx-auto">
        <div className="flex items-start gap-3">
          <div className="w-10 h-10 rounded-xl bg-quest-gold/15 flex items-center justify-center shrink-0 text-xl">🏰</div>
          <div className="flex-1">
            <p className="text-parchment font-bold font-display text-sm">Add to Home Screen</p>
            {showIOS ? (
              <p className="text-parchment-dim text-xs mt-1">
                Tap <Share className="w-3 h-3 inline" /> then <strong>Add to Home Screen</strong>
              </p>
            ) : (
              <p className="text-parchment-dim text-xs mt-1">Install 11+ Quest for offline access</p>
            )}
          </div>
          <button onClick={dismiss} className="text-parchment-dim/60 hover:text-parchment-dim transition-colors">
            <X className="w-5 h-5" />
          </button>
        </div>
        {!showIOS && (
          <button onClick={install}
            className="w-full mt-3 flex items-center justify-center gap-2 py-2.5 bg-quest-gold text-twilight-deep rounded-xl font-bold font-display text-sm hover:shadow-glow transition-all">
            <Download className="w-4 h-4" /> Install App
          </button>
        )}
      </div>
    </div>
  );
}
