class CreateMfgWorkOrderLosses < ActiveRecord::Migration[8.0]
  def change
    create_table :mfg_work_order_losses do |t|
      t.integer :work_order_id
      t.integer :bom_loss_id
      t.integer :product_id
      t.decimal :plan_loss_qty, precision: 10, scale: 2
      t.decimal :actual_loss_qty, precision: 10, scale: 2
      t.integer :user_id
      t.integer :updater_id

      t.timestamps
    end
    add_index :mfg_work_order_losses, :work_order_id
    add_index :mfg_work_order_losses, :bom_loss_id
    add_index :mfg_work_order_losses, :product_id
  end
end
