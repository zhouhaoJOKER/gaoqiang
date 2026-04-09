class CreatePurCollections < ActiveRecord::Migration[8.0]
  def change
    create_table :pur_collections do |t|
      t.references :purchase_contract, foreign_key: { to_table: :pur_contracts }
      t.integer :sort
      t.integer :product_id
      t.string :product_name
      t.decimal :length
      t.decimal :width
      t.decimal :height
      t.string :unit
      t.decimal :qty
      t.decimal :price
      t.decimal :amount_excl_tax
      t.decimal :tax
      t.decimal :amount
      t.integer :user_id
      t.integer :updater_id
      t.string :remark
      t.string :other
      t.string :py

      t.timestamps
    end
  end
end
