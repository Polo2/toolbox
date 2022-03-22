Rails.application.routes.draw do
  get "tanks/details", to: "tanks#details"
  resources :tanks
  root to: 'pages#home'

  post :fake_webhook, to: 'bump#fake_webhook'
  get :ping_webhook, to: 'bump#ping'
end
