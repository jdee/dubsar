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

# A set of synonymous words.
class Synset < ActiveRecord::Base
  has_many :senses, -> { order 'senses.freq_cnt DESC, senses.id ASC' }
  has_many :words, :through => :senses

  has_many :pointers, -> { order 'pointers.id ASC' }, as: :source
  has_many :targets, :through => :pointers

  has_one :source, :class_name => 'Pointer', :as => :target

  validates :definition, :presence => true
  validates :lexname, :presence => true
  validates :part_of_speech, :presence => true

  # Return a collection of +Word+ model objects excluding the one
  # passed in as the +word+ argument.
  def words_except(word)
    words.where([ "name != ?", word.name ]).order(:name)
  end

  # Return a collection of +Sense+ model objects excluding the one
  # associated with the +word+ argument.
  def senses_except(word)
    senses.joins("INNER JOIN words w ON w.id = senses.word_id").
      where([ "w.name != ?", word.name ]).order('w.name')
  end

  def gloss
    definition.sub(/;\s*".*$/, '')
  end

  def samples
    matches = /;\s*(".*)$/.match definition
    s = matches ? matches[1] : ''
    s.split(';')
  end

  def freq_cnt
    senses.map(&:freq_cnt).inject(&:+)
  end

  def page_title
    "Dubsar - #{word_list_and_pos}"
  end

  def meta_description
    description = "Dubsar Dictionary Project Synset entry for #{words.map(&:name).join(", ")} <#{lexname}>"
    description += " freq. cnt.: #{freq_cnt}" unless freq_cnt.zero?
    description += "; #{gloss}"
    description
  end

  def word_list_and_pos
    "#{words.order(:name).map(&:name).join(", ")} (#{Word.pos(part_of_speech)}.)"
  end
end
