class CreateMfgWorkOrderByproducts < ActiveRecord::Migration[8.0]
  def change
    create_table :mfg_work_order_byproducts do |t|
      t.integer :work_order_id
      t.integer :bom_byproduct_id
      t.integer :product_id
      t.decimal :plan_qty, precision: 10, scale: 2
      t.decimal :actual_qty, precision: 10, scale: 2
      t.integer :user_id
      t.integer :updater_id

      t.timestamps
    end
    add_index :mfg_work_order_byproducts, :work_order_id
    add_index :mfg_work_order_byproducts, :bom_byproduct_id
    add_index :mfg_work_order_byproducts, :product_id
  end
end
