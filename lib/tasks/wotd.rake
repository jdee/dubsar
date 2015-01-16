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
    wotd = DailyWord.word_of_the_day.word
    url = "https://dubsar.info/words/#{wotd.id}"

    tweet = "Word of the day: #{wotd.name_and_pos} #{url}"

    twitter_url = "https://api.twitter.com/1.1/statuses/update.json?status=#{CGI.escape tweet}"
    puts twitter_url

    # TODO: OAuth signature & header

    # TODO: POST
  end
end
