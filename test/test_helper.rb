require 'simplecov'
SimpleCov.start 'rails'

ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

# https://github.com/mperham/sidekiq/wiki/Testing
require 'sidekiq/testing'
Sidekiq::Testing.disable!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  # self.use_transactional_tests = false
end
