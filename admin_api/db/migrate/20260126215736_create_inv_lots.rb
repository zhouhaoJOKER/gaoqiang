class CreateInvLots < ActiveRecord::Migration[8.0]
  def change
    create_table :inv_lots do |t|
      t.string :code
      t.integer :item_id
      t.integer :product_id
      t.integer :company_id
      t.string :ref
      t.decimal :qty, precision: 10, scale: 2
      t.decimal :unit_cost, precision: 10, scale: 2
      t.datetime :expiration_date
      t.datetime :alert_date
      t.datetime :removal_date
      t.string :order_type
      t.integer :order_id
      t.integer :order_line_id
      t.integer :user_id
      t.text :description

      t.timestamps
    end
    add_index :inv_lots, :item_id
    add_index :inv_lots, :product_id
    add_index :inv_lots, :company_id
    add_index :inv_lots, :order_id
    add_index :inv_lots, :order_line_id
  end
end
