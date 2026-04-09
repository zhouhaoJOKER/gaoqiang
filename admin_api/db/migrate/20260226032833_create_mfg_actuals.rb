class CreateMfgActuals < ActiveRecord::Migration[8.0]
  def change
    create_table :mfg_actuals do |t|
      t.string :leader
      t.integer :product_id
      t.date :date
      t.string :name
      t.string :code
      t.string :specification
      t.string :spec
      t.integer :qty
      t.string :unit
      t.datetime :time_start
      t.datetime :time_end
      t.decimal :hour
      t.string :planned_production_qty
      t.decimal :actual_production_qty
      t.string :actual_production_unit
      t.integer :worker_count
      t.string :uncompleted_remark
      t.text :remark
      t.integer :sort
      t.integer :user_id
      t.integer :updater_id
      t.string :py

      t.timestamps
    end
  end
end
