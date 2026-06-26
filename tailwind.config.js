/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      opacity: { '3': '0.03', '8': '0.08' },
      colors: {
        // Renamed in spirit to a coastal palette, but token names (twilight/quest/
        // realm/parchment) are kept unchanged so every existing component that
        // references them updates automatically without further edits.
        twilight: {
          DEFAULT: '#0E2A3D',   // deep sea blue (was deep violet)
          deep:     '#081A26',  // near-black navy
          surface:  '#143C53',  // lighter steel-blue surface
          raised:   '#1B4D6B',  // raised panel blue
        },
        quest: {
          gold:    '#D9A463',   // sand brown (was gold)
          goldDim: '#B5804A',   // darker sand/tan
        },
        realm: {
          emerald: '#4FB8A3',   // sea-foam teal (kept close to original for success states)
          coral:   '#E0764B',   // warm coral/terracotta (kept for streak/energy)
        },
        parchment: {
          DEFAULT: '#F2E8D8',   // sand/cream (was parchment cream — kept nearly identical)
          dim:      '#D6C7AC',  // muted sand
        },
      },
      fontFamily: {
        display: ['"Baloo 2"', 'cursive'],
        body:    ['Nunito', 'sans-serif'],
        ledger:  ['"JetBrains Mono"', 'monospace'],
      },
      borderRadius: {
        scroll: '1.25rem 0.5rem 1.25rem 0.5rem',
      },
      boxShadow: {
        glow:     '0 0 24px 0 rgba(217, 164, 99, 0.35)',
        'glow-emerald': '0 0 24px 0 rgba(79, 184, 163, 0.35)',
        'glow-coral':   '0 0 24px 0 rgba(224, 118, 75, 0.35)',
      },
    },
  },
  plugins: [],
};
