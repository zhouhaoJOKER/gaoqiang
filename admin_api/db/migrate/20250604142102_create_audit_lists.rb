class CreateAuditLists < ActiveRecord::Migration[8.0]
  def change
    create_table :audit_lists do |t|
      t.integer :audit_contract_id
      t.integer :sn
      t.string :serial_number
      t.string :risk_clause
      t.string :risk_level
      t.string :legal_advice
      t.string :reply
      t.integer :user_id

      t.timestamps
      t.index :audit_contract_id

    end
  end
end
