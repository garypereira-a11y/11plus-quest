import { useState } from 'react';
import { useAuth } from '../context/AuthContext';
import { Eye, EyeOff, User, Users, GraduationCap, Loader } from 'lucide-react';

type Mode = 'signIn' | 'signUp';

interface Props {
  onSuccess: () => void;
}

export function AuthPage({ onSuccess }: Props) {
  const { signIn, signUp } = useAuth();
  const [mode, setMode]       = useState<Mode>('signIn');
  const [isParent, setIsParent] = useState(true);
  const [name, setName]       = useState('');
  const [email, setEmail]     = useState('');
  const [password, setPassword] = useState('');
  const [showPw, setShowPw]   = useState(false);
  const [error, setError]     = useState('');
  const [loading, setLoading] = useState(false);

  const submit = async () => {
    setError('');
    if (mode === 'signUp' && name.trim().length < 2) { setError('Please enter your name.'); return; }
    if (!email.includes('@')) { setError('Please enter a valid email.'); return; }
    if (password.length < 6)  { setError('Password must be at least 6 characters.'); return; }

    setLoading(true);
    try {
      if (mode === 'signIn') {
        const { error: err } = await signIn(email, password);
        if (err) { setError(err); return; }
      } else {
        const { error: err } = await signUp(email, password, name.trim(), isParent);
        if (err) { setError(err); return; }
      }
      onSuccess();
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-twilight-deep via-twilight to-twilight-deep flex flex-col items-center justify-center px-4">
      <div className="w-full max-w-sm">
        {/* Logo */}
        <div className="text-center mb-8">
          <div className="text-6xl mb-3 animate-shimmer">🏰</div>
          <h1 className="text-parchment text-3xl font-display font-extrabold tracking-wide">11+ Quest</h1>
          <p className="text-parchment-dim text-sm mt-1">Begin your child's realm of learning</p>
        </div>

        {/* Tab switcher */}
        <div className="flex bg-white/5 rounded-2xl p-1 mb-6">
          {(['signIn', 'signUp'] as Mode[]).map(m => (
            <button key={m} onClick={() => { setMode(m); setError(''); }}
              className={`flex-1 py-2.5 rounded-xl text-sm font-bold transition-all font-display ${
                mode === m ? 'bg-quest-gold text-twilight-deep shadow-sm' : 'text-parchment-dim hover:text-parchment'
              }`}>
              {m === 'signIn' ? 'Sign In' : 'Sign Up'}
            </button>
          ))}
        </div>

        {/* Role selector (sign-up only) */}
        {mode === 'signUp' && (
          <div className="grid grid-cols-2 gap-3 mb-5">
            <button onClick={() => setIsParent(true)}
              className={`flex flex-col items-center gap-2 py-4 rounded-2xl border-2 transition-all ${isParent ? 'border-quest-gold bg-quest-gold/10' : 'border-white/10 bg-white/5 hover:border-white/25'}`}>
              <Users className={`w-6 h-6 ${isParent ? 'text-quest-gold' : 'text-parchment-dim/60'}`} />
              <span className={`text-xs font-bold font-display ${isParent ? 'text-quest-gold' : 'text-parchment-dim'}`}>Parent</span>
              <span className="text-parchment-dim/50 text-[10px] text-center leading-tight">Manage children's profiles</span>
            </button>
            <button onClick={() => setIsParent(false)}
              className={`flex flex-col items-center gap-2 py-4 rounded-2xl border-2 transition-all ${!isParent ? 'border-quest-gold bg-quest-gold/10' : 'border-white/10 bg-white/5 hover:border-white/25'}`}>
              <GraduationCap className={`w-6 h-6 ${!isParent ? 'text-quest-gold' : 'text-parchment-dim/60'}`} />
              <span className={`text-xs font-bold font-display ${!isParent ? 'text-quest-gold' : 'text-parchment-dim'}`}>Student</span>
              <span className="text-parchment-dim/50 text-[10px] text-center leading-tight">Direct learning access</span>
            </button>
          </div>
        )}

        {/* Fields */}
        <div className="space-y-3 mb-4">
          {mode === 'signUp' && (
            <div className="relative">
              <User className="absolute left-4 top-1/2 -translate-y-1/2 w-5 h-5 text-parchment-dim/40" />
              <input type="text" value={name} onChange={e => setName(e.target.value)}
                placeholder="Your name" autoComplete="name"
                className="w-full pl-12 pr-4 py-4 rounded-2xl bg-white/5 border-2 border-white/10 focus:border-quest-gold focus:outline-none text-parchment placeholder-parchment-dim/30 font-medium" />
            </div>
          )}
          <input type="email" value={email} onChange={e => setEmail(e.target.value)}
            placeholder="Email address" autoComplete="email"
            className="w-full px-4 py-4 rounded-2xl bg-white/5 border-2 border-white/10 focus:border-quest-gold focus:outline-none text-parchment placeholder-parchment-dim/30 font-medium" />
          <div className="relative">
            <input type={showPw ? 'text' : 'password'} value={password} onChange={e => setPassword(e.target.value)}
              placeholder="Password" autoComplete={mode === 'signIn' ? 'current-password' : 'new-password'}
              onKeyDown={e => e.key === 'Enter' && submit()}
              className="w-full px-4 pr-12 py-4 rounded-2xl bg-white/5 border-2 border-white/10 focus:border-quest-gold focus:outline-none text-parchment placeholder-parchment-dim/30 font-medium" />
            <button type="button" onClick={() => setShowPw(s => !s)}
              className="absolute right-4 top-1/2 -translate-y-1/2 text-parchment-dim/50 hover:text-parchment-dim transition-colors">
              {showPw ? <EyeOff className="w-5 h-5" /> : <Eye className="w-5 h-5" />}
            </button>
          </div>
        </div>

        {error && (
          <div className="bg-realm-coral/15 border border-realm-coral/30 rounded-xl px-4 py-3 mb-4">
            <p className="text-realm-coral text-sm">{error}</p>
          </div>
        )}

        <button onClick={submit} disabled={loading}
          className="w-full flex items-center justify-center gap-2 py-4 bg-gradient-to-r from-quest-goldDim to-quest-gold text-twilight-deep rounded-2xl font-bold font-display text-lg hover:shadow-glow transition-all active:scale-95 disabled:opacity-50 shadow-lg">
          {loading ? <Loader className="w-5 h-5 animate-spin" /> : mode === 'signIn' ? 'Sign In' : 'Create Account'}
        </button>

        <p className="text-center text-parchment-dim/50 text-xs mt-6">
          By continuing you agree to our{' '}
          <button className="text-parchment-dim underline hover:text-parchment transition-colors">Privacy Policy</button>
        </p>
      </div>
    </div>
  );
}
