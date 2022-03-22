class CreateStories < ActiveRecord::Migration
  def change
    create_table :stories do |t|
      t.string :title
      t.text :desc
      t.integer :activity

      t.timestamps
    end
  end
end
