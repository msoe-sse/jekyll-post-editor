[![Build Status](https://travis-ci.com/msoe-sse/jekyll-post-editor.svg?branch=master)](https://travis-ci.com/msoe-sse/jekyll-post-editor)
# Setup
1. You will need Ruby installed on your development machine. Ruby 2.4 or 2.5 should both work fine. 
    - Check version with `ruby -v`
2. Clone the repository and navigate to your project directory in cmd, git bash
3. Ask the webmaster for the development GitHub Client ID and Client Secret values
4. Run `export GH_BASIC_CLIENT_ID="<Client ID Here>"
5. Run `export GH_BASIC_SECRET_ID="<Client Secret Here>"
6. Run `gem install bundler`
7. Run `bundle install`
8. If 6 and 7 succeed you should be able to run the post editor application locally by running `rails server` and navigating to http://localhost:3000 in a brower.
# Continuous Integration
There are checks that will be performed whenever Pull Requests are opened. To save time on the build server, please run the tests locally to check for errors that will occur in the CI builds.
1. To run all tests, run the command `rake`
    - To run tests in an individual file run the command `rails test <path_to_test_file>`
2. To run rubocop, run the command `bundle exec rubocop`
