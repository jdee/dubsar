#  Dubsar Dictionary Project
#  Copyright (C) 2010-13 Jimmy Dee
#
#  This program is free software; you can redistribute it and/or
#  modify it under the terms of the GNU General Public License
#  as published by the Free Software Foundation; either version 2
#  of the License, or (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require 'openssl'
require 'net/http'
require 'yaml'

RSS_LIMIT=30

def send_tweet(tweet, oauth_header)
  base_url = "https://api.twitter.com/1.1/statuses/update.json"
  twitter_url = "#{base_url}?status=#{percent_escape tweet}"

  uri = URI(twitter_url)

  attempt_required = true
  backoff = 8
  start_time = Time.now.to_i
  while attempt_required

    begin
      # About to make an attempt, so set this to false.
      attempt_required = false

      puts "#{DateTime.now} attempting POST to #{base_url}"

      resp = Net::HTTP.start(uri.host, uri.port, use_ssl: true) do |http|
        req = Net::HTTP::Post.new uri
        req['Authorization'] = oauth_header

        http.request req
      end

      puts "#{DateTime.now} #{resp.code} #{resp.message}"

      if resp.code.to_i >= 500 && resp.code.to_i < 600
        # Retry any 5xx error.
        attempt_required = true
      end

    # DEBT: Do SSL/TLS errors fall under either of these?
    rescue SystemCallError, IOError => e
      puts "#{DateTime.now} #{e.inspect}"

      # Failed to connect. Retry.
      attempt_required = true
    rescue => e
      puts "#{DateTime.now} irrecoverable error: #{e.inspect}"
      return
    end

    # Cap retry at 12 hrs
    if Time.now.to_i - start_time >= 12 * 3600
      attempt_required = false
      puts "#{DateTime.now} giving up after 12 hrs."
    end

    return unless attempt_required

    # If we get here, we got a 5xx status code or a connection failure.

    puts "#{DateTime.now} will retry in #{backoff} s"

    sleep backoff

    backoff *= 2
    backoff = 120 if backoff > 120

  end
end

def build_oauth_header(consumer_key, nonce, signature, timestamp, token)
  oauth_header_params = {
    oauth_consumer_key: consumer_key,
    oauth_nonce: nonce,
    oauth_signature: signature,
    oauth_signature_method: "HMAC-SHA1",
    oauth_timestamp: timestamp,
    oauth_token: token,
    oauth_version: "1.0"
  }

  oauth_header = "OAuth "
  oauth_header_params.each do |k, v|
    key = k.to_s
    value = v.to_s
    oauth_header = "#{oauth_header}#{percent_escape key}=\"#{percent_escape value}\", "
  end
  oauth_header.sub(/, $/, '')
end

def build_oauth_signature(consumer_key, consumer_secret, nonce, timestamp,
  token, token_secret, status)

  # puts "oauth_nonce: #{nonce.inspect}"
  # puts "oauth_timestamp: #{timestamp}"

  oauth_params = {
    oauth_consumer_key: consumer_key,
    oauth_nonce: nonce,
    oauth_signature_method: "HMAC-SHA1",
    oauth_timestamp: timestamp,
    oauth_token: token,
    oauth_version: "1.0",
    status: status
  }

  oauth_parameter_string = nil
  oauth_params.each do |k, v|
    key = k.to_s
    value = v.to_s

    if oauth_parameter_string.blank?
      oauth_parameter_string = "#{percent_escape key}=#{percent_escape value}"
    else
      oauth_parameter_string = "#{oauth_parameter_string}&#{percent_escape key}=#{percent_escape value}"
    end
  end

  base_url = "https://api.twitter.com/1.1/statuses/update.json"
  http_method = "POST"

  oauth_signature_base = "#{http_method}&#{percent_escape base_url}&#{percent_escape oauth_parameter_string}"
  oauth_signing_key = "#{percent_escape consumer_secret}&#{percent_escape token_secret}"

  # puts "OAuth signature base: #{oauth_signature_base}"

  digest = OpenSSL::HMAC.digest 'sha1', oauth_signing_key, oauth_signature_base

  Base64.encode64(digest).chomp
end

def percent_escape(data)
  CGI.escape(data.to_s).gsub(/\+/, "%20")
end

namespace :wotd do
  # cheat on strftime formats knowing the server is GMT
  desc 'build the RSS feed for the wotd'
  task :build => :environment do
    build_time = DateTime.now
    File.open(ENV['FILE'] || 'public/wotd.xml', 'w') do |file|
      xml = Builder::XmlMarkup.new :target => file, :indent => 2
      xml.instruct!(:xml, :version => '1.0', :standalone => 'yes')
      xml.rss :version => '2.0', 'xmlns:atom' => 'http://www.w3.org/2005/Atom' do |rss|
        rss.channel do |channel|
          channel.atom :link, :href => 'https://dubsar.info/wotd.xml', :rel => 'self', :type => 'application/rss+xml'
          channel.title 'Dubsar Word of the Day'
          channel.description 'Dubsar Word of the Day News Feed'
          channel.link 'https://dubsar.info'
          channel.lastBuildDate build_time.strftime("%a, %d %b %Y %H:%M:%S GMT")
          channel.pubDate DailyWord.order('created_at DESC').first.created_at.strftime("%a, %d %b %Y %H:%M:%S GMT")
          channel.image do |image|
            image.url 'https://s.dubsar.info/images/dubsar-link.png'
            image.title 'Dubsar Word of the Day'
            image.link 'https://dubsar.info'
            image.description 'Dubsar Word of the Day News Feed'
            image.width '88'
            image.height '20'
          end
          DailyWord.order('created_at DESC').limit(RSS_LIMIT).each do |dw|
            word = dw.word
            channel.item do |item|
              name_and_pos = "#{word.name} (#{word.pos}.)"
              item.title name_and_pos

              description = name_and_pos
              description += " freq. cnt.: #{word.freq_cnt}" if word.freq_cnt > 0
              description += "; also #{word.other_forms}" unless word.other_forms.empty?

              item.description description
              item.link "https://dubsar.info/words/#{word.id}"
              item.guid dw.id, :isPermaLink => 'false'
              item.pubDate dw.created_at.strftime("%a, %d %b %Y %H:%M:%S GMT")
            end
          end
        end
      end
    end
  end

  desc 'generate a new word of the day'
  task :new => :environment do
    word = Word.random_word

    puts "word of the day is #{word.name} (#{word.pos}.) [ID #{word.id}]"
    daily_word = DailyWord.create! :word => word

    Rake::Task['wotd:build'].invoke
  end

  desc 'remove any dev tokens from prod'
  task scrub_prod: :environment do
    # Somehow my development tokens keep getting into prod.
    DeviceToken.where(production:false).each do |dt|
      prod = DeviceToken.find_by_token_and_production dt.token, true
      unless prod.blank?
        puts "#{DateTime.now} deleting #{dt.token} from prod"
        prod.destroy
      end
    end
  end

  desc 'tweet the word of the day'
  task tweet: :environment do
    # 0. Gather params

    # Take tweet from TWEET param or generate a WOTD tweet
    tweet = ENV['TWEET']
    unless tweet
      wotd = DailyWord.word_of_the_day.word
      url = "https://dubsar.info/words/#{wotd.id}"
      tweet = "Word of the day: #{wotd.name_and_pos} #{url}"
    end

    # OAuth params needed for the next two steps

    # Load credentials
    oauth_credentials = YAML::load_file(File.join(Rails.root, 'config', 'twitter_credentials.yml')).symbolize_keys

    oauth_consumer_key = oauth_credentials[:oauth_consumer_key]
    oauth_consumer_secret = oauth_credentials[:oauth_consumer_secret]
    oauth_token = oauth_credentials[:oauth_token]
    oauth_token_secret = oauth_credentials[:oauth_token_secret]

    # Generate a nonce and a timestamp, to be used in building both the signature
    # and the OAuth header.
    oauth_nonce = Base64.encode64(SecureRandom.random_bytes(32)).chomp
    oauth_timestamp = Time.now.to_i

    # 1. Build the OAuth signature
    oauth_signature = build_oauth_signature oauth_consumer_key, oauth_consumer_secret,
      oauth_nonce, oauth_timestamp, oauth_token, oauth_token_secret, tweet

    # puts "oauth_signature: #{oauth_signature.inspect}"

    # 2. Build the OAuth (Authorization) header, including the signature
    oauth_header = build_oauth_header oauth_consumer_key, oauth_nonce, oauth_signature,
      oauth_timestamp, oauth_token

    # puts "Authorization: #{oauth_header}"

    # 3. Send the request
    send_tweet tweet, oauth_header
  end
end
