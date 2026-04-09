class CreateMfgScrapOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :mfg_scrap_orders do |t|
      t.string :code
      t.string :scrap_category
      t.integer :product_id
      t.integer :item_id
      t.integer :lot_id
      t.integer :location_id
      t.decimal :planned_qty, precision: 10, scale: 2
      t.integer :user_id
      t.integer :updater_id

      t.timestamps
    end
    add_index :mfg_scrap_orders, :product_id
    add_index :mfg_scrap_orders, :item_id
    add_index :mfg_scrap_orders, :lot_id
    add_index :mfg_scrap_orders, :location_id
  end
end
