// app/javascript/controllers/infinite_scroll_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["entries", "pagination", "loading"];
  static values = {
    url: String,
    page: Number,
    loading: Boolean,
  };

  initialize() {
    this.pageValue = this.pageValue || 1;
    this.loadingValue = false;
    this.setupLazyLoading();
  }

  connect() {
    if (this.hasPaginationTarget) {
      // より高い感度でIntersectionObserverを設定
      this.intersectionObserver = new IntersectionObserver(
        (entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting && !this.loadingValue) {
              this.loadMore();
            }
          });
        },
        {
          rootMargin: "300px", // より大きなマージンで早めに検知
          threshold: 0.1, // わずかに見えるだけで発火
        }
      );

      this.intersectionObserver.observe(this.paginationTarget);
      console.log("Infinite scroll observer connected");
    } else {
      console.warn("Pagination target not found for infinite scroll");
    }
  }

  disconnect() {
    if (this.intersectionObserver) {
      this.intersectionObserver.disconnect();
    }
  }

  loadMore() {
    if (this.loadingValue) return;

    this.loadingValue = true;
    console.log(`Loading page ${this.pageValue + 1}`);

    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.remove("hidden");
    }

    this.pageValue++;
    const url = `${this.urlValue}?slide=${this.pageValue}`;

    // URLパスからページタイプを判別
    const isMypage = window.location.pathname.includes("/mypage");

    console.log(`Fetching: ${url}`);

    fetch(url, {
      headers: {
        Accept: "application/json",
        "X-Requested-With": "XMLHttpRequest",
      },
    })
      .then((response) => {
        if (!response.ok) {
          console.error(`HTTP error: ${response.status}`);
          throw new Error(`Network response was not ok: ${response.status}`);
        }
        return response.json();
      })
      .then((data) => {
        this.loadingValue = false;
        if (this.hasLoadingTarget) {
          this.loadingTarget.classList.add("hidden");
        }

        console.log(`Received ${data.posts ? data.posts.length : 0} posts`);
        console.log(
          "First post data:",
          data.posts && data.posts.length > 0 ? data.posts[0] : "No posts"
        );

        if (data.posts && data.posts.length > 0) {
          // URLに基づいて異なるHTMLビルダーを使用
          if (isMypage) {
            this.entriesTarget.insertAdjacentHTML(
              "beforeend",
              this.buildGridPostsHTML(data.posts)
            );
          } else {
            this.entriesTarget.insertAdjacentHTML(
              "beforeend",
              this.buildPostsHTML(data.posts)
            );
          }

          this.setupLazyLoading();

          // スライダー初期化はグリッドレイアウト（マイページ）では不要
          if (!isMypage) {
            this.initializeNewSliders();
          }
        }

        if (!data.next_page && this.hasPaginationTarget) {
          console.log("No more pages, removing pagination target");
          this.paginationTarget.remove();
        }
      })
      .catch((error) => {
        console.error("無限スクロールエラー:", error);
        this.loadingValue = false;
        if (this.hasLoadingTarget) {
          this.loadingTarget.classList.add("hidden");
        }
      });
  }

  // 画像の遅延読み込み設定
  setupLazyLoading() {
    const lazyImages = document.querySelectorAll(".lazy-image");

    if ("IntersectionObserver" in window) {
      const imageObserver = new IntersectionObserver(
        (entries) => {
          entries.forEach((entry) => {
            if (entry.isIntersecting) {
              const lazyImage = entry.target;
              lazyImage.src = lazyImage.dataset.src;
              lazyImage.classList.remove("lazy-image");
              imageObserver.unobserve(lazyImage);
            }
          });
        },
        { rootMargin: "200px" }
      );

      lazyImages.forEach((image) => {
        imageObserver.observe(image);
      });
    } else {
      // IntersectionObserverがサポートされていないブラウザ向けのフォールバック
      lazyImages.forEach((image) => {
        image.src = image.dataset.src;
      });
    }
  }

  // 新しく追加されたスライダーを初期化
  initializeNewSliders() {
    const application = this.application;
    const newSliders = this.entriesTarget.querySelectorAll(
      '[data-controller="slider"]:not(.slider-initialized)'
    );

    newSliders.forEach((slider) => {
      slider.classList.add("slider-initialized");
      application.getControllerForElementAndIdentifier(slider, "slider");
    });
  }

  // マイページのグリッドレイアウト用のHTMLを生成
  buildGridPostsHTML(posts) {
    return posts
      .map((post) => {
        if (post.post_images && post.post_images.length > 0) {
          return `
          <div class="aspect-square overflow-hidden relative group">
            ${
              post.post_images[0].url
                ? `<img data-src="${post.post_images[0].url}" class="w-full h-full object-cover transition-transform duration-200 group-hover:scale-105 lazy-image">`
                : ``
            }
            ${
              post.post_images.length > 1
                ? `<div class="absolute top-2 right-2 bg-black/50 backdrop-blur-sm rounded-md p-1.5">
                <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5 text-white">
                  <path stroke-linecap="round" stroke-linejoin="round" d="M16.5 8.25V6a2.25 2.25 0 0 0-2.25-2.25H6A2.25 2.25 0 0 0 3.75 6v8.25A2.25 2.25 0 0 0 6 16.5h2.25m8.25-8.25H18a2.25 2.25 0 0 1 2.25 2.25V18A2.25 2.25 0 0 1 18 20.25h-7.5A2.25 2.25 0 0 1 8.25 18v-1.5m8.25-8.25h-6a2.25 2.25 0 0 0-2.25 2.25v6" />
                </svg>
              </div>`
                : ``
            }
          </div>
        `;
        }
        return "";
      })
      .join("");
  }

  // 投稿のHTMLを生成する関数（ハッシュタグページ用）
  buildPostsHTML(posts) {
    return posts
      .map((post) => {
        return `
        <div class="bg-white rounded-lg shadow-sm overflow-hidden">
          <!-- ユーザーヘッダー -->
          <div class="flex items-center justify-between p-4 border-b border-gray-100">
            <div class="flex items-center gap-4">
              <div class="w-10 h-10 rounded-full bg-gray-100 flex-shrink-0 overflow-hidden">
                ${
                  post.user && post.user.profile_image_url
                    ? `<img src="${post.user.profile_image_url}" alt="${post.user.uid}" class="w-full h-full object-cover">`
                    : `<img src="/assets/sample_icon1.svg" alt="${
                        post.user ? post.user.uid : ""
                      }" class="w-full h-full object-cover">`
                }
              </div>
              <div>
                <h4 class="font-semibold text-sm">${
                  post.user ? post.user.uid : ""
                }</h4>
                <p class="text-xs text-gray-500">${
                  post.prefecture ? post.prefecture.name : ""
                }</p>
              </div>
            </div>
          </div>

          <!-- 画像スライダー -->
          ${
            post.post_images && post.post_images.length > 0
              ? `<div class="relative" data-controller="slider">
              <div class="w-full md:aspect-[4/3] aspect-square overflow-hidden touch-none">
                <div class="flex h-full will-change-transform touch-pan-y" data-slider-target="wrapper">
                  ${post.post_images
                    .map(
                      (image, index) => `
                    <div class="w-full flex-shrink-0 flex items-center justify-center select-none" data-slider-target="slide">
                      ${
                        image.image && image.image.url
                          ? `<img data-src="${image.image.url}" class="w-full h-full object-contain select-none pointer-events-none lazy-image" draggable="false">`
                          : `<div class="w-full h-full bg-gray-900 flex items-center justify-center text-white select-none">
                          <span>画像なし</span>
                        </div>`
                      }
                    </div>
                  `
                    )
                    .join("")}
                </div>

                ${
                  post.post_images.length > 1
                    ? `<div class="absolute top-2 right-2 bg-black bg-opacity-50 text-white text-xs px-2 py-1 rounded-full">
                    <span data-slider-target="counter">1</span>/${post.post_images.length}
                  </div>

                  <button class="absolute left-2 top-1/2 -translate-y-1/2 w-8 h-8 bg-black bg-opacity-20 rounded-full shadow flex items-center justify-center z-10 focus:outline-none" data-slider-target="prevButton" data-action="click->slider#prev">
                    <svg class="w-8 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 19l-7-7 7-7"/>
                    </svg>
                  </button>
                  <button class="absolute right-2 top-1/2 -translate-y-1/2 w-8 h-8 bg-black bg-opacity-20 rounded-full shadow flex items-center justify-center z-10 focus:outline-none" data-slider-target="nextButton" data-action="click->slider#next">
                    <svg class="w-8 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 5l7 7-7 7"/>
                    </svg>
                  </button>`
                    : ""
                }
              </div>
            </div>`
              : ""
          }

          <!-- 投稿本文 -->
          <div class="px-4 py-4">
            <div class="text-sm md:text-base mb-2">
              <span>${this.formatContentWithHashtags(post.content)}</span>
            </div>

            ${
              post.hashtags && post.hashtags.length > 0
                ? `<div class="flex flex-wrap gap-2 mt-3">
                ${post.hashtags
                  .map(
                    (tag) =>
                      `<a href="/posts/hashtag/${tag.name}" class="text-xs bg-blue-50 text-blue-600 px-2 py-1 rounded-full">
                    #${tag.name}
                  </a>`
                  )
                  .join("")}
              </div>`
                : ""
            }

            <p class="text-xs md:text-sm text-gray-500 mt-4">投稿日：${
              post.created_at_formatted || post.created_at
            }</p>
          </div>

          <!-- 詳細ページへのリンクを追加 -->
          <div class="p-4 border-t">
            <a href="/posts/${
              post.id
            }" class="w-full inline-flex items-center justify-center px-4 py-2 rounded-lg bg-indigo-600 text-white font-medium hover:bg-indigo-700 transition duration-150 ease-in-out shadow-sm hover:shadow focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 text-sm">
              <svg class="w-5 h-5 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6v6m0 0v6m0-6h6m-6 0H6"/>
              </svg>
              ポイントをつけよう！
            </a>
          </div>
        </div>
      `;
      })
      .join("");
  }

  // ハッシュタグをリンクに変換する関数（サーバーサイドのformat_content_with_hashtagsと同等の処理）
  formatContentWithHashtags(content) {
    if (!content) return "";
    return content.replace(
      /#(\w+)/g,
      '<a href="/posts/hashtag/$1" class="text-blue-500">#$1</a>'
    );
  }
}
