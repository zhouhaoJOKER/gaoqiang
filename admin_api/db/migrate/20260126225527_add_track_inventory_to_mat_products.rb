class AddTrackInventoryToMatProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :mat_products, :track_inventory, :boolean, default: false
  end
end
