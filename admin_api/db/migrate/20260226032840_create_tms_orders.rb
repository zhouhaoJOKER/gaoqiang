class CreateTmsOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :tms_orders do |t|
      t.integer :contract_id
      t.string :document_number
      t.date :document_date
      t.string :company_name
      t.string :reference_code
      t.string :consignee_name
      t.string :consignee_contact
      t.string :consignee_phone
      t.text :delivery_address
      t.string :carrier_id_no
      t.string :vehicle_no
      t.string :carrier_name
      t.string :consignee_stamp_note
      t.string :consignee_signature_note
      t.integer :approved_id
      t.integer :prepared_id
      t.string :contract_note
      t.integer :user_id
      t.integer :updater_id
      t.string :py

      t.timestamps
    end
  end
end
