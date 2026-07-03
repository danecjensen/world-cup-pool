Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "home#index"

  resource :profile, only: [:show], controller: "profiles" do
    patch :update_name
    patch :update_password
    get :flag
    patch :update_flag
  end

  resources :watch_parties, only: [:create, :destroy]

  resource :group_picks, only: [:show, :update], controller: "group_picks"
  resource :bracket_picks, only: [:show, :update], controller: "bracket_picks"
  resource :bracket_insights, only: [:show], controller: "bracket_insights"
  resource :champion_picks, only: [:show], controller: "champion_picks"
  resources :standings, only: [:index]

  get "drip-cup" => "drip_cup#show", as: :drip_cup
  post "drip-cup/votes" => "drip_cup#vote", as: :drip_cup_votes
  get "drip-cup/leaderboard" => "drip_cup#leaderboard", as: :drip_cup_leaderboard
  get "brackets/:user_id" => "user_brackets#show", as: :user_bracket

  get "feed" => "feed#index", as: :feed
  post "feed" => "feed#create"
  get "feed/:id" => "feed#show", as: :feed_post
  delete "feed/:id" => "feed#destroy"
  post "feed/:id/comments" => "comments#create", as: :feed_post_comments
  delete "feed/:id/comments/:comment_id" => "comments#destroy", as: :feed_post_comment

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
    resources :knockout_matches, only: [:index, :edit, :update] do
      delete :result, on: :member, action: :clear_result
    end
    resource :advancing_teams, only: [:show, :update], controller: "advancing_teams"
    resources :teams, only: [:index, :edit, :update]
    resources :users, only: [:index, :update] do
      member { patch :reset_password }
      resource :bracket_picks, only: [:show, :update], controller: "bracket_picks"
    end
    resources :payments, only: [:index, :update]
    resources :feed_posts, only: [:index, :destroy] do
      member { patch :approve }
    end
    get "group_pick_status" => "group_pick_status#index", as: :group_pick_status
    get "knockout_pick_status" => "knockout_pick_status#index", as: :knockout_pick_status
    get "pick_audits" => "pick_audits#index", as: :pick_audits
    post "score" => "dashboard#recompute_scores", as: :recompute_scores
    post "toggle_bracket_visibility" => "dashboard#toggle_bracket_visibility", as: :toggle_bracket_visibility
    post "toggle_drip_cup" => "dashboard#toggle_drip_cup", as: :toggle_drip_cup
  end
end
