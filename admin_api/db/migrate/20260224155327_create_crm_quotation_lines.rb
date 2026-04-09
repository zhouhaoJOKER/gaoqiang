class CreateCrmQuotationLines < ActiveRecord::Migration[8.0]
  def change
    create_table :crm_quotation_lines do |t|
      t.references :quotation, foreign_key: { to_table: :crm_quotations }
      t.integer :item_id
      t.string :product_name
      t.string :spec
      t.decimal :qty
      t.string :unit
      t.decimal :unit_price
      t.decimal :amount
      t.string :remark
      t.integer :sort
      t.integer :user_id

      t.timestamps
    end
  end
end
