class CreateBlacklists < ActiveRecord::Migration[8.0]
  def change
    create_table :blacklists do |t|
    t.integer "user_id", default: 0, comment: "id > 0 用户黑名单，默认0 代表终端黑名单"
    t.string "ip", comment: "记录ip"
    t.integer "num", default: 0, comment: "登录失败次数"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    end
  end
    add_index :blacklists, :user_id

end
