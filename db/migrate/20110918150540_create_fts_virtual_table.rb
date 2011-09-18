#  Dubsar Dictionary Project
#  Copyright (C) 2010-11 Jimmy Dee
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

class CreateFtsVirtualTable < ActiveRecord::Migration
  def self.up
    say "creating virtual table"
    ActiveRecord::Base.connection.execute <<-SQL
      CREATE VIRTUAL TABLE inflections_fts USING fts3(id, name, word_id)
    SQL

    say "populating virtual table"
    ActiveRecord::Base.connection.execute <<-SQL
      INSERT INTO inflections_fts(id, name, word_id)
        SELECT id, name, word_id FROM inflections
    SQL

    say "optimizing virtual table"
    ActiveRecord::Base.connection.execute <<-SQL
      INSERT INTO inflections_fts(inflections_fts) VALUES('optimize')
    SQL

    say "done"
  end

  def self.down
    ActiveRecord::Base.connection.execute("DROP TABLE inflections_fts")
  end
end
