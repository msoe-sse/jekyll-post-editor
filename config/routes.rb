Rails.application.routes.draw do
  get 'github/callback'
  get 'post/list'
  get 'post/edit'
  post 'post/preview'
  post 'post/submit'
  root 'post#list'
end
