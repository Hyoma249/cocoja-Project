import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["input", "results"];

  connect() {
    this.hideResults();

    this.debounceTimeout = null;

    this.clickOutsideHandler = this.handleClickOutside.bind(this);
    document.addEventListener("click", this.clickOutsideHandler);

    console.log("Autocomplete controller connected");
  }

  disconnect() {
    document.removeEventListener("click", this.clickOutsideHandler);
  }

  search() {
    clearTimeout(this.debounceTimeout);

    const query = this.inputTarget.value.trim();

    if (query === "") {
      this.hideResults();
      return;
    }

    this.debounceTimeout = setTimeout(() => {
      this.fetchResults(query);
    }, 300);
  }

  async fetchResults(query) {
    try {
      const response = await fetch(
        `/search/autocomplete?query=${encodeURIComponent(query)}`
      );

      if (!response.ok) {
        throw new Error("Network response was not ok");
      }

      const data = await response.json();

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

  displayResults(results, query) {
    this.resultsTarget.innerHTML = "";

    results.forEach((result) => {

      let resultUrl = result.url;

      if (result.type === "prefecture") {
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

    this.showResults();
  }

  showNoResults() {
    this.resultsTarget.innerHTML = `
      <div class="p-4 text-center text-gray-500">
        検索結果がありません
      </div>
    `;
    this.showResults();
  }

  showError() {
    this.resultsTarget.innerHTML = `
      <div class="p-4 text-center text-red-500">
        検索中にエラーが発生しました
      </div>
    `;
    this.showResults();
  }

  showResults() {
    this.resultsTarget.classList.remove("hidden");
  }

  hideResults() {
    this.resultsTarget.classList.add("hidden");
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.hideResults();
    }
  }
}
