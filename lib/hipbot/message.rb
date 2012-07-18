module Hipbot
  class Message
    attr_accessor :body, :sender, :raw_body
    def initialize body, sender
      self.raw_body = body
      self.body = strip_recipient(body)
      self.sender = sender
    end

    def recipients
      results = raw_body.scan(/@(\w+)/) + raw_body.scan(/@"(.*)"/)
      results.flatten
    end

    def for? recipient
      recipients.include? recipient.to_s.gsub(/\s+/, '')
    end

    def strip_recipient body
      body.gsub(/^@\w+\W*/, '')
    end
  end
end
