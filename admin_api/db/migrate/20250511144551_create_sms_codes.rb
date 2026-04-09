class CreateSmsCodes < ActiveRecord::Migration[8.0]
  def change
    create_table :sms_codes do |t|
      t.string :code
      t.integer :user_id

      t.timestamps
    end
    add_index :sms_codes, [:user_id, :created_at]
  end
end
