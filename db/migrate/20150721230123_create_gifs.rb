class CreateGifs < ActiveRecord::Migration
  def change
    create_table :gifs do |t|
      t.string :title
      t.string :source_url
      t.references :session

      t.timestamps null: false
    end
  end
end
