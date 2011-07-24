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
class GenerateSemanticPointers < ActiveRecord::Migration
  def self.up
    transaction do
      rename_index :pointers, "index_pointers_on_sense_id", "index_pointers_on_source_id"
      add_index :pointers, [ :target_type, :target_id ]

      pointer_count = Pointer.all(:conditions => { :target_type => 'Synset' }, :select => 'DISTINCT ON (target_id) *').count
      say "#{DateTime.now} processing #{pointer_count.to_s :delimiter => ','} distinct semantic pointers"
      STDOUT.flush

      # The :include clause improves matters in development, where RAM is
      # plentiful, but the process peaked around 1.5 GB RSS. This should
      # be a bit kinder to production.

      # Pointer.all(:conditions => { :target_type => 'Synset' }, :select => 'DISTINCT ON (target_id) *', :include => { :source => :synset } ).each_with_index do |pointer, index|

      Pointer.all(:conditions => { :target_type => 'Synset' }, :select => 'DISTINCT ON (target_id) *').each do |pointer|
        Pointer.create! :source_id => pointer.source.synset_id, :source_type => 'Synset', :target_id => pointer.target_id, :target_type => 'Synset', :ptype => pointer.ptype
      end

      say "#{DateTime.now} finished"
      remove_index :pointers, [ :target_type, :target_id ]
    end
  end

  def self.down
    transaction do
      Pointer.delete_all(:source_type => 'Synset')
      rename_index :pointers, "index_pointers_on_source_id", "index_pointers_on_sense_id"
    end
  end
end
