import { Controller } from "@hotwired/stimulus";
import Swiper from "swiper";
import { Navigation, Pagination } from "swiper/modules";

export default class extends Controller {
  static targets = ["container"];

  connect() {
    if (
      document.readyState === "complete" ||
      document.readyState === "interactive"
    ) {
      setTimeout(() => this.initSwiper(), 10);
    } else {
      window.addEventListener("load", () => this.initSwiper());
    }
  }

  initSwiper() {
    try {
      const container = this.containerTarget;
      const hasMultipleSlides =
        container.querySelectorAll(".swiper-slide").length > 1;

      this.applyEmergencySwiperStyles(container);

      this.swiper = new Swiper(container, {
        modules: [Navigation, Pagination],
        slidesPerView: 1,
        direction: "horizontal",
        preloadImages: true,
        updateOnWindowResize: true,

        pagination: hasMultipleSlides
          ? {
              el: ".swiper-pagination",
              clickable: true,
            }
          : false,

        on: {
          init: function () {
            container.classList.add("swiper-initialized");
            console.log("Swiper initialized successfully");
          },
          slideChange: () => {
            if (hasMultipleSlides && this.swiper) {
              const indexElement = container.querySelector(".swiper-index");
              if (indexElement) {
                indexElement.textContent = this.swiper.activeIndex + 1;
              }
            }
          },
        },
      });
    } catch (error) {
      console.error("Swiper initialization error:", error);
    }
  }

  applyEmergencySwiperStyles(container) {
    Object.assign(container.style, {
      position: "relative",
      width: "100%",
      height: "100%",
      overflow: "visible",
      zIndex: "1",
      marginLeft: "auto",
      marginRight: "auto",
    });

    const wrapper = container.querySelector(".swiper-wrapper");
    if (wrapper) {
      Object.assign(wrapper.style, {
        position: "relative",
        width: "100%",
        height: "100%",
        zIndex: "1",
        display: "flex",
        boxSizing: "content-box",
        transitionProperty: "transform",
        overflow: "visible",
      });
    }

    const slides = container.querySelectorAll(".swiper-slide");
    slides.forEach((slide) => {
      Object.assign(slide.style, {
        flexShrink: "0",
        width: "100%",
        height: "100%",
        position: "relative",
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
      });
    });

    const pagination = container.querySelector(".swiper-pagination");
    if (pagination) {
      Object.assign(pagination.style, {
        position: "absolute",
        left: "0",
        right: "0",
        bottom: "-24px",
        display: "flex",
        justifyContent: "center",
        alignItems: "center",
        zIndex: "10",
      });
    }
  }

  disconnect() {
    if (this.swiper && typeof this.swiper.destroy === "function") {
      this.swiper.destroy(true, true);
      this.swiper = null;
    }
  }
}
