#!/usr/bin/env ruby

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

# This script runs against a fully seeded DB (development, backup,
# backup_dev, production) to check the results of the seeding process.
# That's why it's not part of the unit test suite.
#
# rails runner script/check_inflections.rb

@fail_count = 0

def check_inflections(test_case)
  head, part_of_speech, inflections = test_case
  word = Word.first(:conditions => [ "name = :name AND part_of_speech = :part_of_speech", { :name => head, :part_of_speech => part_of_speech } ])
  raise "could not find #{head} (#{part_of_speech})" unless word

  passed = true

  # includes head
  if word.inflections.count != inflections.count + 1
    puts "*** wrong inflection count for #{head} (#{part_of_speech}), found #{word.inflections.count}, expected #{inflections.count+1}"
    passed = false
  end

  inflections.each do |inflection|
    count = word.inflections.count(:all, :conditions => [ "name = ?", inflection ])
    if count <= 0
      puts "*** could not find inflection #{inflection} for #{head} (#{part_of_speech})"
      passed = false
    end

    if count > 1
      puts "*** multiple instances of inflection #{inflection} for #{head} (#{part_of_speech})"
      passed = false
    end
  end

  unless passed
    @fail_count += 1
    print "*** "
  end
  puts "#{head} (#{part_of_speech}) #{passed ? 'passed' : 'failed'}"
end

@test_cases = [
  [ 'dog', 'noun', %w{dogs} ],
  [ 'hero', 'noun', %w{heroes} ],
  [ 'cage', 'noun', %w{cages} ],
  [ 'man', 'noun', %w{men} ],
  [ 'Man', 'noun', [] ],
  [ 'shaman', 'noun', %w{shamans} ],
  [ 'be', 'verb', %w{am are been being is was were} ],
  [ 'look', 'verb', %w{looked looking looks} ],
  [ 'take', 'verb', %w{taking takes took taken} ],
  [ 'bake', 'verb', %w{bakes baking baked} ],
  [ 'flow', 'verb', %w{flowed flowing flows} ],
  [ 'chip', 'verb', %w{chips chipping chipped} ],
  [ 'search', 'verb', %w{searches searching searched} ],
  [ 'die', 'verb', %w{dies dying} ],
  [ 'picnic', 'verb', %w{picnics picnicking picnicked} ],
  [ 'occur', 'verb', %w{occurs occurring occurred} ],
  [ 'diet', 'verb', %w{diets dieting dieted} ],
  [ 'span', 'verb', %w{spans spanning spanned} ],
  [ 'happen', 'verb', %w{happens happening happened} ],
  [ 'log-in', 'verb', [] ],
  [ 'crochet', 'verb', %w{crochets crocheted crocheting} ],
  [ 'shoot the breeze', 'verb', [] ],
  [ 'visit', 'verb', %w{visits visited visiting} ],
  [ 'quit', 'verb', %w{quits quitted quitting} ],
  [ 'hit', 'verb', %w{hits hitting} ],
  [ 'splat', 'verb', %w{splats splatted splatting} ],
  [ '4', 'noun', [] ],
  [ 'sabbatical', 'adjective', [] ],
  [ 'good', 'adjective', %w{best better} ],
  [ 'plainly', 'adverb', [] ],
  [ 'well', 'adverb', %w{best better} ]
]

@test_cases.each do |test_case|
  begin
    check_inflections test_case
  rescue => errmsg
    @fail_count += 1
    puts "*** #{errmsg}"
  end
end

puts "finished testing #{@test_cases.length} test cases"
puts "### #{@test_cases.length-@fail_count} passed, #{@fail_count} failed ###"
