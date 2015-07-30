class AddUrlToGifs < ActiveRecord::Migration
  def change
    add_column :gifs, :url, :string
  end
end
