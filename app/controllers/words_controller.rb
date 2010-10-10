class WordsController < ApplicationController
  respond_to :html, :json
  before_filter :init_count

  def index
  end

  def show
    @words = Word.all :conditions => [ 'name ilike ?', params[:name] ]
  end

  def starts_with
    # TODO: Handle a request without a ?term
    search_options = {
      :conditions => [ 'name ilike ?', params[:term] + '%' ],
      :order => 'name'
    }

    respond_to do |format|
      format.html do
        @words = Word.paginate({ :page => params[:page] }.merge(search_options))
      end
      format.json do
        @words = Word.all search_options
        respond_with @words.map{ |w| w.name }.uniq
      end
    end
  end

  def init_count
    # count accordion divs
    @count = 0
  end
end
