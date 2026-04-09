class CreateProvinces < ActiveRecord::Migration[8.0]
  def change
    create_table :provinces do |t|
      t.integer :code, null: false
      t.string :name, null: false
      t.string :py, null: false
    end
    add_index :provinces, :code, unique: true
  end
end
