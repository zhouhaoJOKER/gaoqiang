class CreatePurSuppliers < ActiveRecord::Migration[8.0]
  def change
    create_table :pur_suppliers do |t|
      t.integer :contract_id
      t.string :code
      t.string :name
      t.string :abbr
      t.string :qual_notes
      t.text :remark
      t.integer :user_id
      t.integer :updater_id
      t.string :py

      t.timestamps
    end
  end
end
