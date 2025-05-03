import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["frame", "loading"];
  static values = {
    cacheKey: String,
  };

  connect() {
    // キャッシュがあれば読み込み
    const cachedContent = sessionStorage.getItem(this.cacheKeyValue);

    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.remove("hidden");
    }

    if (cachedContent) {
      // キャッシュがあれば即時表示
      this.frameTarget.innerHTML = cachedContent;
      if (this.hasLoadingTarget) {
        this.loadingTarget.classList.add("hidden");
      }
    }

    // frameのロード完了時にキャッシュする
    this.frameTarget.addEventListener(
      "turbo:frame-load",
      this.cacheContent.bind(this)
    );
  }

  disconnect() {
    this.frameTarget.removeEventListener(
      "turbo:frame-load",
      this.cacheContent.bind(this)
    );
  }

  cacheContent() {
    if (this.frameTarget.innerHTML) {
      sessionStorage.setItem(this.cacheKeyValue, this.frameTarget.innerHTML);
    }

    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.add("hidden");
    }
  }
}
