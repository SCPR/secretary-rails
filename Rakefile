#!/usr/bin/env rake
RAKED = true

require 'rubygems'
require 'bundler/setup'

require 'appraisal'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks

# Latest Rails version + SQLite (default db)
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = "--format progress --colour --no-profile"
  t.verbose = false
end

# Full test suite!
desc "Run the full test suite (All supported Rails version, all supported DBs)."
task :test do
  sh "bundle exec appraisal rake test:db:all"
end

databases = %w(sqlite mysql postgresql)

namespace :test do
  desc "Setup your databases to run the tests. " \
       "You should only need to run this once."
  task :setup do
    load 'spec/support/test_setup.rb'
    TestSetup.setup

    databases.each do |database|
      $stdout.puts "*** [secretary] Setting up #{database}"
      TestSetup.move_database_config(database)
      TestSetup.load_database_config
      Combustion::Database.reset_database
    end

    TestSetup.remove_database_config
  end


  namespace :db do
    databases.each do |database|
      desc "Run tests against latest stable Rails + #{database}"
      task database do
        sh "bundle exec rake spec DB=#{database}"
      end
    end

    desc "Run tests against latest stable Rails + all databases"
    task :all => databases
  end
end
