class CreateBlockerUsers < ActiveRecord::Migration
  def change
    create_table :blocker_users do |t|
      t.references :user, index: true, foreign_key: true
      t.references :blocker, index: true, foreign_key: true
      t.references :site, index: true, foreign_key: true
      t.datetime :used_at

      t.timestamps null: false
    end
  end
end
