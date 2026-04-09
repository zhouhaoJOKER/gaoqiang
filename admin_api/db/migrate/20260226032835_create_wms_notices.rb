class CreateWmsNotices < ActiveRecord::Migration[8.0]
  def change
    create_table :wms_notices do |t|
      t.integer :contract_id
      t.string :recipient
      t.string :issuing_company
      t.date :issue_date
      t.integer :total_pieces
      t.string :unloading_fee_per_cbm
      t.string :minimum_charge_per_shipment
      t.string :entry_fee_per_vehicle
      t.text :nighttime_surcharge_note
      t.string :dangerous_goods_vehicle_fee
      t.string :box_truck_surcharge_note
      t.text :important_notes
      t.string :warehousing_number
      t.datetime :delivery_deadline
      t.string :warehouse_name
      t.text :warehouse_address
      t.string :contact_person
      t.string :contact_phone
      t.string :contact_hours
      t.string :dangerous_goods_receiving_note
      t.string :remarks_contact
      t.integer :user_id
      t.integer :updater_id
      t.string :py

      t.timestamps
    end
  end
end
