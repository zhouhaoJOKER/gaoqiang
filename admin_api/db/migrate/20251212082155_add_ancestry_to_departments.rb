class AddAncestryToDepartments < ActiveRecord::Migration[8.0]
  def change
    add_column :departments, :ancestry, :string unless column_exists? :departments, :ancestry
    add_index :departments, :ancestry  unless index_exists? :departments, :ancestry
    add_column :nodes, :ancestry, :string  unless column_exists? :nodes, :ancestry
    add_index :nodes, :ancestry  unless index_exists? :departments, :ancestry
  end
end
