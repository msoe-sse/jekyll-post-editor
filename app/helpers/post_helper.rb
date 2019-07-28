##
# A helper module contains helpers for PostController views
module PostHelper
  ##
  # Formats the form url for post submission. If it's an existing post a path parameter
  # will be added to the url. There will be no url parameters otherwise
  #
  # Params:
  # +post_path+::a path to an existing post on the website
  def get_post_submission_url(post_path)
    return "/post/submit?path=#{post_path}" if post_path
    '/post/submit'
  end
end
