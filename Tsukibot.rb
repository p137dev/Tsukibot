require 'nokogiri'
require 'open-uri'
require 'mojinizer'


class Tsukibot
	include Cinch::Plugin

	match "help", method: :help
	match /en_to_jp (.+) (\d?)/, method: :en_to_jp
	match /(.+) in Japanese, (\d?)/, method: :en_to_jp, use_prefix: false
	match /jp_to_en (.+)/, method: :jp_to_en
	match /(.+) from Japanese/, method: :jp_to_en, use_prefix: false
	match /hiraganize (.+)/, method: :hiraganize
	match /katakanize (.+)/, method: :katakanize
	match /aesthetic (.+)/, method: :aesthetic, use_prefix: false
	match "jikan", method: :jikan
	match /(bleak|uncertain|beautiful|sad|happy|angry|excited|love) emoji/, method: :emoji, use_prefix: false
	match /ground control/, method: :bowie, use_prefix: false

	def help(m)
		#I should probably make better formatting here.
		m.reply('AVAILABLE COMMANDS: en_to_jp <word> <dict_entry>, "<word> in Japanese, <entry>", jp_to_en <word>, "<word> from Japanese", hiraganize <word>, katakanize <word>, aesthetic <word>, jikan, "<emotion> emoji". Apostrophes mark prefixless commands.', "#{m.user.nick}: ")
	end

	def en_to_jp(m, word, entry)

		entry = entry.to_i - 1

		raw_page = open("http://classic.jisho.org/words?jap=&eng=#{word}&dict=edict&common=on")
		jisho_page = Nokogiri.HTML(raw_page.read)

		entries = jisho_page.css("div.pagination").text.strip
		entries = /\d/.match(entries)[0].to_i

		m.reply("Found #{entries} definitions.", "#{m.user.nick}: ")

		if entries != 0

			if entry < entries and entry >= 0
				kanji = jisho_page.css("td.kanji_column")[entry].text.strip
				kana = jisho_page.css("td.kana_column")[entry].text.strip
				meanings = jisho_page.css("td.meanings_column")[entry].text.split(";").join(" | ")

				kanji = "-" if kanji.empty?
				m.reply("Displaying definition \##{entry + 1}.", "#{m.user.nick}: ")
				m.reply("| #{kanji} | #{kana} | #{kana.romaji} | #{meanings} |", "#{m.user.nick}: ")
			else
				m.reply("Incorrect entry number.", "#{m.user.nick}: ")
			end

		end

  end

	def jp_to_en(m, word)

		raw_page = open("http://classic.jisho.org/words?jap=#{word}&eng=&dict=edict&common=on&romaji=on")
		jisho_page = Nokogiri.HTML(raw_page.read)
		entries = jisho_page.css("div.pagination").text.strip
		entries = /\d/.match(entries)[0].to_i

		if entries == 0
			m.reply("Sorry, no dice. Try different spelling?", "#{m.user.nick}: ")
		else
			kanji = jisho_page.css("td.kanji_column")[0].text.strip
			romaji = jisho_page.css("td.kana_column")[0].text.strip
			meanings = jisho_page.css("td.meanings_column")[0].text.split(";").join(" | ")

			m.reply("| #{kanji} | #{romaji} | #{meanings} |", "#{m.user.nick}: ")
		end

	end

	def hiraganize(m, word)
		m.reply(word.hiragana, "#{m.user.nick}: ")
	end

	def katakanize(m, word)
		m.reply(word.katakana, "#{m.user.nick}: ")
	end

	def aesthetic(m, word)
		m.reply word.han_to_zen
	end

	def jikan(m)
		m.reply(Time.now.getlocal('+09:00'), "#{m.user.nick}: ")
	end

	def emoji(m, emotion)

		# This will most likely cease to work soon. Sorry.

		case emotion
		when "sad"
			raw_page = open("http://hexascii.com/sad-emoticons/")
		when "angry"
			raw_page = open("http://hexascii.com/angry-japanese-emoticons/")
		when "happy"
			raw_page = open("http://hexascii.com/happy-japanese-emoticons/")
		when "excited"
			raw_page = open("http://hexascii.com/excited-emoticons-emojis/")
		when "love"
			raw_page = open("http://hexascii.com/love-japanese-emoticons/")
		end

		emoji_page = Nokogiri.HTML(raw_page.read)
		emoji = emoji_page.css("tr").text.split("\n").reject!{|emoji| emoji == ""}
		m.reply emoji.sample
	end

	def bowie(m)

		m.reply [
  							"take your protein pills and put your helmet on",
  							"can you hear me major tom",
  							"now it's time to leave the capsule if you dare",
								"planet earth is blue and there's nothing i can do",
								"can you hear me major tom",
								"and i'm floating around my tin can"

						].sample
	end

end
