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

class WordsController < ApplicationController
  respond_to :html, :json
  before_filter :init_count
  before_filter :setup_captions

  @max_json_limit = 1000

  class << self
    attr_reader :max_json_limit
  end

  def error
    redirect_with_error 'bad request'
  end

  def qunit
    render :layout => false
  end

  # Retrieve all words matching the specified +term+ and render as
  # HTML or JSON, one page at a time.
  def show
    @term = params[:term]
    match = params[:match]

    case match
    when nil, '', 'case', 'exact', 'regexp'
    else
      redirect_with_error('bad request') and return
    end

    # show and index use the same URL
    render(:action => :index) and return unless @term

    # strip leading and trailing white space and compress internal
    # whitespace
    @term = @term.sub(/^\s+/, '').sub(/\s+$/, '').gsub(/\s+/, ' ')

    respond_to do |format|
      format.html do
        @words = Word.search params.merge(:page => params[:page], :order => 'name ASC, part_of_speech ASC')
        if @words.count > 0
          render :action => 'show'
        else
          redirect_with_error(
            "no results for \"#{CGI.escapeHTML @term}\"")
        end
      end

      format.json do
        local_params = params.clone
        # when the autocompleter makes many successive requests for
        # the same thing, use the flash to avoid counting all matches
        # every time
        @total_words = flash[:last_count] if
          flash[:last_term] == @term and
          flash[:last_match] == local_params[:match]
        @total_words ||= Word.search_count local_params

        flash[:last_term ] = @term
        flash[:last_match ] = local_params[:match]
        flash[:last_count] = @total_words

        # protect myself against stupid requests
        local_params[:limit] = local_params[:limit].to_i if local_params[:limit]
        local_params[:limit] ||= self.class.max_json_limit
        local_params[:limit] = self.class.max_json_limit if
          local_params[:limit] > self.class.max_json_limit

        @words = Word.search local_params.merge(:order => 'freq_cnt DESC, name ASC, part_of_speech ASC')

        # The uniq method call is case-sensitive.  It has the effect of
        # collapsing multiple parts of speech, e.g. cold (n.) and cold
        # (adj.).  But we still have the issue of Jack and jack, which
        # we address with the inject.
        word_list = @words.map{ |w| w.name }.uniq.inject([]) do |list, w|
          if ! list.empty? and list.last.casecmp(w) == 0
            if w < list.last
              list.pop
              list << w
            end
          else
            list << w
          end
          list
        end

        respond_with({
          :match  => local_params[:match] || '',
          :offset => local_params[:offset],
          :limit  => local_params[:limit],
          :total  => @total_words,
          :term   => @term.sub(/%$/, ''),
          :list   => word_list
        }.to_json)
      end

    end
  end

  def init_count
    @count = -1
  end

  private

  def redirect_with_error(errmsg)
    flash[:error] = errmsg
    redirect_to(params[:back] == 'yes' ? :back : :root)
  end

  def setup_captions
    @dubsar_caption = 'dub-sar cuneiform signs from the Pennsylvania" +
      " Sumerian Dictionary'
    @dubsar_alt = 'dub-sar'
  end
end
