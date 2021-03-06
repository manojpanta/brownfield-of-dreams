# frozen_string_literal: true

require 'spec_helper'

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)

abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'rspec/rails'
require 'vcr'
require 'webmock/rspec'
require 'pry'
require './app/helpers/authentication'

VCR.configure do |config|
  config.ignore_localhost = true
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.configure_rspec_metadata!
  config.filter_sensitive_data('<YOUTUBE_API_KEY>') { ENV['YOUTUBE_API_KEY'] }
  config.filter_sensitive_data('<GITHUB_API_KEY>') { ENV['github_key'] }
end

def stub_get_json(url, filename)
  json_response = File.open("./fixtures/#{filename}")
  stub_request(:get, url)
    .to_return(body: json_response, status: 200)
end


def mock_youtube_playlist
  filename = 'video_list.json'
  url = 'https://www.googleapis.com/youtube/v3/playlistItems'
  stub_get_json(url, filename)
end

def mock_user_dashboard_github
  filename = 'user_following.json'
  url = 'https://api.github.com/user/following'
  stub_get_json(url, filename)

  filename = 'user_followers.json'
  url = 'https://api.github.com/user/followers'
  stub_get_json(url, filename)

  filename = 'user_repos.json'
  url = 'https://api.github.com/user/repos'
  stub_get_json(url, filename)
end

ActiveRecord::Migration.maintain_test_schema!

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, browser: :chrome)
end

Capybara.javascript_driver = :selenium_chrome

Capybara.configure do |config|
  config.default_max_wait_time = 5
end

SimpleCov.start 'rails'

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

OmniAuth.config.test_mode = true
OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
  'uid' => '34468256',
  'credentials' => { 'token' => ENV['TEST_AUTHORIZATION_TOKEN'], 'expires' => false },
  'extra' =>
  { 'raw_info' =>
    { 'login' => 'manojpanta' } }
)

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  config.include FactoryBot::Syntax::Methods

  config.include Helpers::Authentication, type: :feature

  config.use_transactional_fixtures = true

  config.infer_spec_type_from_file_location!

  config.filter_rails_from_backtrace!
end
