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

def create_fts_table
  ActiveRecord::Base.connection.execute <<-SQL
    DROP TABLE IF EXISTS inflections_fts
  SQL
  ActiveRecord::Base.connection.execute <<-SQL
    DROP TABLE IF EXISTS inflections_fts_content
  SQL
  ActiveRecord::Base.connection.execute <<-SQL
    DROP TABLE IF EXISTS inflections_fts_segdir
  SQL
  ActiveRecord::Base.connection.execute <<-SQL
    DROP TABLE IF EXISTS inflections_fts_segments
  SQL

  ActiveRecord::Base.connection.execute <<-SQL
    CREATE VIRTUAL TABLE inflections_fts USING fts3(id, name, word_id)
  SQL
  ActiveRecord::Base.connection.execute <<-SQL
    INSERT INTO inflections_fts(id, name, word_id)
      SELECT id, name, word_id FROM inflections
  SQL
  ActiveRecord::Base.connection.execute <<-SQL
    INSERT INTO inflections_fts(inflections_fts) VALUES('optimize')
  SQL
end

def add_inflections(word)
  word.inflections.each do |i|
    ActiveRecord::Base.connection.execute <<-SQL
      INSERT INTO inflections_fts(id, name, word_id) VALUES(#{i.id}, '#{i.name}', #{word.id})
    SQL
  end
  ActiveRecord::Base.connection.execute <<-SQL
    INSERT INTO inflections_fts(inflections_fts) VALUES('optimize')
  SQL
end
