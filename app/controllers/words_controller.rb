class WordsController < ApplicationController
  respond_to :html, :json
  before_filter :init_count
  before_filter :setup_captions

  def error
    redirect_with_error 'bad request'
  end

  # Retrieve all words matching the specified +term+ and render as
  # HTML or JSON, one page at a time.
  def show
    page = params[:page]
    @term = params[:term]

    set_time_of_news_update

    # show and index use the same URL
    render(:action => :index) and return unless @term

    operator = params[:case].blank? ? 'ilike' : 'like'
    search_options = {
      :conditions => [ "name #{operator} ?", @term ],
      :order => 'name'
    }

    respond_to do |format|

      format.html {
        @words = Word.paginate({ :page => page }.merge(search_options))
        if @words.count > 0
          render :action => 'show'
        else
          redirect_with_error "no results for \"#{CGI.escapeHTML @term}\""
        end
      }

      format.json do
        page ||= 1

        total_pages = Word.count(search_options)/100 + 1;
        @words = Word.all({:offset => 100*(page.to_i-1), :limit => 100}.merge(search_options));
        respond_with({
          :case      => params[:case] || '',
          :next_page => page.to_i + 1,
          :total     => total_pages,
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
    @dubsar_caption = 'dub-sar cuneiform signs from the Pennsylvania Sumerian Dictionary'
    @dubsar_alt = 'dub-sar'
  end

  def set_time_of_news_update
    # This doesn't work with Capistrano.
    # @last_news_update = File.stat(File.join(File.dirname(__FILE__), '..', 'views', 'words', '_news.html.haml')).mtime.strftime("%d-%b-%Y");
    @last_news_update = '23-Oct-2010'
  end
end
