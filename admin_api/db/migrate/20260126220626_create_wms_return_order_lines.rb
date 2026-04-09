class CreateWmsReturnOrderLines < ActiveRecord::Migration[8.0]
  def change
    create_table :wms_return_order_lines do |t|
      t.integer :return_order_id
      t.integer :item_id
      t.integer :location_id
      t.decimal :returned_qty, precision: 10, scale: 2
      t.string :damage_status
      t.integer :inventory_status_id
      t.integer :user_id
      t.integer :updater_id

      t.timestamps
    end
    add_index :wms_return_order_lines, :return_order_id
    add_index :wms_return_order_lines, :item_id
    add_index :wms_return_order_lines, :location_id
    add_index :wms_return_order_lines, :inventory_status_id
  end
end
