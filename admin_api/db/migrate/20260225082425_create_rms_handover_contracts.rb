class CreateRmsHandoverContracts < ActiveRecord::Migration[8.0]
  def change
    create_table :rms_handover_contracts do |t|
      t.references :recipe_handover, foreign_key: { to_table: :rms_handovers }
      t.references :contract, foreign_key: { to_table: :crm_contracts }
      t.decimal :qty

      t.timestamps
    end
  end
end
