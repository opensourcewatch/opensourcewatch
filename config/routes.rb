Rails.application.routes.draw do
  root 'landing#index'
  get '/about' => 'landing#about'
  get '*path' => redirect('/')
end
