class WordsController < ApplicationController
  respond_to :html, :json
  before_filter :setup_captions

  def error
    redirect_with_error 'bad request'
  end

  # Retrieve all words matching the specified +term+ and render as
  # HTML or JSON, one page at a time.
  def show
    page = params[:page]
    @term = params[:term]

    # show and index use the same URL
    render(:action => :index) and return unless @term

    @term += '%' if params[:starts_with] == 'yes'
    search_options = {
      :conditions => [ 'name ilike ?', @term ],
      :order => 'name'
    }
    @words = Word.paginate({ :page => page }.merge(search_options))

    respond_to do |format|
      format.html {
        if @words.count > 0
          render :action => 'show'
        else
          redirect_with_error "no results for \"#{@term}\""
        end
      }
      format.json do
        respond_with({
          :page  => page ? page.to_i + 1 : 2,
          :total => @words.total_pages,
          :term  => @term.sub(/%$/, ''),
          :list  => @words.map{ |w| w.name }.uniq
        }.to_json)
      end
    end
  end

  def setup_captions
    @dubsar_caption = 'dub-sar cuneiform signs from the Pennsylvania Sumerian Dictionary'
    @dubsar_alt = 'dub-sar'
  end

  def redirect_with_error(errmsg)
    flash[:error] = errmsg
    redirect_to(params[:back] == 'yes' ? :back : :root)
  end
end
