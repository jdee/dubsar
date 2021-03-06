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

class SynsetsController < ApplicationController
  respond_to :html, :json

  def tab
    @synset = Synset.includes([ { senses: [ :synset, :word ] }, { pointers: :target} ]).find params[:synset_id]
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
    @synset = Synset.includes([ { senses: [ :synset, :word ] }, { pointers: :target} ]).find params[:id]
    respond_to do |format|
      format.html
      format.json do
        respond_with json_show_response
      end
    end
  rescue
    error
  end

  def m_show
    redirect_to synset_path(id: params[:id]), status: :moved_permanently
  end

  private

  def json_show_response
    [ @synset.id, Word.pos(@synset.part_of_speech), @synset.lexname, @synset.gloss, @synset.samples, @synset.senses.includes(:word).order('freq_cnt DESC').map{|s|[s.id,s.word.name,s.marker,s.freq_cnt,s.word_id]}, @synset.freq_cnt, pointer_response ]
  end

  def pointer_response
    @synset.pointers.map do |ptr|
      response = [ ptr.ptype, ptr.target_type.downcase, ptr.target.id ]
      response << ptr.target.word_list_and_pos
      response << ptr.target.gloss
      response << ptr.target.synset_id if ptr.target.is_a? Sense
      response
    end
  end
end
