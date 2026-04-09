class CreateIqcPkgs < ActiveRecord::Migration[8.0]
  def change
    create_table :iqc_pkgs do |t|
      t.integer :contract_id
      t.integer :product_id
      t.string :name
      t.string :code
      t.string :batch_number
      t.string :submitting_unit
      t.string :inspection_basis
      t.string :batch_qty
      t.date :request_inspection_date
      t.date :report_date
      t.text :record_content
      t.string :conclusion
      t.text :remark
      t.integer :reviewer_id
      t.integer :inspector_id
      t.integer :user_id
      t.integer :updater_id
      t.string :py

      t.timestamps
    end
  end
end
