source "https://rubygems.org"
gemspec

gem "appraisal", "~> 1.0.3"

group :test do
  # Ths has to be in the Gemfile, not the gemspec.
  gem "test_after_commit"
  gem 'pry'
  gem "combustion", :github => 'bricker/combustion', :branch => 'fix-recreate'

  gem "sqlite3"
  gem "mysql2"
  gem "pg"
  gem 'rspec-rails', "~> 3.0"
  gem "factory_girl"
  gem "generator_spec", "~> 0.9.1"
end
