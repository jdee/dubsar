#  Dubsar Dictionary Project
#  Copyright (C) 2010 Jimmy Dee
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

class AddIndices < ActiveRecord::Migration
  def self.up
    add_index :inflections, :word_id
    add_index :pointers, :sense_id
    add_index :pointers, [ :sense_id, :target_id, :target_type, :ptype ]
    add_index :senses, :word_id
    add_index :senses, [ :word_id, :synset_id ]
    add_index :senses_verb_frames, :sense_id
  end

  def self.down
    remove_index :senses_verb_frames, :sense_id
    remove_index :senses, [ :word_id, :synset_id ]
    remove_index :senses, :word_id
    remove_index :pointers, [ :sense_id, :target_id, :target_type, :ptype ]
    remove_index :pointers, :sense_id
    remove_index :inflections, :word_id
  end
end
