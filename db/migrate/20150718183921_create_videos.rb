class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.string :title
      t.string :description
      t.attachment :video

      t.timestamps null: false
    end
  end
end
