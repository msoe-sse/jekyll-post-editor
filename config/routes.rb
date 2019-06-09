Rails.application.routes.draw do
  get 'home/index'
  post 'home/login'
  get 'github/callback'
  get 'post/list'
  get 'post/edit'
  post 'post/preview'
  post 'post/submit'
  root 'home#index'
end
