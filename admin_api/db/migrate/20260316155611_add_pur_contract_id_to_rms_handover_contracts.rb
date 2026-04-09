class AddPurContractIdToRmsHandoverContracts < ActiveRecord::Migration[8.0]
  def change
    add_column :rms_handover_contracts, :pur_contract_id, :bigint
  end
end
