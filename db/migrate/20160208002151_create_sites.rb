class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :url
      t.string :title
      t.string :locale
      t.integer :count, default: 0

      t.timestamps null: false
    end

    add_index :sites, [:url, :locale], unique: true
  end
end
