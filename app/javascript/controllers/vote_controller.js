import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["pointButtons", "submitButton"]

  connect() {
    console.log("Vote controller connected")

    // 初期状態ではボタンを無効化
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = true
    }
  }

  selectPoint(event) {
    // ボタンを有効化
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = false
    }

    // 選択したポイントをハイライト表示
    if (this.hasPointButtonsTarget) {
      const labels = this.pointButtonsTarget.querySelectorAll("label")
      labels.forEach(label => {
        label.classList.remove("ring-2", "ring-indigo-300")
      })

      const selectedInput = event.target
      const selectedLabel = selectedInput.nextElementSibling

      if (selectedLabel) {
        selectedLabel.classList.add("ring-2", "ring-indigo-300")
      }
    }
  }
}