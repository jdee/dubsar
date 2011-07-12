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

class WordsController < ApplicationController
  respond_to :html, :json
  before_filter :init_count
  before_filter :setup_captions
  before_filter :munge_search_params, :only => [ :search ]

  @max_json_limit = 25

  class << self
    attr_reader :max_json_limit
  end

  def error
    redirect_with_error 'bad request'
  end

  def qunit
    render :layout => false
  end

  def m_faq
    render :layout => false
  end

  def m_license
    render :layout => false
  end

  def mobile
    render :layout => 'mobile'
  end

  def m_sense
    @sense = Sense.find params[:id], :include => [ { :synset => :words }, { :senses_verb_frames => :verb_frame }, :pointers ]
    @index = params[:index]
    render :layout => false
  end

  def show
    @back = request.env['HTTP_REFERER']
    @word = Word.find params[:id], :include => [ :inflections, { :senses => :synset } ]
  end

  def m_show
    @back = request.env['HTTP_REFERER']
    @word = Word.find params[:id], :include => [ :inflections, { :senses => :synset } ]
    render :layout => false
  end

  def m_search
    @term = params['term']

    options = params.symbolize_keys
    if @term
      @words = Word.search options.merge(:page => params[:page], :per_page => 10,
        :order => 'words.name ASC, words.part_of_speech ASC'
      )
    end
    render :layout => 'mobile'
  end

  def os
    respond_to do |format|
      format.json do
        @term = params[:term]

        # strip leading and trailing white space and compress internal
        # whitespace
        @term.sub!(/^\s*/, '').sub!(/\s*$/, '').gsub!(/\s+/, ' ')

        local_params = params.clone
        local_params[:term] = "#{@term}%"
        @words = Word.search local_params.merge(:select => 'name',
          :offset => 0, :limit => 10,
          :order => 'freq_cnt DESC, name ASC, part_of_speech ASC')

        # The uniq method call is case-sensitive.  It has the effect of
        # collapsing multiple parts of speech, e.g. cold (n.) and cold
        # (adj.).  But we still have the issue of Jack and jack, which
        # we address with the inject.
        word_list = @words.map{ |w| w.name }.uniq.inject([]) do |list, w|
          unless list.empty? or list.last.casecmp(w) != 0
            if w < list.last
              list.pop
              list << w
            end
          else
            list << w
          end
          list
        end

        respond_with [ @term, word_list ]
      end
    end
  end

  # Retrieve all words matching the specified +term+ and render as
  # HTML or JSON, one page at a time.
  def search
    respond_to do |format|
      format.html do
        options = params.symbolize_keys
        @words = Word.search options.merge(:page => params[:page],
          :order => 'words.name ASC, words.part_of_speech ASC',
          :include => [
            :inflections,
            { :senses => [
              { :synset => :words },
              { :senses_verb_frames => :verb_frame },
              :pointers ]
            }
          ]
        )
        if @words.count > 0
          render :action => 'search'
        else
          redirect_with_error(
            "no results for \"#{CGI.escapeHTML @term}\"")
        end
      end

      format.json do
        # TODO: Implement JSON search for native mobile apps.
      end

    end
  end

  private

  def setup_captions
    @dubsar_caption = 'dub-sar cuneiform signs from the Pennsylvania' +
      ' Sumerian Dictionary'
    @dubsar_alt = 'dub-sar'
  end

  def init_count
    @count = -1
  end

  def munge_search_params
    # DEBT: This is an unpleasant kluge, but refining this will
    # gradually help weed duplicates out of search engine indices.
    @term = params[:term]

    # search and index use the same URL
    unless @term
      # flash.now[:notice] = 'Dubsar is undergoing a number of changes. Thanks for your patience.'
      render :action => :index
      return
    end

    # strip leading and trailing white space and compress internal
    # whitespace
    @term.sub!(/^\s*/, '').sub!(/\s*$/, '').gsub!(/\s+/, ' ')

    redirect_with_error('bad request') and return false if @term.blank?

    @match = params[:match]
    @title = params[:title]

    case @match
    when nil, ''
      if @term =~ /^[A-Z]%$/
        letter = /^([A-Z])%$/.match(@term)[1]
        @match = 'regexp'
        @term = "^[#{letter}#{letter.downcase}]"
        @title = letter
      end
    when 'case', 'exact', 'regexp'
    else
      redirect_with_error('bad request') and return false
    end

  end
end
