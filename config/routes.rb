Rails.application.routes.draw do
  resources :categories, only: [:new, :create, :destroy]

  resources :products do
    collection do
      get :report
    end
    member do
      patch :adjust_stock
    end
  end

  root "products#index"
end