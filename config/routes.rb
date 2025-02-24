Rails.application.routes.draw do
  # ヘルスチェック用エンドポイント
  get '/up', to: proc { [200, {}, ['OK']] }

  get "up" => "rails/health#show", as: :rails_health_check

  root 'static_pages#top'
end
