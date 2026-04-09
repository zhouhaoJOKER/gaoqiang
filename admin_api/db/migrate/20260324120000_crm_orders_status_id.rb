# frozen_string_literal: true

class CrmOrdersStatusId < ActiveRecord::Migration[8.0]
  def change
    add_reference :crm_orders, :status, foreign_key: { to_table: :properties }, null: true
    remove_column :crm_orders, :order_status, :string
  end
end
