class CreateMfgOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :mfg_orders do |t|
      t.string :code
      t.integer :product_id
      t.integer :item_id
      t.integer :bom_id
      t.decimal :plan_qty, precision: 10, scale: 2
      t.decimal :finish_qty, precision: 10, scale: 2
      t.decimal :scrap_qty, precision: 10, scale: 2
      t.string :status
      t.datetime :demand_date
      t.string :source_order_type
      t.integer :source_order_id
      t.integer :company_id
      t.integer :warehouse_id
      t.integer :user_id
      t.integer :updater_id

      t.timestamps
    end
    add_index :mfg_orders, :product_id
    add_index :mfg_orders, :item_id
    add_index :mfg_orders, :bom_id
    add_index :mfg_orders, :source_order_id
    add_index :mfg_orders, :company_id
    add_index :mfg_orders, :warehouse_id
  end
end
