class AddSortToNodes < ActiveRecord::Migration[8.0]
  def change
    add_column :nodes, :sort, :integer
  end
end
