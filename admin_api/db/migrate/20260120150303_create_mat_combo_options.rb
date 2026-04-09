class CreateMatComboOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :mat_combo_options do |t|
      t.integer :combo_id
      t.integer :product_id
      t.string :name
      t.decimal :price, precision: 10, scale: 2
      t.decimal :extra_price, precision: 10, scale: 2

      t.timestamps
    end
  end
end
