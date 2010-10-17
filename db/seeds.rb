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

    synset = Synset.new definition: defn.chomp
    rest.slice(0, 2*w_cnt).each_slice(2) do |a|
      s = a[0].gsub('_', ' ')
      synonym = Word.find_by_name_and_part_of_speech s, part_of_speech
      next if synonym and synset.words << synonym

      synset.words.build name: s, part_of_speech: part_of_speech
    end
    synset.save
    synset_count += 1
  end
  puts "#{Time.now} loaded #{Word.count(:conditions => { :part_of_speech => part_of_speech})} #{part_of_speech.pluralize} (#{synset_count} synsets)"
end
