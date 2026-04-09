class AddComboIdToMatProduct < ActiveRecord::Migration[8.0]
  def change
    add_column :mat_products, :combo_id, :integer
  end
end
