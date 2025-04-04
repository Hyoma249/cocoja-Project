import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "preview"];

  connect() {
    console.log("PostPrevController が接続されました.");
  }

  displayPreview(event) {
    this.previewTarget.innerHTML = "";

    const files = event.target.files;
    if (files.length > 0) {
      Array.from(files).forEach((file) => {
        const reader = new FileReader();

        reader.onload = (e) => {
          const img = document.createElement("img");
          img.src = e.target.result;
          img.classList.add("w-24", "h-24", "object-cover", "rounded-md", "shadow-md");
          this.previewTarget.appendChild(img);
        };

        reader.readAsDataURL(file);
      });
    }
  }
}