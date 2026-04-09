class CreateCrmAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :crm_addresses do |t|
      t.references :client, foreign_key: { to_table: :crm_clients }
      t.string :addr_kind
      t.string :contact
      t.string :phone
      t.text :addr
      t.boolean :is_default
      t.string :remark
      t.integer :user_id
      t.integer :updater_id
      t.string :py

      t.timestamps
    end
  end
end
