class CreateMfgOrderLines < ActiveRecord::Migration[8.0]
  def change
    create_table :mfg_order_lines do |t|
      t.integer :order_id
      t.integer :product_id
      t.integer :item_id
      t.integer :bom_line_id
      t.datetime :required_date
      t.decimal :required_qty, precision: 10, scale: 2
      t.decimal :allocated_qty, precision: 10, scale: 2
      t.decimal :available_qty, precision: 10, scale: 2
      t.decimal :shortage_qty, precision: 10, scale: 2
      t.string :status
      t.boolean :is_alternative
      t.integer :alternative_for_id

      t.timestamps
    end
    add_index :mfg_order_lines, :order_id
    add_index :mfg_order_lines, :product_id
    add_index :mfg_order_lines, :item_id
    add_index :mfg_order_lines, :bom_line_id
    add_index :mfg_order_lines, :alternative_for_id
  end
end
