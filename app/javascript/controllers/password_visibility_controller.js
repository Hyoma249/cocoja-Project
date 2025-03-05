import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["field", "showIcon", "hideIcon"];

  toggle(event) {
    // アニメーション効果の追加
    const button = event.currentTarget;
    button.classList.add("transform", "transition-transform");
    button.style.transform = "scale(0.95)";
    setTimeout(() => (button.style.transform = "scale(1)"), 100);

    // パスワードフィールドの表示/非表示切り替え
    if (this.fieldTarget.type === "password") {
      this.showPassword();
    } else {
      this.hidePassword();
    }
  }

  showPassword() {
    this.fieldTarget.type = "text";
    this.showIconTarget.classList.remove("hidden");
    this.hideIconTarget.classList.add("hidden");
    this.element.setAttribute("aria-label", "パスワードを隠す");
  }

  hidePassword() {
    this.fieldTarget.type = "password";
    this.showIconTarget.classList.add("hidden");
    this.hideIconTarget.classList.remove("hidden");
    this.element.setAttribute("aria-label", "パスワードを表示");
  }
}
