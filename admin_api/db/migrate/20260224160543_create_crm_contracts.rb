class CreateCrmContracts < ActiveRecord::Migration[8.0]
  def change
    create_table :crm_contracts do |t|
      t.string :code
      t.date :sign_at
      t.references :client, foreign_key: { to_table: :crm_clients }
      t.integer :client_contact_id
      t.string :client_contact_name
      t.string :client_phone
      t.string :client_fax
      t.references :supplier, foreign_key: { to_table: :pur_suppliers }
      t.string :supplier_contact_name
      t.integer :supplier_contact_id
      t.string :supplier_phone
      t.string :supplier_fax
      t.string :product_en
      t.string :product_zh
      t.text :specs
      t.text :pack_req
      t.decimal :qty
      t.decimal :unit_price
      t.decimal :total
      t.decimal :tax
      t.decimal :amount_net
      t.string :total_cn
      t.date :deliver_at
      t.string :deliver_addr
      t.string :indicator_req
      t.string :req_docs
      t.integer :settlement_id
      t.text :remarks
      t.integer :user_id
      t.integer :updater_id
      t.string :py

      t.timestamps
    end
  end
end
