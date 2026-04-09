class CreateWmsTransferOrderLines < ActiveRecord::Migration[8.0]
  def change
    create_table :wms_transfer_order_lines do |t|
      t.integer :transfer_order_id
      t.integer :item_id
      t.integer :from_location_id
      t.integer :to_location_id
      t.decimal :plan_qty, precision: 10, scale: 2
      t.decimal :moved_qty, precision: 10, scale: 2
      t.decimal :received_qty, precision: 10, scale: 2

      t.timestamps
    end
    add_index :wms_transfer_order_lines, :transfer_order_id
    add_index :wms_transfer_order_lines, :item_id
    add_index :wms_transfer_order_lines, :from_location_id
    add_index :wms_transfer_order_lines, :to_location_id
  end
end
