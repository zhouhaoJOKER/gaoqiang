class AddPyToMatCombos < ActiveRecord::Migration[8.0]
  def change
    add_column :mat_combos, :py, :string
  end
end
