class AddGroupIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :group_id, :integer
    add_index :comments, :group_id
  end
end
