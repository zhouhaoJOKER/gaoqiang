class AddFmContractIdToPurContracts < ActiveRecord::Migration[8.0]
  def change
    add_column :pur_contracts, :fm_contract_id, :integer, comment: "关联订购合同(fm_contracts)"
  end
end
