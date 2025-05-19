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
    const existingPreviews = previewArea.querySelectorAll("div").length;

    if (existingPreviews + files.length > 5) {
      alert("画像は最大5枚までアップロードできます");
      input.value = "";
      return;
    }

    previewArea.className = "mt-4 flex flex-wrap gap-3 items-center";

    const fragment = document.createDocumentFragment();
    const previewPromises = [];

    for (const file of files) {
      if (file.type.startsWith("image/")) {
        if (file.size > 5 * 1024 * 1024) {
          continue;
        }

        const previewPromise = new Promise((resolve) => {
          const reader = new FileReader();
          const previewContainer = document.createElement("div");
          previewContainer.className =
            "w-24 h-24 relative inline-flex mb-2 transform transition-all duration-300 ease-in-out hover:scale-105";

          previewContainer.innerHTML =
            '<div class="w-24 h-24 flex items-center justify-center bg-gray-100 rounded-lg"><span class="animate-pulse">読込中...</span></div>';
          fragment.appendChild(previewContainer);

          reader.onload = () => {
            const img = document.createElement("img");
            img.src = reader.result;
            img.className = "w-24 h-24 object-cover rounded-lg shadow-sm";

            const deleteButton = document.createElement("button");
            deleteButton.type = "button";
            deleteButton.className =
              "absolute top-0 right-0 bg-red-500 text-white rounded-tr-lg rounded-bl-lg w-6 h-6 flex items-center justify-center shadow-sm transition-colors hover:bg-red-600";
            deleteButton.innerHTML = "×";
            deleteButton.onclick = (e) => {
              e.preventDefault();
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

            while (previewContainer.firstChild) {
              previewContainer.removeChild(previewContainer.firstChild);
            }

            previewContainer.appendChild(img);
            previewContainer.appendChild(deleteButton);

            resolve(previewContainer);
          };

          reader.readAsDataURL(file);
        });

        previewPromises.push(previewPromise);
      }
    }

    previewArea.appendChild(fragment);

    Promise.all(previewPromises).then((containers) => {
      setTimeout(() => {
        containers.forEach((container) => {
          container.style.opacity = "1";
          container.style.transform = "scale(1)";
        });
      }, 50);
    });
  }
}
