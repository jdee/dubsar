# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

def find_or_create_word(name, part_of_speech)
    w = Word.find_by_name_and_part_of_speech(name, part_of_speech) ||
      Word.new(:name => name, :part_of_speech => part_of_speech)
end

%w{adj adv noun verb}.each do |part|
  part_of_speech = case part
  when 'adj'
    'adjective'
  when 'adv'
    'adverb'
  else
    part
  end

  puts "#{Time.now} loading #{part_of_speech.pluralize}"
  File.open(File.join(File.dirname(__FILE__), 'defaults', "data.#{part}")).each do |line|
    next if line =~ /^\s/

    left, defn = line.split('| ')
    synset_offset, lex_filenum, ss_type, w_cnt, name, lex_id, *rest = left.split(' ')
    w_cnt = w_cnt.to_i

    w = find_or_create_word name, part_of_speech
    w.definitions.build :body => defn

    rest.slice(0, 2*(w_cnt-1)).each_slice(2) do |a|
      s = a[0]
      synset = w.synset
      synonym = Word.find_by_name_and_part_of_speech s, part_of_speech
      next if synonym and synset and synset.words.include?(synonym)

      synset = w.build_synset unless synset
      next if synonym and synset.words << synonym

      synset.words.build :name => s, :part_of_speech => part_of_speech
      synset.save
    end if w_cnt > 1
    w.save
  end
end
