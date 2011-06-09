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

class CorrectUVerbInflections < ActiveRecord::Migration
  @words = %w{quit equip quip acquit quiz squat}

  def self.up
    @words.each do |word|
      w = Word.find_by_name_and_part_of_speech word, 'verb'
      inflection = w.inflections.find :first, :conditions => "name ~ '[ai][ptz]ing'"
      w.inflections.delete inflection
      inflection.destroy
      w.save
    end
  end

  def self.down
    @words.each do |word|
      w = Word.find_by_name_and_part_of_speech word, 'verb'
      w.inflections.create :name => word.name + 'ing'
      w.save
    end
  end
end
