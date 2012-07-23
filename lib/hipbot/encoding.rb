require 'socket'
class TCPSocket
  def external_encoding
    Encoding::BINARY
  end
end

require 'rexml/source'
class REXML::IOSource
  alias_method :encoding_assign, :encoding=
  def encoding=(value)
    encoding_assign(value) if value
  end
end

begin
  require 'openssl'
  class OpenSSL::SSL::SSLSocket
    def external_encoding
      Encoding::BINARY
    end
  end
rescue
end
