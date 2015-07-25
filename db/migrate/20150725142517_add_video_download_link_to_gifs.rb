class AddVideoDownloadLinkToGifs < ActiveRecord::Migration
  def change
    add_column :gifs, :video_download_link, :string
  end
end
