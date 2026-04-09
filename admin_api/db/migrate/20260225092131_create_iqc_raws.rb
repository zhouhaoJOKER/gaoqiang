class CreateIqcRaws < ActiveRecord::Migration[8.0]
  def change
    create_table :iqc_raws do |t|
      t.integer :contract_id
      t.integer :product_id
      t.string :name
      t.string :code
      t.string :supplier_id
      t.string :supplier_name
      t.string :batch_number
      t.string :inspection_qty
      t.date :request_inspection_date
      t.date :inspection_date
      t.string :inspection_basis
      t.decimal :std_sample_m
      t.decimal :std_sample_x
      t.decimal :std_sample_a_r_1
      t.decimal :std_sample_a_r_2
      t.string :ph_value
      t.string :moisture_percent
      t.string :other_indicators
      t.string :conclusion
      t.boolean :issue_ncr
      t.text :notes
      t.integer :inspector_id
      t.integer :reviewer_id
      t.integer :user_id
      t.integer :updater_id
      t.string :py

      t.timestamps
    end
  end
end
