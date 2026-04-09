class AddGramWeightToMatProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :mat_products, :gram_weight, :string, comment: "克重"
  end
end
