# frozen_string_literal: true

class AddInternalTrackingToCrmOrderLines < ActiveRecord::Migration[8.0]
  def change
    change_table :crm_order_lines, bulk: true do |t|
      t.decimal :delivery_qty, precision: 14, scale: 3
      t.decimal :loss_qty, precision: 14, scale: 3
      t.date :line_delivery_date
      t.string :production_machine
      t.string :injection_prod_code
      t.date :injection_prod_date
      t.string :gasket_machine
      t.string :gasket_prod_code
      t.date :gasket_prod_date
      t.date :closing_date
      t.decimal :semi_inventory, precision: 14, scale: 3
      t.decimal :semi_completed, precision: 14, scale: 3
      t.decimal :semi_reserve, precision: 14, scale: 3
      t.decimal :original_inventory, precision: 14, scale: 3
      t.decimal :outsourcing_qty, precision: 14, scale: 3
      t.decimal :unfinished_qty, precision: 14, scale: 3
      t.decimal :finished_total, precision: 14, scale: 3
    end
  end
end
