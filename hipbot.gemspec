# -*- encoding: utf-8 -*-
require File.expand_path('../lib/hipbot/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Tomasz Pewiński"]
  gem.email         = ["pewniak747@gmail.com"]
  gem.description   = "Hipbot is a bot for HipChat, written in ruby & eventmachine."
  gem.summary       = "Hipbot is a bot for HipChat, written in ruby & eventmachine."
  gem.homepage      = "http://github.com/pewniak747/hipbot"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "hipbot"
  gem.require_paths = ["lib"]
  gem.version       = Hipbot::VERSION
  gem.add_runtime_dependency "daemons", ["~> 1.1.8"]
  gem.add_runtime_dependency "active_support", ["~> 3.0.0"]
  gem.add_runtime_dependency "i18n", ["~> 0.6.0"]
  gem.add_runtime_dependency "eventmachine", ["~> 0.12.10"]
  gem.add_runtime_dependency "em-http-request", ["~> 0.3.0"]
  gem.add_runtime_dependency "xmpp4r", ["~> 0.5"]
end
