class CreateWmsPickOrderLines < ActiveRecord::Migration[8.0]
  def change
    create_table :wms_pick_order_lines do |t|
      t.integer :pick_order_id
      t.integer :item_id
      t.integer :location_id
      t.decimal :plan_qty, precision: 10, scale: 2
      t.decimal :picked_qty, precision: 10, scale: 2
      t.string :status
      t.integer :user_id
      t.integer :updater_id

      t.timestamps
    end
    add_index :wms_pick_order_lines, :pick_order_id
    add_index :wms_pick_order_lines, :item_id
    add_index :wms_pick_order_lines, :location_id
  end
end
