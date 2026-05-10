# frozen_string_literal: true

class CreateWgdOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :wgd_orders do |t|
      t.string :code, limit: 40
      t.date :receive_date
      t.references :client, foreign_key: { to_table: :crm_clients }, null: true
      t.string :client_name
      t.string :contract_code
      t.string :hazard_pack_month, limit: 100
      t.string :customer_delivery_date_text
      t.datetime :follow_at
      t.text :follow_progress
      t.integer :follower_id
      t.string :follower_name, limit: 100
      t.string :invoice_status, limit: 100
      t.datetime :invoice_at
      t.decimal :amount, precision: 14, scale: 2
      t.integer :status_id
      t.text :remark
      t.integer :user_id
      t.integer :updater_id

      t.timestamps
    end

    add_index :wgd_orders, :code, unique: true
    add_index :wgd_orders, :follower_id
    add_index :wgd_orders, :status_id
    add_index :wgd_orders, :receive_date
    add_index :wgd_orders, :contract_code
  end
end
