class CreateTmsOrderLines < ActiveRecord::Migration[8.0]
  def change
    create_table :tms_order_lines do |t|
      t.references :shipping_order, foreign_key: { to_table: :tms_orders }
      t.integer :product_id
      t.string :product_name
      t.string :packaging_spec
      t.string :pieces_capitalized
      t.integer :pieces
      t.string :net_weight_display
      t.decimal :net_weight_ton
      t.decimal :unit_price
      t.decimal :amount
      t.integer :sort
      t.integer :user_id

      t.timestamps
    end
  end
end
