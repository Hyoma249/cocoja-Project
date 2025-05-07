import { Controller } from "@hotwired/stimulus";

// 投稿へのスクロール機能を管理するコントローラー
export default class extends Controller {
  static targets = ["container"];

  connect() {
    // ページ読み込み後、ハッシュフラグメントをチェック
    this.checkHashAndScroll();

    // ハッシュの変化を監視
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
      // 少し遅延させてスクロールを実行（DOMの読み込み完了を待つため）
      setTimeout(() => {
        targetElement.scrollIntoView({ behavior: "smooth", block: "start" });

        // 視覚的に目立たせる
        targetElement.classList.add("highlight-post");
        setTimeout(() => {
          targetElement.classList.remove("highlight-post");
        }, 2000);
      }, 500);
    }
  }
}
