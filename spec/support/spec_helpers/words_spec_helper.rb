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

def create_word!(name, part_of_speech, options={})
  params = { :part_of_speech => part_of_speech.to_s, :freq_cnt => 0, :name => name }
  params.merge!(options)
  word = Word.create! params
  add_inflections(word)
  word
end

def create_synonyms!
  food_synset = Factory :food_synset
  food = Factory.build :noun
  grub = Factory.build :grub

  food.senses << Factory.build(:sense, :synset => food_synset)
  grub.senses << Factory.build(:sense, :synset => food_synset, :synset_index => 2)
  food.save!
  grub.save!

  add_inflections food
  add_inflections grub

  # define 'substance' as a hypernym for food
  substance = Factory :substance
  substance_sense = Factory :sense, :word => substance, :synset => Factory(:substance_synset)
  substance.senses << substance_sense
  substance.save!
  Factory :pointer, :source => food.senses.first, :target => substance_sense, :ptype => 'hypernym'

  [ food, grub ]
end

def create_antonyms!
  good = Factory :good
  bad = Factory :bad
  good_sense = Factory(:sense, :synset => Factory(:good_synset))
  bad_sense = Factory(:sense, :synset => Factory(:bad_synset ))

  good_sense.synset.pointers << Factory(:pointer, :ptype => 'antonym', :target => bad_sense.synset, :source => good_sense.synset)
  bad_sense.synset.pointers << Factory(:pointer, :ptype => 'antonym', :target => good_sense.synset, :source => bad_sense.synset)

  good.senses << good_sense
  bad.senses  << bad_sense

  good.save!
  bad.save!

  add_inflections good
  add_inflections bad

  [ good, bad ]
end
