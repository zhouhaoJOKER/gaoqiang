class CreateCrmSpecItems < ActiveRecord::Migration[8.0]
  def change
    create_table :crm_spec_items do |t|
      t.string :code
      t.string :name
      t.string :name_en
      t.integer :sort
      t.string :remark
      t.integer :user_id
      t.integer :updater_id
      t.string :py

      t.timestamps
    end
  end
end
