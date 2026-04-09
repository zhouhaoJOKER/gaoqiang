class CreateCrmQuotations < ActiveRecord::Migration[8.0]
  def change
    create_table :crm_quotations do |t|
      t.integer :contract_id
      t.references :client, foreign_key: { to_table: :crm_clients }
      t.string :code
      t.date :quote_date
      t.date :valid_until
      t.string :currency
      t.integer :status_id
      t.integer :tax_rate_id
      t.decimal :amount
      t.decimal :total_amount
      t.text :remark
      t.integer :user_id
      t.integer :updater_id
      t.string :py

      t.timestamps
    end
  end
end
