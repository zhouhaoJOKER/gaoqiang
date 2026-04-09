class CreateInvInventoryTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :inv_inventory_transactions do |t|
      t.string :code
      t.integer :item_id
      t.integer :location_id
      t.integer :inventory_id
      t.string :transaction_type
      t.string :related_order_type
      t.integer :related_order_id
      t.decimal :quantity_before, precision: 10, scale: 2
      t.decimal :quantity_change, precision: 10, scale: 2
      t.decimal :quantity_after, precision: 10, scale: 2
      t.integer :operator_id
      t.datetime :transaction_time
      t.text :remark
      t.integer :user_id
      t.integer :updater_id

      t.timestamps
    end
    add_index :inv_inventory_transactions, :item_id
    add_index :inv_inventory_transactions, :location_id
    add_index :inv_inventory_transactions, :inventory_id
    add_index :inv_inventory_transactions, :related_order_id
  end
end
