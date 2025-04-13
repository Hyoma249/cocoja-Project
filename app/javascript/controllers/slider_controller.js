import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["wrapper", "slide", "prevButton", "nextButton", "counter"];
  static values = {
    initialIndex: { type: Number, default: 0 },
  };

  connect() {
    // スライド数の確認
    this.slidesCount = this.slideTargets.length;
    if (this.slidesCount <= 1) {
      this.hideNavigation();
      return;
    }

    // 初期インデックスの設定
    this.initializeCurrentIndex();

    // スライド幅を取得
    this.slideWidth = this.wrapperTarget.offsetWidth;

    // スワイプ関連の変数を初期化
    this.initializeSwipeVariables();

    // 初期スライドを表示
    this.updateSlider(false);

    // イベントリスナーを設定
    this.setupSwipeEvents();

    // UI要素を更新
    this.updateButtonVisibility();
    this.updateCounter();
  }

  initializeCurrentIndex() {
    const urlParams = new URLSearchParams(window.location.search);
    const slideIndex = urlParams.get("slide");

    if (
      slideIndex !== null &&
      !isNaN(parseInt(slideIndex)) &&
      parseInt(slideIndex) < this.slidesCount
    ) {
      this.currentIndex = parseInt(slideIndex) - 1; // 1ベースから0ベースに変換
    } else {
      this.currentIndex = this.initialIndexValue;
    }
  }

  initializeSwipeVariables() {
    this.startX = 0;
    this.currentX = 0;
    this.isDragging = false;
    this.threshold = 50; // スワイプを検知する閾値
  }

  setupSwipeEvents() {
    // タッチイベント (モバイル用)
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

    // マウスイベント (PC用)
    this.wrapperTarget.addEventListener(
      "mousedown",
      this.touchStart.bind(this)
    );
    this.wrapperTarget.addEventListener("mousemove", this.touchMove.bind(this));
    this.wrapperTarget.addEventListener("mouseup", this.touchEnd.bind(this));
    this.wrapperTarget.addEventListener("mouseleave", this.touchEnd.bind(this));
  }

  touchStart(event) {
    this.isDragging = true;
    this.startX = this.getPositionX(event);

    // トランジションを無効化して即座に反応するようにする
    this.wrapperTarget.style.transition = "none";

    // カーソルスタイルを変更
    this.wrapperTarget.style.cursor = "grabbing";
  }

  touchMove(event) {
    if (!this.isDragging) return;

    event.preventDefault(); // スクロールを防止

    this.currentX = this.getPositionX(event);
    const diffX = this.currentX - this.startX;

    // スライダーの位置を更新（移動量を制限）
    const translateX = this.calculateTranslateX(diffX);
    this.wrapperTarget.style.transform = `translateX(${translateX}%)`;
  }

  calculateTranslateX(diffX) {
    // 現在のスライド位置を基準とした移動量を計算
    const currentTranslate = this.currentIndex * -100;
    const movePercent = (diffX / this.slideWidth) * 100;
    let newTranslate = currentTranslate + movePercent;

    // 端のスライドでの移動制限
    if (this.currentIndex === 0 && newTranslate > 0) {
      newTranslate = movePercent * 0.3; // 最初のスライドでの右方向への移動を制限
    } else if (
      this.currentIndex === this.slidesCount - 1 &&
      newTranslate < -100 * (this.slidesCount - 1)
    ) {
      const overflow = newTranslate + 100 * (this.slidesCount - 1);
      newTranslate = -100 * (this.slidesCount - 1) + overflow * 0.3; // 最後のスライドでの左方向への移動を制限
    }

    return newTranslate;
  }

  touchEnd(event) {
    if (!this.isDragging) return;

    this.isDragging = false;
    // 最後のタッチ位置を正しく取得
    this.currentX = this.getPositionX(event);
    const diffX = this.currentX - this.startX;

    // カーソルスタイルを戻す
    this.wrapperTarget.style.cursor = "";

    // スムーズなトランジションを再有効化
    this.wrapperTarget.style.transition =
      "transform 0.3s cubic-bezier(0.25, 0.1, 0.25, 1)";

    // スワイプの方向と距離に基づいてスライドを移動
    this.handleSwipe(diffX);

    // スライダーとUI要素を更新
    this.updateSlider(true);
    this.updateButtonVisibility();
    this.updateCounter();

    // デバッグ用のログ
    console.log({
      startX: this.startX,
      currentX: this.currentX,
      diffX: diffX,
      threshold: this.threshold,
      currentIndex: this.currentIndex,
    });

    // URLを更新
    this.updateURL();
  }

  handleSwipe(diffX) {
    if (Math.abs(diffX) > this.threshold) {
      if (diffX > 0 && this.currentIndex > 0) {
        // 右スワイプ -> 前のスライド
        this.currentIndex--;
      } else if (diffX < 0 && this.currentIndex < this.slidesCount - 1) {
        // 左スワイプ -> 次のスライド
        this.currentIndex++;
      }
    }
  }

  getPositionX(event) {
    // タッチイベントとマウスイベントの両方に対応
    return event.type.includes("mouse")
      ? event.pageX
      : event.touches[0].clientX;
  }

  updateSlider(animate = true) {
    const offset = this.currentIndex * -100;

    // アニメーションの有無を設定
    if (animate) {
      this.wrapperTarget.style.transition =
        "transform 0.3s cubic-bezier(0.25, 0.1, 0.25, 1)";
    } else {
      this.wrapperTarget.style.transition = "none";
    }

    // スライダーの位置を更新
    this.wrapperTarget.style.transform = `translateX(${offset}%)`;

    // アニメーション完了後、トランジションをリセット
    if (animate) {
      setTimeout(() => {
        this.wrapperTarget.style.transition = "none";
      }, 300);
    }
  }

  // ボタンによるナビゲーション
  next() {
    if (this.currentIndex < this.slidesCount - 1) {
      this.currentIndex++;
      this.updateSlider(true);
      this.updateButtonVisibility();
      this.updateCounter();
      this.updateURL();
    }
  }

  prev() {
    if (this.currentIndex > 0) {
      this.currentIndex--;
      this.updateSlider(true);
      this.updateButtonVisibility();
      this.updateCounter();
      this.updateURL();
    }
  }

  // URLの更新機能
  updateURL() {
    if (window.history && window.history.replaceState) {
      const url = new URL(window.location);
      url.searchParams.set("slide", this.currentIndex + 1); // 0ベースから1ベースに変換
      window.history.replaceState({}, "", url);
    }
  }

  hideNavigation() {
    if (this.hasPrevButtonTarget) {
      this.prevButtonTarget.style.display = "none";
    }
    if (this.hasNextButtonTarget) {
      this.nextButtonTarget.style.display = "none";
    }
  }

  updateButtonVisibility() {
    if (this.hasPrevButtonTarget) {
      this.prevButtonTarget.style.display =
        this.currentIndex === 0 ? "none" : "flex";
    }

    if (this.hasNextButtonTarget) {
      this.nextButtonTarget.style.display =
        this.currentIndex === this.slidesCount - 1 ? "none" : "flex";
    }
  }

  updateCounter() {
    if (this.hasCounterTarget) {
      this.counterTarget.textContent = (this.currentIndex + 1).toString();
    }
  }
}
