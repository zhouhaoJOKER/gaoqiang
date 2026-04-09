class AddTaxIdToFmContracts < ActiveRecord::Migration[8.0]
  def change
    add_column :fm_contracts, :tax_id, :integer, comment: "税率（关联 properties）"
  end
end
