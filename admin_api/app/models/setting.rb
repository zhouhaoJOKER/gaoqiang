# RailsSettings Model
class Setting < RailsSettings::Base
  cache_prefix { "v1" }

  # Application scope fields
  field :app_name, default: "Rails Settings", validates: { presence: true, length: { in: 2..20 } }
  field :title_name, default: "Rails Settings", validates: { presence: true, length: { in: 2..20 } }
  field :open_captcha, type: :boolean, default: true
  field :author_name, default: "Cheenwe", validates: { presence: true, length: { in: 2..20 } }
  field :slogan, default: "来自上海，普惠全球。", validates: { presence: true, length: { in: 2..50 } }
  field :author_url, default: "https://github.com/cheenwe", validates: { presence: true, length: { in: 2..64 } }
  field :logo, default: "https://v3.ice.work/img/logo.png", validates: { presence: true, length: { in: 2..64 } }
  field :favicon, default: "https://v3.ice.work/img/favicon.ico", validates: { presence: true, length: { in: 2..64 } }
  field :icp, default: "沪ICP备6423XX号", validates: { presence: true, length: { in: 2..64 } }
  field :police_code, default: "沪公网安备XXX", validates: { presence: true, length: { in: 2..64 } }
  field :version_code, default: "V1.0.0", validates: { presence: true, length: { in: 2..64 } }
  field :host, default: "http://example.com", readonly: false

  def self.base_info
    %w(app_name title_name open_captcha author_name author_url logo favicon icp police_code version_code host slogan)
  end

  # ======================== smtp mail config ========================
  field :support_phone, default: "185xxx", type: :string, validates: { presence: true, length: { is: 11 } }
  field :reply_email_to, default: "cxhyun@126.com", type: :string
  field :sender_display_name, default: "iStar【客户服务】", type: :string
  field :reply_display_name, default: "iStar【技术支持】", type: :string 

  field :smtp_address, default: "smtp.163.com",type: :string
  field :smtp_port, default: 465,type: :string
  field :smtp_user_name, default: "cxhyun@163.com",type: :string
  field :smtp_password, default: "mail_password",type: :string
  field :smtp_domain, default: "163.com",type: :string
  field :smtp_authentication, default: :login,type: :string
  field :smtp_enable_ssl, type: :boolean, default: true 

  def self.mail_info
    %w(support_phone reply_email_to sender_display_name reply_display_name smtp_address smtp_port smtp_user_name smtp_password smtp_domain smtp_authentication smtp_enable_ssl)
  end


  field :collaboration, default: "wechat_work", type: :string

  field :wechat_work, type: :hash, default: {
    corp_id: '',
    agent_id: '',
    secret: ''
  }

  field :dingtalk, type: :hash, default: {
    corp_id: '',
    app_id: '',
    app_secret: '',
    inner_app_id: ''
  }

  field :feishu, type: :hash, default: {
    corp_id: '',
    app_id: '',
    app_secret: '',
    callback_url: ''
  }

  def self.collaboration_info
    %w(collaboration wechat_work dingtalk feishu)
  end

  # 文件存储类型 local/qiniu/aliyun/tencent
  field :storage_service, default: "local", type: :string
  field :storage_prefix, default: "demo", type: :string
  field :s3, type: :hash, default: {
    access_key_id: '',
    secret_access_key: '',
    region: 'us-east-1',
    bucket: '',
    endpoint: ''
  }

  def self.storage_info
    %w(storage_service storage_prefix s3)
  end


  field :default_password, default: "qwer1234!", type: :string
  field :time_zone, default: "Beijing", type: :string

  field :get_request_ip, default: "request.ip", type: :string, readonly: false

  field :allow_visit_start, default: "09:00", type: :string, readonly: false
  field :allow_visit_end, default: "24:00", type: :string, readonly: false

  field :ip_max_login_fail_num, type: :integer, default: 50, readonly: false
  field :user_max_login_fail_num, type: :integer, default: 5, readonly: false

  field :login_validity_period_hour, type: :integer, default: 24*7, readonly: false

  field :password_min_length, type: :integer, default: 6, readonly: false
  field :password_max_length, type: :integer, default: 12, readonly: false
  field :max_login_timeout_hours, type: :integer, default: 168, readonly: false
   
  
  field :open_log, type: :boolean, default: false
  field :open_security_certificate, type: :boolean, default: false
  field :open_check_digit, type: :boolean, default: false


  field :whitelists, type: :array, default: []

  def self.security_info
    %w(default_password time_zone get_request_ip allow_visit_start allow_visit_end ip_max_login_fail_num user_max_login_fail_num login_validity_period_hour password_min_length password_max_length open_log open_security_certificate open_check_digit)
  end

  # ======================== Add your own fields here ========================
  # Define your fields
  # field :host, type: :string, default: "http://localhost:3000"
  # ======================== devise config ========================
  field :devise_secret_key, default: "131d674d797f41970b9c9d63fef55a2b4dac0a4346b624a0770a24fdf96b042b3c0b83ea2e4752492c7dc12bc180683cf7e682cc81d29112a55b69b95f70ffd9",type: :string
  field :devise_remember_for, default: 14,type: :integer
  field :devise_timeout_in, default: 3,type: :integer
  field :devise_maximum_attempts, default: 5,type: :integer
  field :devise_unlock_in, default: 2,type: :integer
  field :devise_reset_password_within, default: 4,type: :integer


  field :jwt_secret, default: "58b322c3fefe46d88f0402338c2c231c", type: :string


  def self.default_host
    Setting.host.split("/")[2].split(":")[0] rescue '127.0.0.1'
  end

end