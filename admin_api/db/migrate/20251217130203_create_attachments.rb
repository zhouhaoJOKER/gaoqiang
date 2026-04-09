class CreateAttachments < ActiveRecord::Migration[8.0]
  def change

    create_table "attachments" do |t|
      t.string "name"
      t.string "file"
      t.string "url"
      t.integer "record_id"
      t.string "record_type"
      t.string "kind"
      t.integer "user_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.string "content_type"
      t.integer "byte_size"
      t.string "uuid"
      t.string "checksum", default: "", null: false
      t.string "remark", default: "", null: false
      t.index ["record_id", "record_type"], name: "index_attachments_on_record_id_and_record_type"
      t.index ["uuid"], name: "index_attachments_on_uuid"
    end unless table_exists? :attachments
  end

end
