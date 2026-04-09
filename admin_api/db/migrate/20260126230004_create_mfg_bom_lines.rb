class CreateMfgBomLines < ActiveRecord::Migration[8.0]
  def change
    create_table :mfg_bom_lines do |t|
      t.integer :bom_id
      t.integer :product_id
      t.decimal :product_qty, precision: 10, scale: 2
      t.integer :product_uom_id
      t.integer :operation_id
      t.boolean :optional
      t.boolean :alternative
      t.integer :sort
      t.integer :user_id
      t.integer :updater_id

      t.timestamps
    end
    add_index :mfg_bom_lines, :bom_id
    add_index :mfg_bom_lines, :product_id
    add_index :mfg_bom_lines, :product_uom_id
    add_index :mfg_bom_lines, :operation_id
  end
end
