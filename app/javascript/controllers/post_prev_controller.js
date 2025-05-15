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

    // プレビューエリアのスタイルを設定
    previewArea.className = "mt-4 flex flex-wrap gap-3 items-center";

    for (const file of files) {
      if (file.type.startsWith("image/")) {
        const reader = new FileReader();
        reader.onload = () => {
          const previewContainer = document.createElement("div");
          previewContainer.className =
            "w-24 h-24 relative inline-flex mb-2 transform transition-all duration-300 ease-in-out hover:scale-105";

          const img = document.createElement("img");
          img.src = reader.result;
          img.className = "w-24 h-24 object-cover rounded-lg shadow-sm";

          const deleteButton = document.createElement("button");
          deleteButton.type = "button";
          deleteButton.className =
            "absolute top-0 right-0 bg-red-500 text-white rounded-tr-lg rounded-bl-lg w-6 h-6 flex items-center justify-center shadow-sm transition-colors hover:bg-red-600";
          deleteButton.innerHTML = "×";
          deleteButton.onclick = (e) => {
            e.preventDefault(); // イベントの伝播を防止

            // 削除時のアニメーション
            previewContainer.classList.add("scale-0", "opacity-0");
            setTimeout(() => {
              previewContainer.remove();
              const newFileList = new DataTransfer();
              for (let i = 0; i < input.files.length; i++) {
                if (input.files[i] !== file) {
                  newFileList.items.add(input.files[i]);
                }
              }
              input.files = newFileList.files;
            }, 300);
          };

          previewContainer.appendChild(img);
          previewContainer.appendChild(deleteButton);

          // 出現アニメーション
          previewContainer.style.opacity = "0";
          previewContainer.style.transform = "scale(0.8)";
          previewArea.appendChild(previewContainer);

          // スムーズな表示アニメーション
          setTimeout(() => {
            previewContainer.style.opacity = "1";
            previewContainer.style.transform = "scale(1)";
          }, 10);
        };
        reader.readAsDataURL(file);
      }
    }
  }
}
