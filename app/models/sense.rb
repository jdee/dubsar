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

class Sense < ActiveRecord::Base
  belongs_to :word
  belongs_to :synset
  has_one :source, :class_name => 'Pointer', :as => :target
  has_many :pointers, -> { order('pointers.id ASC') }, as: :source
  has_many :targets, :through => :pointers
  has_many :senses_verb_frames, dependent: :destroy
  has_many :verb_frames, -> { order :number }, through: :senses_verb_frames
  validates :freq_cnt, :presence => true
  validates :synset_index, :presence => true

  def words
    [ word ]
  end

  def frames
    verb_frames.map do |frame|
      matches = /^(.*)%s(.*)$/.match frame.frame
      matches ? matches[1] + '<strong>' + word.name + '</strong>' + matches[2] : frame.frame
    end
  end

  def synonyms
    synset.words_except(word)
  end

  def page_title
    "Dubsar - #{word.name} (#{word.pos}.) #{synset.gloss}"
  end

  def meta_description
    description = "Dubsar Dictionary Project Sense entry for #{word.name}: #{synset.gloss} <#{synset.lexname}>"
    description += " (#{marker})" unless marker.blank?
    description += " freq. cnt.: #{freq_cnt}" unless freq_cnt.zero?
    description += " (#{synonyms.map(&:name).join(", ")})" unless synonyms.empty?
    description
  end

  def gloss
    synset.gloss
  end

  def unique_name
=begin
    # This is only useful when distinguishing words in a synset, but useless to distinguish
    # synsets a word belongs to. The easiest thing to do is use the id and be done with it.
    name = word.name
    (name.capitalized? ? 'cap-' : '') + name.downcase.gsub(/[\s.']/, '_')
=end
    id
  end

  def path_to_synset_with_fragment
    "#{synset_path(synset)}##{unique_name}"
  end

end
