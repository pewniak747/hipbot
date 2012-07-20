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
end
