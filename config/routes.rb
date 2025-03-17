Rails.application.routes.draw do
  # ヘルスチェック
  get "up" => "rails/health#show", as: :rails_health_check

  # 未ログインのトップページ
  root 'static_pages_guest#top'

  # ログイントップページ
  get 'top_page_login', to: 'top_page_login#top'

  # deviseのルーティング
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    confirmations: 'users/confirmations',
    sessions: 'users/sessions',
  }

  # プロフィール登録機能を実装するためのルーティング
  resources :profiles, only: [:new, :create, :edit, :update]
  # 投稿関連
  resources :posts, only: [:index, :new, :create]

  # letter_opener_webのルーティング（開発環境のみ）
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end