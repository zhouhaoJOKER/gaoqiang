class CreatePurContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :pur_contacts do |t|
      t.references :supplier, foreign_key: { to_table: :pur_suppliers }
      t.string :name
      t.string :dept
      t.string :phone
      t.string :mobile
      t.string :email
      t.boolean :is_primary
      t.string :remark
      t.integer :user_id
      t.integer :updater_id
      t.string :py

      t.timestamps
    end
  end
end
