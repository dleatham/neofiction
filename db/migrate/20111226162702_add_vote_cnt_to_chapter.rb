class AddVoteCntToChapter < ActiveRecord::Migration
  def change
    add_column :chapters, :vote_cnt, :integer
    add_index :chapters, :vote_cnt
  end
end
