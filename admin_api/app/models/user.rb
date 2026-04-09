class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable, :timeoutable, :lockable

  belongs_to :role, class_name: "Role", foreign_key: "role_id"
  belongs_to :department, class_name: "Department"

  has_many :blacklists, class_name: "Blacklist"
  has_many :logs, class_name: "Log"

  # before_create :generate_code

  validates :name, length: { in: 2..20 },  presence: true, uniqueness: true

  scope :actived, -> { where(approved: true) }

  mount_uploader :avatar, AvatarUploader

  attribute :created_time, :string
  attribute :updated_time, :string

  # TODO 当前用户能看到的菜单
  def current_menus
      # if id == 1
      #   Menu.all
      # else
      company_id = get_current_company_id
      sign = role.sign
      Menu.where(company_id: company_id).where("signs like '%#{sign}%'").order("sort asc")
    # end
  end

  def get_current_company_id
    if current_company_id.present?
      current_company_id
    elsif company_id.present?
      company_id
    else
      Company.last.id rescue 1
    end
  end

  # TODO 当前用户能看到的公司
  def current_companies
    if id == 1
      Company.all
    else
      ids = role.company_ids.split(",").reject(&:empty?) rescue []
      Company.where(id: ids)
    end
  end

  # 生成jwt
  def generate_jwt_token
    hmac_secret = Setting.jwt_secret # #JWT私钥
    payload = {
      login_at: System.now_s,
      time: Time.now,
      id: id,
      name: name
    }
    JWT.encode payload, hmac_secret, "HS256"
  end

  # User.decoded_jwt_infos(token)
  def self.decoded_jwt_infos(token)
    JWT.decode(token, Setting.jwt_secret, true, { algorithm: "HS256" })[0]
  end



  # 校验当前用户密码
  def validate_current_password(password_str = Setting.default_password)
    # p password_str
    # p password_str
    # p password_str
    return false if password_str.blank?

    valid_password? password_str
    # password_hash = enc_password(password_str)
    # # p password_hash
    # # p  password
    # # p   password_hash == password
    # password_hash == password
  end


  #  上次登陆的状态是否失败
  #  User.second.is_show_fail_logs?()
  def is_show_fail_logs?
    res =  true # false
    # res =   true if (logs&.last&.result == false)
    res
  end

  #  成功登陆后显示登陆失败的原因
  #  User.second.login_fail_logs()
  def login_fail_logs
    last_success_id = logs.login.success.last.id rescue 1

    fail_logs  = logs.where(category: [ 0, 1 ]).where("id >= ?", last_success_id) rescue ""
    fail_logs.map { |e| e.fails_info }
    # p fail_logs.size
  end





  #  通过缓存计算当前在线人数
  #  User.online_user_count
  def self.online_user_count
    start_time =  Time.now -  Setting.login_validity_period_hour.hours
    num = User.where.not(current_sign_in_at: nil).where("current_sign_in_at >?", start_time).size
    num
  end


  def index_info
    {
      id: id,
      email: email,
      name: name,
      nickname: nickname,
      phone: phone,
      approved: approved,
      uuid: uuid,
      code: code,
      sex: sex,
      marriage: marriage,
      cardnum: cardnum,
      brondate: brondate,
      department_id: department_id,
      post_id: post_id,
      hire_date: hire_date,
      fire_date: fire_date,
      director_id: director_id,
      role_id: role_id,
      status: status,
      avatar: avatar,
      remark: remark,
      whitelists: whitelists,
      change_passowrd: change_passowrd,
      created_at: created_at,
      updated_at: updated_at,
      created_time: created_time,
      updated_time: updated_time

    }
  end


  def thin_info
    {
      "id": id,
      "name": name
    }
  end

  def department_info
    {
      "userId": id,
      "userName": name,
      "deptId": department_id
    }
  end

  def avatar_url
    if avatar.present?
      str = "<img src='#{avatar}' alt='image' class='img-fluid avatar-md rounded-circle'>"
    else
      str = "
          <span class='avatar-lg bg-soft-secondary text-secondary font-20 rounded-circle'>
              #{username[0]}
          </span>"
    end
  end

  def recent_notify
    notifications.last(5)
  end

  def nick_name
    # self.id == 1
    self.nickname  || self.name
  end

  def admin?
    self.id == 1 ||self.role_id == 1 || email == "cxhyun@126.com"
  end

  def permissions
    role_ids = role.role_ids.map(&:to_i) rescue []
    permissions =   Permission.where(id: role_ids) rescue []
  end

  def sub_permissions
    role_ids = sub_role.role_ids.map(&:to_i) rescue []

    permissions =   Permission.where(id: role_ids) rescue []
  end

  def wuser_userid
    wuser.userid rescue ""
  end


  # User.find_by_username_or_email(name)
  def self.find_by_username_or_email(login)
    login = login.downcase
    where([ "(lower(username) = :value OR lower(email) = :value) and approved = 1", { value: login } ]).first rescue ""
  end

  # User.get_avatar_url_by_name(name)
  def self.get_avatar_url_by_name(name)
    user = User.find_by(username: name)
    user.avatar_url
  end



  # User.gen_new_user(name)
  def self.gen_new_user(username, email, password = Setting.default_password)
    User.create!(
      avatar: File.open("#{Rails.root}/public/icon.png"),
      nickname: username,
      name: username,
      confirmed_at: Time.now,
      password: password,
      email: email,
      role_id: Role.first.id,
      approved: 1
    )
  end

  # User.gen_user(name)
  def self.gen_user(name, username = System.string(5))
    User.create!(
      username: name,
      name: name,
      confirmed_at: Time.now,
      password: Setting.default_password,
      email: "#{username}@qq.com",
      role_id: Role.first.id,
      approved: 1
    )
  end

  def reset_passwd
    unlock_token = System.uuid
    update(
      unlock_token: nil,
      confirmed_at: Time.now,
      confirmation_token: nil,
      confirmation_sent_at: nil,
      reset_password_token: nil,
      reset_password_sent_at: nil,
      failed_attempts: 0,
      locked_at:  nil,
      password: Setting.default_password,
    )
    # `reset_password_token` = NULL, `users`.`reset_password_sent_at` = NULL
  end

  def restore_passwd
    password = unlock_token
    unlock_token =  ""
    update_columns(
      unlock_token: unlock_token,
      encrypted_password: password,
    )
  end



  def login_fail_blocked?
    login_fail_num = Blacklist.find_by(user_id: id).num rescue 0
    return true if  Setting.user_max_login_fail_num <= login_fail_num
    false
    # return true if login_fail_num < 1
  end



  def ip_blocked?(ip)
    blacklists.find_by(ip: ip).blocked rescue false
  end

  # User.search_or_create_user(name)
  def self.search_or_create_user(name)
    if name.present?
      users = User.where(name: name)
      if users.present?
        user = users.first
      else
        user = User.gen_user(name)
      end
      user.id
    else
      ""
    end
  end


  #  User.actived_name_titles
  # 返回名称的arrary
  def self.all_name_titles
    User.actived.map { |e| e.name_titles }
  end

  #  User.name_titles
  # 返回名称的arrary
  def name_titles
    { "title": name, "value": name }
  end


  # 当前登录状态是否有效
  def current_login_active?
    false
    current_sign_in_at.present?&&(current_sign_in_at + Setting.login_validity_period_hour.hours) > Time.now
  end


  def user_expired?
    user_validity.present? &&  Time.now> user_validity
  end

  def active_for_authentication?
    super && approved? && !user_expired?
  end



  # 我拥有的角色名称
  def roles_name?(name)
    res = false
    role = Role.find_by(name: name) rescue ""
    if role and (role_id == role.id ||  sub_role_id == role.id)
      res = true
    end
    res
  end

  # 发送激活账号邮件
  def send_confirmation_email
    update_columns(
      confirmation_token: System.uuid,
      confirmation_sent_at: Time.now,
    )
    SendMailer.confirmation_mail(self).deliver_now
  end

  # 发送重置密码邮件
  def send_reset_password_email
    update_columns(
      reset_password_token: System.uuid,
      reset_password_sent_at: Time.now,
    )
    SendMailer.reset_password_mail(self).deliver_now
  end

  class << self
    def current_user=(user)
      Thread.current[:current_user] = user
    end

    def current_user
      Thread.current[:current_user]
    end
  end
  def inactive_message
    if !approved?
      :not_approved
    # elsif user_expired?
    #   flash[:alert] ="user_expired"
    else
      super # Use whatever other message
    end
  end

  def user_info
    {
      "userId": id,
      "userName": name,
      "deptId": (department.name rescue "")
    }
  end

  def is_in_shangwu_or_admin?
    id.in? User.shangwu_or_admin_ids
  end

  class << self
    # User.xingzheng_managers
    def xingzheng_managers
      # 行政管理员	role_id = 4
      role_id = 4
      User.where(role_id: role_id)
    end

    # User.shangwu_or_admin_ids
    def shangwu_or_admin_ids
      # 行政管理员	role_id = 4
      # role_id = 4
      # role_ids = Role.where("name like '%管理员' or name like '商务经理' or name like '所长'").ids
      role_ids = Role.where(kind: "访问全部").where("role_name like '%删除商机%'").ids
      users = User.where(role_id: role_ids).ids
      users2 = User.where(sub_role_id: role_ids).ids
      [ users, users2 ].flatten.uniq
      # TODO ok 选择子角色也能修改。 没有权限的话访问列表也能看到。
    end


    # def has_role?(role)
    #   case role
    #     when :root then admin?
    #     else false
    #   end
    # end
  end
end
