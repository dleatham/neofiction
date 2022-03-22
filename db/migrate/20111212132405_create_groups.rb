class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :title
      t.text :desc
      
      t.timestamps
    end
  end
end
