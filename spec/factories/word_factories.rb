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

Factory.define :word do |w|
  w.freq_cnt 10
end

Factory.define :sense do |s|
  s.freq_cnt 10
  s.synset_index 1
end

Factory.define :inflection do |i|
end

Factory.define :adjective, :parent => :word do |w|
  w.name 'foul'
  w.part_of_speech 'adjective'
  w.inflections { |i| [ i.association(:inflection, :name => 'foul') ] }
end

Factory.define :adverb, :parent => :word do |w|
  w.name 'well'
  w.part_of_speech 'adverb'
  w.inflections { |i| [ i.association(:inflection, :name => 'well') ] }
end

Factory.define :conjunction, :parent => :word do |w|
  w.name 'but'
  w.part_of_speech 'conjunction'
  w.inflections { |i| [ i.association(:inflection, :name => 'but') ] }
end

Factory.define :interjection, :parent => :word do |w|
  w.name 'hey'
  w.part_of_speech 'interjection'
  w.inflections { |i| [ i.association(:inflection, :name => 'hey') ] }
end

Factory.define :noun, :parent => :word do |w|
  w.name 'food'
  w.part_of_speech 'noun'
  w.inflections do |i|
    [
      i.association(:inflection, :name => 'food'),
      i.association(:inflection, :name => 'foods')
    ]
  end
end

Factory.define :preposition, :parent => :word do |w|
  w.name 'from'
  w.part_of_speech 'preposition'
  w.inflections { |i| [ i.association(:inflection, :name => 'from') ] }
end

Factory.define :pronoun, :parent => :word do |w|
  w.name 'you'
  w.part_of_speech 'pronoun'
  w.inflections { |i| [ i.association(:inflection, :name => 'you') ] }
end

Factory.define :verb, :parent => :word do |w|
  w.name 'follow'
  w.part_of_speech 'verb'
  w.inflections do |i|
    [
      i.association(:inflection, :name => 'follow'),
      i.association(:inflection, :name => 'follows'),
      i.association(:inflection, :name => 'followed'),
      i.association(:inflection, :name => 'following')
    ]
  end
end

Factory.define :slang, :parent => :word do |w|
  w.name 'slang'
  w.part_of_speech 'noun'
  w.inflections do |i|
    [
      i.association(:inflection, :name => 'slang'),
      i.association(:inflection, :name => 'slangs')
    ]
  end
end

Factory.define :well_noun, :parent => :word do |w|
  w.name 'well'
  w.part_of_speech 'noun'
  w.inflections do |i|
    [
      i.association(:inflection, :name => 'well'),
      i.association(:inflection, :name => 'wells')
    ]
  end
end

Factory.define :bad_part_of_speech, :parent => :word do |w|
  w.name 'fudge'
  w.part_of_speech 'thingy'
  w.inflections do |i|
    [
      i.association(:inflection, :name => 'fudge'),
      i.association(:inflection, :name => 'fudges')
    ]
  end
end

Factory.define :grub, :parent => :word do |w|
  w.name 'grub'
  w.part_of_speech 'noun'
  w.inflections do |i|
    [
      i.association(:inflection, :name => 'grub'),
      i.association(:inflection, :name => 'grubs')
    ]
  end
end

Factory.define :bad, :parent => :word do |w|
  w.name 'bad'
  w.part_of_speech 'adjective'
  w.freq_cnt 11
  w.inflections do |i|
    [
      i.association(:inflection, :name => 'bad'),
      i.association(:inflection, :name => 'worse'),
      i.association(:inflection, :name => 'worst')
    ]
  end
end

Factory.define :good, :parent => :word do |w|
  w.name 'good'
  w.part_of_speech 'adjective'
  w.freq_cnt 9
  w.inflections do |i|
    [
      i.association(:inflection, :name => 'good'),
      i.association(:inflection, :name => 'better'),
      i.association(:inflection, :name => 'best')
    ]
  end
end

Factory.define :sweet, :parent => :word do |w|
  w.name 'sweet'
  w.part_of_speech 'adjective'
  w.freq_cnt 8
  w.inflections { |i| [ i.association(:inflection, :name => 'sweet') ] }
end

Factory.define :substance, :parent => :word do |w|
  w.name 'substance'
  w.part_of_speech 'noun'
  w.inflections do |i|
    [
      i.association(:inflection, :name => 'substance'),
      i.association(:inflection, :name => 'substances')
    ]
  end
end

Factory.define :list_entry, :class => Word do |w|
  w.sequence(:name) { |n| @name = "word_#{n}" }
  w.part_of_speech 'noun'
  w.inflections { |i| [ i.association(:inflection, :name => @name) ] }
end

Factory.define :capitalized_word, :class => Word do |w|
  w.name 'Word_1'
  w.part_of_speech 'noun'
  w.inflections { |i| [ i.association(:inflection, :name => 'Word_1') ] }
end
