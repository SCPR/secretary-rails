$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "secretary/gem_version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "secretary-rails"
  s.version     = Secretary::GEM_VERSION
  s.authors     = ["Bryan Ricker"]
  s.email       = ["bricker@scpr.org"]
  s.homepage    = "https://github.com/scpr/secretary-rails"
  s.summary     = "Light-weight model versioning for ActiveRecord."
  s.description = "A Rails engine that provides simple versioning for " \
                  "your records."

  s.files = Dir["{app,config,db,lib}/**/*"] +
            ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", ">= 3.2.0"
  s.add_dependency "diffy", "~> 3.0.1"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "combustion"
  s.add_development_dependency "factory_girl"
end
