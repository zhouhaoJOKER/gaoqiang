class CreateMatItems < ActiveRecord::Migration[8.0]
  def change
    create_table :mat_items do |t|
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
      t.string :barcode
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
      t.integer :product_id
      t.integer :value_id
      t.string :sku
      t.decimal :weight, precision: 10, scale: 2
      t.decimal :volume, precision: 10, scale: 2
      t.integer :qty_onhand
      t.integer :qty_available
      t.integer :qty_incoming
      t.integer :qty_outgoing

      t.timestamps
    end
    add_index :mat_items, :company_id
    add_index :mat_items, :type_id
    add_index :mat_items, :category_id
    add_index :mat_items, :product_id
  end
end
