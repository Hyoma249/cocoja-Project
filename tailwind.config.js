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
        "swiper-bullet": "#2563eb",
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
