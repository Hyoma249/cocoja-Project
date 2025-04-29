Rails.application.routes.draw do
  # OPTIONSリクエストを許可
  match "*path", to: proc { [ 204, {}, [] ] }, via: :options, constraints: { path: /.*/ }

  get "settings/index"
  # ヘルスチェック
  get "up" => "rails/health#show", :as => :rails_health_check

  # 未ログインのトップページ
  root "static_pages_guest#top"

  # ログイントップページ
  get "top_page_login", to: "top_page_login#top"

  # プロフィール登録
  get "profile/setup", to: "profiles#setup"
  patch "profile/update", to: "profiles#update"

  # ハッシュタグ
  get "/posts/hashtag/:name", to: "posts#hashtag", as: "hashtag_posts"

  # deviseのルーティング
  devise_for :users, controllers: {
    registrations: "users/registrations",
    # confirmations: 'users/confirmations',
    sessions: "users/sessions"
  }

  # 投稿関連
  resources :posts, only: [ :index, :new, :create, :show ] do
    resources :votes, only: [ :create ]
  end

  # 都道府県
  resources :prefectures, only: [ :index, :show ]

  # ランキング
  resources :rankings, only: [ :index ]

  # マイページ
  resource :mypage, only: [ :show, :edit, :update ]

  # letter_opener_webのルーティング（開発環境のみ）
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
