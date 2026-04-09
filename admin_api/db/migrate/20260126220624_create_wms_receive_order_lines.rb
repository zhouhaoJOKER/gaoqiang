class CreateWmsReceiveOrderLines < ActiveRecord::Migration[8.0]
  def change
    create_table :wms_receive_order_lines do |t|
      t.integer :receive_order_id
      t.integer :item_id
      t.integer :location_id
      t.decimal :plan_qty, precision: 10, scale: 2
      t.decimal :received_qty, precision: 10, scale: 2
      t.string :status
      t.integer :work_order_byproduct_id
      t.integer :user_id
      t.integer :updater_id

      t.timestamps
    end
    add_index :wms_receive_order_lines, :receive_order_id
    add_index :wms_receive_order_lines, :item_id
    add_index :wms_receive_order_lines, :location_id
    add_index :wms_receive_order_lines, :work_order_byproduct_id
  end
end
