$:.push File.expand_path("../lib", __FILE__)

require "secretary/gem_version"

Gem::Specification.new do |s|
  s.name        = "secretary-rails"
  s.version     = Secretary::GEM_VERSION
  s.authors     = ["Bryan Ricker"]
  s.email       = ["bricker@scpr.org"]
  s.homepage    = "https://github.com/scpr/secretary-rails"
  s.license     = "MIT"
  s.summary     = "Light-weight model versioning for ActiveRecord."
  s.description = "A Rails engine that provides simple versioning for " \
                  "your records."

  s.files = Dir["{app,config,db,lib}/**/*"] +
            ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "railties", [">= 4.0.0", "< 6"]
  s.add_dependency "activerecord", [">= 4.0.0", "< 6"]
  s.add_dependency "diffy", [">= 3.0", "< 4"]

  s.add_development_dependency 'bundler', ['>= 1.7.0', '< 2']
end
