# frozen_string_literal: true

class CreateCrmOrderLines < ActiveRecord::Migration[8.0]
  def change
    create_table :crm_order_lines do |t|
      t.references :order, foreign_key: { to_table: :crm_orders }
      t.references :product, foreign_key: { to_table: :mat_products }

      t.string :product_name
      t.string :model
      t.string :color
      t.string :weight
      t.decimal :qty, precision: 14, scale: 3
      t.string :unit

      t.string :stock_status
      t.string :color_master_status
      t.text :remark

      t.integer :sort
      t.integer :user_id

      t.timestamps
    end
  end
end
