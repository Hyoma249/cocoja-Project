Rails.application.routes.draw do
  # ヘルスチェック
  get "up" => "rails/health#show", as: :rails_health_check

  root 'static_pages_guest#top'
end
