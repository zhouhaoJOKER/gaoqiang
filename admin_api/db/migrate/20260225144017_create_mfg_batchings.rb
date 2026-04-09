class CreateMfgBatchings < ActiveRecord::Migration[8.0]
  def change
    create_table :mfg_batchings do |t|
      t.integer :contract_id
      t.integer :product_id
      t.string :product_name
      t.string :production_batch_number
      t.string :batching_ratio
      t.decimal :batching_qty
      t.date :production_date
      t.decimal :batching_qty_recheck
      t.text :production_requirements_notes
      t.integer :order_placed_id
      t.integer :weighing_id
      t.integer :weighing_supervised_id
      t.integer :operator_id
      t.integer :user_id
      t.integer :updater_id
      t.string :py

      t.timestamps
    end
  end
end
