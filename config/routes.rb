Rails.application.routes.draw do
  match '*path', to: proc { [204, {}, []] }, via: :options, constraints: { path: /.*/ }

  get 'settings/index'

  get 'up' => 'rails/health#show', :as => :rails_health_check

  root 'static_pages_guest#top'

  get 'guide', to: 'static_pages#guide', as: 'static_pages_guide'

  get 'top_page_login', to: 'top_page_login#top'

  get 'profile/setup', to: 'profiles#setup'
  patch 'profile/update', to: 'profiles#update'

  get '/posts/hashtag/:name', to: 'posts#hashtag', as: 'hashtag_posts'

  get 'search/autocomplete', to: 'search#autocomplete'

  get '/contact', to: 'pages#contact'
  get '/terms', to: 'pages#terms'
  get '/privacy', to: 'pages#privacy'

  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    omniauth_callbacks: 'users/omniauth_callbacks',
    confirmations: 'users/confirmations',
    passwords: 'users/passwords'
  }

  resources :users, only: [:show] do
    member do
      get :following
      get :followers
      get :posts
    end
    resource :relationships, only: %i[create destroy]
  end

  resources :posts, only: %i[index new create show] do
    resources :votes, only: [:create]
  end

  resources :prefectures, only: %i[index show] do
    member do
      get :posts
    end
  end

  resources :rankings, only: [:index]

  resource :mypage, only: %i[show edit update] do
    get 'posts', to: 'mypages#posts'
  end
end
