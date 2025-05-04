import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "results"];

  // 接続時の初期設定
  connect() {
    // 検索結果を隠しておく
    this.hideResults();

    // デバウンスを設定（入力後少し待ってから検索を実行）
    this.debounceTimeout = null;

    // クリック処理のリスナーを設定
    this.clickOutsideHandler = this.handleClickOutside.bind(this);
    document.addEventListener("click", this.clickOutsideHandler);

    console.log("Autocomplete controller connected");
  }

  // コントローラーが切断されるときの処理
  disconnect() {
    // イベントリスナーをクリーンアップ
    document.removeEventListener("click", this.clickOutsideHandler);
  }

  // 入力イベントハンドラ
  search() {
    // 前回の検索タイマーをクリア
    clearTimeout(this.debounceTimeout);

    // 検索テキストを取得
    const query = this.inputTarget.value.trim();

    // 検索テキストが空なら結果を隠す
    if (query === "") {
      this.hideResults();
      return;
    }

    // 0.3秒後に検索を実行（タイピング中の過剰リクエストを防ぐ）
    this.debounceTimeout = setTimeout(() => {
      this.fetchResults(query);
    }, 300);
  }

  // APIからデータを取得
  async fetchResults(query) {
    try {
      // APIリクエスト
      const response = await fetch(
        `/search/autocomplete?query=${encodeURIComponent(query)}`
      );

      if (!response.ok) {
        throw new Error("Network response was not ok");
      }

      const data = await response.json();

      // 結果があれば表示
      if (data.results.length > 0) {
        this.displayResults(data.results, query);
      } else {
        this.showNoResults();
      }
    } catch (error) {
      console.error("検索中にエラーが発生しました:", error);
      this.showError();
    }
  }

  // 検索結果を表示
  displayResults(results, query) {
    // 一旦結果をクリア
    this.resultsTarget.innerHTML = "";

    // 結果のHTMLを生成
    results.forEach((result) => {
      // 元のURLを保持
      let resultUrl = result.url;

      // 都道府県の場合、検索クエリを追加
      if (result.type === "prefecture") {
        // URLにクエリパラメータがすでにある場合は&で連結、なければ?で始める
        const separator = resultUrl.includes("?") ? "&" : "?";
        resultUrl = `${resultUrl}${separator}query=${encodeURIComponent(
          query
        )}`;
      }

      const item = document.createElement("a");
      item.href = resultUrl;
      item.className =
        "flex items-center p-3 border-b border-gray-100 hover:bg-gray-50 transition";

      let iconHtml = "";

      // 結果タイプごとに異なるアイコンを表示
      switch (result.type) {
        case "user":
          iconHtml = result.image
            ? `<img src="${result.image}" alt="${result.text}" class="w-8 h-8 rounded-full mr-3 object-cover">`
            : `<div class="w-8 h-8 rounded-full bg-blue-100 flex items-center justify-center mr-3">
                <svg class="w-4 h-4 text-blue-500" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd" />
                </svg>
              </div>`;
          break;
        case "prefecture":
          iconHtml = `<div class="w-8 h-8 rounded-full bg-green-100 flex items-center justify-center mr-3">
                        <svg class="w-4 h-4 text-green-500" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                          <path fill-rule="evenodd" d="M5.05 4.05a7 7 0 119.9 9.9L10 18.9l-4.95-4.95a7 7 0 010-9.9zM10 11a2 2 0 100-4 2 2 0 000 4z" clip-rule="evenodd" />
                        </svg>
                      </div>`;
          break;
        case "hashtag":
          iconHtml = `<div class="w-8 h-8 rounded-full bg-purple-100 flex items-center justify-center mr-3">
                        <svg class="w-4 h-4 text-purple-500" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor">
                          <path fill-rule="evenodd" d="M9.243 3.03a1 1 0 01.727 1.213L9.53 6h2.94l.56-2.243a1 1 0 111.94.486L14.53 6H17a1 1 0 110 2h-2.97l-1 4H15a1 1 0 110 2h-2.47l-.56 2.242a1 1 0 11-1.94-.485L10.47 14H7.53l-.56 2.242a1 1 0 11-1.94-.485L5.47 14H3a1 1 0 110-2h2.97l1-4H5a1 1 0 010-2h2.47l.56-2.243a1 1 0 011.213-.727zM9.03 8l-1 4h2.938l1-4H9.031z" clip-rule="evenodd" />
                        </svg>
                      </div>`;
          break;
      }

      // タイプごとのラベルテキスト
      const typeText =
        result.type === "user"
          ? "ユーザー"
          : result.type === "prefecture"
          ? "都道府県"
          : result.type === "hashtag"
          ? "ハッシュタグ"
          : "";

      item.innerHTML = `
        ${iconHtml}
        <div class="flex-1">
          <div class="font-medium">${result.text}</div>
          <div class="text-xs text-gray-500">${typeText}</div>
        </div>
      `;

      this.resultsTarget.appendChild(item);
    });

    // 結果を表示
    this.showResults();
  }

  // 結果がない場合の表示
  showNoResults() {
    this.resultsTarget.innerHTML = `
      <div class="p-4 text-center text-gray-500">
        検索結果がありません
      </div>
    `;
    this.showResults();
  }

  // エラー表示
  showError() {
    this.resultsTarget.innerHTML = `
      <div class="p-4 text-center text-red-500">
        検索中にエラーが発生しました
      </div>
    `;
    this.showResults();
  }

  // 検索結果を表示
  showResults() {
    this.resultsTarget.classList.remove("hidden");
  }

  // 検索結果を隠す
  hideResults() {
    this.resultsTarget.classList.add("hidden");
  }

  // コンポーネント外クリック時のハンドラ
  handleClickOutside(event) {
    // クリックがコンポーネントの外部で発生した場合、結果を隠す
    if (!this.element.contains(event.target)) {
      this.hideResults();
    }
  }
}
