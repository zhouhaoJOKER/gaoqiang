class AddPurContractIdToCrmHandovers < ActiveRecord::Migration[8.0]
  def change
    add_column :crm_handovers, :pur_contract_id, :bigint
  end
end
