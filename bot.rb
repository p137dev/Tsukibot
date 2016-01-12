require 'cinch'
require './Tsukibot.rb'

bot = Cinch::Bot.new do
        configure do |cfg|
                cfg.nick = "tsukibot"
                cfg.user = "tsukibot"
                cfg.realname = "#1 moonrune specialist"
                cfg.server = "irc.freenode.net"
                cfg.channels = ["#tsukibot"]
                cfg.plugins.plugins = [Tsukibot]
                cfg.plugins.prefix = ":"
        end
end

bot.start
