Rails.application.routes.draw do
  #default json response
  get 'default/index'
  root 'default#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  post 'authenticate', to: 'authentication#authenticate'
  get 'products', to: 'product#index'
end
