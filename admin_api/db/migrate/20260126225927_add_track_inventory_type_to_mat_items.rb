class AddTrackInventoryTypeToMatItems < ActiveRecord::Migration[8.0]
  def change
    add_column :mat_items, :track_inventory_type, :string
  end
end
