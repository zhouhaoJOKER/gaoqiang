class AddCodeToPurContracts < ActiveRecord::Migration[8.0]
  def change
    add_column :pur_contracts, :code, :string, comment: "合同编号"
  end
end
