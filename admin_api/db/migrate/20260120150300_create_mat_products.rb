class CreateMatProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :mat_products do |t|
      t.json :labels
      t.json :custom_fields
      t.integer :user_id
      t.integer :updater_id
      t.integer :company_id
      t.string :name
      t.string :logo
      t.string :code
      t.string :py
      t.string :pinyin
      t.integer :type_id
      t.integer :category_id
      t.decimal :price, precision: 10, scale: 2
      t.decimal :cost_price, precision: 10, scale: 2
      t.decimal :market_price, precision: 10, scale: 2
      t.text :description
      t.integer :uom_id
      t.integer :uom_po_id
      t.integer :sale_tax_id
      t.integer :purchase_tax_id
      t.boolean :is_sale
      t.boolean :is_purchase
      t.boolean :is_manufacture
      t.boolean :is_stock
      t.boolean :is_active

      t.timestamps
    end
    add_index :mat_products, :company_id
    add_index :mat_products, :type_id
    add_index :mat_products, :category_id
  end
end
