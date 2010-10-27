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

    # show and index use the same URL
    render(:action => :index) and return unless @term

    # strip leading and trailing white space and compress internal
    # whitespace
    @term = @term.sub(/^\s+/, '').sub(/\s+$/, '').gsub(/\s+/, ' ')

    operator = params[:case].blank? ? 'ilike' : 'like'
    search_options = {
      :conditions => [ "name #{operator} ?", @term ],
      :order => 'name'
    }

    respond_to do |format|

      format.html do
        @words = Word.paginate({:page => params[:page]}.merge(search_options))
        if @words.count > 0
          @words.each do |w|
            w.hit_count += 1
            w.save
          end
          render :action => 'show'
        else
          redirect_with_error(
            "no results for \"#{CGI.escapeHTML @term}\"")
        end
      end

      format.json do
        # when the autocompleter makes many successive requests for
        # the same thing, use the flash to avoid counting all matches
        # every time
        @total_words = flash[:last_count] if
          flash[:last_term] == @term and
          flash[:last_case] == params[:case]
        @total_words ||= Word.count(search_options)

        flash[:last_term ] = @term
        flash[:last_case ] = params[:case]
        flash[:last_count] = @total_words

        # protect myself against stupid requests
        limit = params[:limit].to_i if params[:limit]
        limit ||= self.class.max_json_limit
        limit = self.class.max_json_limit if
          limit > self.class.max_json_limit

        @words = Word.all(
          :offset => params[:offset],
          :limit => limit,
          :conditions => [ "name #{operator} ?", @term ],
          :order => 'hit_count DESC, name ASC')

        respond_with({
          :case      => params[:case] || '',
          :offset    => params[:offset],
          :limit     => limit,
          :total     => @total_words,
          :term      => @term.sub(/%$/, ''),
          :list      => @words.map{ |w| w.name }.uniq
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
