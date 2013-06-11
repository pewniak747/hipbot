# Pull out a random image from the Google Images API and display it
# Uses: google_image_api http://rubygems.org/gems/google_image_api
# Author Rushi Vishavadia <rushi.v@gmail.com>

require 'hipbot'
require 'google_image_api'

class SampleBot < Hipbot::Bot
  configure do |c|
    c.jid = ENV['HIPBOT_JID']
    c.password = ENV['HIPBOT_PASSWORD']
  end

  on /\Aimage (.+)/i do |img_str|
    max = 8 # max number of results you want to pull a random
    puts img_str
    begin
      results = GoogleImageApi.find(img_str, :rsz => max)
      if results.raw_data["responseStatus"] == 200 and results.images.size > 0
        reply(results.images.take(max).sample['unescapedUrl'])
      elsif results.raw_data["responseStatus"] == 200 and results.images.size == 0
        reply("I'm sorry I couldn't find an image for #{img_str}")
      else
        reply("I'm sorry, an error occurred. Try again please") # Most likely a 403
      end
    rescue => e
      reply("I'm sorry, an error occurred trying to find that image")
      p e.message
      p e.backtrace
    end
  end
end

SampleBot.start!
