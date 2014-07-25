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

namespace :wn do
  desc 'reload the WN db tables without dropping or altering row IDS for words, synsets or senses'
  task reload: :environment do
    require File.expand_path('db/reload', Rails.root)
  end

  desc 'verify the WN 3.1 DB content'
  task verify: :environment do
    # DEBT: Nouns only for now
    File.open(File.expand_path("db/defaults/data.noun", Rails.root)).each do |line|
      next if line =~ /^\s/

      left, defn = line.split('| ')
      synset_offset, lex_filenum, ss_type, w_cnt, *rest = left.split(' ')

      puts "##### Failed to find synset at offset #{synset_offset}" if Synset.where(offset: synset_offset.to_i, part_of_speech:'noun').count == 0
    end
  end
end
