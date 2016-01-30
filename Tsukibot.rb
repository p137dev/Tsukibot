require 'nokogiri'
require 'open-uri'
require 'mojinizer'
require "addressable/uri"


class Tsukibot
	include Cinch::Plugin

	match "help", method: :help
	match /en_to_jp (.+) (\d?)/, method: :en_to_jp_lookup
	match /(.+) in Japanese, (\d?)/, method: :en_to_jp_lookup, use_prefix: false
	match /en_to_jp (.+)/, method: :en_to_jp_enumerate
	match /(.+) in Japanese/, method: :en_to_jp_enumerate, use_prefix: false
	match /jp_to_en (.+)/, method: :jp_to_en
	match /(.+) from Japanese/, method: :jp_to_en, use_prefix: false
	match /hiraganize (.+)/, method: :hiraganize
	match /katakanize (.+)/, method: :katakanize
	match /aesthetic (.+)/, method: :aesthetic, use_prefix: false
	match "jikan", method: :jikan
	match /(nervous|sad|poor|happy|angry|excited|love) emoji/, method: :emoji, use_prefix: false
	match /ground control/, method: :bowie, use_prefix: false
	match /¥(\d+)/, method: :jpy, use_prefix: false
	match /(\d+) JPY/, method: :jpy, use_prefix: false
	match /(\d+) yen/, method: :jpy, use_prefix: false


	def help(m)
		#I should probably make better formatting here.
		m.reply('AVAILABLE COMMANDS: en_to_jp <word> <dict_entry>, "<word> in Japanese, <entry>", jp_to_en <word>, "<word> from Japanese", hiraganize <word>, katakanize <word>, aesthetic <word>, jikan, "<emotion> emoji". Apostrophes mark prefixless commands.', "#{m.user.nick}: ")
	end

	def en_to_jp_enumerate(m, word)
		raw_page = open("http://classic.jisho.org/words?jap=&eng=#{word}&dict=edict&common=on")
		jisho_page = Nokogiri.HTML(raw_page.read)
		entries = jisho_page.css("div.pagination").text.strip
		entries = /\d/.match(entries)[0].to_i
		m.reply("Found #{entries} entries.", m.user.nick + ": ")
	end


	def en_to_jp_lookup(m, word, entry)

		entry = entry.to_i - 1

		raw_page = open("http://classic.jisho.org/words?jap=&eng=#{word}&dict=edict&common=on")
		jisho_page = Nokogiri.HTML(raw_page.read)

		entries = jisho_page.css("div.pagination").text.strip
		entries = /\d/.match(entries)[0].to_i

		if entries != 0

			if entry < entries and entry >= 0
				kanji = jisho_page.css("td.kanji_column")[entry].text.strip
				kana = jisho_page.css("td.kana_column")[entry].text.strip
				meanings = jisho_page.css("td.meanings_column")[entry].text.split(";").join("; ")

				kanji = "-" if kanji.empty?
				m.reply("Found #{entries} definitions. Displaying definition \##{entry + 1}.", m.user.nick + ": ")
				m.reply([kanji, kana, kana.romaji].join(" | "))
				m.reply meanings
			else
				m.reply("Incorrect entry number.", "#{m.user.nick}: ")
			end

		else
			m.reply("Found no definitions.", m.user.nick + ": ")
		end

  end

	def jp_to_en(m, word)

		unless word.contains_kana? and word.contains_kanji?
			if word.contains_kanji?
				raw_uri = Addressable::URI.parse("http://classic.jisho.org/kanji/details/#{word}")
				raw_page = open(raw_uri.normalize).read
				jisho_page = Nokogiri.HTML(raw_page)
				kanji = jisho_page.css("div.english_meanings").css("p").text.strip.split(";").join("; ")
				m.reply(kanji, m.user.nick + ": ")
			else
				raw_uri = Addressable::URI.parse("http://classic.jisho.org/words?jap=#{word}&eng=&dict=edict&common=on")
				raw_page = open(raw_uri.normalize).read
				jisho_page = Nokogiri.HTML(raw_page)
				entries = jisho_page.css("div.pagination").text.strip
				entries = /\d/.match(entries)[0].to_i

				if entries == 0
					m.reply("Sorry, no dice. Try different spelling?", "#{m.user.nick}: ")
				else
					kanji = jisho_page.css("td.kanji_column")[0].text.strip
					kanji = "-" if kanji.empty?
					kana = jisho_page.css("td.kana_column")[0].text.strip
					meanings = jisho_page.css("td.meanings_column")[0].text.split(";").join("; ")
					m.reply([kanji, kana, kana.romaji].join(" | "), m.user.nick + ": ")
					m.reply meanings
				end
			end
		else
				m.reply "Input contains both kanji and kana. You have to translate kanji and kana separately."
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

	def jpy(m, amount)
		currency_page = Nokogiri.HTML(open("http://www.google.com/finance/converter?a=#{amount.to_i}&from=JPY&to=USD"))
		m.reply "(that's #{currency_page.css("span.bld").text})"
	end

end
