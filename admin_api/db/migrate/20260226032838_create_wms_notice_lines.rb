class CreateWmsNoticeLines < ActiveRecord::Migration[8.0]
  def change
    create_table :wms_notice_lines do |t|
      t.references :notice, foreign_key: { to_table: :wms_notices }
      t.string :order_no
      t.integer :product_id
      t.string :product_name
      t.string :qty
      t.string :qty_unit
      t.string :packaging_note
      t.integer :pieces
      t.integer :sort
      t.integer :user_id

      t.timestamps
    end
  end
end
