#  Dubsar Dictionary Project
#  Copyright (C) 2010-13 Jimmy Dee
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
  food_synset = FactoryGirl.create :food_synset
  food = FactoryGirl.build :noun
  grub = FactoryGirl.build :grub

  food.senses << FactoryGirl.build(:sense, :synset => food_synset)
  grub.senses << FactoryGirl.build(:sense, :synset => food_synset, :synset_index => 2)
  food.save!
  grub.save!

  add_inflections food
  add_inflections grub

  # define 'substance' as a hypernym for food
  substance = FactoryGirl.create :substance
  substance_sense = FactoryGirl.create :sense, :word => substance, :synset => FactoryGirl.create(:substance_synset)
  substance.senses << substance_sense
  substance.save!
  FactoryGirl.create :pointer, :source => food.senses.first, :target => substance_sense, :ptype => 'hypernym'

  [ food, grub ]
end

def create_antonyms!
  good = FactoryGirl.create :good
  bad = FactoryGirl.create :bad
  good_sense = FactoryGirl.create(:sense, :synset => FactoryGirl.create(:good_synset))
  bad_sense = FactoryGirl.create(:sense, :synset => FactoryGirl.create(:bad_synset ))

  good_sense.synset.pointers << FactoryGirl.create(:pointer, :ptype => 'antonym', :target => bad_sense.synset, :source => good_sense.synset)
  bad_sense.synset.pointers << FactoryGirl.create(:pointer, :ptype => 'antonym', :target => good_sense.synset, :source => bad_sense.synset)

  good.senses << good_sense
  bad.senses  << bad_sense

  good.save!
  bad.save!

  add_inflections good
  add_inflections bad

  [ good, bad ]
end
