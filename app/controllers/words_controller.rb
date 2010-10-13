class WordsController < ApplicationController
  respond_to :html, :json
  before_filter :init_count

  def index
    @dubsar_caption = 'dub-sar cuneiform signs from the Pennsylvania Sumerian Dictionary'
  end

  # Retrieve all words matching the specified +term+ and render as
  # HTML or JSON, one page at a time.
  def show
    # TODO: Handle a(n erroneous) request without a ?term
    page = params[:page]
    term = params[:term]
    term += '%' if term and params[:starts_with] == 'yes'
    search_options = {
      :conditions => [ 'name ilike ?', term ],
      :order => 'name'
    }
    @words = Word.paginate({ :page => page }.merge(search_options))

    respond_to do |format|
      format.html { render :action => 'show' }
      format.json do
        respond_with({
          :page  => page ? page.to_i + 1 : 2,
          :total => @words.total_pages,
          :term  => term.sub(/%$/, ''),
          :list  => @words.map{ |w| w.name }.uniq
        }.to_json)
      end
    end
  end

  # count accordion divs
  def init_count
    @count = 0
  end
end
