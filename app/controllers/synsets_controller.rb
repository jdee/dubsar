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

class SynsetsController < ApplicationController
  respond_to :html, :json

  def tab
    @synset = Synset.find params[:synset_id],
      :include => [ :words, :senses, { :pointers => :target } ]
    @sense = Sense.find params[:sense_id]
    respond_to do |format|
      format.html do
        render @synset
      end
    end
  rescue
    error
  end

  def show
    @synset = Synset.find params[:id], :include => [ :words, :senses, { :pointers => :target } ]
    respond_to do |format|
      format.html
      format.json do
        respond_with json_show_request
      end
    end
  rescue
    error
  end

  def m_show
    @synset = Synset.find params[:id], :include => [ :words, :senses, { :pointers => :target } ]
  rescue
    m_error
  end

  private

  def json_show_request
    [ @synset.id, Word.pos(@synset.part_of_speech), @synset.lexname, @synset.gloss, @synset.samples, @synset.senses.all(:joins => "JOIN words ON words.id = senses.word_id", :order => 'words.name').map{|s|[s.id,s.word.name]}, @synset.freq_cnt ]
  end
end
