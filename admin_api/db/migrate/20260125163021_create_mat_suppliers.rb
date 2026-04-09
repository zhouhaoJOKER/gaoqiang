class CreateMatSuppliers < ActiveRecord::Migration[8.0]
  def change
    create_table :mat_suppliers do |t|
      t.json :labels
      t.json :custom_fields
      t.integer :user_id
      t.integer :updater_id
      t.integer :company_id
      t.integer :product_id
      t.string :name
      t.string :code
      t.string :py
      t.string :pinyin
      t.decimal :min_qty, precision: 10, scale: 2
      t.decimal :price, precision: 10, scale: 2
      t.integer :currency_id
      t.string :c
      t.integer :delay
      t.boolean :is_main
      t.float :sort

      t.timestamps
    end
    add_index :mat_suppliers, :company_id
    add_index :mat_suppliers, :product_id
    add_index :mat_suppliers, :currency_id
  end
end
