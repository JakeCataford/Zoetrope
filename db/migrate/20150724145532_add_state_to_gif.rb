class AddStateToGif < ActiveRecord::Migration
  def change
    add_column :gifs, :state, :string
  end
end
