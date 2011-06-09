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

class CleanupInflections < ActiveRecord::Migration
  def self.up
    word = Word.find_by_name_and_part_of_speech 'hurt', 'verb'
    inflection = word.inflections.find :first,
      :conditions => { :name => 'hurted'}
    word.inflections.delete inflection
    word.save
    inflection.destroy
  end

  def self.down
    word = Word.find_by_name_and_part_of_speech 'hurt', 'verb'
    word.inflections.create :name => 'hurted'
  end
end
