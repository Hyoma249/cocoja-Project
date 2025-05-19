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
    this.scrollDebounceTimer = null;
    this.loadCooldown = 1000;
    this.lastLoadTime = 0;
  }

  connect() {
    if (this.hasPaginationTarget) {
      this.intersectionObserver = new IntersectionObserver(
        (entries) => {
          const now = Date.now();
          entries.forEach((entry) => {
            if (
              entry.isIntersecting &&
              !this.loadingValue &&
              now - this.lastLoadTime > this.loadCooldown
            ) {
              clearTimeout(this.loadMoreTimeout);
              this.loadMoreTimeout = setTimeout(() => this.loadMore(), 250);
            }
          });
        },
        {
          rootMargin: "200px",
          threshold: 0.05,
        }
      );

      this.intersectionObserver.observe(this.paginationTarget);
      console.log("Infinite scroll observer connected");
    }
  }

  disconnect() {
    if (this.intersectionObserver) {
      this.intersectionObserver.disconnect();
    }
    if (this.imageObserver) {
      this.imageObserver.disconnect();
    }
    clearTimeout(this.loadMoreTimeout);
  }

  loadMore() {
    if (this.loadingValue) return;

    this.loadingValue = true;
    this.lastLoadTime = Date.now();

    if (this.hasLoadingTarget) {
      this.loadingTarget.classList.remove("hidden");
    }

    this.pageValue++;
    const url = `${this.urlValue}?slide=${this.pageValue}`;

    const isMypage = window.location.pathname.includes("/mypage");

    fetch(url, {
      headers: {
        Accept: "application/json",
        "X-Requested-With": "XMLHttpRequest",
      },
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error(`Network response was not ok: ${response.status}`);
        }
        return response.json();
      })
      .then((data) => {
        this.loadingValue = false;
        if (this.hasLoadingTarget) {
          this.loadingTarget.classList.add("hidden");
        }

        if (data.posts && data.posts.length > 0) {
          const fragment = document.createDocumentFragment();
          const tempContainer = document.createElement("div");

          if (isMypage) {
            tempContainer.innerHTML = this.buildGridPostsHTML(data.posts);
          } else {
            tempContainer.innerHTML = this.buildPostsHTML(data.posts);
          }

          while (tempContainer.firstChild) {
            fragment.appendChild(tempContainer.firstChild);
          }

          this.entriesTarget.appendChild(fragment);

          this.setupLazyLoading();

          if (!isMypage) {
            setTimeout(() => this.initializeNewSliders(), 10);
          }
        }

        if (!data.next_page && this.hasPaginationTarget) {
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

  setupLazyLoading() {
    const lazyImages = document.querySelectorAll(
      "img[data-src]:not(.opacity-100)"
    );

    if (!lazyImages.length) return;

    if ("IntersectionObserver" in window) {
      if (!this.imageObserver) {
        this.imageObserver = new IntersectionObserver(
          (entries) => {
            entries.forEach((entry) => {
              if (entry.isIntersecting) {
                const lazyImage = entry.target;
                this.imageObserver.unobserve(lazyImage);

                if (!lazyImage.classList.contains("opacity-0")) {
                  lazyImage.classList.add("opacity-0");
                }
                if (!lazyImage.classList.contains("transition-opacity")) {
                  lazyImage.classList.add("transition-opacity");
                }
                if (!lazyImage.classList.contains("duration-300")) {
                  lazyImage.classList.add("duration-300");
                }

                lazyImage.src = lazyImage.dataset.src;
                lazyImage.onload = () => {
                  lazyImage.classList.remove("opacity-0");
                  lazyImage.classList.add("opacity-100");
                };
                lazyImage.onerror = () => {
                  lazyImage.classList.remove("opacity-0");
                  lazyImage.classList.add("opacity-100");
                };
              }
            });
          },
          {
            rootMargin: "300px",
            threshold: 0.01,
          }
        );
      }

      const batchSize = 5;
      for (let i = 0; i < lazyImages.length; i += batchSize) {
        const batch = Array.from(lazyImages).slice(i, i + batchSize);
        batch.forEach((image) => {

          if (!image.classList.contains("opacity-100")) {
            this.imageObserver.observe(image);
          }
        });

        if (i + batchSize < lazyImages.length) {
          setTimeout(() => {}, 5);
        }
      }
    }
  }

  initializeNewSliders() {
    const application = this.application;
    const newSliders = this.entriesTarget.querySelectorAll(
      '[data-controller="swiper"]:not(.initialized-swiper)'
    );

    if (!newSliders.length) return;

    let index = 0;
    const initializeNextSlider = () => {
      if (index >= newSliders.length) return;

      const slider = newSliders[index];
      slider.classList.add("initialized-swiper");
      application.getControllerForElementAndIdentifier(slider, "swiper");

      index++;
      if (index < newSliders.length) {
        setTimeout(initializeNextSlider, 16);
      }
    };

    initializeNextSlider();
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
                ? `<img data-src="${post.post_images[0].url}" class="w-full h-full object-cover transition-transform duration-200 group-hover:scale-105 opacity-0 transition-opacity duration-300">`
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

          <!-- 画像スライダー - Swiperに変更 -->
          ${
            post.post_images && post.post_images.length > 0
              ? `<div class="relative overflow-hidden pb-8" data-controller="swiper">
              <div class="swiper w-full md:aspect-[4/3] aspect-square" data-swiper-target="container">
                <div class="swiper-wrapper">
                  ${post.post_images
                    .map(
                      (image, index) => `
                    <div class="swiper-slide">
                      ${
                        image.image && image.image.url
                          ? `<img data-src="${image.image.url}" src="${image.image.url}" class="w-full h-full object-contain select-none" draggable="false" loading="lazy">`
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
                    ? `<div class="absolute top-2 right-2 bg-black bg-opacity-50 text-white text-xs px-2 py-1 rounded-full z-10">
                    <span class="swiper-index">1</span>/${post.post_images.length}
                  </div>

                  <div class="swiper-pagination"></div>`
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

          <!-- 詳細ページへのリンク -->
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

  formatContentWithHashtags(content) {
    if (!content) return "";
    return content.replace(
      /#(\w+)/g,
      '<a href="/posts/hashtag/$1" class="text-blue-500">#$1</a>'
    );
  }
}
