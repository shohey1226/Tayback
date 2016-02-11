class CreateBlockers < ActiveRecord::Migration
  def change
    create_table :blockers do |t|
      t.string :title
      t.text :rule
      t.integer :count, default: 0
      t.integer :created_by

      t.timestamps null: false
    end
  end
end
