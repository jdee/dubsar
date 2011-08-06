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

  def qunit
    render :layout => false
  end

  def m_faq
    render :layout => 'mobile'
  end

  def m_support
    render :layout => 'mobile'
  end

  def m_license
    render :layout => false
  end

  def mobile
    render :layout => 'mobile'
  end

  def tab
    @word = Word.find params[:word_id], :include => [ :inflections, { :senses => :synset } ]
    @sense = Sense.find params[:sense_id]
    respond_to do |format|
      format.html do
        render @word
      end
    end
  rescue
    error
  end

  def show
    @word = Word.find params[:id], :include => [ :inflections, { :senses => :synset } ]
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
    @word = Word.find params[:id], :include => [ :inflections, { :senses => :synset } ]
    render :layout => false
  rescue
    m_error
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
    options = params.symbolize_keys

    respond_to do |format|
      format.html do
        @words = Word.search options.merge(:page => params[:page],
          :order => 'words.name ASC, words.part_of_speech ASC',
          :include => [
            :inflections,
            { :senses => [
              { :synset => { :senses => :word } },
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
        @words = Word.search options.merge(:page => params[:page],
          :order => 'words.name ASC, words.part_of_speech ASC',
          :include => :inflections
        )

        # Bad requests are kicked back in the munge_search_params
        # filter. If no search results are found, the result will be an
        # empty array.
        respond_with json_search_response
      end

    end
  end

  def wotd
    word = DailyWord.word_of_the_day

    respond_to do |format|
      format.json do
        respond_with json_wotd_response(word)
      end
      format.xml
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

    error and return false if @term.blank?

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
      error and return false
    end

  end

  def json_wotd_response(word)
    [ word.id, word.name, word.pos, word.freq_cnt, word.other_forms ]
  end

  def json_search_response
    [ @term, @words.map { |w| [ w.id, w.name, w.pos, w.freq_cnt, w.other_forms ] }, @words.total_pages ]
  end

  def json_show_response
    senses = @word.senses.map do |s|
      [ s.id, s.synset.senses_except(s.word).map{|_s| [ _s.id, _s.word.name ]}, s.synset.gloss, s.synset.lexname, s.marker, s.freq_cnt ]
    end
    [ @word.id, @word.name, @word.pos, @word.other_forms, senses, @word.freq_cnt ]
  end
end
