Rails.application.routes.draw do
  # Canonical host redirect. When CANONICAL_HOST is set (e.g. "worldcup.cool"),
  # requests to the "www." variant are permanently redirected to the bare apex,
  # so users always land on the single hostname the TLS certificate covers. This
  # avoids Safari's "This Connection Is Not Private" error in the case where only
  # one of apex/www has a valid cert. It is a no-op in development and on
  # *.herokuapp.com because the request host won't match "www.<CANONICAL_HOST>".
  # NOTE: this only helps once the apex's own certificate is valid — it is a
  # complement to correct DNS + Heroku ACM on the apex, not a replacement.
  if (canonical_host = ENV["CANONICAL_HOST"].presence)
    constraints(host: "www.#{canonical_host}") do
      match "(*path)", via: :all, to: redirect(status: 301) { |params, request|
        query = request.query_string.empty? ? "" : "?#{request.query_string}"
        "https://#{canonical_host}/#{params[:path]}#{query}"
      }
    end
  end

  devise_for :users, controllers: { registrations: "users/registrations" }

  get "up" => "rails/health#show", as: :rails_health_check
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  root "home#index"

  resource :profile, only: [:show], controller: "profiles" do
    patch :update_name
    patch :update_password
  end

  resource :group_picks, only: [:show, :update], controller: "group_picks"
  resource :bracket_picks, only: [:show, :update], controller: "bracket_picks"
  resources :standings, only: [:index]

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
    resources :knockout_matches, only: [:index, :edit, :update]
    resources :teams, only: [:index, :edit, :update]
    resources :users, only: [:index, :update] do
      member { patch :reset_password }
    end
    resources :payments, only: [:index, :update]
    resources :feed_posts, only: [:index, :destroy] do
      member { patch :approve }
    end
    get "group_pick_status" => "group_pick_status#index", as: :group_pick_status
    post "score" => "dashboard#recompute_scores", as: :recompute_scores
    post "toggle_bracket_visibility" => "dashboard#toggle_bracket_visibility", as: :toggle_bracket_visibility
  end
end
