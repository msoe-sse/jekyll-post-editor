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

  ##
  # Returns the valid selected value for the overlay dropdown given an existing post's overlay
  #
  # Params:
  # +post_overlay+::the overlay for an existing post
  def get_selected_overlay(post_overlay)
    if post_overlay
      return 'Red' if post_overlay.downcase == 'red'
      return 'Blue' if post_overlay.downcase == 'blue'
      return 'Green' if post_overlay.downcase == 'green'
    end
  end
end
