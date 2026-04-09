class CreateMfgWorkOrders < ActiveRecord::Migration[8.0]
  def change
    create_table :mfg_work_orders do |t|
      t.string :code
      t.integer :bom_id
      t.integer :product_id
      t.decimal :plan_qty, precision: 10, scale: 2
      t.decimal :actual_qty, precision: 10, scale: 2
      t.string :status
      t.datetime :plan_start
      t.datetime :plan_finish
      t.datetime :actual_start
      t.datetime :actual_finish
      t.integer :warehouse_id
      t.integer :company_id
      t.integer :user_id
      t.integer :updater_id

      t.timestamps
    end
    add_index :mfg_work_orders, :bom_id
    add_index :mfg_work_orders, :product_id
    add_index :mfg_work_orders, :warehouse_id
    add_index :mfg_work_orders, :company_id
  end
end
