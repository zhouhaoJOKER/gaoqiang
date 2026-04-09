# frozen_string_literal: true

class CreateCrmOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :crm_orders do |t|
      t.string :code
      t.references :pre_order, foreign_key: { to_table: :mat_pre_orders }
      t.references :client, foreign_key: { to_table: :crm_clients }

      t.date :receive_date
      t.string :contract_code
      t.date :customer_delivery_date

      t.integer :follower_id
      t.datetime :follow_at
      t.text :follow_progress

      t.decimal :amount, precision: 14, scale: 2
      t.string :order_status
      t.decimal :delivered_qty, precision: 14, scale: 3

      t.decimal :invoice_amount, precision: 14, scale: 2
      t.datetime :invoice_at
      t.decimal :payment_amount, precision: 14, scale: 2
      t.datetime :payment_at

      t.integer :user_id
      t.integer :updater_id
      t.string :py

      t.timestamps
    end

    add_index :crm_orders, :code, unique: true
  end
end
