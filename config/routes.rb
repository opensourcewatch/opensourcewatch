Rails.application.routes.draw do
  resources :ruby_gems, only: [:index]
  get "ruby_gems/search", to: "ruby_gems#search"

  get "*path", to: "ruby_gems#index"
end
