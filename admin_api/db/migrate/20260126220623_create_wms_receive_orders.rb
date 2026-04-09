class CreateWmsReceiveOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :wms_receive_orders do |t|
      t.string :code
      t.integer :work_order_id
      t.string :order_category
      t.string :status
      t.integer :warehouse_id
      t.datetime :plan_date
      t.integer :company_id
      t.text :description
      t.integer :user_id
      t.integer :updater_id

      t.timestamps
    end
    add_index :wms_receive_orders, :work_order_id
    add_index :wms_receive_orders, :warehouse_id
    add_index :wms_receive_orders, :company_id
  end
end
