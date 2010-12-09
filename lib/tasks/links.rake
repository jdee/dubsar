#  Dubsar Dictionary Project
#  Copyright (C) 2010 Jimmy Dee
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

# For details on the Google subscribed link XML protocol, see
# http://www.google.com/coop/docs/subscribedlinks/xml-simple.html

# assume text does not start with a space
def get_line(text)
  return text if text.length <= 80
  return text[0,80] if text[80] == 32

  text[0,80].sub(/\s[^\s]*$/, '')
end

def results(term, words)
  @s = words.map do |word|
    result = "#{word.name}, #{word.pos}."
    result += " (#{word.other_forms})" unless word.other_forms.empty?
    result
  end.join("; ")

  lines = []
  3.times do
    line = get_line @s
    lines << line
    break if line.length == @s.length

    @s = @s[line.length+1,@s.length-line.length-1]
  end

  lines
end

desc 'build XML for Google subscribed links'
task :links => :environment do
  puts "#{Time.now} Starting"
  STDOUT.flush

  File.open('public/links.xml', 'w') do |file|
    xml = Builder::XmlMarkup.new :target => file
    xml.Results do |xml|
      xml.AuthorInfo :description => 'Dubsar Dictionary Project subscribed links', :author => 'Dubsar Dictionary Project'

      # We're limited to an overall total of 10 MB.  This condition is
      # an effort at identifying words that are obscure, hence both
      # interesting and likely to be searched for.  There's little
      # point in having a subscribed link for "well."  To limit the
      # data sample and meet the overall limit, while still
      # representing the lion's share of the data, we select nouns
      # (which make up the bulk of WordNet) that are single,
      # uncapitalized, unpunctuated words, i.e. all lower case with no
      # hyphens or other punctuation.  We select only those with a
      # frequency count of 0 and at least a certain number of letters.

      # Don't need :select => 'DISTINCT name' here because everything
      # is all lower case and only nouns, so the names are all unique.
      Word.all(:conditions => "name ~ '^[a-z]{10}[a-z]*$' AND part_of_speech = 'noun' AND freq_cnt = 0",
        :order => 'name').each do |word|
        term = word.name

        xml.ResultSpec :id => term do |xml|
          xml.Query term
          xml.Response do
            xml.Output "Dubsar - #{term}", :name => 'title'
            xml.Output "dubsar-dictionary.com/?term=#{URI.escape term}", :name => 'more_url'
            xml.Output "http://s.dubsar-dictionary.com/images/dg.png", :name => 'image_src'
            xml.Output 'mini_square', :name => 'image_size'

            count = 1
            results(term, Word.search(:term => term, :page => nil)).each do |line|
              xml.Output line, :name => "text#{count}"
              count += 1
            end
          end
        end
      end
    end
  end
  puts "#{Time.now} Done"
end
