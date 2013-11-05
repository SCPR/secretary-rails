ENV["RAILS_ENV"] ||= 'test'

require 'rubygems'
require 'bundler/setup'

require 'combustion'
Combustion.initialize! :active_record

require 'rspec/rails'
require 'factory_girl'
load 'factories.rb'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include FactoryGirl::Syntax::Methods
  config.mock_with :rspec
  config.order = "random"
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
