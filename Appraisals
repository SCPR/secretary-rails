rails_gems = %w{ activerecord railties }

appraise "rails40" do
  rails_gems.each { |g| gem g, "~> 4.0.0" }
end

appraise "rails41" do
  rails_gems.each { |g| gem g, "~> 4.1.0" }
end

appraise "railsedge" do
  rails_gems.each { |g| gem g, :github => "rails/rails" }
  gem 'actionview', :github => 'rails/rails'
  gem 'arel', :github => "rails/arel"
end
