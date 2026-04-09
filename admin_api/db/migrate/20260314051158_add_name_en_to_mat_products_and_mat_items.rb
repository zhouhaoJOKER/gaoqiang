class AddNameEnToMatProductsAndMatItems < ActiveRecord::Migration[8.0]
  def change
    add_column :mat_products, :name_en, :string, comment: "英文名称"
    add_column :mat_items, :name_en, :string, comment: "英文名称"
  end
end
