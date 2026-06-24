import { useState, useEffect } from 'react';
import { Bell, X } from 'lucide-react';

const VAPID_PUBLIC_KEY = import.meta.env.VITE_VAPID_PUBLIC_KEY as string | undefined;
const NOTIF_KEY = 'push_notif_asked';

function urlBase64ToUint8Array(base64String: string): ArrayBuffer {
  const padding = '='.repeat((4 - (base64String.length % 4)) % 4);
  const base64 = (base64String + padding).replace(/-/g, '+').replace(/_/g, '/');
  const rawData = atob(base64);
  const buf  = new ArrayBuffer(rawData.length);
  const view = new Uint8Array(buf);
  for (let i = 0; i < rawData.length; ++i) view[i] = rawData.charCodeAt(i);
  return buf;
}

export function usePushNotifications() {
  const [permission, setPermission] = useState<NotificationPermission>('default');

  useEffect(() => {
    if ('Notification' in window) setPermission(Notification.permission);
  }, []);

  const requestPermission = async () => {
    if (!('Notification' in window) || !('serviceWorker' in navigator) || !VAPID_PUBLIC_KEY) return;
    const result = await Notification.requestPermission();
    setPermission(result);
    if (result !== 'granted') return;

    try {
      const reg = await navigator.serviceWorker.ready;
      const sub = await reg.pushManager.subscribe({
        userVisibleOnly: true,
        applicationServerKey: urlBase64ToUint8Array(VAPID_PUBLIC_KEY),
      });
      console.log('Push subscription:', JSON.stringify(sub));
    } catch (err) {
      console.warn('Push subscription failed:', err);
    }
  };

  return { permission, requestPermission };
}

export function NotificationPrompt() {
  const { permission, requestPermission } = usePushNotifications();
  const [visible, setVisible]             = useState(false);

  useEffect(() => {
    if (localStorage.getItem(NOTIF_KEY)) return;
    if (permission !== 'default') return;
    const t = setTimeout(() => setVisible(true), 8000);
    return () => clearTimeout(t);
  }, [permission]);

  const dismiss = () => { setVisible(false); localStorage.setItem(NOTIF_KEY, '1'); };

  const enable = async () => {
    await requestPermission();
    dismiss();
  };

  if (!visible || permission !== 'default') return null;

  return (
    <div className="fixed top-4 left-4 right-4 z-50 animate-fadeIn">
      <div className="bg-[#1e2d3d] border border-white/15 rounded-2xl p-4 shadow-2xl max-w-sm mx-auto">
        <div className="flex items-start gap-3">
          <div className="w-10 h-10 rounded-xl bg-sky-400/15 flex items-center justify-center shrink-0">
            <Bell className="w-5 h-5 text-sky-400" />
          </div>
          <div className="flex-1">
            <p className="text-white font-bold text-sm">Weekly Test Reminders</p>
            <p className="text-white/50 text-xs mt-1">Get notified when it's time for your child's weekly test</p>
          </div>
          <button onClick={dismiss} className="text-white/30 hover:text-white/60 transition-colors">
            <X className="w-5 h-5" />
          </button>
        </div>
        <div className="flex gap-2 mt-3">
          <button onClick={dismiss}
            className="flex-1 py-2 bg-white/5 text-white/50 rounded-xl text-sm font-medium hover:bg-white/10 transition-all">
            Not now
          </button>
          <button onClick={enable}
            className="flex-1 py-2 bg-sky-500 text-white rounded-xl text-sm font-bold hover:bg-sky-400 transition-all">
            Enable
          </button>
        </div>
      </div>
    </div>
  );
}
