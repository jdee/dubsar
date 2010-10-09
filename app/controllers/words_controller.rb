class WordsController < ApplicationController
  def index
  end

  def show
    @words = Word.all :conditions => [ 'name ilike ?', params[:name] ]
  end

  def starts_with
    @start = params[:start]
    @words = Word.paginate :page => params[:page], :conditions => [ 'name ilike ?', @start + '%' ], :order => 'name'
  end
end
