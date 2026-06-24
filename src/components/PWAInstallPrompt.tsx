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
      <div className="bg-[#1e2d3d] border border-white/15 rounded-2xl p-4 shadow-2xl max-w-sm mx-auto">
        <div className="flex items-start gap-3">
          <div className="w-10 h-10 rounded-xl bg-amber-400/15 flex items-center justify-center shrink-0 text-xl">🎓</div>
          <div className="flex-1">
            <p className="text-white font-bold text-sm">Add to Home Screen</p>
            {showIOS ? (
              <p className="text-white/50 text-xs mt-1">
                Tap <Share className="w-3 h-3 inline" /> then <strong>Add to Home Screen</strong>
              </p>
            ) : (
              <p className="text-white/50 text-xs mt-1">Install 11+ Quest for offline access</p>
            )}
          </div>
          <button onClick={dismiss} className="text-white/30 hover:text-white/60 transition-colors">
            <X className="w-5 h-5" />
          </button>
        </div>
        {!showIOS && (
          <button onClick={install}
            className="w-full mt-3 flex items-center justify-center gap-2 py-2.5 bg-amber-400 text-amber-900 rounded-xl font-bold text-sm hover:bg-amber-300 transition-all">
            <Download className="w-4 h-4" /> Install App
          </button>
        )}
      </div>
    </div>
  );
}
