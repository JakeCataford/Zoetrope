class AddStatusToGif < ActiveRecord::Migration
  def change
    add_column :gifs, :status, :string
    add_column :gifs, :progress, :string
  end
end
