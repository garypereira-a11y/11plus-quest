import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { registerSW } from 'virtual:pwa-register';
import './index.css';
import App from './App.tsx';

const updateSW = registerSW({
  onNeedRefresh() {
    if (confirm('New version available. Reload to update?')) updateSW(true);
  },
  onOfflineReady() {
    console.log('11+ Quest is ready to work offline');
  },
});

createRoot(document.getElementById('root')!).render(
  <StrictMode><App /></StrictMode>,
);
