class AddInventorySyncedToMfgWorkOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :mfg_work_orders, :inventory_synced, :boolean, default: false
  end
end
