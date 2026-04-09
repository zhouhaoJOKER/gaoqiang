class AddCompanyIdToDepartments < ActiveRecord::Migration[8.0]
  def change
    add_column :departments, :company_id, :integer
    add_index :departments, :company_id
    add_column :menus, :company_id, :integer
    add_index :menus, :company_id
    add_column :nodes, :company_id, :integer
    add_index :nodes, :company_id
    add_column :users, :company_id, :integer
    add_index :users, :company_id
  end
end
