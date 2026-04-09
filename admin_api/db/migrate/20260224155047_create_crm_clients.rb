class CreateCrmClients < ActiveRecord::Migration[8.0]
  def change
    create_table :crm_clients do |t|
      t.integer :parent_id
      t.string :code
      t.string :name
      t.string :abbr
      t.string :tax_no
      t.string :address
      t.string :phone
      t.string :bank_name
      t.string :bank_account
      t.integer :settlement_id
      t.string :payment_terms
      t.integer :invoice_type_id
      t.text :remark
      t.integer :user_id
      t.integer :updater_id
      t.string :py

      t.timestamps
    end
  end
end
