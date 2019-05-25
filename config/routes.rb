Rails.application.routes.draw do
  get 'home/index'
  post 'home/login'
  get 'post/list'
  get 'post/edit'
  post 'post/preview'
  post 'post/submit'
  root 'home#index'
end
