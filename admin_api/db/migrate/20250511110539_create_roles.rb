class CreateRoles < ActiveRecord::Migration[8.0]
  def change
    create_table :roles do |t|
      t.string :code
      t.string :name
      t.integer :category
      t.integer :sort
      t.string :describe
      t.text :roles
      t.integer :user_id

      t.timestamps
    end
    add_index :roles, :user_id

  end
end
