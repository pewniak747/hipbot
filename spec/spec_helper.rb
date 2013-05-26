require_relative '../lib/hipbot'

require 'coveralls'
Coveralls.wear!

RSpec.configure do |config|
  config.mock_with :mocha
end

Hipbot.logger.level = Logger::FATAL
