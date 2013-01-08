#  Dubsar Dictionary Project
#  Copyright (C) 2010-13 Jimmy Dee
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

class InflectionsController < ApplicationController
  before_filter :authenticate_user!
  respond_to :html, :json

  def review
    per_page = request.format == :html ? 135 : 10
    @inflections = Inflection.paginate(
      :joins => 'INNER JOIN words ON words.id = inflections.word_id',
      :conditions => [
        "words.part_of_speech IN ('noun', 'verb') AND words.name >= 'a' AND words.name < '{' AND words.name GLOB '[a-z]*' AND NOT words.name GLOB ? AND NOT words.name = inflections.name",
        "*[A-Z0-9 .'-]*" ],
      :page => params[:page],
      :per_page => per_page,
      :order => 'name ASC')

    respond_to do |format|
      format.html
      format.json do
        respond_with json_review_response
      end
    end
  end

  def index
    @inflections = Inflection.paginate :page => params[:page],
      :per_page => 10000, :order => 'id ASC'
    respond_to do |format|
      format.json do
        respond_with json_review_response
      end
    end
  end

  def show
    @inflection = Inflection.find params[:id]
    respond_to do |format|
      format.json do
        respond_with @inflection
      end
    end
  end

  def create
    word = Word.find params[:word_id]
    @inflection = word.inflections.create(:name => params[:name])
    ActiveRecord::Base.connection.execute <<-SQL
      INSERT INTO inflections_fts(id, name, word_id)
        VALUES(#{@inflection.id}, "#{@inflection.name}", #{params[:word_id]})
    SQL
    respond_to do |format|
      format.json do
        head :created, :location => @inflection
      end
    end
  end

  def update
    respond_to do |format|
      format.json do
        @inflection = Inflection.find params[:id]
        @inflection.update_attributes :name => params[:name]
        ActiveRecord::Base.connection.execute <<-SQL
          UPDATE inflections_fts SET name = "#{params[:name]}"
            WHERE id = #{params[:id]}
        SQL
        respond_with @inflection
      end
    end
  end

  def destroy
    respond_to do |format|
      format.json do
        @inflection = Inflection.find params[:id]
        @inflection.destroy
        ActiveRecord::Base.connection.execute <<-SQL
          DELETE FROM inflections_fts WHERE id = #{params[:id]}
        SQL
        respond_with @inflection
      end
    end
  end

  def word
    word = Word.find params[:word_id]
    @inflections = word.inflections.all
    respond_to do |format|
      format.json do
        respond_with @inflections
      end
    end
  end

  private

  def json_review_response
    inflections = []
    @inflections.each do |inflection|
      inflections << { :id => inflection.id, :name => inflection.name,
        :word => { :id => inflection.word_id, :name => inflection.word.name,
        :pos => inflection.word.pos } }
    end
    { :page => params[:page] || 1, :total_pages => @inflections.total_pages,
      :inflections => inflections }
  end
end
