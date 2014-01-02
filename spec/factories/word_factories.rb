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

FactoryGirl.define do
  factory :daily_word do
  end
  
  factory :word do |w|
    w.freq_cnt 10
  end
  
  factory :sense do |s|
    s.freq_cnt 10
    s.synset_index 1
  end
  
  factory :inflection do |i|
  end
  
  factory :adjective, :parent => :word do |w|
    w.name 'foul'
    w.part_of_speech 'adjective'
    w.inflections { |i| [ i.association(:inflection, :name => 'foul') ] }
  end
  
  factory :adverb, :parent => :word do |w|
    w.name 'well'
    w.part_of_speech 'adverb'
    w.inflections { |i| [ i.association(:inflection, :name => 'well') ] }
  end
  
  factory :conjunction, :parent => :word do |w|
    w.name 'but'
    w.part_of_speech 'conjunction'
    w.inflections { |i| [ i.association(:inflection, :name => 'but') ] }
  end
  
  factory :interjection, :parent => :word do |w|
    w.name 'hey'
    w.part_of_speech 'interjection'
    w.inflections { |i| [ i.association(:inflection, :name => 'hey') ] }
  end
  
  factory :noun, :parent => :word do |w|
    w.name 'food'
    w.part_of_speech 'noun'
    w.inflections do |i|
      [
        i.association(:inflection, :name => 'food'),
        i.association(:inflection, :name => 'foods')
      ]
    end
  end
  
  factory :preposition, :parent => :word do |w|
    w.name 'from'
    w.part_of_speech 'preposition'
    w.inflections { |i| [ i.association(:inflection, :name => 'from') ] }
  end
  
  factory :pronoun, :parent => :word do |w|
    w.name 'you'
    w.part_of_speech 'pronoun'
    w.inflections { |i| [ i.association(:inflection, :name => 'you') ] }
  end
  
  factory :verb, :parent => :word do |w|
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
  
  factory :slang, :parent => :word do |w|
    w.name 'slang'
    w.part_of_speech 'noun'
    w.inflections do |i|
      [
        i.association(:inflection, :name => 'slang'),
        i.association(:inflection, :name => 'slangs')
      ]
    end
  end
  
  factory :well_noun, :parent => :word do |w|
    w.name 'well'
    w.part_of_speech 'noun'
    w.inflections do |i|
      [
        i.association(:inflection, :name => 'well'),
        i.association(:inflection, :name => 'wells')
      ]
    end
  end
  
  factory :bad_part_of_speech, :parent => :word do |w|
    w.name 'fudge'
    w.part_of_speech 'thingy'
    w.inflections do |i|
      [
        i.association(:inflection, :name => 'fudge'),
        i.association(:inflection, :name => 'fudges')
      ]
    end
  end
  
  factory :grub, :parent => :word do |w|
    w.name 'grub'
    w.part_of_speech 'noun'
    w.inflections do |i|
      [
        i.association(:inflection, :name => 'grub'),
        i.association(:inflection, :name => 'grubs')
      ]
    end
  end
  
  factory :bad, :parent => :word do |w|
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
  
  factory :good, :parent => :word do |w|
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
  
  factory :sweet, :parent => :word do |w|
    w.name 'sweet'
    w.part_of_speech 'adjective'
    w.freq_cnt 8
    w.inflections { |i| [ i.association(:inflection, :name => 'sweet') ] }
  end
  
  factory :substance, :parent => :word do |w|
    w.name 'substance'
    w.part_of_speech 'noun'
    w.inflections do |i|
      [
        i.association(:inflection, :name => 'substance'),
        i.association(:inflection, :name => 'substances')
      ]
    end
  end
  
  factory :list_entry, :class => Word do |w|
    w.sequence(:name) { |n| "word_#{n}" }
    w.part_of_speech 'noun'
    w.freq_cnt 100

    after :create do |word|
      word.inflections << FactoryGirl.create(:inflection, :name => word.name)
      word.inflections << FactoryGirl.create(:inflection, :name => "#{word.name}s")
      word.save!
    end
  end
  
  factory :w, :class => Word do |w|
    w.name 'w'
    w.part_of_speech 'noun'
    w.inflections do |i|
      [
        i.association(:inflection, :name => 'w')
      ]
    end
    w.freq_cnt 0
  end
  
  factory :capitalized_word, :class => Word do |w|
    w.name 'Word_1'
    w.part_of_speech 'noun'
    w.inflections { |i| [ i.association(:inflection, :name => 'Word_1') ] }
  end
end
