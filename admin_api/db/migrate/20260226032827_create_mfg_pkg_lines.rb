class CreateMfgPkgLines < ActiveRecord::Migration[8.0]
  def change
    create_table :mfg_pkg_lines do |t|
      t.integer :contract_id
      t.integer :pkg_handover_id
      t.integer :line_id
      t.date :record_date
      t.string :weather
      t.string :temperature
      t.integer :product_id
      t.string :name
      t.string :code
      t.string :customer_trademark_name
      t.string :planned_total_qty_kl
      t.integer :planned_total_pieces
      t.string :packaging_batch_number
      t.string :semi_finished_batch_number
      t.decimal :specific_gravity
      t.string :packaging_spec
      t.string :net_weight_per_bottle
      t.string :empty_bottle_weight
      t.string :filling_range
      t.string :standard_weight_per_bottle
      t.string :standard_weight_per_box
      t.text :packaging_key_points
      t.string :formal_filling_start_time
      t.string :formal_filling_end_time
      t.integer :packages_this_shift
      t.string :filling_debug_air_pressure
      t.string :filling_debug_temperature
      t.string :filling_debug_horizontal_temp
      t.string :filling_debug_vertical_temp
      t.string :filling_debug_notes
      t.boolean :labeling_machine_result
      t.boolean :filling_machine_result
      t.boolean :capping_machine_result
      t.boolean :sealing_machine_result
      t.boolean :coding_machine_result
      t.boolean :shrink_film_machine_result
      t.boolean :packing_machine_result
      t.string :operator_info
      t.integer :line_foreman_id
      t.text :other
      t.text :remark
      t.integer :user_id

      t.timestamps
    end
  end
end
