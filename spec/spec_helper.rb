require_relative '../lib/hipbot'

# require 'coveralls'
# Coveralls.wear!

RSpec.configure do |config|
  config.mock_with :mocha

  # config.before(:all) do
  #   Hipbot::Bot.instance.configuration.logger = Logger.new($stdout)
  # end
end

class NullLogger
  def self.instance
    Logger.new('/dev/null')
  end
end
