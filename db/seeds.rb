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
  STDOUT.flush

  puts "#{Time.now} loading #{part_of_speech.pluralize}"
  STDOUT.flush
  synset_count = 0
  sense_count = 0
  File.open(File.expand_path("defaults/data.#{sfx}", File.dirname(__FILE__))).each do |line|
    next if line =~ /^\s/

    left, defn = line.split('| ')
    synset_offset, lex_filenum, ss_type, w_cnt, *rest = left.split(' ')
    w_cnt = w_cnt.to_i(16)

    synset = Synset.new :definition => defn.chomp,
      :offset => synset_offset.to_i,
      :lexname => @lexnames[lex_filenum],
      :part_of_speech => part_of_speech
    synset_index = 0
    rest.slice(0, 2*w_cnt).each_slice(2) do |a|
      s = a[0].gsub('_', ' ')
      synset_index += 1

      md = /^(.+)\(([a-z]+)\)\s*$/.match s
      if md
        marker = md[2]
        s = md[1]
      end

      synonym = Word.find_by_name_and_part_of_speech(s, part_of_speech) ||
        Word.create(:name => s, :part_of_speech => part_of_speech, :irregular => @irregular_inflections[s.gsub(' ', '_').to_sym])
      key = part_of_speech + '_' + synset_offset + '_' + s
      sense = synonym.senses.create :synset => synset,
        :freq_cnt => @sense_index[key.to_s],
        :synset_index => synset_index
      sense.update_attribute(:marker, marker) if marker

      if part_of_speech == 'verb'
        lex_id = case a[1].to_i
        when (0..9)
          '0' + a[1]
        else
          a[1]
        end
        sense_key = "#{a[0]}%2:#{lex_filenum}:#{lex_id}::"
        sentences = @verb_sentences[sense_key]

        if sentences
          sentences.each do |number|
            frame = VerbFrame.find_by_number(number.to_i+1000)
            SensesVerbFrame.create :sense => sense, :verb_frame => frame
          end
        end
      end

      # recompute freq_cnt for synonym
      synonym.save
      sense_count += 1
    end

    synset_count += 1
    synset.save

    p_cnt, *more = rest.slice(2*w_cnt, rest.length-2*w_cnt)
    next unless more

    p_cnt = p_cnt.to_i
    next unless part_of_speech == 'verb'

    f_cnt, *more_frames = more.slice(4*p_cnt, more.length-4*p_cnt)
    f_cnt = f_cnt.to_i
    next if f_cnt == 0 or more_frames.nil?

    more_frames.slice(0, 3*f_cnt).each_slice(3) do |f|
      plus, f_num, w_num = f
      verb_frame_id = @verb_frames[f_num.to_i][0]
      w_num = w_num.to_i
      if w_num != 0
        sense = synset.senses.find(:first, :conditions => "synset_index = #{w_num}")
        SensesVerbFrame.create :sense_id => sense.id, :verb_frame_id => verb_frame_id
      else
        synset.senses.each do |sense|
          SensesVerbFrame.create :sense_id => sense.id, :verb_frame_id => verb_frame_id
        end
      end
    end
  end
  puts "#{Time.now} loaded #{Word.count(:conditions => { :part_of_speech => part_of_speech})} #{part_of_speech.pluralize} (#{synset_count} synsets, #{sense_count} senses)"
  STDOUT.flush
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

  puts "#{Time.now} loading #{part_of_speech} pointers"
  STDOUT.flush
  File.open(File.expand_path("defaults/data.#{sfx}", File.dirname(__FILE__))).each do |line|
    next if line =~ /^\s/

    left, defn = line.split('| ')
    synset_offset, lex_filenum, ss_type, w_cnt, *rest = left.split(' ')

    synset = Synset.find_by_offset_and_part_of_speech synset_offset.to_i,
      part_of_speech

    w_cnt = w_cnt.to_i(16)
    p_cnt, *more = rest.slice(2*w_cnt, rest.length-2*w_cnt)
    next unless more

    p_cnt = p_cnt.to_i
    more.slice(0, 4*p_cnt).each_slice(4) do |p|
      pointer_symbol, target_synset_offset, target_pos, source_target = p

      target_synset =
        Synset.find_by_offset_and_part_of_speech target_synset_offset.to_i,
        case target_pos
        when 'n'
          'noun'
        when /^[as]$/
          'adjective'
        when 'r'
          'adverb'
        when 'v'
          'verb'
        end

      if source_target == '0000'
        ptype = pointer_type(pointer_symbol)
        Pointer.create_new :source => synset, :target => target_synset,
            :ptype => ptype

        rtype = reflected_pointer_type(pointer_symbol)
        Pointer.create_new :source => target_synset, :target => synset,
          :ptype => rtype
      else
        source_no = source_target[0,2]
        target_no = source_target[2,2]
        source_no = source_no.to_i(16)
        target_no = target_no.to_i(16)

        sense = synset.senses.find(:first, :conditions => "synset_index = #{source_no}")
        target = target_synset.senses.find(:first, :conditions => "synset_index = #{target_no}")

        Pointer.create_new :source => sense, :target => target, :ptype => pointer_type(pointer_symbol)
        rtype = reflected_pointer_type(pointer_symbol)
        Pointer.create_new(:source => target, :target => sense, :ptype => rtype) unless rtype.blank?
      end
    end
  end
end
puts "#{Time.now} ### Dubsar DB seed complete ###"
