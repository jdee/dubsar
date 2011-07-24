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

class PolymorphicPointerSource < ActiveRecord::Migration
  def self.up
    # All existing pointers are currently from senses, even semantic
    # ones. Each sense in a synset gets a pointer to the target synset
    # of a semantic pointer belonging to the source synset. This is
    # very convenient for rendering sense views, where you want to see
    # pointers associated with the parent synset, so it will remain.
    # The next migration will add new pointers from synset to synset.

    transaction do
      rename_column :pointers, :sense_id, :source_id
      add_column :pointers, :source_type, :string, :null => false, :default => "Sense"
    end
  end

  def self.down
    transaction do
      remove_column :pointers, :source_type
      rename_column :pointers, :source_id, :sense_id
    end
  end
end
