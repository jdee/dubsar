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
  factory :pointer do
  end
  
  factory :verb_frame do
  end
  
  factory :senses_verb_frame do
  end
  
  factory :food_synset, :class => Synset do
    definition 'something edible'
    lexname 'noun.Tops'
    part_of_speech 'noun'
  end
  
  factory :substance_synset, :class => Synset do
    definition 'a material or thing'
    lexname 'noun.Tops'
    part_of_speech 'noun'
  end
  
  factory :bad_synset, :class => Synset do
    definition 'the opposite of good; "a bad boy"; "a bad thing"'
    lexname 'adj.all'
    part_of_speech 'adjective'
  end
  
  factory :good_synset, :class => Synset do
    definition 'the opposite of bad'
    lexname 'adj.all'
    part_of_speech 'adjective'
  end
  
  factory :follow_synset, :class => Synset do
    definition 'pursue; follow in or as if in pursuit'
    lexname 'verb.motion'
    part_of_speech 'verb'
  end
end
