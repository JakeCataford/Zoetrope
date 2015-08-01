class AddExternalValidationStatusToGifs < ActiveRecord::Migration
  def change
    add_column :gifs, :external_validation_status, :integer, default: 0
  end
end
