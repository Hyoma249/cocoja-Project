import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container"];

  connect() {
    this.checkHashAndScroll();
    window.addEventListener("hashchange", this.checkHashAndScroll.bind(this));
  }

  disconnect() {
    window.removeEventListener(
      "hashchange",
      this.checkHashAndScroll.bind(this)
    );
  }

  checkHashAndScroll() {
    if (!window.location.hash) return;

    const hash = window.location.hash;
    const targetElement = document.querySelector(hash);

    if (targetElement) {
      setTimeout(() => {
        targetElement.scrollIntoView({ behavior: "smooth", block: "start" });

        targetElement.classList.add("highlight-post");
        setTimeout(() => {
          targetElement.classList.remove("highlight-post");
        }, 2000);
      }, 500);
    }
  }
}
