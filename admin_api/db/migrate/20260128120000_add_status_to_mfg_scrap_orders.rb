class AddStatusToMfgScrapOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :mfg_scrap_orders, :status, :string, default: "draft"
    add_column :mfg_scrap_orders, :inventory_synced, :boolean, default: false
    add_index :mfg_scrap_orders, :status
  end
end
