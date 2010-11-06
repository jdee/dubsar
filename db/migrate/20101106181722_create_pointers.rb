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

class CreatePointers < ActiveRecord::Migration
  def self.up
    create_table :pointers do |t|
      t.references :target, :null => false, :polymorphic => true
      t.references :sense, :null => false
      t.string :ptype, :null => false
    end
    add_column :senses, :synset_index, :integer, :null => false, :default => 0
    add_index :synsets, [ :offset, :part_of_speech ]
  end

  def self.down
    remove_index :synsets, [ :offset, :part_of_speech ]
    remove_column :senses, :synset_index
    drop_table :pointers
  end
end
