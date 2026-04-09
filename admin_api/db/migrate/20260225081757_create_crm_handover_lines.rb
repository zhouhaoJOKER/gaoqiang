class CreateCrmHandoverLines < ActiveRecord::Migration[8.0]
  def change
    create_table :crm_handover_lines do |t|
      t.references :handover, foreign_key: { to_table: :crm_handovers }
      t.references :spec_item, foreign_key: { to_table: :crm_spec_items }
      t.string :contract_req
      t.string :internal_req
      t.integer :sort
      t.integer :user_id

      t.timestamps
    end
  end
end
