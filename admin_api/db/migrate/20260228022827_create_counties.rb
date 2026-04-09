# frozen_string_literal: true

class CreateCounties < ActiveRecord::Migration[8.0]
  def change
    create_table :counties do |t|
      t.references :city, null: false, foreign_key: true
      t.integer :code, null: false
      t.string :name, null: false
      t.string :py, null: false

    end
    add_index :counties, :code, unique: true
    add_index :counties, [:city_id, :code], unique: true
  end
end
