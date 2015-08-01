class AddTemporaryDownloadLinkToGifs < ActiveRecord::Migration
  def change
    add_column :gifs, :temporary_download_link, :string
  end
end
