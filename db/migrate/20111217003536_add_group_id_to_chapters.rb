class AddGroupIdToChapters < ActiveRecord::Migration
  def change
    add_column :chapters, :group_id, :integer
  end
end
