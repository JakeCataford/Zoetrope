class AddAbortReasonToGifs < ActiveRecord::Migration
  def change
    add_column :gifs, :abort_reason, :string
  end
end
