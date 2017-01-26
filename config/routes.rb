Rails.application.routes.draw do
  root 'landing#index'
  get '*path' => redirect('/')
end
