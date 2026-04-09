class CreateCrmInvoices < ActiveRecord::Migration[8.0]
  def change
    create_table :crm_invoices do |t|
      t.string :billable_type
      t.integer :billable_id
      t.string :title
      t.string :tax_no
      t.string :address
      t.string :phone
      t.string :bank_name
      t.string :bank_account
      t.integer :invoice_type_id
      t.boolean :is_default
      t.string :remark
      t.integer :user_id
      t.integer :updater_id
      t.string :py

      t.timestamps
    end
  end
end
