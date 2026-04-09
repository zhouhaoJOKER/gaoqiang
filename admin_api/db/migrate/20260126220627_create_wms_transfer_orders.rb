class CreateWmsTransferOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :wms_transfer_orders do |t|
      t.string :code
      t.string :transfer_type
      t.string :status
      t.integer :from_warehouse_id
      t.integer :to_warehouse_id
      t.string :move_category
      t.datetime :plan_date
      t.integer :user_id
      t.integer :updater_id

      t.timestamps
    end
    add_index :wms_transfer_orders, :from_warehouse_id
    add_index :wms_transfer_orders, :to_warehouse_id
  end
end
