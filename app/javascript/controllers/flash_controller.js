import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  initialize() {
    this.hide = this.hide.bind(this);
  }

  connect() {
    setTimeout(this.hide, 5000);
  }

  hide() {
    this.element.classList.add("opacity-0", "transform", "translate-y-[-1rem]");
    setTimeout(() => {
      this.element.remove();
    }, 150);
  }
}
