# frozen_string_literal: true

class AddStatusFieldsToMatPreOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :mat_pre_orders, :status, :string, default: "pending", null: false
    add_column :mat_pre_orders, :processed_at, :datetime
    add_column :mat_pre_orders, :crm_order_id, :integer
    add_column :mat_pre_orders, :processor_id, :integer
  end
end
