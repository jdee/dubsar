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

class CreateSenses < ActiveRecord::Migration
  def self.up
    rename_table :synsets_words, :senses
    add_column :senses, :freq_cnt, :integer, :null => false, :default => 0
    add_column :senses, :id, :primary_key
  end

  def self.down
    remove_column :senses, :freq_cnt
    remove_column :senses, :id
    rename_table :senses, :synsets_words
  end
end
