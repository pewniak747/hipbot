require_relative '../lib/hipbot'

require 'coveralls'
Coveralls.wear!

RSpec.configure do |config|
  config.mock_with :mocha

  config.before(:all) do
    Hipbot::Bot.instance.configuration.logger = NullLogger.instance
  end
end

class NullLogger
  def self.instance
    Logger.new('/dev/null')
  end
end
