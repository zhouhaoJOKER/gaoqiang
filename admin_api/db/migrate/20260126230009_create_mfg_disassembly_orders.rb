class CreateMfgDisassemblyOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :mfg_disassembly_orders do |t|
      t.string :code
      t.integer :product_id
      t.integer :item_id
      t.integer :lot_id
      t.decimal :planned_qty, precision: 10, scale: 2
      t.integer :user_id
      t.integer :updater_id

      t.timestamps
    end
    add_index :mfg_disassembly_orders, :product_id
    add_index :mfg_disassembly_orders, :item_id
    add_index :mfg_disassembly_orders, :lot_id
  end
end
