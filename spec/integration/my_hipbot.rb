module HipbotHelpers
  def project_name
    "Project: #{room.name}"
  end

  def sender_first_name
    "you are #{message.sender.split[0]}"
  end
end

class AwesomePlugin
  include Hipbot::Plugin

  desc 'respond awesome - responds with awesome'
  on /respond awesome/ do
    reply('awesome responded')
  end
end

class CoolPlugin
  include Hipbot::Plugin

  desc 'respond cool - responds with cool'
  on /respond cool/ do
    reply('cool responded')
  end
end

class MyHipbot < Hipbot::Bot
  configure do |config|
    config.jid     = 'robbot@chat.hipchat.com'
    config.helpers = HipbotHelpers
    config.plugins = [CoolPlugin.instance, AwesomePlugin.instance]
    config.teams   = { vip: ['John Doe', 'Jane Doe'] }
    config.rooms   = { project_rooms: ['Project 1', 'Project 2'] }
  end

  default from: 'Other Guy' do
    reply('What do you mean, Other Guy?')
  end

  default do
    reply("I didn't understand you")
  end

  desc 'greets the user'
  on /^hello hipbot!$/ do
    reply('hello!')
  end

  desc 'he already knows that'
  on /you're (.*), robot/ do |adj|
    reply("I know I'm #{adj}")
  end

  desc 'says hello'
  on /hi everyone!/, global: true do
    reply('hello!')
  end

  desc 'returns project name'
  on /tell me the project name/ do
    reply(project_name)
  end

  desc 'returns sender\'s name'
  on /tell me my name/ do
    reply("you are #{sender.first_name}")
  end

  scope from: 'John Doe' do
    desc 'does John thing'
    on /John Doe thing/ do
      reply('doing John Doe thing')
    end

    scope room: 'Project 1' do
      desc 'does John project thing'
      on /John Doe project thing/ do
        reply('doing John Doe project thing')
      end
    end
  end

  desc 'deploys project'
  on /deploy/, room: :project_rooms do
    reply('deploying')
  end

  desc 'restarts server'
  on /restart/, from: :vip do
    reply('restarting')
  end

  desc 'does room thing'
  on /room thing/, room: true do
    reply('doing room thing')
  end

  desc 'does private thing'
  on /private thing/, room: false do
    reply('doing private thing')
  end
end
