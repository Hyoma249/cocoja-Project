import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "submitButton",
    "pointDisplay",
    "quickSelect",
    "pointInput",
  ];

  connect() {
    this.submitButtonTarget.disabled = true;
    this.pointDisplayTarget.textContent = "選択してください";
  }

  selectPoint(event) {
    const points = event.currentTarget.dataset.pointValue;
    this.pointInputTarget.value = points;
    this.pointDisplayTarget.textContent = `${points} ポイント`;

    // ボタンの選択状態を更新
    this.quickSelectTargets.forEach((btn) => {
      btn.setAttribute("aria-selected", btn.dataset.pointValue === points);
    });

    this.submitButtonTarget.disabled = false;
  }
}
