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

# For details on the Google subscribed link XML protocol, see
# http://www.google.com/coop/docs/subscribedlinks/xml-simple.html

require 'set'

# assume text does not start with a space
def get_line(text)
  return text if text.length <= 80
  return text[0,80] if text[80] == 32

  text[0,80].sub(/\s[^\s]*$/, '')
end

# Generates a description, breaking it into 80-character lines
# Returns those lines as an array.
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

  word_count = 0
  File.open(ENV['FILE'] || 'public/links.xml', 'w') do |file|
    xml = Builder::XmlMarkup.new :target => file
    xml.Results do |xml|
      xml.AuthorInfo :description => 'Dubsar Dictionary Project subscribed links',
        :author => 'Dubsar Dictionary Project'

      terms = Set.new
      Word.all(:select => 'DISTINCT name',
        :conditions => "name ~* '^[a-z]{9}[a-z]*$'",
        :order => 'name').each do |word|
        term = word.name.downcase
        next if terms.include?(term)
        terms << term

        term = word.name

        xml.ResultSpec :id => term do |xml|
          xml.Query term
          xml.Response do
            xml.Output "Dubsar - #{term}", :name => 'title'
            xml.Output "dubsar-dictionary.com/?term=#{URI.escape term}", :name => 'more_url'

            results(term, Word.search(:term => term, :page => nil)).each_with_index do |line, count|
              xml.Output line, :name => "text#{count+1}"
            end
          end
        end
        word_count += 1
      end
    end
  end
  puts "#{Time.now} Processed #{word_count} words"
end
