#!/usr/bin/env rake
require 'bundler/setup'
require 'appraisal'
require 'rspec/core/rake_task'

Bundler::GemHelper.install_tasks

RSpec::Core::RakeTask.new(:test)
task :default => :test
