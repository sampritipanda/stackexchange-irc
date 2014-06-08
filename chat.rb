require 'cinch'

require_relative 'se-chatty'

class Bridge
  def self.run se_site_id, chatbot_user_id, irc_server, irc_channel, irc_nick="SEBot"
    sec = SEChatty.new 'stackexchange.com', ENV['SE_EMAIL'], ENV['SE_PASSWORD'], se_site_id

    bot = Cinch::Bot.new do
      configure do |c|
        c.server = irc_server
        c.nick = irc_nick
        c.channels = ["#CS_CS169.1x", irc_channel]
      end
    end

    bot.on :message do |m|
      sec.send_message "#{m.user.nick}: #{m.params[1]}"
    end

    bot_thread = Thread.new {
      bot.start
    }
    sec_thread = Thread.new {
      sec.get_messages { |event|
        JSON.parse(event.data).each do |room, data|
          room_number = room.match(/\d+/)[0]
          if data['e']
            data['e'].each do |e|
              p e
              next if e['user_id'] == chatbot_user_id # my chatbot's id
              bot.Channel(irc_channel).send("#{e["user_name"]}: #{e["content"]}") unless e["content"].nil?
            end
          end
        end
      }
    }
    bot_thread.join
    sec_thread.join
  end
end
