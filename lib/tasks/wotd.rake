#  Dubsar Dictionary Project
#  Copyright (C) 2010-11 Jimmy Dee
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

RSS_LIMIT=10

# cheat on strftime formats knowing the server is GMT
def build_rss
  build_time = DateTime.now
  File.open(ENV['FILE'] || 'public/wotd.xml', 'w') do |file|
    xml = Builder::XmlMarkup.new :target => file
    xml.instruct! :xml, :version => '1.0', :standalone => 'yes', :encoding => 'UTF-8'
    xml.rss :version => '2.0', 'xmlns:atom' => 'http://www.w3.org/2005/Atom' do |rss|
      rss.channel do |channel|
        channel.atom :link, :href => 'http://dubsar-dictionary.com/wotd.xml', :rel => 'self', :type => 'application/rss+xml'
        channel.title 'Dubsar Word of the Day'
        channel.description 'Dubsar Word of the Day News Feed'
        channel.link 'http://dubsar-dictionary.com'
        channel.lastBuildDate build_time.strftime("%a, %d %b %Y %H:%M:%S GMT")
        channel.pubDate build_time.strftime("%a, %d %b %Y %H:%M:%S GMT")
        channel.image do |image|
          image.url 'http://s.dubsar-dictionary.com/images/dubsar-link.png'
          image.title 'Dubsar Word of the Day'
          image.link 'http://dubsar-dictionary.com'
          image.description 'Dubsar Word of the Day News Feed'
          image.width '88'
          image.height '20'
        end
        DailyWord.all(:order => 'created_at DESC', :limit => RSS_LIMIT).each do |dw|
          word = dw.word
          channel.item do |item|
            name_and_pos = "#{word.name} (#{word.pos}.)"
            item.title name_and_pos

            description = name_and_pos
            description += " freq. cnt.: #{word.freq_cnt}" if word.freq_cnt > 0
            description += "; also #{word.other_forms}" unless word.other_forms.empty?

            item.description description
            item.link "http://dubsar-dictionary.com/words/#{word.id}"
            item.guid dw.id, :isPermaLink => 'false'
            item.pubDate build_time.strftime("%a, %d %b %Y %H:%M:%S GMT")
          end
        end
      end
    end
  end
end

desc 'generate a new word of the day'
task :wotd => :environment do
  word = Word.random_word

  puts "word of the day is #{word.name} (#{word.pos}.) [ID #{word.id}]"
  DailyWord.create! :word => word

  build_rss
end
