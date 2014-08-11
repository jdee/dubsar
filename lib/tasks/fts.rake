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

namespace :fts do
  desc 'build the FTS tables in the current database'
  task :build => :environment do
    puts "building inflections_fts table"
    puts " dropping any old tables"
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
      DROP TABLE IF EXISTS inflections_fts_docsize
    SQL
    ActiveRecord::Base.connection.execute <<-SQL
      DROP TABLE IF EXISTS inflections_fts_stat
    SQL

    puts " creating new table"
    ActiveRecord::Base.connection.execute <<-SQL
      CREATE VIRTUAL TABLE inflections_fts USING fts4(id, name, word_id)
    SQL
    puts " populating new table"
    ActiveRecord::Base.connection.execute <<-SQL
      INSERT INTO inflections_fts(id, name, word_id)
        SELECT id, name, word_id FROM inflections
    SQL
    puts " done"

    puts "building synsets_fts table"
    puts " dropping any old tables"
    ActiveRecord::Base.connection.execute <<-SQL
      DROP TABLE IF EXISTS synsets_fts
    SQL
    ActiveRecord::Base.connection.execute <<-SQL
      DROP TABLE IF EXISTS synsets_fts_content
    SQL
    ActiveRecord::Base.connection.execute <<-SQL
      DROP TABLE IF EXISTS synsets_fts_segdir
    SQL
    ActiveRecord::Base.connection.execute <<-SQL
      DROP TABLE IF EXISTS synsets_fts_segments
    SQL
    ActiveRecord::Base.connection.execute <<-SQL
      DROP TABLE IF EXISTS synsets_fts_docsize
    SQL
    ActiveRecord::Base.connection.execute <<-SQL
      DROP TABLE IF EXISTS synsets_fts_stat
    SQL

    puts " creating new table"
    ActiveRecord::Base.connection.execute <<-SQL
      CREATE VIRTUAL TABLE synsets_fts USING fts4(id, definition)
    SQL
    puts " populating new table"
    ActiveRecord::Base.connection.execute <<-SQL
      INSERT INTO synsets_fts(id, definition)
        SELECT id, definition FROM synsets
    SQL

    puts "building synset_suggestions table"
    puts " dropping any old tables"
    ActiveRecord::Base.connection.execute <<-SQL
      DROP TABLE IF EXISTS synset_suggestions
    SQL
    ActiveRecord::Base.connection.execute <<-SQL
      DROP TABLE IF EXISTS synset_suggestions_content
    SQL
    ActiveRecord::Base.connection.execute <<-SQL
      DROP TABLE IF EXISTS synset_suggestions_segdir
    SQL
    ActiveRecord::Base.connection.execute <<-SQL
      DROP TABLE IF EXISTS synset_suggestions_segments
    SQL
    ActiveRecord::Base.connection.execute <<-SQL
      DROP TABLE IF EXISTS synset_suggestions_docsize
    SQL
    ActiveRecord::Base.connection.execute <<-SQL
      DROP TABLE IF EXISTS synset_suggestions_stat
    SQL

    puts " creating new table"
    ActiveRecord::Base.connection.execute <<-SQL
      CREATE VIRTUAL TABLE synset_suggestions USING fts4(synset_id, suggestion)
    SQL
    puts "#{DateTime.now} populating new table"
    Synset.order('id ASC').each do |synset|
      synset.definition.split(/[;"'`.,:()]+/).each do |suggestion|
        next if suggestion.blank?
        suggestion.chomp!
        suggestion.strip!

        ActiveRecord::Base.connection.execute <<-SQL
          INSERT INTO synset_suggestions(synset_id, suggestion) VALUES(#{synset.id}, '#{suggestion}')
        SQL

      end
      puts "#{DateTime.now} finished #{synset.id}/#{Synset.count}" if synset.id % 10_000 == 0
    end

    Rake::Task['fts:optimize'].invoke
    puts " done"
  end

  desc "optimize FTS tables"
  task :optimize => :environment do
    puts "optimizing fts tables"
    ActiveRecord::Base.connection.execute <<-SQL
      INSERT INTO inflections_fts(inflections_fts) VALUES('optimize')
    SQL
    ActiveRecord::Base.connection.execute <<-SQL
      INSERT INTO synsets_fts(synsets_fts) VALUES('optimize')
    SQL
    ActiveRecord::Base.connection.execute <<-SQL
      INSERT INTO synset_suggestions(synset_suggestions) VALUES('optimize')
    SQL
    puts "done"
  end

  desc 'seed with FTS'
  task :seed do
    Rake::Task['db:reset'].invoke
    Rake::Task['fts:build'].invoke
  end
end
