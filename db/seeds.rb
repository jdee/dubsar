# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

%w{adj adv noun verb}.each do |part|
  part_of_speech = case part
  when 'adj'
    'adjective'
  when 'adv'
    'adverb'
  else
    part
  end

  File.open(File.join(File.dirname(__FILE__), 'defaults', "data.#{part}")).each do |line|
    name = line.split(' ').fifth
    defn = line.split('| ').second

    w = Word.find_by_name_and_part_of_speech(name, part_of_speech) ||
      Word.new(:name => name, :part_of_speech => part_of_speech)
    w.definitions.build :body => defn

    w.save
  end
end
