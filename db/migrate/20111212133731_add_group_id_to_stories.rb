class AddGroupIdToStories < ActiveRecord::Migration
  def change
    add_column :stories, :group_id, :integer
  end
end
