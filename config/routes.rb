Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "home#index"

  resource :group_picks, only: [:show, :update], controller: "group_picks"
  resource :bracket_picks, only: [:show, :update], controller: "bracket_picks"
  resources :standings, only: [:index]

  namespace :admin do
    root to: "dashboard#index"
    resources :matches, only: [:index, :edit, :update]
    resources :knockout_matches, only: [:index, :edit, :update]
    resources :teams, only: [:index, :edit, :update]
    post "score" => "dashboard#recompute_scores", as: :recompute_scores
  end
end
