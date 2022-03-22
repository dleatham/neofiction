class AddBlogUrlToUser < ActiveRecord::Migration
  def change
    add_column :users, :blog_url, :string
    add_column :users, :bio, :text
  end
end
