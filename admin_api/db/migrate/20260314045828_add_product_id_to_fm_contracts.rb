class AddProductIdToFmContracts < ActiveRecord::Migration[8.0]
  def change
    add_column :fm_contracts, :product_id, :integer, comment: "关联产品（mat_products）"
    add_index :fm_contracts, :product_id
  end
end
