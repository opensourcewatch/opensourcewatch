Rails.application.routes.draw do
  root 'landing#index'
  get '/about' => 'landing#about'
  get '/story' => 'landing#story'
  get '*path' => redirect('/')
end
