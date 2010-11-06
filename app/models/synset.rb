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

# A set of synonymous words.
class Synset < ActiveRecord::Base
  has_many :senses
  has_many :words, :through => :senses

  has_one :source, :class_name => 'Pointer', :as => :target

  validates :definition, :presence => true
  validates :lexname, :presence => true

  # Return a collection of +Word+ model objects excluding the one
  # passed in as the +word+ argument.
  def words_except(word)
    words.find :all, :conditions => [ "LOWER(name) != LOWER(?)", word.name ],
      :order => 'name'
  end

  def gloss
    definition.sub(/;\s*".*$/, '')
  end

  def samples
    matches = /;\s*(".*)$/.match definition
    s = matches ? matches[1] : ''
    s.split(';')
  end
end
