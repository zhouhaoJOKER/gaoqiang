class CreateInvInventoryLocks < ActiveRecord::Migration[8.0]
  def change
    create_table :inv_inventory_locks do |t|
      t.integer :item_id
      t.integer :location_id
      t.integer :inventory_id
      t.decimal :locked_qty, precision: 10, scale: 2
      t.string :order_type
      t.integer :order_id
      t.string :lock_type
      t.string :status
      t.datetime :expires_at
      t.integer :user_id
      t.integer :updater_id

      t.timestamps
    end
    add_index :inv_inventory_locks, :item_id
    add_index :inv_inventory_locks, :location_id
    add_index :inv_inventory_locks, :inventory_id
    add_index :inv_inventory_locks, :order_id
  end
end
