class CreateTmsPlans < ActiveRecord::Migration[8.0]
  def change
    create_table :tms_plans do |t|
      t.integer :contract_id
      t.string :code
      t.string :name
      t.date :date
      t.string :required_warehouse_entry_date
      t.integer :client_id
      t.string :client_name
      t.string :contract_code
      t.integer :product_id
      t.string :product_name
      t.decimal :qty
      t.string :specification
      t.string :outer_box_dimensions
      t.string :merchandiser_id
      t.string :pieces
      t.text :warehouse_address
      t.string :is_ready
      t.integer :kind_id
      t.text :remark
      t.string :warehouse_entry_note
      t.decimal :volume_inspection
      t.decimal :gross_weight_inspection
      t.integer :sort
      t.integer :user_id
      t.integer :updater_id
      t.string :py
      t.integer :status
      t.date :ship_date
      t.integer :shiper_id
      t.string :vehicle_usage
      t.string :direct_info

      t.timestamps
    end
  end
end
