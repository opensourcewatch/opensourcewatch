Rails.application.routes.draw do
  resources :ruby_gems, only: [:index]

  get "*path", to: "ruby_gems#index"
end
