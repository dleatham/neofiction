class AddPopularityScoreToUser < ActiveRecord::Migration
  def change
    add_column :users, :popularity_score, :integer
    add_index :users, :popularity_score
    add_index :users, :activity_score
  end
end
