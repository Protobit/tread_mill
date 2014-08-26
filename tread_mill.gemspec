$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "tread_mill/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "tread_mill"
  s.version     = TreadMill::VERSION
  s.authors     = ["Terry Meacham"]
  s.email       = ["zv1n.fire@gmail.com"]
  s.homepage    = "http://www.protobit.com"
  s.summary     = "Easy Sneakers/ActiveJob integration."
  s.description = "Easy Sneakers/ActiveJob integration."
  s.license     = "BSD 3-Clause"

  s.files = Dir["{app,config,db,lib}/**/*", "LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.5"
  s.add_dependency "sneakers", "~> 0.1.1.pre"

  # This should go away with Rails 4.2.0.beta1
  s.add_dependency "activejob"

  s.add_development_dependency "sqlite3"
end
