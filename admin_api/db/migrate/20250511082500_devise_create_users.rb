class DeviseCreateUsers < ActiveRecord::Migration[8.0]
  def change
    # drop_table :users
    create_table :users do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      t.string   :unlock_token # Only if unlock strategy is :email or :both
      t.datetime :locked_at

      t.string  :nickname, default: "", null: false , :comment => "昵称"
      t.string  :name, default: "", null: false , :comment => "姓名"
      t.string  :phone, default: "", null: false , :comment => "电话"
      t.boolean  :approved, default: false, null: false , :comment => "允许使用"
      t.string  :uuid, default: "", null: false , :comment => "UUID"
      t.string :code, default: "", null: false, :comment => "编号"
      t.string :sex, default: "", null: false, :comment => "性别"
      t.string :marriage, default: "", null: false, :comment => "婚姻, Y：已婚  N：未婚  O：其他  L：离异  S：丧偶  B：保密"
      t.string :cardnum, default: "", null: false, :comment => "身份证号"
      t.date :brondate, default: "", :comment => "出生日期"
      t.integer  :department_id, default: "", :comment => "部门"
      t.integer  :post_id, default: "", :comment => "岗位"
      t.date :hire_date, default: "", :comment => "入职日期"
      t.date :fire_date, default: "", :comment => "离职日期"
      t.integer  :director_id, default: "", :comment => "直接主管"
      t.integer  :role_id, default: 0, null: false , :comment => "角色"
      t.integer  :status, default: 0, null: false , :comment => "同步标识"

      t.string  :avatar, default: "", null: false , :comment => "头像"
      t.text  :remark, :comment => "备注"
      t.text "whitelists", comment: "IP白名单"
      t.boolean "change_passowrd", default: false, comment: "是否强制修改密码"

      t.timestamps null: false
    end

    add_index :users, :name,                unique: true
    add_index :users, :email,                unique: true
    add_index :users, :phone,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
    add_index :users, :role_id
    add_index :users, :department_id
  end
end
