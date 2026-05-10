# frozen_string_literal: true

class CreateWgdOrderLines < ActiveRecord::Migration[8.0]
  def change
    create_table :wgd_order_lines do |t|
      t.references :order, foreign_key: { to_table: :wgd_orders }, null: false
      t.string :product_name
      t.string :model
      t.string :foil_pad_status
      t.string :color
      t.text :requirements
      t.string :weight, limit: 100
      t.string :color_master_status
      t.string :product_image_text
      t.decimal :qty, precision: 14, scale: 3
      t.string :unit, limit: 50
      t.decimal :unit_price, precision: 12, scale: 2
      t.decimal :line_amount, precision: 14, scale: 2
      t.decimal :delivered_qty, precision: 14, scale: 3
      t.decimal :undelivered_qty, precision: 14, scale: 3
      t.integer :sort
      t.text :remark

      t.timestamps
    end

    add_index :wgd_order_lines, :product_name
    add_index :wgd_order_lines, :model
    add_index :wgd_order_lines, :sort
  end
end
