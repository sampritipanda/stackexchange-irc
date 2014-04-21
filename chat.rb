require 'debugger'
require 'cinch'

require_relative 'se-chatty'

sec = SEChatty.new 'stackexchange.com', ENV['SE_CHAT_EMAIL'], ENV['SE_CHAT_PASSWORD'], 13843

bot = Cinch::Bot.new do
  configure do |c|
    c.server = "cs1692x.moocforums.org"
    c.nick = "SEBot"
    c.channels = ["#CS_CS169.1x"]
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
          next if e['user_id'] == 115411 # my chatbot's id
          bot.Channel("#CS_CS169.1x").send("#{e["user_name"]}: #{e["content"]}")
        end
      end
    end
  }
}
bot_thread.join
sec_thread.join