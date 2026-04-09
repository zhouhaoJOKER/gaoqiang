class CreateCrmHandovers < ActiveRecord::Migration[8.0]
  def change
    create_table :crm_handovers do |t|
      t.integer :contract_id
      t.string :doc_no
      t.string :order_company
      t.string :order_contract_no
      t.string :goods_name
      t.text :specs
      t.string :order_kind
      t.string :special_note
      t.decimal :qty
      t.string :qty_unit
      t.text :pack_specs
      t.date :deliver_at
      t.text :notes
      t.integer :reviewer_id
      t.date :review_at
      t.integer :prod_signer_id
      t.integer :tech_signer_id
      t.integer :qa_signer_id
      t.integer :user_id
      t.integer :updater_id
      t.string :py

      t.timestamps
    end
  end
end
