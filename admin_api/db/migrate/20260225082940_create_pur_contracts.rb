class CreatePurContracts < ActiveRecord::Migration[8.0]
  def change
    create_table :pur_contracts do |t|
      t.integer :contract_id
      t.string :contract_title
      t.integer :supplier_id
      t.string :supplier_name
      t.integer :client_id
      t.string :sign
      t.string :client_name
      t.integer :kind_id
      t.integer :status_id
      t.string :contract_number
      t.string :signing_location
      t.date :signing_date
      t.date :receive_date
      t.decimal :total_amount
      t.string :total_amount_chinese
      t.string :related_item
      t.text :quality_standard
      t.text :delivery_location_method
      t.string :transportation_cost_bearer
      t.string :loss_calculation_method
      t.text :packaging_standard
      t.string :packaging_loss_responsibility
      t.text :inspection_method
      t.string :reinspection_period
      t.string :objection_period
      t.string :quality_issue_responsibility
      t.string :spare_parts_supply
      t.text :settlement_method_term
      t.string :breach_of_contract_liability
      t.string :dispute_resolution_method
      t.text :other_agreements
      t.text :remark
      t.text :other
      t.integer :user_id
      t.integer :updater_id
      t.string :py
      t.date :validity_start_date
      t.date :validity_end_date

      t.timestamps
    end
  end
end
