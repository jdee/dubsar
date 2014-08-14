class RemoveCasted < ActiveRecord::Migration
  def up
    %w{podcast overcast miscast}.each do |has_ed|
      word = Word.find_by_name_and_part_of_speech has_ed, 'verb'
      word.inflections.where(name: "#{has_ed}ed").destroy_all
    end

    word = Word.find_by_name_and_part_of_speech 'telecast', 'verb'
    word.inflections.create! name: 'telecasted'

    Rake::Task['fts:optimize'].invoke
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
