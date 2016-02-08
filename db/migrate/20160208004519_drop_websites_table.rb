class DropWebsitesTable < ActiveRecord::Migration
  def up
    drop_table :websites
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
