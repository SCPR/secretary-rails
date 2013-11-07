gems = %w{ activerecord railties }

appraise "rails32" do
  gems.each { |g| gem g, "~> 3.2.0" }
end

appraise "rails40" do
  gems.each { |g| gem g, "~> 4.0.0" }
end

appraise "railsedge" do
  gems.each { |g| gem g, :github => "rails/rails" }
  gem 'actionview', :github => 'rails/rails'
end
