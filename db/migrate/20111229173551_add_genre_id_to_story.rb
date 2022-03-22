class AddGenreIdToStory < ActiveRecord::Migration
  def change
    add_column :stories, :genre_id, :integer
  end
end
