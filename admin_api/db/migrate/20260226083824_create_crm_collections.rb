class CreateCrmCollections < ActiveRecord::Migration[8.0]
  def change
    create_table :crm_collections do |t|
      t.integer :contract_id
      t.integer :sort
      t.integer :product_id
      t.string :name
      t.integer :unit_id
      t.decimal :qty
      t.decimal :price
      t.decimal :amount_excl_tax
      t.decimal :tax
      t.decimal :amount
      t.integer :user_id
      t.integer :updater_id
      t.string :remark

      t.timestamps
    end
    add_index :crm_collections, :contract_id
  end
end
