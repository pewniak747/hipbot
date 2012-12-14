# Pull out a random image from the Google Images API and display it
# Uses: google_image_api http://rubygems.org/gems/google_image_api
# Author Rushi Vishavadia <rushi.v@gmail.com>

require 'hipbot'
require 'google_image_api'

class SampleBot < Hipbot::Bot
  configure do |c|
    c.jid = ENV['HIPBOT_JID']
    c.password = ENV['HIPBOT_PASSWORD']
    c.name = ENV['HIPBOT_NAME']
  end

  on /^image (.*)/i do |img_str|
        require 'google_image_api'
        max = 8
        # TODO: Wrap it up in a try/catch
        if img_str != ""
            results = GoogleImageApi.find(img_str, :rsz => max)
            if results.raw_data["responseStatus"] == 200
                rand_max = (max > results.images.size) ? results.images.size : max
                rand_loc = rand(rand_max)
                reply(results.images[rand_loc]['unescapedUrl'])
            else
                reply('An error occurred, try again please')
            end
        end
    end
end

SampleBot.start!
