Rails.application.routes.draw do
  get 'settings/index'
  # ヘルスチェック
  get "up" => "rails/health#show", as: :rails_health_check

  # 未ログインのトップページ
  root 'static_pages_guest#top'

  # ログイントップページ
  get 'top_page_login', to: 'top_page_login#top'

  # プロフィール登録
  get 'profile/setup', to: 'profiles#setup'
  patch 'profile/update', to: 'profiles#update'

  # ハッシュタグ
  get '/posts/hashtag/:name', to: 'posts#hashtag', as: 'hashtag_posts'

  # deviseのルーティング
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    confirmations: 'users/confirmations',
    sessions: 'users/sessions',
  }

  # 投稿関連
  resources :posts, only: [:index, :new, :create]
  # ランキング
  resources :rankings, only: [:index]
  # マイページ
  resource :mypage, only: [:show, :edit, :update]

  # letter_opener_webのルーティング（開発環境のみ）
  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end

  # ヘルスチェック用のルーティング
  get '/debug_headers', to: proc {
    |env| [200, {}, [env.select {|k,v| k.match(/^HTTP_/) }.map {|k,v| "#{k}: #{v}" }.join("\n")]]
  }

  # routes.rbに追加（既存の/debug_headersとは別に）
  get '/simple_test', to: proc { [200, {"Content-Type" => "text/plain"}, ["It works!"]] }
end