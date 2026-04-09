class AddPurContractAndCollectionToIqcRaws < ActiveRecord::Migration[8.0]
  def change
    add_column :iqc_raws, :pur_contract_id, :integer, comment: "关联采购合同(pur_contracts)"
    add_column :iqc_raws, :pur_collection_id, :integer, comment: "关联采购明细(pur_collections)"
  end
end
