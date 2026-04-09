class AddTrackInventoryTypeAndOnHandQuantityToMatProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :mat_products, :track_inventory_type, :string
    add_column :mat_products, :on_hand_quantity, :decimal, precision: 10, scale: 2, default: 0
  end
end
