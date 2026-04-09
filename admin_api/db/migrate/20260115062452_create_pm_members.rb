class CreatePmMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :pm_members do |t|
      t.integer :record_id
      t.string :record_type
      t.integer :user_id
      t.integer :role_id
      t.datetime :joined_at

      t.timestamps
      t.index [:record_type, :record_id]
    end
  end
end
