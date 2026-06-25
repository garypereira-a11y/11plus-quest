/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      opacity: { '3': '0.03', '8': '0.08' },
      colors: {
        twilight: {
          DEFAULT: '#1B1033',
          deep:     '#120A22',
          surface:  '#2D1B4E',
          raised:   '#3A2563',
        },
        quest: {
          gold:    '#F4C95D',
          goldDim: '#C9A246',
        },
        realm: {
          emerald: '#5FBFA3',
          coral:   '#E0654B',
        },
        parchment: {
          DEFAULT: '#F4E9D8',
          dim:      '#D8CBB3',
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
        glow:     '0 0 24px 0 rgba(244, 201, 93, 0.35)',
        'glow-emerald': '0 0 24px 0 rgba(95, 191, 163, 0.35)',
        'glow-coral':   '0 0 24px 0 rgba(224, 101, 75, 0.35)',
      },
    },
  },
  plugins: [],
};
