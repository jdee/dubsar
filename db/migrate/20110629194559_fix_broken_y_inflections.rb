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

class FixBrokenYInflections < ActiveRecord::Migration
  def self.up
    Word.all(:conditions => "part_of_speech = 'verb' AND name ~ '^[a-z]*[aeou]y$'").each do |word|
      inflection = word.inflections.first(:conditions => { :name => word.name.sub(/y$/, 'ies') })
      inflection.update_attribute(:name, "#{word.name}s") if inflection

      inflection = word.inflections.first(:conditions => { :name => word.name.sub(/y$/, 'ied') })
      inflection.update_attribute(:name, "#{word.name}ed") if inflection
    end
  end

  def self.down
    # raise ActiveRecord::IrreversibleMigration
  end
end
