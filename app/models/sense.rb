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

class Sense < ActiveRecord::Base
  belongs_to :word
  belongs_to :synset
  has_one :source, :class_name => 'Pointer', :as => :target
  has_many :pointers, :as => :source, :order => 'id ASC'
  has_many :targets, :through => :pointers
  has_many :senses_verb_frames
  has_many :verb_frames, :through => :senses_verb_frames,
    :order => 'number'
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
    "Dubsar - #{word.name} (#{word.pos}.)"
  end

  def meta_description
    "Dubsar Dictionary Project Sense entry for #{word.name} (#{word.pos}.): #{synset.gloss}"
  end

  def gloss
    synset.gloss
  end
end
