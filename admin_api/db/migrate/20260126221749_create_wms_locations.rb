class CreateWmsLocations < ActiveRecord::Migration[8.0]
  def change
    create_table :wms_locations do |t|
      t.integer :warehouse_id
      t.integer :area_id
      t.string :name
      t.string :abbr
      t.string :code
      t.integer :type_id
      t.boolean :is_active
      t.boolean :is_adjustment
      t.boolean :is_reservation
      t.integer :sort
      t.text :description
      t.integer :user_id
      t.integer :updater_id
      t.string :py
      t.string :pinyin

      t.timestamps
    end
    add_index :wms_locations, :warehouse_id
    add_index :wms_locations, :area_id
  end
end
