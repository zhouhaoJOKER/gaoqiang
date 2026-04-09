class Blacklist < ApplicationRecord
  # columns: user_id, ip, num
  # if Setting.is_rendajincang_sql
  #   self.table_name = 'public.blacklists'
  # end
 
  #belongs_to :record, polymorphic: true
  # belongs_to :user, class_name: "::User"

  # validates :user_id, presence: true
  #validates :name, length: { in: 2..20 },  presence: true, uniqueness:true
  validates_uniqueness_of :ip, :scope => :user_id
  #validates :amount, numericality: { greater_than_or_equal_to: 0 }, :allow_nil => true
  #validates :port, numericality: {only_integer: true, greater_than: 0}, allow_blank: true
 

  scope :devices, -> {where(user_id:0)}
  scope :users, -> {where("user_id >?", 0)}

  # 设备黑名单
  # Blacklist.block_devise_ip
  def self.block_devise_ips
    block_devises.map{|e|e.ip}
  end

  # 设备锁定
  def self.block_devises
    devices.where("num >=?", Setting.ip_max_login_fail_num)
  end

  def self.block_users
    users.where("num >=?", Setting.user_max_login_fail_num)
  end

  # Blacklist.blocked_ip_nums # 
  def self.blocked_ip_nums
    Setting.ip_max_login_fail_num
  end

  # Blacklist.blocked_user_nums # 
  def self.blocked_user_nums
    Setting.user_max_login_fail_num
  end

  # Blacklist.block_ip_num("116.236.178.147")
  def self.block_ip_num(ip)
    # Setting.ip_max_login_fail_num
    devices.find_by(ip:ip).try(:num)||0
  end

  # Blacklist.block_user_num("116.236.178.147",1)
  def self.block_user_num(ip, user_id)
    # Setting.ip_max_login_fail_num
    Blacklist.where(ip:ip,user_id:user_id).last.try(:num) rescue 0
  end

  # Blacklist.block_ip_info("116.236.178.147")
  def self.block_ip_info(ip)
    block_ip_num = Blacklist.block_ip_num(ip)
    return "当前终端已登录失败【#{block_ip_num}】次，剩余尝试次数【#{Blacklist.blocked_ip_nums-block_ip_num}】； "
  end

  # Blacklist.block_user_info("116.236.178.147",1)
  def self.block_user_info(ip, user_id)
    block_user_num = Blacklist.block_user_num(ip, user_id)
    less_num = Blacklist.blocked_user_nums-block_user_num
    return "用户已在该终端已登录失败【#{block_user_num}】次，剩余尝试次数【#{less_num}】 ", less_num, block_user_num
  end

  # 用户锁定
  def blocked
    num >= Setting.user_max_login_fail_num
  end

  # 生成设备锁定记录
  # Blacklist.gen_record(ip)
  def self.gen_record(ip, user_id=0)
    # user_id, ip, num
    record  = Blacklist.where(ip: ip, user_id:user_id).last rescue ''
    if record
      record.update(num: record.num+1)
    else
      Blacklist.create(ip: ip, user_id:user_id, num:1)
    end
  end
  

  def index_info
    {  id:id, user_id: user_id,  ip: ip,  num: num, user_name: User.get_name(user_id), created_at: created_at , updated_at: updated_at }
  end

  def show_info
       
    {  id:id, user_id: user_id,  ip: ip,  num: num,  user_name: User.get_name(user_id), created_at: created_at , updated_at: updated_at }
  end
end

# === other ===
#_sidebar
# <li class="<%= 'active' if nav_check_url?('blacklists')  %>"><a href="/blacklists"  title="blacklist"><span><%= I18n.t :"blacklist.modelname" %></span></a></li>
