Rails.application.routes.draw do
  # 認証に関連する複数のルートを自動的に生成します。
  devise_for :users
  # ユーザー認証状態で分岐（ログインのトップページ）
  authenticated :user do
    root 'home#index', as: :authenticated_root
  end

  # 未ログインユーザー用のトップページ
  root 'static_pages_guest#top'

  # ヘルスチェック
  get "up" => "rails/health#show", as: :rails_health_check
end