class CreateMfgBomByproducts < ActiveRecord::Migration[8.0]
  def change
    create_table :mfg_bom_byproducts do |t|
      t.integer :bom_id
      t.integer :product_id
      t.decimal :product_qty, precision: 10, scale: 2
      t.integer :product_uom_id
      t.string :output_category
      t.boolean :is_inventory
      t.integer :sort
      t.integer :user_id
      t.integer :updater_id

      t.timestamps
    end
    add_index :mfg_bom_byproducts, :bom_id
    add_index :mfg_bom_byproducts, :product_id
    add_index :mfg_bom_byproducts, :product_uom_id
  end
end
