# frozen_string_literal: true

class AddMoreFieldsForCrmOrdersAndLines < ActiveRecord::Migration[8.0]
  def change
    change_table :crm_orders, bulk: true do |t|
      t.string :hazard_pack_month
    end

    change_table :crm_order_lines, bulk: true do |t|
      t.decimal :unit_price, precision: 12, scale: 2
      t.decimal :line_amount, precision: 14, scale: 2
      t.string :ship_doc_unreturned
      t.string :ship_doc_returned
    end
  end
end

