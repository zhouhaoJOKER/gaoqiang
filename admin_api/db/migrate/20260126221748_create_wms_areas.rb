class CreateWmsAreas < ActiveRecord::Migration[8.0]
  def change
    create_table :wms_areas do |t|
      t.integer :warehouse_id
      t.string :name
      t.string :abbr
      t.string :code
      t.integer :type_id
      t.boolean :is_active
      t.integer :sort
      t.text :description
      t.integer :user_id
      t.integer :updater_id
      t.string :py
      t.string :pinyin

      t.timestamps
    end
    add_index :wms_areas, :warehouse_id
  end
end
