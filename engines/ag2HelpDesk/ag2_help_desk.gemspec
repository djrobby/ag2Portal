$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "ag2_help_desk/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "ag2_help_desk"
  s.version     = Ag2HelpDesk::VERSION
  s.authors     = ["Nestor Rodriguez Maldonado"]
  s.email       = ["nestor@aguaygestion.com"]
  s.homepage    = "http://agestiona2.aguaygestion.com"
  s.summary     = "Summary of Ag2HelpDesk."
  s.description = "Description of Ag2HelpDesk."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.12"
  # s.add_dependency "jquery-rails"

  s.add_development_dependency "mysql2"
end
