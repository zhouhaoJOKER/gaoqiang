class CreateRmsHandovers < ActiveRecord::Migration[8.0]
  def change
    create_table :rms_handovers do |t|
      t.integer :product_id
      t.string :name
      t.string :code
      t.date :handover_date
      t.text :ordering_companies_text
      t.decimal :order_qty
      t.string :order_qty_unit
      t.references :handover_order, foreign_key: { to_table: :crm_contracts }
      t.integer :prepared_id
      t.integer :received_id
      t.text :general_notes
      t.integer :user_id
      t.integer :updater_id
      t.string :py

      t.timestamps
    end
  end
end
