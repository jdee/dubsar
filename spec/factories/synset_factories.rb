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

Factory.define :pointer do |p|
end

Factory.define :verb_frame do |vf|
end

Factory.define :senses_verb_frame do |svf|
end

Factory.define :food_synset, :class => Synset do |s|
  s.definition 'something edible'
  s.lexname 'noun.Tops'
  s.part_of_speech 'noun'
end

Factory.define :substance_synset, :class => Synset do |s|
  s.definition 'a material or thing'
  s.lexname 'noun.Tops'
  s.part_of_speech 'noun'
end

Factory.define :bad_synset, :class => Synset do |s|
  s.definition 'the opposite of good; "a bad boy"; "a bad thing"'
  s.lexname 'adj.all'
  s.part_of_speech 'adjective'
end

Factory.define :good_synset, :class => Synset do |s|
  s.definition 'the opposite of bad'
  s.lexname 'adj.all'
  s.part_of_speech 'adjective'
end

Factory.define :follow_synset, :class => Synset do |s|
  s.definition 'pursue; follow in or as if in pursuit'
  s.lexname 'verb.motion'
  s.part_of_speech 'verb'
end
