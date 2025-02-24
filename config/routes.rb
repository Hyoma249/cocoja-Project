Rails.application.routes.draw do
  # ヘルスチェック用エンドポイント
  get '/up', to: proc { [200, {}, ['OK']] }

  # ルートを追加
  root to: proc { [200, {}, ['Welcome to Rails on Back4app!']] }
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root 'static_pages#top'
end
