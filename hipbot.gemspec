# -*- encoding: utf-8 -*-
require File.expand_path('../lib/hipbot/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Bartosz Kopiński", "Tomasz Pewiński"]
  gem.email         = ["bartosz.kopinski@netguru.pl", "pewniak747@gmail.com"]
  gem.description   = "Hipbot is a XMPP bot for HipChat, written in Ruby with EventMachine."
  gem.summary       = "Hipbot is a XMPP bot for HipChat, written in Ruby with EventMachine."
  gem.homepage      = "http://github.com/pewniak747/hipbot"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "hipbot"
  gem.require_paths = ["lib"]
  gem.version       = Hipbot::VERSION
  gem.add_runtime_dependency "xmpp4r-hipchat", [">= 0.0.1"]
  gem.add_runtime_dependency "daemons", [">= 1.1.8"]
  gem.add_runtime_dependency "activesupport", [">= 3.2.12"]
  gem.add_runtime_dependency "eventmachine", [">= 1.0.3"]
  gem.add_runtime_dependency "em-http-request", [">= 1.0.3"]
  gem.add_runtime_dependency "xmpp4r", ["~> 0.5"]
  gem.add_development_dependency "rspec", ['~> 2.13.0']
  gem.add_development_dependency "guard-rspec", ['~> 2.5.1']
  gem.add_development_dependency "mocha", ['~> 0.13.3']
end
