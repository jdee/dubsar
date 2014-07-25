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

# The following code loads the WN 3.1 data set without changing row IDS for
# senses, synsets or words whenever possible. It should work with any subsequent
# update using the same file format, with the exception of this list, which
# refers to the numeric offset of each synset as listed in the first column of each
# row in the data.* files. These represent synsets with significant changes that
# are difficult to identify automatically. If using this code with any subsequent
# data set, remove the contents of the dictionary for each part of speech below, so
# that you have "adjective" => {}, "adverb" => {}, and so forth. Synsets in this
# list will not be identified by the synset_for_data_line method otherwise with WN 3.1.
#
# The key in the dictionary for each part of speech is the offset read from the
# data file, as a string, with the initial 0's stripped. The value is an integer
# equal to the synset ID in the database for the matching synset.
@synset_exceptions = {
  "adjective" => {
    "24458" => 116,
    "24701" => 117,
    "25079" => 119,
    "43834" => 222,
    "51791" => 266,
    "52486" => 427,
    "101225" => 530,
    "106981" => 562,
    "119817" => 628,
    "123654" => 650,
    "165213" => 889,
    "177648" => 952,
    "178829" => 957,
    "242247" => 1340,
    "243558" => 1349,
    "247479" => 1376,
    "302053" => 1670,
    "302637" => 1673,
    "318624" => 1755,
    "357450" => 1979,
    "403798" => 2284,
    "403922" => 2286,
    "414699" => 2343,
    "427259" => 2411,
    "490985" => 2752,
    "492970" => 2761,
    "493366" => 2763,
    "510662" => 2860,
    "2331344" => 2939,
    "529920" => 2957,
    "533833" => 2975,
    "537047" => 2988,
    "537516" => 2992,
    "558079" => 3101,
    # manually edited data.adj for 562326 to correct spelling of "crowded".
    # parsing here does not depend on offsets being accurate, just unique.
    "562326" => 3127,
    "575501" => 3195,
    "576056" => 3198,
    "594915" => 3291,
    "596783" => 3301,
    "598545" => 3306,
    "2506031" => 3357,
    "618080" => 3415,
    "627729" => 3478,
    "628097" => 3480,
    "660221" => 3651,
    "661271" => 3657,
    "662119" => 3663,
    "683799" => 3789,
    "699967" => 3876,
    "700543" => 3879,
    "714186" => 3944,
    "717749" => 3962,
    "735762" => 4054,
    "736942" => 4060,
    "746008" => 4114,
    "752408" => 4144,
    "760641" => 4187,
    "768832" => 4224,
    "786516" => 4314,
    "828657" => 4537,
    "829356" => 4540,
    "868970" => 4748,
    "881395" => 4815,
    "889690" => 4860,
    "911705" => 4973,
    "913487" => 4981,
    "923395" => 5039,
    "946057" => 5163,
    "953800" => 5209,
    "973992" => 5313,
    "992194" => 5412,
    "997760" => 5433,
    "1012028" => 5523,
    "1012335" => 5525,
    "1018989" => 5554,
    "1022875" => 5575,
    "1033904" => 5633,
    "1034170" => 5635,
    "1047301" => 5716,
    "1065188" => 5818,
    "1116284" => 6107,
    "1119860" => 6123,
    "1121419" => 6129,
    "1143790" => 6238,
    "1149209" => 6267, # manually changed veritcal to vertical
    "1159105" => 6323,
    "2608757" => 6575,
    "1249700" => 6822,
    "1251747" => 6831,
    "1253778" => 6843,
    "1554025" => 7074,
    "1303318" => 7085,
    "1308279" => 7113,
    "1320185" => 7175,
    "1338108" => 7281,
    "1341128" => 7296,
    "667636" => 7318,
    "1362125" => 7405,
    "1362306" => 7406,
    "1371994" => 7458,
    "1386320" => 7531,
    "1395848" => 7584,
    "1407374" => 7659,
    "1408930" => 7670,
    "1415578" => 7705,
    "1418056" => 7722,
    "1444145" => 7877,
    "187511" => 7926,
    "1459756" => 7970,
    "1461111" => 7979,
    "1461331" => 7980,
    "1461461" => 7981,
    "1461579" => 7982,
    "1461821" => 7983,
    "1461939" => 7984,
    "1466459" => 8009,
    "1468558" => 8020,
    "1475013" => 8061,
    "1475232" => 8062,
    "1478687" => 8081,
    "1490267" => 8154,
    "1490840" => 8158,
    "1493868" => 8174,
    "1159816" => 8183,
    "1514513" => 8292,
    "1514879" => 8295,
    "1515033" => 8296,
    "1517859" => 8310,
    "1524174" => 8344,
    "1537778" => 8421,
    "1542473" => 8445,
    "1542711" => 8446,
    "1558769" => 8533,
    "1581122" => 8645,
    "1613579" => 8815,
    "1644403" => 8978,
    "2682500" => 9133,
    "1679481" => 9181,
    "1682215" => 9190,
    "1751027" => 9421,
    "1734977" => 9494,
    "1737104" => 9506,
    "1752186" => 9592,
    "1757717" => 9624,
    "1759375" => 9632,
    "1773890" => 9707,
    "1803966" => 9887,
    "1806732" => 9898,
    "1807949" => 9900,
    "1808909" => 9905,
    "1812324" => 9923,
    "1848878" => 10126,
    "1852738" => 10146,
    "1868236" => 10226,
    "1880529" => 10286,
    "1884969" => 10312,
    "1885720" => 10315,
    "1895355" => 10365,
    "1920631" => 10498,
    "1940682" => 10601,
    "1943120" => 10610,
    "1968015" => 10739,
    "1972513" => 10765,
    "1991733" => 10869,
    "2007041" => 10949,
    "2031662" => 11090,
    "2032205" => 11093,
    "2037940" => 11126,
    "2048059" => 11179,
    "2058261" => 11248,
    "2059434" => 11255,
    "86117" => 11365,
    "2098311" => 11460,
    "2141133" => 11681,
    "2141804" => 11685,
    "2171017" => 11887,
    "2187588" => 11985,
    "2203651" => 12104,
    "2275064" => 12553,
    "2276242" => 12557,
    "2277044" => 12561,
    "2287272" => 12612,
    "2305827" => 12721,
    "2328429" => 12855,
    "2328637" => 12856,
    "2332671" => 12877,
    "2333471" => 12881,
    "2344113" => 12938,
    "2344882" => 12942,
    "2351216" => 12976,
    "2354846" => 12995,
    "2359909" => 13026,
    "2371053" => 13081,
    "2412395" => 13306,
    "2334464" => 13308,
    "2435043" => 13425,
    "2435464" => 13428,
    "2444489" => 13485,
    "2445119" => 13487,
    "2455914" => 13561,
    "2463673" => 13608,
    "2475791" => 13666,
    "2479427" => 13686,
    "2505376" => 13843,
    "2512593" => 13880,
    "2516967" => 13901,
    "2528983" => 13969,
    "2542324" => 14043,
    "2542621" => 14045,
    "2548215" => 14078,
    "2548368" => 14079,
    "2548500" => 14080,
    "2548631" => 14081,
    "2548820" => 14082,
    "2548958" => 14083,
    "2549079" => 14084,
    "2549225" => 14085,
    "2570464" => 14200,
    "2532138" => 14242,
    "2581199" => 14268,
    "2582052" => 14270,
    "2596626" => 14350,
    "2171017" => 14354,
    "2784673" => 15671,
    "2900710" => 16438,
    "2916222" => 16535,
    "2943474" => 16701,
    "2964788" => 16842,
    "3099007" => 17700,
    "3119449" => 17830,
    "3119629" => 17831
  },
  "adverb" => {
    "2669" => 18163,
    "3317" => 18165,
    "8102" => 18195,
    "20362" => 18256,
    "21667" => 18264,
    "27761" => 18298,
    "36138" => 18350,
    "172866" => 18528,
    "80132" => 18621,
    "80266" => 18622,
    "86161" => 18664,
    "95613" => 18732,
    "95742" => 18733,
    "103874" => 18787,
    "109919" => 18828,
    "110206" => 18830,
    "113022" => 18976,
    "140318" => 19067,
    "145227" => 19108,
    "149175" => 19135,
    "156898" => 19192,
    "157363" => 19196,
    "165875" => 19254,
    "168477" => 19274,
    "168718" => 19276,
    "169587" => 19283,
    "172866" => 19305,
    "174785" => 19322,
    "187293" => 19412,
    "192471" => 19453,
    "193383" => 19459,
    "196934" => 19488,
    "197608" => 19493,
    "212370" => 19596,
    "224618" => 19672,
    "232612" => 19730,
    "237364" => 19762,
    "247755" => 19839,
    "261760" => 19958,
    "269134" => 20010,
    "280708" => 20098,
    "297139" => 20206,
    "305545" => 20255,
    "306956" => 20266,
    "333090" => 20429,
    "344222" => 20499,
    "382155" => 20747,
    "400747" => 20877,
    "458383" => 21347,
    "472106" => 21403,
    "473918" => 21415,
    "503489" => 21646,
    "386914" => 21654,
    "505869" => 21664,
    "508298" => 21681
  },
  "noun" => {
    "45638" => 21875,
    "50548" => 21898,
    "173531" => 22554,
    "258637" => 22982,
    "422316" => 23852,
    "432277" => 23896,
    "443377" => 23956,
    "460751" => 24065,
    "464604" => 24088,
    "469063" => 24104,
    "609469" => 24855,
    "609736" => 24856,
    "632200" => 24975,
    "728118" => 25481,
    "728250" => 25482,
    "751514" => 25611,
    "774891" => 25705,
    "789119" => 25778,
    "847184" => 26079,
    "919445" => 26460,
    "967829" => 26693,
    "998599" => 26853,
    "1046116" => 27106,
    "1156868" => 27684,
    "1259202" => 28223,
    "1259362" => 28224,
    "1296823" => 28405,
    "2410277" => 34501,
    "2686412" => 36088,
    "2716929" => 36267,
    "2723487" => 36294,
    "2733566" => 36342,
    "2803952" => 36748,
    "2825534" => 36887,
    "2828584" => 36908,
    "2829422" => 36914,
    "2834779" => 36948,
    "2839812" => 36980,
    "2841101" => 36989,
    "2842193" => 36996,
    "2844544" => 37012,
    "2853790" => 37072,
    "2857998" => 37096,
    "2861187" => 37115,
    "2861345" => 37116,
    "2872589" => 37181,
    "2896189" => 37324,
    "2899704" => 37346,
    "2904397" => 37375,
    "2906120" => 37387,
    "2914189" => 37441,
    "2950279" => 37658,
    "2971443" => 37783,
    "3003364" => 37967,
    "3012598" => 38023,
    "3023088" => 38094,
    "3347602" => 39955,
    "3409064" => 40336,
    "3443167" => 40535,
    "3448836" => 40570,
    "3461243" => 40652,
    "3482896" => 40793,
    "3499638" => 40889,
    "3529313" => 41069,
    "3542421" => 41146,
    "3599921" => 41475,
    "3605477" => 41509,
    "3642609" => 41736,
    "3840952" => 42892,
    "3905309" => 43287,
    "3909811" => 43315,
    "3922839" => 43394,
    "6249497" => 55538
  }
}

def strings_equal_by_words(s1, s2)
  words1 = s1.split(/[^A-Za-z0-9]+/)
  words2 = s2.split(/[^A-Za-z0-9]+/)

  return false unless words1.count == words2.count

  words1.join(" ") == words2.join(" ")
end

def word_count(s)
  s.split(/[^A-Za-z0-9]+/).count
end

def words_in_common(s1, s2)
  words1 = s1.split(/[^A-Za-z0-9]+/)
  words2 = s2.split(/[^A-Za-z0-9]+/)

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

  exceptions = @synset_exceptions[part_of_speech]
  synset_id = exceptions[synset_offset.to_s] if exceptions

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
      # nil.foo
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

        # puts "Non-matching definition \"#{stripped_synset_defn}\" has #{in_common} of #{stripped_synset_defn_count} with \"#{defn}\" (#{defn_count})"
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
    # nil.foo
    return make_synset! synset_offset, defn, @lexnames[lex_filenum], @part_of_speech, synonyms, markers
  end

  puts "No Synset found matching #{synset_offset} <#{@lexnames[lex_filenum]}> #{defn.strip} (#{synonyms.join(",")})"
  synonyms.each do |synonym|
    if Word.find_by_name_and_part_of_speech(synonym, @part_of_speech).senses.count == 0
      puts "Synonym #{synonym} has no synsets [#{candidates} candidate(s)]"
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
        puts "MISSING #{last_id + 1}-#{synset.id-1}. Jumped from #{last_id} to #{synset.id}"
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
