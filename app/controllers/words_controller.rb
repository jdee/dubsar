#  Dubsar Dictionary Project
#  Copyright (C) 2010-12 Jimmy Dee
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

  def ios_faq
    render :layout => 'mobile'
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

        @words = []
        exact = Inflection.find_by_name(@term)
        @words << exact.name if exact

        @words += InflectionsFt.all(:select => 'DISTINCT name',
          :conditions => [ "name MATCH ? AND name != ?", "#{@term}*", @term ],
          :order => 'name ASC', :limit => 10-@words.count).map(&:name)

        respond_with [ @term, @words ]
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

  def review
    @inflections = Inflection.paginate(
      :joins => 'INNER JOIN words ON words.id = inflections.word_id',
      :conditions => [
        "words.part_of_speech IN ('noun', 'verb') AND words.name >= 'a' AND words.name < '{' AND words.name GLOB '[a-z]*' AND NOT words.name GLOB ? ",
        "*[A-Z0-9 .-']*" ],
      :page => params[:page],
      :per_page => 135,
      :order => 'name ASC')
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
      # flash.now[:notice] = 'Happy Halloween. In honor of the occasion, the dark theme is free all day!'
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
        @match = 'glob'
        @term = "[#{letter}#{letter.downcase}]*"
        @title = letter
      end
    when 'case', 'exact', 'glob', 'regexp'
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
    senses = @word.senses.all(:order => 'freq_cnt DESC').map do |s|
      [ s.id, s.synset.senses_except(s.word).map{|_s| [ _s.id, _s.word.name ]}, s.synset.gloss, s.synset.lexname, s.marker, s.freq_cnt ]
    end
    [ @word.id, @word.name, @word.pos, @word.other_forms, senses, @word.freq_cnt ]
  end
end
