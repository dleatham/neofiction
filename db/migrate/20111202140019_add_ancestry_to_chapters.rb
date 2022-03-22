class AddAncestryToChapters < ActiveRecord::Migration
  def change
    add_column :chapters, :ancestry, :string
    add_index :chapters, :ancestry
  end
end
