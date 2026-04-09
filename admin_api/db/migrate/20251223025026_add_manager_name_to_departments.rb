class AddManagerNameToDepartments < ActiveRecord::Migration[8.0]
  def change
    add_column :departments, :manager_name, :string unless column_exists? :departments, :manager_name
  end
end
