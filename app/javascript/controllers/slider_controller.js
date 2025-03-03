import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["wrapper", "slide", "prevButton", "nextButton"];

  initialize() {
    this.currentIndex = 0;
    // 無効なボタンを非表示にする ⬇️
    this.updateButtonVisibility();
  }

  next() {
    this.currentIndex = Math.min(
      this.currentIndex + 1,
      this.slideTargets.length - 1
    );
    this.updateSlider();
    this.updateButtonVisibility();
  }

  prev() {
    this.currentIndex = Math.max(this.currentIndex - 1, 0);
    this.updateSlider();
    this.updateButtonVisibility();
  }

  updateSlider() {
    const offset = this.currentIndex * -100;
    this.wrapperTarget.style.transform = `translateX(${offset}%)`;
  }

  updateButtonVisibility() {
    if (this.prevButtonTarget) {
      this.prevButtonTarget.style.display = this.currentIndex === 0 ? "none" : "block";
    }

    if (this.nextButtonTarget) {
      this.nextButtonTarget.style.display = this.currentIndex === this.slideTargets.length - 1 ? "none" : "block";
    }
  }
}
