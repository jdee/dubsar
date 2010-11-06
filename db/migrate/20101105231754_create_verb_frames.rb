#  Dubsar Dictionary Project
#  Copyright (C) 2010 Jimmy Dee
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

class CreateVerbFrames < ActiveRecord::Migration
  def self.up
    create_table :verb_frames do |t|
      t.string :frame
      t.integer :number
    end

    create_table :senses_verb_frames do |t|
      t.references :sense
      t.references :verb_frame
    end

    @verb_frames = {}
    File.open(File.expand_path('../defaults/frames.vrb', File.dirname(__FILE__))).each do |line|
      matches = /^(\d+)\s+(.*)$/.match(line.chomp)
      number = matches[1].to_i
      frame = matches[2]
      verb_frame = VerbFrame.create :number => number, :frame => frame
      @verb_frames[number] = [ verb_frame.id, frame ]
    end

    File.open(File.expand_path('../defaults/data.verb', File.dirname(__FILE__))).each do |line|
      next if line =~ /^\s/

      left, defn = line.split('| ')
      synset_offset, lex_filenum, ss_type, w_cnt, *rest = left.split(' ')
      w_cnt = w_cnt.to_i(16)

      synset = Synset.find_by_part_of_speech_and_offset('verb',
        synset_offset.to_i)
      @words = []
      rest.slice(0, 2*w_cnt).each_slice(2) { |a| @words << a[0].gsub('_', ' ') }

      p_cnt, *more = rest.slice(2*w_cnt, rest.length-2*w_cnt)
      next unless more

      p_cnt = p_cnt.to_i
      frames = more.slice(2*p_cnt, more.length-2*p_cnt)

      f_cnt, *more_frames = frames
      f_cnt = f_cnt.to_i
      next if f_cnt == 0 or more_frames.nil?

      more_frames.slice(0, 3*f_cnt).each_slice(3) do |f|
        plus, f_num, w_num = f
        verb_frame_id = @verb_frames[f_num.to_i][0]
        sense = synset.senses.find :first, :conditions => [ "words.name = ?",
          @words[w_num.to_i] ], :joins => 'INNER JOIN words ON words.id = senses.word_id'
        SensesVerbFrame.create :sense_id => sense.id, :verb_frame_id => verb_frame_id
      end
    end
  end

  def self.down
    drop_table :senses_verb_frames
    drop_table :verb_frames
  end
end
