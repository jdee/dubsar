class WordsController < ApplicationController
  def index
  end

  def show
    @words = Word.all :conditions => { :name => params[:name] }
  end

  def by_letter
    @letter = params[:letter]
    @words = Word.paginate :page => params[:page], :conditions => [ 'name like ?', @letter.downcase + '%' ], :order => 'name'
  end
end
