Rails.application.routes.draw do
  # ログインのトップページ
  # authenticated :user do
  #   root 'home#index', as: :authenticated_root
  # end

  # 未ログインのトップページ
  root 'static_pages_guest#top'

  # 認証に関連する複数のルートを自動的に生成します。
  devise_for :users, controllers: {
    registrations: 'users/registrations',
  }

  # ヘルスチェック
  get "up" => "rails/health#show", as: :rails_health_check
end