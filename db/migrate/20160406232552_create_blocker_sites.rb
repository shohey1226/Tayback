class CreateBlockerSites < ActiveRecord::Migration
  def change
    create_table :blocker_sites do |t|
      t.references :site, index: true, foreign_key: true
      t.references :blocker, index: true, foreign_key: true
      t.integer :count, default: 0

      t.timestamps null: false
    end
  end
end
