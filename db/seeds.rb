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
@sense_index = Hash.new(0)
@lexnames = {}

File.open(File.expand_path('defaults/lexnames', File.dirname(__FILE__))).each do |line|
  number, name, pos_index = line.chomp.split
  @lexnames[number] = name
end

File.open(File.expand_path('defaults/index.sense', File.dirname(__FILE__))).each do |line|
  sense_key, synset_offset, sense_number, tag_cnt = line.chomp.split
  next if tag_cnt == '0'

  lemma, lex_sense = sense_key.split '%'
  ss_type, lex_filenum, lex_id, head_word, head_id = lex_sense.split ':'
  part_of_speech= case ss_type.to_i
  when 1
    'noun'
  when 2
    'verb'
  when 3,5
    'adjective'
  when 4
    'adverb'
  end

  # one big string
  key = part_of_speech + '_' + synset_offset + '_' + lemma
  @sense_index[key.to_s] = tag_cnt.to_i
end

%w{adj adv noun verb}.each do |sfx|
  part_of_speech = case sfx
  when 'adj'
    'adjective'
  when 'adv'
    'adverb'
  else
    sfx
  end

  @irregular_inflections = {}
  File.open(File.expand_path("defaults/#{sfx}.exc", File.dirname(__FILE__))).each do |line|
    i, *_w = line.chomp.split

    _w.each do |w|
      @irregular_inflections[w.to_sym] ||= []
      inflections = @irregular_inflections[w.to_sym]

      inflections << i.gsub('_', ' ')
    end
  end
  puts "#{Time.now} loaded irregular #{part_of_speech} inflections"

  puts "#{Time.now} loading #{part_of_speech.pluralize}"
  synset_count = 0
  sense_count = 0
  File.open(File.expand_path("defaults/data.#{sfx}", File.dirname(__FILE__))).each do |line|
    next if line =~ /^\s/

    left, defn = line.split('| ')
    synset_offset, lex_filenum, ss_type, w_cnt, *rest = left.split(' ')
    w_cnt = w_cnt.to_i(16)

    synset = Synset.new :definition => defn.chomp,
      :offset => synset_offset.sub(/^0+/, '').to_i,
      :lexname => @lexnames[lex_filenum],
      :part_of_speech => part_of_speech
    rest.slice(0, 2*w_cnt).each_slice(2) do |a|
      s = a[0].gsub('_', ' ')
      synonym = Word.find_by_name_and_part_of_speech(s, part_of_speech) ||
        Word.create(:name => s, :part_of_speech => part_of_speech, :irregular => @irregular_inflections[s.gsub(' ', '_').to_sym])
      key = part_of_speech + '_' + synset_offset + '_' + s
      synonym.senses.create :synset => synset, :freq_cnt => @sense_index[key.to_s]
      # recompute freq_cnt for synonym
      synonym.save
      sense_count += 1
    end
    synset.save
    synset_count += 1
  end
  puts "#{Time.now} loaded #{Word.count(:conditions => { :part_of_speech => part_of_speech})} #{part_of_speech.pluralize} (#{synset_count} synsets, #{sense_count} senses)"
end

total = Word.count(:conditions => "part_of_speech = 'verb'")
puts "#{Time.now} removing duplicate verb inflections"
puts "#{Time.now} processing #{total} verbs"
@chunk = (total*0.1).to_i
@verb_cnt = 0
@last_report = Time.now
Word.all(:conditions => "part_of_speech = 'verb'").each do |w|
  w.inflections.each do |i|
    w.inflections.delete(i) if
      w.inflections.count(:conditions => [ "name = ?", i.name ]) > 1
  end
  w.save

  @verb_cnt += 1
  if @verb_cnt % @chunk == 0
    now = Time.now
    i = @verb_cnt/@chunk
    puts "#{now} #{i*10}% done, est. complete at #{now+(now-@last_report)*(10-i)}"
    @last_report = now
  end
end

puts "#{Time.now} ### Dubsar DB seed complete ###"
