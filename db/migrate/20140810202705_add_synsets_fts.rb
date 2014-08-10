class AddSynsetsFts < ActiveRecord::Migration
  def up
    Rake::Task["fts:build"].invoke
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
