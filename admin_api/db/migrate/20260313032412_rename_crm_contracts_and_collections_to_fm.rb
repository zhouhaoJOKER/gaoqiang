# 将 Crm::Contract / Crm::Collection 迁移到 Fm 模块后，表重命名为 fm_contracts / fm_collections
class RenameCrmContractsAndCollectionsToFm < ActiveRecord::Migration[8.0]
  def change
    rename_table :crm_contracts, :fm_contracts
    rename_table :crm_collections, :fm_collections
  end
end
