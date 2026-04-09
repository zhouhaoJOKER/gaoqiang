# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


User.delete_all

def init_user(id)
  data = {
    id:id,
    name: "user#{id}",
    nickname: "管理员",
    email: "admin#{id}@qq.com",
    password: "123123123",
    phone: "1851605375#{id}",
    uuid: System.uuid,
    cardnum: "15211219901209345#{id}",
    code: "ac0#{id}",
    change_passowrd: false,
    role_id: id,
    approved: true,
    whitelists: "0.0.0.0",
  }
  # User.avatar 挂载了 CarrierWave，直接传字符串会被当作上传流程处理后丢失，
  # 这里改为底层列赋值，确保满足 avatar NOT NULL 约束。
  user = User.new(data)
  user[:avatar] = "ac0#{id}.png"
  user.save!
end



%w(1 2 3 4).each do |id|
  init_user(id)
end

# 单号规则默认配置（各模块可单独配置）
DocNumberRule.find_or_create_by!(key: "fm_contracts") do |r|
  r.name = "FM合同单号"
  r.format = "FM-{YYMMDD}-{seq:4}"
  r.reset_period = "day"
  r.current_sequence = 0
end
DocNumberRule.find_or_create_by!(key: "crm_quotations") do |r|
  r.name = "CRM报价单号"
  r.format = "QT-{YYMMDD}-{seq:4}"
  r.reset_period = "day"
  r.current_sequence = 0
end
DocNumberRule.find_or_create_by!(key: "crm_handovers") do |r|
  r.name = "CRM交接单号"
  r.format = "JH-{YYMMDD}-{seq:4}"
  r.reset_period = "day"
  r.current_sequence = 0
end

# 流程模板初始化
load Rails.root.join("db", "seeds", "workflow.rb")