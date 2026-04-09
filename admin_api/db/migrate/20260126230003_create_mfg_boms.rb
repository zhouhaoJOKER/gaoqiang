class CreateMfgBoms < ActiveRecord::Migration[8.0]
  def change
    create_table :mfg_boms do |t|
      t.string :code
      t.integer :product_id
      t.string :type
      t.decimal :product_qty, precision: 10, scale: 2
      t.integer :uom_id
      t.boolean :is_active
      t.boolean :is_default
      t.decimal :ready_to_produce, precision: 10, scale: 2
      t.integer :picking_type_id
      t.integer :company_id
      t.integer :user_id
      t.integer :updater_id

      t.timestamps
    end
    add_index :mfg_boms, :product_id
    add_index :mfg_boms, :uom_id
    add_index :mfg_boms, :picking_type_id
    add_index :mfg_boms, :company_id
  end
end
