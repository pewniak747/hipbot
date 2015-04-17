require 'rspec/its'

require_relative '../lib/hipbot'

begin
  require 'coveralls'
  Coveralls.wear!
rescue LoadError
end

RSpec.configure do |config|
  config.mock_with :rspec

  config.before(:all) do
    Hipbot::User.send(:include, Hipbot::Storages::Hash)
    Hipbot::Room.send(:include, Hipbot::Storages::Hash)
  end
end
