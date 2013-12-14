require_relative '../lib/hipbot'

require 'coveralls'
Coveralls.wear!

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:all) do
    Hipbot::User.send(:include, Hipbot::Storages::Hash)
    Hipbot::Room.send(:include, Hipbot::Storages::Hash)
    Hipbot.stub(logger: NullLogger.instance)
  end
end

class NullLogger
  def self.instance
    Logger.new('/dev/null')
  end
end
