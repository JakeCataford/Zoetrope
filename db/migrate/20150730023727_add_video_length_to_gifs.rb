class AddVideoLengthToGifs < ActiveRecord::Migration
  def change
    add_column :gifs, :video_length, :integer
  end
end
