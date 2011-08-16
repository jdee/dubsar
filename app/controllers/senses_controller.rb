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

class SensesController < ApplicationController
  respond_to :html, :json

  def tab
    @sense = Sense.find params[:sense_id], :include => [ { :synset => :words }, { :senses_verb_frames => :verb_frame }, { :pointers => :target } ]
    respond_to do |format|
      format.html do
        render @sense
      end
    end
  rescue
    error
  end

  def show
    @sense = Sense.find params[:id], :include => [ { :synset => :words }, { :senses_verb_frames => :verb_frame }, { :pointers => :target } ]

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
    @sense = Sense.find params[:id], :include => [ { :synset => :words }, { :senses_verb_frames => :verb_frame }, { :pointers => :target } ]
    render :layout => false
  rescue
    m_error
  end

  private

  def json_show_response
    response = [ @sense.id, [ @sense.word.id, @sense.word.name, @sense.word.pos ], [ @sense.synset.id, @sense.synset.gloss ], @sense.synset.lexname, @sense.marker, @sense.freq_cnt ]
    response << @sense.synset.senses_except(@sense.word).sort{|s1,s2|s2.freq_cnt<=>s1.freq_cnt}.map{|s|[s.id,s.word.name,s.marker,s.freq_cnt]}
    response << @sense.verb_frames.map(&:frame)
    response << @sense.synset.samples
    response << pointer_response
    response
  end

  def pointer_response
    @sense.pointers.map do |ptr|
      response = [ ptr.ptype, ptr.target_type.downcase, ptr.target.id ]
      case ptr.target_type
      when 'Sense'
        response << ptr.target.word.name_and_pos
      when 'Synset'
        response << ptr.target.word_list_and_pos
      end
      response << ptr.target.gloss
    end
  end
end
