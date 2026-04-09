class AddProductSpecFieldsToMatProducts < ActiveRecord::Migration[8.0]
  def change
    add_column :mat_products, :image_url, :string, comment: "产品图片URL"
    add_column :mat_products, :material, :string, comment: "产品材质"
    add_column :mat_products, :full_capacity, :string, comment: "满口容量"
    add_column :mat_products, :nominal_capacity, :string, comment: "公称容量"
    add_column :mat_products, :caliber, :string, comment: "口径"
    add_column :mat_products, :cap_height, :string, comment: "带盖高度"
    add_column :mat_products, :max_diameter, :string, comment: "最大直径"
    add_column :mat_products, :label_size, :string, comment: "贴标尺寸"
  end
end
