Rails.application.routes.draw do
  get 'github/callback'
  get 'post/list'
  get 'post/edit'
  get 'post/preview'
  post 'post/submit'
  root 'post#list'
  post 'image/upload'
end
