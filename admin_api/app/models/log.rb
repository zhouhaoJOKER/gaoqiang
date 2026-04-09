class Log < ApplicationRecord
  # if Setting.is_rendajincang_sql
  #   self.table_name = 'public.logs'
  # else
  #   self.table_name = 'logs'
  # end
  # columns: user_id, event, category, ip, result, describe, modules, core, check_digit, checked

  attribute :created_time, :string

  #belongs_to :record, polymorphic: true
  belongs_to :user, class_name: "::User", optional: true

  scope :minutes, -> {where("created_at > ?", Time.now-1.minutes)}
  scope :today, -> {where("created_at > ?", Time.now-1.days)}
  scope :fail, -> {where(result:0)}
  scope :success, -> {where(result:1)}

  scope :login, -> {where(category:0)}
  scope :operate, -> {where(category:10)}
  scope :security, -> {where(category:20)}
  scope :audit, -> {where(category:30)}

  scope :all_login, -> {login.where(modules:"登录")}
  
  scope :renzheng, -> {where(category:10000).map{|e|e.modules}.uniq}

  scope :olded, -> {where("created_at < ?", Time.now-1.month)}

  
  scope :db_backup, -> {where(category:110)} #手动备份db
  scope :backups, -> {where(category:120)} #手动导出数据

  scope :clear_db, -> {where(category:130)} #手动导出数据

  # validates :user_id, presence: true
  #validates :name, length: { in: 2..20 },  presence: true, uniqueness:true
  #validates_uniqueness_of :name, :scope => :sign
  #validates :amount, numericality: { greater_than_or_equal_to: 0 }, :allow_nil => true
  #validates :port, numericality: {only_integer: true, greater_than: 0}, allow_blank: true


  after_update :update_check_digit
  after_create :update_check_digit
  # after_save :update_check_digit


  def self.poller_api_code
    if Setting.is_jianyan
      "01-11-000017"
    else
      "01-01-700001"
    end
  end

  # Log.reporter_api_code
  def self.reporter_api_code
    if Setting.is_jianyan
      "01-11-000018"
    else
      "01-01-700002"
    end
  end

  def index_info
    {  id:id, user_id: user_id,user_name: (user.name rescue ''),  event: event,  category: category,  ip: ip,  result: result,  describe: describe,  modules: modules,  core: core,  check_digit: check_digit,  checked: checked, created_time: created_time, category_name: check_category_name }
  end

  def security_info
    # 用户、事件、来源、类型（增、删、该、查）、模块、是否核心功能、是否非常规业务、结果和描述。
    {  id:id,
      user_id: user_id,
      user_name: User.get_name(user_id),
      event: event,
      ip: ip,
      modules: modules,
      describe: describe,
      category_name: (check_category_name rescue "其他"),
      core: core,
      is_not_routine: !(describe.include?("非常规")), 
      result: result,
      check_digit: check_digit,
      checked: checked,
      created_at: created_at }
  end

  def check_category_name
      res = "其他"
    if event.present?
      if  event.include?("访问")
        res = "查看"
      elsif  event.include?("完整性校验")
        res = "系统异常日志"
      elsif  event.include?("数据库连接")
        res = "系统异常日志"
      elsif  event.include?("01-11-000017")
        res = "读取机动车检验智能审核待比对信息查询接口"
      elsif  event.include?("01-11-000018")
        res = "检验照片比对结果信息写入接口"
      elsif  event.include?("01-01-700001")
        res = "读取机动车查验和资料照片"
      elsif  event.include?("01-01-700001")
        res = "写机动车查验和资料照片比对结果信息"
      elsif  event.include?("登录")
        res = "登录"
      elsif  event.include?("新建")
        res = "新建"
      elsif  event.include?("删除")
        res = "删除"
      elsif event.include?("修改")
        res = "修改"
      end
    end
    res
  end
  

  def show_info

    { id:id,  user_id: user_id,  event: event,  category: category,  ip: ip,  result: result,  describe: describe,  modules: modules,  core: core,  check_digit: check_digit,  checked: checked,  user_name: User.get_name(user_id), created_at: created_at }
  end

  def fails_info
    {
      id: id,
      created_at: created_at,
      ip: ip,
      event: event,
      result: result,  
      describe: describe, 
      user_name: User.get_name(user_id)
    }
  end
  

  def update_check_digit
    if Setting.open_security_certificate || Setting.open_log
      str = "#{id}.#{user_id}.#{event}.#{category}.#{ip}.#{modules}.#{describe}.#{created_at}"
      check_digit = Digest::MD5.hexdigest(str)
      CheckDigitJob.perform_later(self, check_digit)
    end
  end

  # user_id, event, category, ip, result, describe, modules, core

  # Log.create_log(category, user_id, ip, describe, event, result, modules, core)
  def self.create_log(category, user_id, ip, describe, event, result, modules, core, record_id: nil, record_type: nil)
    return unless Setting.open_security_certificate || Setting.open_log

    attrs = {
      category: category,
      user_id: user_id,
      ip: ip,
      describe: describe,
      event: event,
      result: result,
      core: core,
      modules: modules
    }
    attrs[:record_id] = record_id if record_id.present?
    attrs[:record_type] = record_type if record_type.present?
    Log.create(attrs)
  end

  # 登录日志 category:0、 登出 1 
  # 操作日志 category:10 
  # 安全日志 category:20
  # 审计日志 category:30
  # Log.gen_security_log(user_id, ip,  event, result = 1, describe="",  modules="")
  def self.gen_security_log(user_id, ip,  event, result = 1, describe="",  modules="",  core=0)
    # Log.generate_log(20, user_id, ip, describe, event, result, modules, core)
    category = 20
    Log.create_log(category, user_id, ip, describe, event, result, modules, core)
  end

  # Log.gen_audit_log( user_id, ip, event, result, describe,  modules)
  def self.gen_audit_log(user_id, ip,  event, result = 1, describe="",  modules="",  core=0)
    category = 30
    Log.create_log(category, user_id, ip, describe, event, result, modules, core)
  end

  def self.generate_log(category, user_id, ip, describe, event_name,  result = 1, modules="",  core=0)
    if modules == ''||modules.nil?
      # 这里日志需要根据菜单中是否是核心模块去生成
      event = Permission.find_by(act: event_name).name rescue ''
      modules = Permission.find_by(act: event_name).ctrl  rescue ''
      is_core = Permission.find_by(act: event_name).core  rescue 0 # 判断核心业务
      is_not_routine = Permission.find_by(act: event_name).is_not_routine?  rescue 0 # 判断非常规业务
      event = "登录系统" if event_name == "login"
      modules = "登录" if event_name == "login"
      event = "退出系统" if event_name == "logout"
      modules = "登出" if event_name == "logout"
      
      if  is_core
        describe_str = "【核心功能】"+describe 
        Log.gen_security_log(user_id, ip,  event, result, describe_str,  modules, is_core)
      end

      if is_not_routine
        describe_str = "【非常规业务】"+describe
        Log.gen_security_log(user_id, ip,  event, result, describe_str,  modules)
        # Log.gen_audit_log(user_id, ip,  event, result, describe_str,  modules) 
      end
    end

    # Log.create(
    #   category: category, 
    #   user_id: user_id, 
    #   ip: ip, 
    #   describe: describe, 
    #   event: event, 
    #   result: result, 
    #   core: core, 
    #   modules: modules
    # )
    Log.create_log(category, user_id, ip, describe, event, result, modules, is_core) if category!=20 ||category!=30
  end



  # 校验 校验位字段
  def check_check_digit
    str = "#{id}.#{user_id}.#{event}.#{category}.#{ip}.#{modules}.#{describe}.#{created_at}"
    new_check_digit = Digest::MD5.hexdigest(str)
    return new_check_digit
  end


  # 校验 校验位字段
  def validate_check_digit
    # str = "#{id}.#{user_id}.#{event}.#{category}.#{ip}.#{modules}.#{describe}.#{created_at}"
    # new_check_digit = Digest::MD5.hexdigest(str)
    new_check_digit = check_check_digit
    # p new_check_digit
    # p new_check_digit

    # p new_check_digit
    # p check_digit
    unless check_digit  == new_check_digit
    #   p "校验成功"
    # else
      # p "==检测到日志记录【#{id}】已被非法篡改"
      update_columns(checked: 1)
      Log.gen_audit_log(1, "0.0.0.0", "数据篡改校验", 1, "检测到日志记录【#{id}】已被非法篡改",  "安全审计")
    end
  end


  def self.check_mult_check_digit(data)
    tmp_str = ""
    data.each do |item|
      new_check_digit = item.check_check_digit
      unless item.check_digit  == new_check_digit
      #   p "#{item.id} 校验成功"
      # else
        # log.info "===审计日志[#{item.id}]校验失败"
        # p new_check_digit
        # p item.check_digit

        msg = "审计日志[#{item.id}]数据校验位被篡改!"
        tmp_str = tmp_str + msg
        Log.gen_security_log(1, "0.0.0.0", "数据完整性校验测", 0, msg,  "安全审计")
        item.update_columns(checked: 1)
      end
    end
    tmp_str
  end

  def self.gen_csv(data, file)
		csv_file = "#{Rails.root}/public/uploads/#{file}"
    File.open("#{csv_file}","w+:gbk") do |f|
    # user_id, event, category, ip, result, describe, modules, core, check_digit, checked
			a = "用户, 时间, IP,  模块, 事件, 描述, 操作结果, 日志类别"
			f.puts a
			data.each do |record|
        c1 = record.user.name
        c2 = record.created_at.strftime("%Y-%m-%d %H:%M:%S")
        c3 = record.ip
        c4 = record.modules
        c5 = record.event
        c6 = record.describe
        c7 = record.result
        c8 = record.category
				a =  "#{c1},#{c2},#{c3},#{c4},#{c5},#{c6},#{c7},#{c8}"
				f.puts a
			end
			f.close
    end
    return csv_file
  end

end

# === other ===
#_sidebar
# <li class="<%= 'active' if nav_check_url?('logs')  %>"><a href="/logs"  title="log"><span><%= I18n.t :"log.modelname" %></span></a></li>
