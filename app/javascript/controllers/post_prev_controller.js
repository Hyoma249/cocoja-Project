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

    // すでに表示されているプレビュー数をカウント
    const existingPreviews = previewArea.querySelectorAll("div").length;

    // 最大表示数（5枚）を超える場合は早期リターン
    if (existingPreviews + files.length > 5) {
      alert("画像は最大5枚までアップロードできます");
      // 選択をリセット
      input.value = "";
      return;
    }

    // プレビューエリアのスタイルを設定
    previewArea.className = "mt-4 flex flex-wrap gap-3 items-center";

    // 画像処理を最適化するため、一度にDOMに追加する代わりにフラグメントを使用
    const fragment = document.createDocumentFragment();

    // 一括処理のためにプロミスの配列を作成
    const previewPromises = [];

    for (const file of files) {
      if (file.type.startsWith("image/")) {
        // 画像サイズチェック（5MB以下に制限）
        if (file.size > 5 * 1024 * 1024) {
          continue; // 5MB以上の画像はスキップ
        }

        const previewPromise = new Promise((resolve) => {
          const reader = new FileReader();
          const previewContainer = document.createElement("div");
          previewContainer.className =
            "w-24 h-24 relative inline-flex mb-2 transform transition-all duration-300 ease-in-out hover:scale-105";

          // 読み込み中表示
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

            // プレビュー表示中の要素を全て削除
            while (previewContainer.firstChild) {
              previewContainer.removeChild(previewContainer.firstChild);
            }

            previewContainer.appendChild(img);
            previewContainer.appendChild(deleteButton);

            // アニメーション適用（一括処理で効率化）
            resolve(previewContainer);
          };

          reader.readAsDataURL(file);
        });

        previewPromises.push(previewPromise);
      }
    }

    // 先にフラグメントを追加
    previewArea.appendChild(fragment);

    // アニメーションを一括適用（パフォーマンス向上）
    Promise.all(previewPromises).then((containers) => {
      // 少し遅延させてからアニメーション適用
      setTimeout(() => {
        containers.forEach((container) => {
          container.style.opacity = "1";
          container.style.transform = "scale(1)";
        });
      }, 50);
    });
  }
}
