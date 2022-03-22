class CreateTracks < ActiveRecord::Migration
  def change
    create_table :tracks do |t|
      t.integer :user_id
      t.integer :trackable_id
      t.string :trackable_type

      t.timestamps
    end
    add_index :tracks, [:trackable_id], :name => "index_tracks_on_trackable_id"
    add_index :tracks, [:user_id], :name => "index_tracks_on_user_id"
    add_index :tracks, [:trackable_type], :name => "index_tracks_on_trackable_type"
  end
end


