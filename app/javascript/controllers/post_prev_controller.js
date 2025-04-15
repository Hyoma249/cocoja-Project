import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["preview"];

  connect() {
    console.log("PostPrevController が接続されました.");
  }

  displayPreview(event) {
    const input = event.target;
    const files = input.files;
    const previewArea = this.previewTarget;

    for (const file of files) {
      if (file.type.startsWith("image/")) {
        const reader = new FileReader();
        reader.onload = () => {
          const previewContainer = document.createElement("div");
          previewContainer.className = "w-24 h-24 relative";

          const img = document.createElement("img");
          img.src = reader.result;
          img.className = "w-24 h-24 object-cover rounded-lg";

          const deleteButton = document.createElement("button");
          deleteButton.type = "button";
          deleteButton.className =
            "absolute top-0 right-0 bg-red-500 text-white rounded-tr-lg w-6 h-6 flex items-center justify-center shadow-sm";
          deleteButton.innerHTML = "×";
          deleteButton.onclick = () => {
            previewContainer.remove();
            const newFileList = new DataTransfer();
            for (let i = 0; i < input.files.length; i++) {
              if (input.files[i] !== file) {
                newFileList.items.add(input.files[i]);
              }
            }
            input.files = newFileList.files;
          };

          previewContainer.appendChild(img);
          previewContainer.appendChild(deleteButton);
          previewArea.appendChild(previewContainer);
        };
        reader.readAsDataURL(file);
      }
    }
  }
}
