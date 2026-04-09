class CreateMfgOprates < ActiveRecord::Migration[8.0]
  def change
    create_table :mfg_oprates do |t|
      t.integer :contract_id
      t.integer :product_id
      t.string :product_name
      t.string :batch_number
      t.decimal :qty_kl
      t.date :record_date
      t.decimal :discharge_qty
      t.string :inspection_result
      t.string :rework_inspection_result
      t.string :second_rework_inspection_result
      t.boolean :safety_env_result
      t.boolean :shear_kettle_result
      t.boolean :filter_result
      t.boolean :pump_result
      t.boolean :special_equipment_result
      t.text :equipment_status_notes
      t.text :remark
      t.integer :batching_operator_id
      t.integer :operator_id
      t.integer :user_id
      t.integer :updater_id
      t.string :py

      t.timestamps
    end
  end
end
