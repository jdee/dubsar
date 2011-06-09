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

class AddVerbFrames < ActiveRecord::Migration
  def self.up
    puts "#{Time.now} loading new verb frames"
    add_index :verb_frames, :number
    File.open(File.expand_path('../../defaults/sents.vrb', __FILE__)).each do |line|
      matches = /^(\d+) (.*)$/.match(line.chomp)
      index = matches[1].to_i + 1000
      frame = matches[2]

      VerbFrame.create :frame => frame, :number => index
    end

    puts "#{Time.now} loading verb sentences"
    @verb_sentences = Hash.new []
    File.open(File.expand_path('../../defaults/sentidx.vrb', __FILE__)).each do |line|
      sense_key, sentences = line.chomp.split
      next unless sentences
      @verb_sentences[sense_key] = sentences.split(',')
    end

    puts "#{Time.now} processing verbs"
    File.open(File.expand_path('../../defaults/data.verb', __FILE__)).each do |line|
      next if line =~ /^\s/

      left, defn = line.split('| ')
      synset_offset, lex_filenum, ss_type, w_cnt, *rest = left.split(' ')
      w_cnt = w_cnt.to_i(16)

      synset = Synset.first :conditions => {
        :offset => synset_offset.to_i,
        :part_of_speech => 'verb'
      }
      synset_index = 0
      rest.slice(0, 2*w_cnt).each_slice(2) do |a|
        lex_id = case a[1].to_i
        when (0..9)
          '0' + a[1]
        else
          a[1]
        end

        sense_key = "#{a[0]}%2:#{lex_filenum}:#{lex_id}::"

        sentences = @verb_sentences[sense_key]
        next if sentences.empty?

        synset_index += 1
        sense = synset.senses.find :first, :conditions => { :synset_index => synset_index }

        sentences.each do |number|
          frame = VerbFrame.find_by_number(number.to_i+1000)
          SensesVerbFrame.create :sense => sense, :verb_frame => frame
        end
      end
    end
    puts "#{Time.now} done"
  end

  def self.down
    remove_index :verb_frames, :number

    VerbFrame.all.each do |frame|
      next if frame.number < 1000

      frame.senses_verb_frames.each do |svf|
        svf.destroy
      end
      frame.destroy
    end
  end
end
