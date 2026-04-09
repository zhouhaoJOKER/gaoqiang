class CreateWmsWarehouses < ActiveRecord::Migration[8.0]
  def change
    create_table :wms_warehouses do |t|
      t.string :name
      t.string :abbr
      t.string :code
      t.integer :type_id
      t.boolean :is_active
      t.integer :sort
      t.integer :company_id
      t.text :description
      t.integer :user_id
      t.integer :updater_id
      t.string :py
      t.string :pinyin

      t.timestamps
    end
    add_index :wms_warehouses, :company_id
  end
end
