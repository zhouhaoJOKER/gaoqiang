class CreateIqcFdfs < ActiveRecord::Migration[8.0]
  def change
    create_table :iqc_fdfs do |t|
      t.integer :contract_id
      t.integer :product_id
      t.string :name
      t.string :code
      t.string :inspection_basis
      t.string :instrument_number
      t.string :customer_trademark_name
      t.date :request_inspection_date
      t.string :std_sample_1_m
      t.decimal :std_sample_1_x
      t.string :std_sample_1_spectrum_id
      t.string :std_sample_1_a_r_1
      t.string :std_sample_1_a_r_2
      t.string :std_sample_2_m
      t.decimal :std_sample_2_x
      t.string :std_sample_2_spectrum_id
      t.string :std_sample_2_a_r_1
      t.string :std_sample_2_a_r_2
      t.integer :user_id
      t.integer :updater_id
      t.string :py

      t.timestamps
    end
  end
end
