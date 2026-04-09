class AddUnitIdToFmContracts < ActiveRecord::Migration[8.0]
  def change
    add_column :fm_contracts, :unit_id, :integer
  end
end
