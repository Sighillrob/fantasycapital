Main::Application.routes.draw do
  get "users/leadboard"

  get "splash/index", as: :splash
  root to: "contests#browse"

  devise_for :users

  resource :entries
  resources :lineups, only: :index
  resources :players, only: [] do
    member do
      get :stats
    end
  end
  resources :contests do
    collection do
      get 'browse'
    end
    resources :lineups
  end
  resources :waiting_lists, only: [:new, :create, :show] do
    collection do
      get :invite
    end
  end

  resources :accounts, only: [:create, :edit, :show, :index] do
    collection do
      get :new_cc
      get :profile
      get :history
      get :withdraw
      get :add_fund

      resources :credit_cards
      post 'credit_cards/deposit' => 'credit_cards#deposit'

      get 'bank_accounts/withdrawal' => 'bank_accounts#withdrawal'
      post 'bank_accounts/withdrawal' => 'bank_accounts#withdrawal_post'
      resources :bank_accounts
    end
  end

  resources :projections, only: :index do
    resources :projection_by_stats do
      resources :projection_by_stat_and_games do
        resources :projection_breakdowns
      end
    end
  end


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
