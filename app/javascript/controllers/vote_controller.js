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
  }

  selectPoint(event) {
    const selectedPoint = event.currentTarget.dataset.pointValue;

    this.quickSelectTargets.forEach((button) => {
      button.setAttribute("aria-selected", "false");
    });

    event.currentTarget.setAttribute("aria-selected", "true");

    this.pointInputTarget.value = selectedPoint;

    this.pointDisplayTarget.textContent = `${selectedPoint}ポイント`;

    this.submitButtonTarget.disabled = false;
  }
}
