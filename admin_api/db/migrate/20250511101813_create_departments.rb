class CreateDepartments < ActiveRecord::Migration[8.0]
  def change
    create_table :departments do |t|
      t.string :code
      t.string :name
      t.integer :parent_id
      t.string :parent_code
      t.integer :status
      t.integer :manager_id
      t.string :remark

      t.timestamps
    end
    add_index :departments, :parent_id

  end
end
