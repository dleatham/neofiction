class CreateFirstChapters < ActiveRecord::Migration
  def change
    create_table :first_chapters do |t|
      t.integer :story_id
      t.integer :chapter_id

      t.timestamps
    end
  end
end
