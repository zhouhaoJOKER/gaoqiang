class AddSortToDepartments < ActiveRecord::Migration[8.0]
  def change
    add_column :departments, :sort, :integer, default: 0, null: false unless column_exists? :departments, :sort
  end
end
