class WordsController < ApplicationController
  def index
  end

  def show
    @word = Word.find_by_name params[:name]
  end

  def by_letter
    @letter = params[:letter]
    @words = Word.all :conditions => [ 'name like ?', @letter.downcase + '%' ],
      :order => 'name'
  end
end
