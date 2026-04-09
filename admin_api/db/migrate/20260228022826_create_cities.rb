# frozen_string_literal: true

class CreateCities < ActiveRecord::Migration[8.0]
  def change
    create_table :cities do |t|
      t.references :province, null: false, foreign_key: true
      t.integer :code, null: false
      t.string :name, null: false
      t.string :py, null: false

    end
    add_index :cities, :code, unique: true
    add_index :cities, [:province_id, :code], unique: true
  end
end
