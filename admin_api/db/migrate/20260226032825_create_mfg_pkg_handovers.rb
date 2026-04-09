class CreateMfgPkgHandovers < ActiveRecord::Migration[8.0]
  def change
    create_table :mfg_pkg_handovers do |t|
      t.integer :contract_id
      t.string :form_date
      t.string :code
      t.integer :preparer_id
      t.integer :client_id
      t.string :contract_code
      t.integer :product_id
      t.string :product_name
      t.string :sign_date
      t.string :qty
      t.string :specification
      t.integer :bottle_contract_id
      t.text :bottle_info
      t.integer :label_contract_id
      t.text :label_info
      t.integer :box_contract_id
      t.text :box_info
      t.text :remark
      t.integer :user_id
      t.integer :updater_id
      t.string :py

      t.timestamps
    end
  end
end
