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

%w{adj adv noun verb}.each do |sfx|
  part_of_speech = case sfx
  when 'adj'
    'adjective'
  when 'adv'
    'adverb'
  else
    sfx
  end

  puts "#{Time.now} loading #{part_of_speech.pluralize}"
  synset_count = 0
  File.open(File.join(File.dirname(__FILE__), 'defaults', "data.#{sfx}")).each do |line|
    next if line =~ /^\s/

    left, defn = line.split('| ')
    synset_offset, lex_filenum, ss_type, w_cnt, *rest = left.split(' ')
    w_cnt = w_cnt.to_i

    synset = Synset.new :definition => defn.chomp
    rest.slice(0, 2*w_cnt).each_slice(2) do |a|
      s = a[0].gsub('_', ' ')
      synonym = Word.find_by_name_and_part_of_speech s, part_of_speech
      next if synonym and synset.words << synonym

      synset.words.build :name => s, :part_of_speech => part_of_speech
    end
    synset.save
    synset_count += 1
  end
  puts "#{Time.now} loaded #{Word.count(:conditions => { :part_of_speech => part_of_speech})} #{part_of_speech.pluralize} (#{synset_count} synsets)"
end
