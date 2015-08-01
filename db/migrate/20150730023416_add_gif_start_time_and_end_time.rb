class AddGifStartTimeAndEndTime < ActiveRecord::Migration
  def change
  	add_column :gifs, :start_time, :integer
  	add_column :gifs, :end_time, :integer
  end
end
