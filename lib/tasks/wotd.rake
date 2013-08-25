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

require 'net/https'
require 'yaml'

RSS_LIMIT=30

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
          channel.atom :link, :href => 'https://dubsar-dictionary.com/wotd.xml', :rel => 'self', :type => 'application/rss+xml'
          channel.title 'Dubsar Word of the Day'
          channel.description 'Dubsar Word of the Day News Feed'
          channel.link 'https://dubsar-dictionary.com'
          channel.lastBuildDate build_time.strftime("%a, %d %b %Y %H:%M:%S GMT")
          channel.pubDate DailyWord.first(:order => 'created_at DESC').created_at.strftime("%a, %d %b %Y %H:%M:%S GMT")
          channel.image do |image|
            image.url 'https://s.dubsar-dictionary.com/images/dubsar-link.png'
            image.title 'Dubsar Word of the Day'
            image.link 'https://dubsar-dictionary.com'
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
              item.link "https://dubsar-dictionary.com/words/#{word.id}"
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

    # Send a broadcast push
    uri = URI('https://go.urbanairship.com/api/push/broadcast/')
    request = Net::HTTP::Post.new(uri.path)

    airship_config = YAML::load_file("config/airship_config.yml").symbolize_keys!

    request.set_content_type "application/json"
    request.body = { :aps => { :alert =>
        "Word of the day: #{word.name_and_pos}",
        :badge => "+1",
        :sound => "default" },
      :dubsar => {
        :type => "wotd",
        :url => "dubsar:///wotd/#{word.id}",
        :expiration => (daily_word.created_at+1.day+1.minute).to_i
      }
    }.to_json

    ["development","production"].each do |environment|
      app_key = airship_config["#{environment}_app_key".to_sym]
      master_secret = airship_config["#{environment}_master_secret".to_sym]
      next unless app_key && master_secret

      request.basic_auth app_key, master_secret

      puts "POST #{uri} [#{environment}]"

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      response = http.request request

      puts "HTTP status code #{response.code}"
    end

    Rake::Task['wotd:build'].invoke
  end

  desc 'get active production device tokens'
  task :prod => :environment do
    uri = URI("https://go.urbanairship.com/api/device_tokens/")
    request = Net::HTTP::Get.new(uri.path)

    airship_config = YAML::load_file("config/airship_config.yml").symbolize_keys!

    request.set_content_type "application/json"
    app_key = airship_config[:production_app_key]
    app_master_secret = airship_config[:production_master_secret]
    puts "not configured" and return if app_key.nil? || app_master_secret.nil?

    request.basic_auth app_key, app_master_secret

    puts "GET #{uri} [prod]"

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    response = http.request request

    puts "HTTP status code #{response.code}"

    if response.code == "200"
      tokens = JSON::parse(response.body).symbolize_keys!
      puts "#{tokens[:active_device_tokens_count]} active device tokens"
      overlap = false
      tokens[:device_tokens].each do |t|
        t.symbolize_keys!
        next unless t[:active]

        token = t[:device_token].downcase
        next if DeviceToken.find_by_token_and_production(token, true).blank?

        puts "#{token} is in production DT list"
        overlap = true
      end
      puts "no overlap with #{DeviceToken.where(production:true).count} tokens in DB" unless overlap
    end
  end
end
