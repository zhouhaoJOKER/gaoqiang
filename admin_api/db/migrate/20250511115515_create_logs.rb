class CreateLogs < ActiveRecord::Migration[8.0]
  def change
      
    create_table "logs", charset: "utf8mb4", collation: "utf8mb4_unicode_ci", force: :cascade do |t|
      t.integer "user_id", comment: "操作用户"
      t.string "event", comment: "事件"
      t.integer "category", comment: "类别"
      t.string "ip", comment: "来源"
      t.boolean "result", default: true, comment: "结果,1成功、0失败"
      t.text "describe", comment: "描述"
      t.string "modules", comment: "模块"
      t.boolean "core", default: false, comment: "是否核心模块,1核心、0非核心"
      t.string "check_digit", comment: "校验位"
      t.boolean "checked", default: false, comment: "是否被篡改，1被篡改"
      t.datetime "created_at", comment: "创建于"
      t.integer "record_id", comment: "模块ID"
      t.string "record_type", comment: "模块名称"
    end

    add_index :logs, :user_id
    add_index :logs, [:record_id, :record_type]

  end
end
