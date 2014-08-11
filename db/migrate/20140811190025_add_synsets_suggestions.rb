class AddSynsetsSuggestions < ActiveRecord::Migration
  def up
    Rake::Task['fts:build'].invoke
  end

  def down
    # raise ActiveRecord::IrrversibleMigration
  end
end
