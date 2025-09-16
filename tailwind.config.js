/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        'kaki': {
          50: '#f7f8f3',
          100: '#eef1e3',
          200: '#dde3c8',
          300: '#c5d0a4',
          400: '#aab97f',
          500: '#8fa45e',
          600: '#6f8048',
          700: '#56633a',
          800: '#465032',
          900: '#3c442d',
        },
        'dark-bg': '#0a0a0a',
        'dark-surface': '#1a1a1a',
      },
      fontFamily: {
        sans: ['Inter', 'sans-serif'],
      },
    },
  },
  plugins: [],
}
