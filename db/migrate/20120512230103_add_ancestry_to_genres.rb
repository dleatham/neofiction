class AddAncestryToGenres < ActiveRecord::Migration
  def change
    add_column :genres, :ancestry, :string
    add_index :genres, :ancestry
  end
end
