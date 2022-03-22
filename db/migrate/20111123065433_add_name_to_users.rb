class AddNameToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string
    add_column :users, :roles_mask, :integer
    add_column :users, :activity_score, :integer
  end
end
