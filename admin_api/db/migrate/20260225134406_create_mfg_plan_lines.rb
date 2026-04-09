class CreateMfgPlanLines < ActiveRecord::Migration[8.0]
  def change
    create_table :mfg_plan_lines do |t|
      t.integer :contract_id
      t.references :plan, foreign_key: { to_table: :mfg_plans }
      t.date :date
      t.string :line_id
      t.string :line_name
      t.integer :product_id
      t.string :product_name
      t.string :name
      t.string :product_kind
      t.string :qty_unit
      t.string :remark
      t.integer :sort
      t.integer :user_id

      t.timestamps
    end
  end
end
