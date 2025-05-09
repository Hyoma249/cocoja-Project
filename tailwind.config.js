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
      colors: {
        // テーマカラーの定義
        "swiper-bullet": "#2563eb", // カラーテーマのみ定義
        "swiper-bullet-active": "#2563eb",
      },
      zIndex: {
        60: 60,
        70: 70,
        80: 80,
      },
    },
  },
  plugins: [
    function ({ addUtilities }) {
      // Swiperコンポーネント関連のスタイルはapplication.tailwind.cssに統合するため、
      // ここではパフォーマンス最適化用のユーティリティのみ定義
      addUtilities({
        ".translate-gpu": {
          transform: "translateZ(0)",
          "-webkit-transform": "translateZ(0)",
        },
        ".backface-hidden": {
          "backface-visibility": "hidden",
          "-webkit-backface-visibility": "hidden",
        },
        ".touch-pan-y": {
          "touch-action": "pan-y",
        },
      });
    },
  ],
};
