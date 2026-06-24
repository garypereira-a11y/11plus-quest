import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { ArrowLeft, Trophy, Medal, Star } from 'lucide-react';

interface Props {
  onBack: () => void;
}

interface LeaderEntry {
  id: string;
  name: string;
  avatar: string;
  xp: number;
  level: number;
}

export function LeaderboardPage({ onBack }: Props) {
  const [entries, setEntries] = useState<LeaderEntry[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    supabase
      .from('children')
      .select('id,first_name,avatar,xp_points,level')
      .order('xp_points', { ascending: false })
      .limit(20)
      .then(({ data }) => {
        setEntries(
          (data ?? []).map(r => ({
            id: r.id,
            name: r.first_name,
            avatar: r.avatar,
            xp: r.xp_points,
            level: r.level,
          }))
        );
        setLoading(false);
      });
  }, []);

  const medal = (rank: number) => {
    if (rank === 0) return <Trophy className="w-5 h-5 text-yellow-400" />;
    if (rank === 1) return <Medal className="w-5 h-5 text-slate-400" />;
    if (rank === 2) return <Medal className="w-5 h-5 text-amber-600" />;
    return <span className="text-white/30 font-bold text-sm w-5 text-center">{rank + 1}</span>;
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-[#0f172a] via-[#1e2d3d] to-[#0f172a] pb-8">
      <div className="px-4 pt-6 pb-4">
        <div className="max-w-lg mx-auto flex items-center gap-3 mb-6">
          <button onClick={onBack}
            className="w-10 h-10 rounded-xl bg-white/5 hover:bg-white/10 flex items-center justify-center transition-all">
            <ArrowLeft className="w-5 h-5 text-white/60" />
          </button>
          <div>
            <p className="text-white/40 text-xs font-semibold uppercase tracking-wide">Rankings</p>
            <h1 className="text-white text-xl font-bold">Leaderboard</h1>
          </div>
        </div>
      </div>

      <div className="px-4">
        <div className="max-w-lg mx-auto">
          {loading ? (
            <div className="space-y-3">
              {Array.from({ length: 5 }).map((_, i) => (
                <div key={i} className="h-16 bg-white/5 rounded-2xl animate-pulse" />
              ))}
            </div>
          ) : entries.length === 0 ? (
            <div className="text-center py-16 text-white/30">No rankings yet</div>
          ) : (
            <div className="space-y-2">
              {entries.map((e, rank) => (
                <div key={e.id}
                  className={`flex items-center gap-4 px-4 py-3.5 rounded-2xl border transition-all ${
                    rank === 0 ? 'bg-yellow-500/10 border-yellow-500/20' :
                    rank === 1 ? 'bg-slate-500/10 border-slate-500/20' :
                    rank === 2 ? 'bg-amber-800/10 border-amber-800/20' :
                    'bg-white/5 border-white/8'
                  }`}>
                  <div className="w-6 flex items-center justify-center shrink-0">{medal(rank)}</div>
                  <span className="text-2xl shrink-0">{e.avatar}</span>
                  <div className="flex-1 min-w-0">
                    <p className="text-white font-bold truncate">{e.name}</p>
                    <p className="text-white/40 text-xs">Level {e.level}</p>
                  </div>
                  <div className="flex items-center gap-1 text-amber-400">
                    <Star className="w-4 h-4" />
                    <span className="font-bold text-sm">{e.xp.toLocaleString()}</span>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
