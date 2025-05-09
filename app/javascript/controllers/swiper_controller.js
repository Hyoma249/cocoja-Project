import { Controller } from "@hotwired/stimulus";
import Swiper from "swiper";
import { Pagination } from "swiper/modules";
import "swiper/css";
import "swiper/css/pagination";

// Swiperのモジュールを明示的に登録
Swiper.use([Pagination]);

export default class extends Controller {
  static targets = ["container"];

  connect() {
    if (document.readyState === "complete") {
      this.initSwiper();
    } else {
      window.addEventListener("load", () => this.initSwiper());
    }
  }

  initSwiper() {
    const container = this.containerTarget;
    const hasMultipleSlides =
      container.querySelectorAll(".swiper-slide").length > 1;

    // Swiperインスタンスをシンプルに初期化
    this.swiper = new Swiper(container, {
      slidesPerView: 1,
      direction: "horizontal",
      preloadImages: true,
      updateOnWindowResize: true,

      // ページネーション設定
      pagination: hasMultipleSlides
        ? {
            el: ".swiper-pagination",
            clickable: true,
          }
        : false,

      on: {
        slideChange: () => {
          // スライド変更時のインデックス表示を更新
          if (hasMultipleSlides && this.swiper) {
            const indexElement = container.querySelector(".swiper-index");
            if (indexElement) {
              indexElement.textContent = this.swiper.activeIndex + 1;
            }
          }
        },
      },
    });
  }

  disconnect() {
    if (this.swiper && this.swiper.destroy) {
      this.swiper.destroy(true, true);
    }
  }
}
