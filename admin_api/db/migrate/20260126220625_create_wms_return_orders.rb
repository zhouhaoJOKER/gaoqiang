class CreateWmsReturnOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :wms_return_orders do |t|
      t.string :code
      t.string :return_category
      t.string :status
      t.integer :original_order_id
      t.integer :warehouse_id
      t.integer :user_id
      t.integer :updater_id

      t.timestamps
    end
    add_index :wms_return_orders, :original_order_id
    add_index :wms_return_orders, :warehouse_id
  end
end
