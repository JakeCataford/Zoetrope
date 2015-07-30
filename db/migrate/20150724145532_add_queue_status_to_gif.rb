class AddQueueStatusToGif < ActiveRecord::Migration
  def change
    add_column :gifs, :queue_status, :integer, default: 0
  end
end
