class CreateSiteUsers < ActiveRecord::Migration
  def change
    create_table :site_users do |t|
      t.references :site, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.datetime :accessed_at

      t.timestamps null: false
    end
  end
end
