class CreateInvInventories < ActiveRecord::Migration[8.0]
  def change
    create_table :inv_inventories do |t|
      t.integer :item_id
      t.integer :location_id
      t.integer :company_id
      t.integer :warehouse_id
      t.decimal :on_hand_qty, precision: 10, scale: 2, default: 0
      t.decimal :available_qty, precision: 10, scale: 2, default: 0
      t.decimal :allocated_qty, precision: 10, scale: 2, default: 0
      t.decimal :in_transit_qty, precision: 10, scale: 2, default: 0
      t.integer :status_id
      t.datetime :last_count_date
      t.integer :user_id
      t.integer :updater_id
      t.json :labels
      t.json :custom_fields

      t.timestamps
    end
    add_index :inv_inventories, :item_id
    add_index :inv_inventories, :location_id
    add_index :inv_inventories, :company_id
    add_index :inv_inventories, :warehouse_id
    add_index :inv_inventories, :status_id
  end
end
