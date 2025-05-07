module.exports = {
  content: [
    "./app/views/**/*.html.erb",
    "./app/helpers/**/*.rb",
    "./app/assets/stylesheets/**/*.css",
    "./app/javascript/**/*.js",
  ],
  theme: {
    extend: {
      cursor: {
        grabbing: "grabbing",
      },
    },
  },
  plugins: [
    function ({ addUtilities, addBase }) {
      // ユーティリティクラス定義
      const newUtilities = {
        ".translate-gpu": {
          transform: "translateZ(0)",
          "-webkit-transform": "translateZ(0)",
        },
        ".backface-hidden": {
          "backface-visibility": "hidden",
          "-webkit-backface-visibility": "hidden",
        },
        ".perspective-1000": {
          perspective: "1000px",
          "-webkit-perspective": "1000px",
        },
        ".touch-pan-y": {
          "touch-action": "pan-y",
        },
        ".webkit-touch-scroll": {
          "-webkit-overflow-scrolling": "touch",
        },
      };
      addUtilities(newUtilities);

      // 基本要素にスタイルを適用
      addBase({
        html: {
          "-webkit-overflow-scrolling": "touch",
        },
        body: {
          "-webkit-overflow-scrolling": "touch",
          "overscroll-behavior-y": "none",
        },
      });
    },
  ],
};
