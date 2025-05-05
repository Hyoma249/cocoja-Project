Rails.application.routes.draw do
  # OPTIONSリクエストを許可
  match '*path', to: proc { [204, {}, []] }, via: :options, constraints: { path: /.*/ }

  get 'settings/index'
  # ヘルスチェック
  get 'up' => 'rails/health#show', :as => :rails_health_check

  # 未ログインのトップページ
  root 'static_pages_guest#top'

  # ログイントップページ
  get 'top_page_login', to: 'top_page_login#top'

  # プロフィール登録
  get 'profile/setup', to: 'profiles#setup'
  patch 'profile/update', to: 'profiles#update'

  # ハッシュタグ
  get '/posts/hashtag/:name', to: 'posts#hashtag', as: 'hashtag_posts'

  # 検索API
  get 'search/autocomplete', to: 'search#autocomplete'

  # deviseのルーティング
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions'
  }

  # ユーザーリソースとフォロー機能のルーティング
  resources :users, only: [:show] do
    member do
      get :following
      get :followers
    end
    resource :relationships, only: %i[create destroy]
  end

  # 投稿関連
  resources :posts, only: %i[index new create show] do
    resources :votes, only: [:create]
  end

  # 都道府県
  resources :prefectures, only: %i[index show] do
    member do
      get :posts # 都道府県ごとの投稿一覧（タイムライン形式）を表示するための新しいルート
    end
  end

  # ランキング
  resources :rankings, only: [:index]

  # マイページ
  resource :mypage, only: %i[show edit update]

  # letter_opener_webのルーティング（開発環境のみ）
  mount LetterOpenerWeb::Engine, at: '/letter_opener' if Rails.env.development?
end
