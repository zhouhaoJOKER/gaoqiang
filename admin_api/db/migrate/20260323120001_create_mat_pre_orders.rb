# frozen_string_literal: true

class CreateMatPreOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :mat_pre_orders do |t|
      t.string :customer_name
      t.string :customer_code
      t.text :spec_requirements
      t.json :line_items
      t.string :request_ip
      t.timestamps
    end
  end
end
