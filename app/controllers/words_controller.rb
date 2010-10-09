class WordsController < ApplicationController
  respond_to :html, :json

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
      format.html { @words = Word.paginate({ :page => params[:page] }.merge(search_options)) }
      format.json do
        @words = Word.all search_options
        respond_with(@words.map{ |w| w.name })
      end
    end
  end
end
