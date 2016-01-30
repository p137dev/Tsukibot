# Tsukibot
## Introduction
Tsukibot is a Ruby Cinch plugin written to make learning/understanding Japanese easier. It also has some "vanity" functions.

## Commands

__The default prefix for the commands is ":".__


- `en_to_jp <word> <entry>` or `<word> in Japanese, <entry>`

Translates a word in English to Japanese, giving you its kanji, hiragaka/katakana, romaji and definition. The second method works without a prefix.


- `jp_to_en <word> <entry>` or `<word> from Japanese`

Translates a Japanese word (in romaji or symbols) using Denshi Jisho. The second method works without a prefix.


- `hiraganize <word>`

Converts romaji to hiragana.


- `katakanize <word>`

Converts romaji to katakana.


- `jikan`

Tells the user the current time in Japan.


- `aesthetic <word>`

Returns the word in full-width Unicode. Works without a prefix.


- `<emotion> emoji`

Fetches an emoji from an external website and sends it to the channel.

- `¥<number>` or `<number> yen` or `<number> JPY`

Converts JPY to USD using Google Finance. Works without a prefix.

## Requirements
- Ruby (confirmed to work on Ruby 1.9.3)
- Cinch
- Nokogiri
- Mojinizer
- Addressable
- Bundler (if you don't want to install dependencies manually)

## Installation
1. `git clone` this repository.

2. Run `bundle install` to install dependencies. If you don't have Bundler installed, you can either `gem install bundler` or `gem install` dependencies manually.

3. Edit appropiate values in the `bot.rb` file.

4. Run the bot with `ruby bot.rb`.

## Configuration
For advanced configuration refer to Cinch documentation.

## Disclaimer
This plugin scrapes the Classic Denshi Jisho, because there's no API for it yet. I'll probably rewrite this plugin when the Jisho's API is finished.
