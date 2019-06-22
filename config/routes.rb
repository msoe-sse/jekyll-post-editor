Rails.application.routes.draw do
  get 'github/callback'
  # This list view was started and not completed. We may come back to this post MVP
  # get 'post/list'
  get 'post/edit'
  post 'post/preview'
  post 'post/submit'
  root 'post#edit'
end
