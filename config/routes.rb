Rails.application.routes.draw do
  get "categories/new"
  get "categories/create"
  get "products/index"
  get "products/show"
  get "products/new"
  get "products/edit"
  resources :categories, only: [:new, :create]
  resources :products do
    member do
      patch :adjust_stock
    end
  end

  # La página principal será directamente la lista de productos
  root "products#index"
end