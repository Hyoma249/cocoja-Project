import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["wrapper", "slide", "counter", "prevButton", "nextButton"];

  // 初期化
  connect() {
    if (!this.hasWrapperTarget || !this.hasSlideTarget) return;

    this.currentIndex = 0;
    this.slideCount = this.slideTargets.length;

    // モバイルでのイベントハンドリング最適化
    this.isDragging = false;
    this.startX = 0;
    this.startTranslate = 0;
    this.currentTranslate = 0;
    this.prevTranslate = 0;
    this.animationID = null;

    // タッチイベントの最適化（passive: trueでスクロールパフォーマンス向上）
    this.wrapperTarget.addEventListener(
      "touchstart",
      this.touchStart.bind(this),
      { passive: true }
    );
    this.wrapperTarget.addEventListener(
      "touchmove",
      this.touchMove.bind(this),
      { passive: false }
    );
    this.wrapperTarget.addEventListener("touchend", this.touchEnd.bind(this), {
      passive: true,
    });

    // 適切なナビゲーションボタン表示の設定
    this.updateButtonVisibility();
  }

  disconnect() {
    // イベントリスナーを適切にクリーンアップ
    if (this.hasWrapperTarget) {
      this.wrapperTarget.removeEventListener(
        "touchstart",
        this.touchStart.bind(this)
      );
      this.wrapperTarget.removeEventListener(
        "touchmove",
        this.touchMove.bind(this)
      );
      this.wrapperTarget.removeEventListener(
        "touchend",
        this.touchEnd.bind(this)
      );
    }
    cancelAnimationFrame(this.animationID);
  }

  // タッチイベントハンドラ - パフォーマンス最適化版
  touchStart(e) {
    // すでにアニメーション中なら中断
    cancelAnimationFrame(this.animationID);

    this.isDragging = true;
    this.startX = e.touches[0].clientX;
    this.startTranslate = this.currentTranslate;

    // 連続したアニメーションフレームの代わりに静的な値を使用
    const transform = window.getComputedStyle(this.wrapperTarget).transform;
    if (transform && transform !== "none") {
      this.startTranslate = parseInt(transform.split(",")[4].trim(), 10) || 0;
    }
  }

  touchMove(e) {
    if (!this.isDragging) return;

    // スクロールを妨げないよう、水平方向の移動が大きい場合のみイベントをキャンセル
    const currentX = e.touches[0].clientX;
    const diffX = currentX - this.startX;
    if (Math.abs(diffX) > 5) {
      e.preventDefault();
    }

    // より少ない計算で位置を決定
    const currentPosition = currentX - this.startX + this.startTranslate;

    // 境界を超えた場合に抵抗を増やす
    const maxTranslate = 0;
    const minTranslate =
      -(this.slideCount - 1) * this.slideTargets[0].offsetWidth;

    if (currentPosition > maxTranslate || currentPosition < minTranslate) {
      // 境界を超えた場合、移動量を半分に
      this.currentTranslate =
        this.startTranslate + (currentX - this.startX) * 0.5;
    } else {
      this.currentTranslate = this.startTranslate + (currentX - this.startX);
    }

    // アニメーションフレームの代わりに直接スタイルを設定（スライド中のみ）
    this.wrapperTarget.style.transform = `translateX(${this.currentTranslate}px)`;
  }

  touchEnd() {
    this.isDragging = false;

    // 移動量が少ない場合はリバウンド、多い場合はスライド切り替え
    const THRESHOLD = 100;
    const slideWidth = this.slideTargets[0].offsetWidth;
    const movedBy = this.currentTranslate - this.startTranslate;

    if (Math.abs(movedBy) > THRESHOLD) {
      if (movedBy > 0 && this.currentIndex > 0) {
        this.currentIndex -= 1;
      } else if (movedBy < 0 && this.currentIndex < this.slideCount - 1) {
        this.currentIndex += 1;
      }
    }

    // スナップ位置に移動
    this.currentTranslate = -slideWidth * this.currentIndex;
    this.wrapperTarget.style.transition = "transform 300ms ease-out";
    this.wrapperTarget.style.transform = `translateX(${this.currentTranslate}px)`;

    // トランジション終了後にリセット
    setTimeout(() => {
      this.wrapperTarget.style.transition = "";
      this.updateCounter();
      this.updateButtonVisibility();
    }, 300);
  }

  // 次へボタン
  next() {
    if (this.currentIndex < this.slideCount - 1) {
      this.currentIndex++;
      this.showSlide(this.currentIndex);
    }
  }

  // 前へボタン
  prev() {
    if (this.currentIndex > 0) {
      this.currentIndex--;
      this.showSlide(this.currentIndex);
    }
  }

  // スライド表示
  showSlide(index) {
    if (!this.hasWrapperTarget || this.slideTargets.length === 0) return;

    const slideWidth = this.slideTargets[0].offsetWidth;
    this.wrapperTarget.style.transition = "transform 300ms ease-out";
    this.wrapperTarget.style.transform = `translateX(${-slideWidth * index}px)`;
    this.currentTranslate = -slideWidth * index;

    setTimeout(() => {
      this.wrapperTarget.style.transition = "";
      this.updateCounter();
      this.updateButtonVisibility();
    }, 300);
  }

  // カウンター更新
  updateCounter() {
    if (this.hasCounterTarget) {
      this.counterTarget.textContent = this.currentIndex + 1;
    }
  }

  // ナビゲーションボタン表示更新
  updateButtonVisibility() {
    if (this.hasPrevButtonTarget) {
      this.prevButtonTarget.style.opacity =
        this.currentIndex === 0 ? "0.3" : "1";
      this.prevButtonTarget.style.pointerEvents =
        this.currentIndex === 0 ? "none" : "auto";
    }

    if (this.hasNextButtonTarget) {
      this.nextButtonTarget.style.opacity =
        this.currentIndex === this.slideCount - 1 ? "0.3" : "1";
      this.nextButtonTarget.style.pointerEvents =
        this.currentIndex === this.slideCount - 1 ? "none" : "auto";
    }
  }
}
