#  Dubsar Dictionary Project
#  Copyright (C) 2010-14 Jimmy Dee
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

@synset_exceptions = {
	"24458" => 116  
}

def strings_equal_by_words(s1, s2)
  words1 = s1.split(/[^A-Za-z]+/)
  words2 = s2.split(/[^A-Za-z]+/)

  return false unless words1.count == words2.count

  words1.join(" ") == words2.join(" ")
end

def word_count(s)
  s.split(/[^A-Za-z]+/).count
end

def words_in_common(s1, s2)
  words1 = s1.split(/[^A-Za-z]+/)
  words2 = s2.split(/[^A-Za-z]+/)

  smaller_list = words1.count < words2.count ? words1 : words2
  larger_list = words1.count < words2.count ? words2 : words1

  smaller_list.count { |w| larger_list.include? w }
end

def make_word!(name, part_of_speech)
  inflections = @irregular_inflections[name.to_sym] || []
  inflections << name
  Word.create! name: name, part_of_speech: part_of_speech, irregular: inflections
end

def make_synset!(offset, defn, lexname, part_of_speech, synonyms, markers)
  synset = Synset.create! offset: offset, definition: defn, lexname: lexname, part_of_speech: part_of_speech

  synonyms.each_with_index do |synonym, index|
    make_synonym! synset, synonym, markers[index], part_of_speech
  end
  synset
end

def make_synonym!(synset, synonym, marker, part_of_speech)
  # word = make_word! synonym, part_of_speech
  word = Word.find_by_name_and_part_of_speech synonym, part_of_speech
  word ||= make_word! synonym, part_of_speech

  Sense.create! synset_id: synset.id, word_id: word.id, marker: marker
end

def make_synonyms!(synset, synonyms, markers, part_of_speech)
  # out with the old
  synset.senses.each do |sense|
    next if synonyms.include? sense.word.name
    sense.destroy
  end

  # in with the new
  synonyms.each_with_index do |synonym, index|
    next if synset.words.where(name: synonym).count == 1
    make_synonym! synset, synonym, markers[index], part_of_speech
  end
end

def synset_for_data_line(line)
  left, defn = line.split('| ')
  synset_offset, lex_filenum, ss_type, w_cnt, *rest = left.split(' ')
  w_cnt = w_cnt.to_i(16)

  defn.chomp!
  synset_offset = synset_offset.to_i

  # Read synonyms
  synonyms = []
  markers = []
  rest.slice(0, 2*w_cnt).each_slice(2) do |a|
    s = a[0].gsub('_', ' ')
    marker = nil

    md = /^(.+)\(([a-z]+)\)\s*$/.match s
    if md
      marker = md[2]
      s = md[1]
    end

    synonyms << s
    markers << marker
  end

  synset = nil

  synset_id = @synset_exceptions[synset_offset.to_s]
  puts "synset exception ID for #{synset_offset.to_s}: #{synset_id}" if synset_id
  synset = Synset.find synset_id if synset_id

  # 1. Look for a synset with the same lexname, synonyms and definition.

  Synset.where(lexname:@lexnames[lex_filenum], definition: defn).each do |a_synset|
    if a_synset.senses.count == synonyms.count &&
      synonyms.all? { |synonym| a_synset.words.where(name: synonym).count == 1 }
      synset = a_synset
      break
    end
  end unless synset

  defn.strip!

  # 2. Check each synonym's synsets from the DB to see if we can find something with
  #    a close definition
  new_count = 0
  candidates = 0
  synonyms.each do |synonym|
    word = Word.find_by_name_and_part_of_speech synonym, @part_of_speech
    if word.blank?
      new_count += 1
      puts "New word: #{synonym}, #{@part_of_speech}"
      nil.foo
      word = make_word! synonym, @part_of_speech
      next
    end

    word.synsets.each do |synonym_synset|
      stripped_synset_defn = synonym_synset.definition.strip
      if stripped_synset_defn == defn ||
        defn.starts_with?(stripped_synset_defn) ||
        stripped_synset_defn.starts_with?(defn) ||
        strings_equal_by_words(defn, stripped_synset_defn)

        synset = synonym_synset
      elsif synonym_synset.lexname == @lexnames[lex_filenum] &&
        synonym_synset.words.count == synonyms.count &&
        synonyms.all? { |synonym| synonym_synset.words.where(name: synonym).count == 1 }

        in_common = words_in_common(defn, stripped_synset_defn)
        defn_count = word_count(defn)
        stripped_synset_defn_count = word_count(stripped_synset_defn)

        puts "Non-matching definition \"#{stripped_synset_defn}\" has #{in_common} of #{stripped_synset_defn_count} with \"#{defn}\" (#{defn_count})"
        # This difference has to be at least 1
        # If the two definitions differ by one word, take this one
        if defn_count == stripped_synset_defn_count && defn_count - in_common <= 1
          synset = synonym_synset
        else
          # Candidates don't have the same definition text but have the same lexname and
          # the same synonyms.
          candidates += 1
        end
      end
    end

    break if synset # synonyms.each
  end unless synset

  if synset
    synset.update_attributes offset: synset_offset unless synset.offset == synset_offset
    if @lexnames[lex_filenum] != synset.lexname
      puts "Lexname changed for Synset ID #{synset.id}: <#{@lexnames[lex_filenum]}>"
      # nil.foo
      synset.update_attributes lexname: @lexnames[lex_filenum]
    end

    # The definition and synonyms have changed, or they would have been found above.
    if defn != synset.definition.strip
      puts "Definition changed for Synset ID #{synset.id}: \"#{defn}\" (WAS \"#{synset.definition}\")"
      # nil.foo
      synset.update_attributes definition: defn
    end

    if synset.senses.count != synonyms.count ||
      synonyms.any? { |synonym| synset.words.where(name: synonym).count != 1 }
      # nil.foo
      puts "Synonyms changed for Synset ID #{synset.id}: \"#{synonyms.join(",")}\""
      make_synonyms! synset, synonyms, markers, @part_of_speech
    end
  end

  return synset if synset

  if new_count == synonyms.count
    puts "All-New synset <#{@lexnames[lex_filenum]}> #{defn} (#{synonyms.join(",")})"
    nil.foo
    return make_synset! synset_offset, defn, @lexnames[lex_filenum], @part_of_speech, synonyms, markers
  else
    puts "No Synset found matching <#{@lexnames[lex_filenum]}> #{defn.strip} (#{synonyms.join(",")})"
    synonyms.each do |synonym|
      if Word.find_by_name_and_part_of_speech(synonym, @part_of_speech).senses.count == 0
        puts "Synonym #{synonym} has no synsets [#{candidates} candidate(s)]"
      end
    end
  end

  nil
end

def pointer_type(symbol)
  case symbol
  when '!'
    'antonym'
  when '@'
    'hypernym'
  when '@i'
    'instance hypernym'
  when '~'
    'hyponym'
  when '~i'
    'instance hyponym'
  when '#m'
    'member holonym'
  when '#s'
    'substance holonym'
  when '#p'
    'part holonym'
  when '%m'
    'member meronym'
  when '%s'
    'substance meronym'
  when '%p'
    'part meronym'
  when '='
    'attribute'
  when '+'
    'derivationally related form'
  when ';c'
    'domain of synset (topic)'
  when '-c'
    'member of this domain (topic)'
  when ';r'
    'domain of synset (region)'
  when '-r'
    'member of this domain (region)'
  when ';u'
    'domain of synset (usage)'
  when '-u'
    'member of this domain (usage)'
  when '*'
    'entailment'
  when '>'
    'cause'
  when '^'
    'also see'
  when '$'
    'verb group'
  when '&'
    'similar to'
  when '<'
    'participle of verb'
  when '\\'
    'derived from/pertains to'
  else
    ''
  end
end

def reflected_pointer_type(symbol)
  case symbol
  when '!'
    'antonym'
  when '~'
    'hypernym'
  when '@'
    'hyponym'
  when '~i'
    'instance hypernym'
  when '@i'
    'instance hyponym'
  when '#m'
    'member meronym'
  when '#s'
    'substance meronym'
  when '#p'
    'part meronym'
  when '%m'
    'member holonym'
  when '%s'
    'substance holonym'
  when '%p'
    'part holonym'
  when '&'
    'similar to'
  when '='
    'attribute'
  when '$'
    'verb group'
  when '+'
    'derivationally related form'
  when ';c'
    'member of this domain (topic)'
  when '-c'
    'domain of synset (topic)'
  when ';r'
    'member of this domain (region)'
  when '-r'
    'domain of synset (region)'
  when ';u'
    'member of this domain (usage)'
  when '-u'
    'domain of synset (usage)'
  else
    ''
  end
end

@sense_index = Hash.new(0)
@lexnames = {}

@verb_frames = {}
File.open(File.expand_path('defaults/frames.vrb', File.dirname(__FILE__))).each do |line|
  matches = /^(\d+)\s+(.*)$/.match(line.chomp)
  number = matches[1].to_i
  frame = matches[2]
  verb_frame = VerbFrame.create :number => number, :frame => frame
  @verb_frames[number] = [ verb_frame.id, frame ]
end

puts "#{Time.now} loaded verb frames"
STDOUT.flush

File.open(File.expand_path('defaults/lexnames', File.dirname(__FILE__))).each do |line|
  number, name, pos_index = line.chomp.split
  @lexnames[number] = name
end

puts "#{Time.now} loaded lexical names"
STDOUT.flush

File.open(File.expand_path('../defaults/sents.vrb', __FILE__)).each do |line|
  matches = /^(\d+) (.*)$/.match(line.chomp)
  index = matches[1].to_i + 1000
  frame = matches[2]

  VerbFrame.create :frame => frame, :number => index
end

@verb_sentences = Hash.new []
File.open(File.expand_path('../defaults/sentidx.vrb', __FILE__)).each do |line|
  sense_key, sentences = line.chomp.split
  next unless sentences
  @verb_sentences[sense_key] = sentences.split(',')
end

puts "#{Time.now} loaded verb sentences"
STDOUT.flush

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

puts "#{Time.now} loaded sense index"
STDOUT.flush

last_id = nil
matching_count = 0
failure_count = 0

%w{adj adv noun verb}.each do |sfx|
  @part_of_speech = case sfx
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
  puts "#{Time.now} loaded irregular #{@part_of_speech} inflections"
  STDOUT.flush

  puts "#{Time.now} loading #{@part_of_speech.pluralize}"
  STDOUT.flush
  synset_count = 0
  sense_count = 0
  @clean_so_far = true
  File.open(File.expand_path("defaults/data.#{sfx}", File.dirname(__FILE__))).each do |line|
    next if line =~ /^\s/

    synset = synset_for_data_line line

    if synset

      if last_id && synset.id != last_id + 1
        puts "MISSING #{last_id + 1}. Jumped from #{last_id} to #{synset.id}"
      end

      last_id = synset.id
      matching_count += 1
    else
      failure_count += 1
      puts "Last: #{last_id}. Matches: #{matching_count}. Failures: #{failure_count}."
    end
  end
end

puts "#{Time.now} finished"
