rails_gems = %w{ activerecord railties }

appraise "rails40" do
  rails_gems.each { |g| gem g, "~> 4.0.0" }
end

appraise "rails41" do
  rails_gems.each { |g| gem g, "~> 4.1.0" }
end

# There was a small change in 4.2.0 that messed us up, which was then fixed in
# 4.2.1, so we're going to test both explicitly.
appraise "rails420" do
  rails_gems.each { |g| gem g, "4.2.0" }
end

appraise "rails421" do
  rails_gems.each { |g| gem g, "~> 4.2.1.rc1" }
end

appraise "railsedge" do
  rails_gems.each { |g| gem g, :github => "rails/rails" }
  gem 'actionview', :github => 'rails/rails'
  gem 'arel', :github => "rails/arel"
end
