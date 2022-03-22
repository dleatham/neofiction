class CreateChapters < ActiveRecord::Migration
  def self.up
    create_table :chapters do |t|
      t.string :heading
      t.text :body
      t.text :notes
      t.integer :vote_count
      t.boolean :published
      t.integer :user_id
      t.timestamps
    end
  end

  def self.down
    drop_table :chapters
  end
end
