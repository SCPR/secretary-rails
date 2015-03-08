ENV["RAILS_ENV"] ||= 'test'

require 'rubygems'
require 'bundler/setup'

# This allows us to run the suite with the `rspec` CLI if we want to.
load 'spec/support/test_setup.rb'
TestSetup.setup

$stdout.puts "*** [secretary] Database: #{TestSetup.database}"

require 'rspec/rails'
require 'factory_girl'
load 'factories.rb'

RSpec.configure do |config|
  config.use_transactional_fixtures = true
  config.include FactoryGirl::Syntax::Methods
  config.mock_with :rspec
  config.order = "random"
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true

  config.after :suite do
    TestSetup.remove_database_config
  end

  # rspec-rails 3 will no longer automatically infer an example group's spec type
  # from the file location. You can explicitly opt-in to the feature using this
  # config option.
  # To explicitly tag specs without using automatic inference, set the `:type`
  # metadata manually:
  #
  #     describe ThingsController, :type => :controller do
  #       # Equivalent to being in spec/controllers
  #     end
  config.infer_spec_type_from_file_location!
end
