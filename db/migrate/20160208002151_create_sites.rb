class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :url
      t.string :title
      t.string :locale
      t.integer :count

      t.timestamps null: false
    end
  end
end
