class CreateAuditContracts < ActiveRecord::Migration[8.0]
  def change
    create_table :audit_contracts do |t|
      t.integer :parent_id
      t.string :version
      t.string :uuid
      t.string :part_a
      t.string :part_b
      t.string :contract_number
      t.string :project_name
      t.integer :department_id
      t.integer :user_id
      t.boolean :is_realtime
      t.string :status
      t.string :file
      t.json :result
      t.string :result_at
      t.string :result_file
      t.text :remark

      t.timestamps
    end
    add_index :audit_contracts, :parent_id
    add_index :audit_contracts, :uuid
  end
end
