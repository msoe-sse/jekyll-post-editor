require_relative 'boot'

require 'rails'
require 'active_model/railtie' 
require 'action_controller/railtie' 
require 'action_view/railtie' 
require 'sprockets/railtie' 
require 'rails/test_unit/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module JekyllPostEditor
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.2

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.
    config.github_org = 'msoe-sse'
    config.webmaster_github_username = 'msoe-sse-webmaster'
    config.pull_request_body = 'This pull request was opened automatically by the jekyll-post-editor.'
    config.default_hero = 'https://source.unsplash.com/collection/145103/'
  end
end
