Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "home#index"

  resource :group_picks, only: [:show, :update], controller: "group_picks"
  resource :bracket_picks, only: [:show, :update], controller: "bracket_picks"
  resources :standings, only: [:index]

  namespace :developer do
    root to: "dashboard#index"
    constraints model: /[a-z_]+/ do
      get    ":model/new",      to: "records#new",     as: :new_record
      post   ":model",          to: "records#create"
      get    ":model/:id/edit", to: "records#edit",    as: :edit_record
      get    ":model/:id",      to: "records#show",    as: :record
      patch  ":model/:id",      to: "records#update"
      put    ":model/:id",      to: "records#update"
      delete ":model/:id",      to: "records#destroy"
      get    ":model",          to: "records#index",   as: :records
    end
  end

  namespace :admin do
    root to: "dashboard#index"
    resources :matches, only: [:index, :edit, :update]
    resources :knockout_matches, only: [:index, :edit, :update]
    resources :teams, only: [:index, :edit, :update]
    resources :users, only: [:index, :update] do
      member { patch :reset_password }
    end
    resources :payments, only: [:index, :update]
    get "group_pick_status" => "group_pick_status#index", as: :group_pick_status
    post "score" => "dashboard#recompute_scores", as: :recompute_scores
    post "toggle_bracket_visibility" => "dashboard#toggle_bracket_visibility", as: :toggle_bracket_visibility
  end
end
