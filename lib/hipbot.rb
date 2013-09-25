require 'active_support/concern'
require 'active_support/core_ext/module/delegation'
require 'active_support/core_ext/array/extract_options'
require 'active_support/core_ext/hash/indifferent_access'
require 'ostruct'
require 'eventmachine'
require 'em-http-request'
require 'xmpp4r/muc/hipchat_client'

require 'hipbot/cache'
require 'hipbot/patches/encoding'
require 'hipbot/logger'
require 'hipbot/callbacks/base'
require 'hipbot/callbacks/private_message'
require 'hipbot/callbacks/message'
require 'hipbot/callbacks/presence'
require 'hipbot/callbacks/invite'
require 'hipbot/adapter'
require 'hipbot/adapters/hipchat/initializer'
require 'hipbot/adapters/hipchat'
require 'hipbot/adapters/telnet'
require 'hipbot/adapters/shell'
require 'hipbot/reaction_factory'
require 'hipbot/reactable'
require 'hipbot/configuration'
require 'hipbot/bot'
require 'hipbot/plugin'
require 'hipbot/storages/hash'
require 'hipbot/storages/mongoid'
require 'hipbot/http'
require 'hipbot/helpers'
require 'hipbot/match'
require 'hipbot/message'
require 'hipbot/reaction'
require 'hipbot/response'
require 'hipbot/room'
require 'hipbot/user'
require 'hipbot/version'
