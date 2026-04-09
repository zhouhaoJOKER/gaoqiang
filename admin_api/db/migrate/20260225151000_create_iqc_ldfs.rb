class CreateIqcLdfs < ActiveRecord::Migration[8.0]
  def change
    create_table :iqc_ldfs do |t|
      t.integer :contract_id
      t.integer :product_id
      t.string :name
      t.string :code
      t.string :customer_trademark
      t.string :sample_color
      t.integer :user_id
      t.integer :updater_id
      t.string :py

      t.timestamps
    end
  end
end
