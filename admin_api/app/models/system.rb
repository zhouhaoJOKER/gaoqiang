# encoding: utf-8
# require 'net/http'
# require 'net/dav'

require 'active_support/json'
# require "redis"
require "uri"
require "cgi"
# require 'zip'


class System

  class << self
    def week_day(date)
      week_num = date.wday
      res = case week_num
      when  0
        "日"
      when 1
        "一"
      when 2
        "二"
      when 3
        "三"
      when 4
        "四"
      when 5
        "五"
      when 6
        "六"
      end
      "周"+res
    end

    

    def is_password(password, digit)
      # /^(?=.*[a-zA-Z])(?=.*[0-9]).{6,}$/
      password =~ /^(?=.*[a-zA-Z])(?=.*[0-9]).{"#{digit}",}$/
    end

    def is_email(name)
      name  =~ /\A[^@]+@([^@\.]+\.)+[^@\.]+\z/
    end

    # System.is_phone(1851605376)
    # System.is_phone(18516053764)
    def is_phone(name)
      name  =~  /^1\d{10}$/
    end

    def is_email?(name)
      is_email(name) == 0
    end

    # System.is_phone(1851605376)
    # System.is_phone(18516053764)
    def is_phone?(name)
      is_phone(name) == 0
    end

    def year
      Date.today.year
    end

    def today
      now.strftime("%Y-%m-%d")
    end

    def time
      now.strftime("%Y-%m-%d %H:%M:%S")
    end

    def now
      Time.now
    end
    
    # System.now_s
    def now_s
      now.strftime("%Y%m%d%H%M%S")
    end

    # System.now_short
    def now_short
      now.strftime("%m%d%H%M")
    end

    # System.now_ss
    def now_ss
      now.strftime("%m%d")
    end

    # System.calculate_letter(3)
    # 获取字符串后 N 位的字符
    def calculate_letter(number, start="A")
      b = start
      (number-1).times do
        b =  b.next
      end
      return b
    end

    # ====> caches fun
    #
    # 缓存添加，获取
    def caches(cache_key, value=-1, expires_in=nil)
      items = Rails.cache.read(cache_key)
      if items.blank?
        items = value
        p items
        Rails.cache.write(cache_key, items, expires_in: expires_in)
      end
      return items
    end

    # 检查 cache
    def check_cache(cache_key)
      res = Rails.cache.read(cache_key)
      return res
    end

    # 写 cache
    def write_cache(cache_key, value=-1, expires_in=nil)
      p cache_key
      p value
      p expires_in
      res =  Rails.cache.write(cache_key, value, expires_in: expires_in)
      return res
    end

    # 检查ip 是否在黑名单中
    # => 如果在黑名单中, 返回 true
    # => 否则 false
    # System.check_block_ip(1111)
    def check_block_ip(ip)
      cache_key="block:#{ip}"
      value = check_cache(cache_key)
      if value.nil?
        0
      else
        value
      end
    end

    # 将ip写入 黑名单中
    # => 否则 false
    # System.write_block_ip(1111)
    def write_block_ip(cache_key, num=1)
      write_cache(cache_key, value=num, expires_in=Setting.block_ip_hour.to_f.hours)
    end

    def write_count_block_ip(ip)
      cache_key="block:#{ip}"
      num = check_block_ip(ip)
      num = num+1

      write_block_ip(cache_key, num)
    end

    # ====> cache fun
    #
    # 缓存添加，获取
    def read_and_cache_key(cache_key, function_name, expires_in=nil)
      items = Rails.cache.read(cache_key)
      if items.blank?
        items = eval(function_name)
        p items
        Rails.cache.write(cache_key, items, expires_in: expires_in)
      end
      return items
    end

    # 当前请求时间戳小于 60 秒内允许请求
    def check_request(at)
      Time.now.to_i - (at.to_i/3.14) < 60000
    end



    $secret_verifier = ActiveSupport::MessageVerifier.new("istar")
    
    # System.encode_secret #加密字符串
    def encode_secret(str="1") 
      signed_message = $secret_verifier.generate str
    end

    # System.decode_secret #解密字符串
    def decode_secret(str="1") 
      signed_message = $secret_verifier.verified str
    end


    def en64(str)
      Base64.urlsafe_encode64(str)
    end

    def de64(str)
      Base64.urlsafe_decode64(str)
    end
    
    # 解密密码
    #  base64 解密后 去除后 5位
    def decode_password(data)
      Base64.decode64(data)[0..-6]
    end

    # Base64.encode64('chenwei12345')[0..-6]
    def ip_to_i(ip)
      IPAddr.new(ip).to_i
    end

    def cached
        p Redis.current.set("aa","______-1111")
        p Redis.current.get("aa")
    end
    


    def uuid
      return SecureRandom.uuid.gsub('-', '')
      # SecureRandom.hex(12)
      # SecureRandom.urlsafe_base64
      # SecureRandom.base64(8)
    end

    def number(n)
      (1..n).collect {digit}.join
    end

    def digit
      (rand() * 9).round.to_s
    end

    def string(n)
      chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
      string = ""
      1.upto(n) { |i| string << chars[rand(chars.size-1)] }
      return string
    end

    # System.db_backup(file)  Mysql文件备份 
    def db_backup(file=Date.today.strftime('%Y%m%d'))
      config = Rails.configuration.database_configuration

      host = config[Rails.env]['host']
      database = config[Rails.env]['database']
      username = config[Rails.env]['username']
      password = config[Rails.env]['password']

      export_sql_path = "#{Rails.root}/tmp/cache/"
      sql_file = "#{database}-#{file}.sql"
      export_sql_file = "#{export_sql_path}#{sql_file}"
      commands = "mysqldump -u#{username} -p#{password} #{database} > #{export_sql_file}"

      p "start export.. "
      system(commands)
      p "success export! "
      p export_sql_file
      p "star tar file ! "
      commands = "cd #{export_sql_path} && tar -zcvf #{sql_file}.tar.gz #{sql_file}"
      system(commands)
      p "star rm sql file ! "
      commands = "cd #{export_sql_path} && rm -rf #{sql_file}"
      system(commands)
      p "all success ! "

      return "#{export_sql_file}.tar.gz"
    end


    # System.auto_log_backup
    def auto_log_backup
      log_path = Rails.root.join("log")
      log_file = "development.log"
      new_log_file ="development_#{Date.today.strftime('%Y%m%d')}.log"
      cmd1 = "cd #{log_path} && mv #{log_file} #{new_log_file}"
      cmd2 = "cd #{log_path} && tar -zcvf  #{new_log_file}.tar.gz  #{new_log_file} && rm #{new_log_file}"
      # p (cmd1)
      # p (cmd2)
      system(cmd1)
      system(cmd2)
    end

    # System.auto_backup_mysql_and_mail   # 自动备份数据库并邮件通知 
    def auto_backup_mysql_and_mail
      file = System.db_backup
      p file
      Log.create(
        user_id: 1,
        event: "自动备份数据",
        describe: file,
        category: 110,
        result: 1,
        ip: "0.0.0.0",
      )
      SendMailer.backup_file(Setting.backup_mails, file).deliver
    end

    def restart
      app_path = Rails.root.join('bin', 'rails')
      system("#{app_path} restart")
    end
    
    

    TIME_FRACTIONS = [:seconds, :minutes, :hours, :days, :weeks, :months, :years]

  # @return [String] the humanized elapsed time in pairs
  #   Always returns a pair of words like:
  #     '23 days and 3 hours'
  #     '5 hours and 44 minutes'
  #     ' 1 minute and 11 seconds'
  #
  #   Or just 1 when no hours/minutes/seconds available:
  #     '23 days'
  #     '17 hours'
  #     '1 minute'
  #     '1 second'
  #
  #   Ẃhen 0 seconds or Time instance is a future date, returns empty string:
  #     ""
  #
  # @note Inspired from http://stackoverflow.com/a/4136485/511069
  # System.ago_in_words(Date.today)
  def ago_in_words(date, is_secs=false)

    # p date
    # p date
    # p date
    # p date
    # p date
    # p date
    if is_secs == true
      secs = date.to_i
    else
      return '很久以前' if date.year < 1800
      secs = Time.now - date
    end
    if  secs <= -1
      res = ''
    elsif secs > -1 && secs < 1
      res = '刚刚'
    elsif secs < 1.minute
      res = "#{secs.to_i} 秒"
    elsif  secs < 7.days #小于 7天
      pair = ago_in_words_pair(secs)
      ary = ago_in_words_singularize(pair)
      res = ary.size == 0 ? '' : ary.join(' ')
    else  #大于 7天
      pair = ago_in_words_pair(secs)
      pair_days = pair[0].split(" ")[0].to_i
      # p pair
      # p pair_days
      if  secs < 28.days #周
        pair_days = pair_days.divmod(7)
        pair = ["#{pair_days[0]} 周", "#{pair_days[1]} 天"]
      elsif secs < 365.days #月
        pair_days = pair_days.divmod(30)
        pair = ["#{pair_days[0]} 月", "#{pair_days[1]} 天"]
      else #年
        pair_days = pair_days.divmod(365)
        pair = ["#{pair_days[0]} 年", "#{pair_days[1]} 天"]
      end
      ary = ago_in_words_singularize(pair)
      res = ary.size == 0 ? '' : ary.join(' ')
    end
    return res
  end

  def day_num(tm)
    time = tm.strftime("%Y-%m-%d")
    ( Date.today -  Date.parse(time)).to_i
  end
  



  def get(url,  options = {})
    uri = URI.parse(url)
    result Net::HTTP.get(uri, options)
  end

  # def post(url, api, options = {})
  #   url = URI.join(url, api)
  #   res = Net::HTTP.post_form(url, options)
  #   result res.body
  # end

  # def put(url, api, options = {})
  #   url = URI.join(url, api)
  #   http = Net::HTTP.new(url.host, url.port)
  #   request = Net::HTTP::Put.new(url)
  #   request.set_form_data(options)
  #   res = http.request(request)
  #   result res.body
  # end

  # def delete(url, api, options = {})
  #   url = URI.join(url, api)
  #   http = Net::HTTP.new(url.host, url.port)
  #   req = Net::HTTP::Delete.new(url)

  #   res = http.request(req)
  #   result res.body
  # end

  def result(body)
    begin
     result =  ActiveSupport::JSON.decode body
    rescue => e
      {
        code: 502,
        msg: '内容解析错误',
        detail: e.to_s
      }
    end
  end



  def post_ssl(url, data = {})
    uri = URI.parse(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(url, {'Content-Type' => 'application/json'})
    request.body = data.to_json
    response = http.request(request)
    result response.body
  end

  # System.send_image_file(path, key)
  def send_image_file(path, key)
    file_abbr = path.split(".")[-1]
    # base_head = "data:image/#{file_abbr};base64,"

    bytes = File.read(path)

    base64   = Base64.strict_encode64(bytes)
    md5 = Digest::MD5.hexdigest(bytes) 
    
    data = {
        "msgtype": "image",
        "image": {
            "base64": base64,
            "md5": md5
        }
    }


    url = "https://qyapi.weixin.qq.com/cgi-bin/webhook/send?debug=1&key="+key
    res = System.post_ssl(url, data)
    
  end
  
  # System.send_wx_notify()
  def send_wx_notify(content="",users="",key=Setting.wx_webhook_key)
    data = {
      "msgtype": "markdown",
      "markdown": {
          "content": content,
          # "mentioned_list": users
      }
    }
    p data
    url = "https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key="+key
    res = System.post_ssl(url, data)
    # p res
  end

  # 单独发送@信息
  # System.send_wx_notify_at(" ", "chenwei")
  # 
  def send_wx_notify_at(content=" ",users="",key=Setting.wx_webhook_key)
    data = {
    "msgtype": "text",
        "text": {
            "content": content,
            "mentioned_list":  users,
        }
    }

    p data
    url = "https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key="+key
    res = System.post_ssl(url, data)

    
  end

  def test_btn_msg_send
    data = {
      "toparty": "",
      "totag": "",
      "msgtype": "template_card",
      "template_card": {
          "card_type": "button_interaction",
          "source": {
              "icon_url": "图片的url",
              "desc": "企业微信",
              "desc_color": 1
          },
          "action_menu": {
              "desc": "卡片副交互辅助文本说明",
              "action_list": [
                  {"text": "接受推送", "key": "A"},
                  {"text": "不再推送", "key": "B"}
              ]
          },
          "main_title": {
              "title": "欢迎使用企业微信",
              "desc": "您的好友正在邀请您加入企业微信"
          },
          # "quote_area": {
          #     "type": 1,
          #     "url": "https://work.weixin.qq.com",
          #     "title": "企业微信的引用样式",
          #     "quote_text": "企业微信真好用呀真好用"
          # },
          "sub_title_text": "下载企业微信还能抢红包！",
          "horizontal_content_list": [
              {
                  "keyname": "邀请人",
                  "value": "张三"
              },
              {
                  "type": 1,
                  "keyname": "企业微信官网",
                  "value": "点击访问",
                  "url": "https://work.weixin.qq.com"
              },
              {
                  "type": 3,
                  "keyname": "员工信息",
                  "value": "点击查看",
                  "userid": "Chenwei"
              }
          ],
          "card_action": {
              "type": 2,
              "url": "https://work.weixin.qq.com",
              "appid": "wxfaf9060b99db8de5",
              "pagepath": "/index.html"
          },
          "task_id": "11",
          # "button_selection": {
          #     "question_key": "btn_question_key1",
          #     "title": "企业微信评分",
          #     "option_list": [
          #         {
          #             "id": "btn_selection_id1",
          #             "text": "100分"
          #         },
          #         {
          #             "id": "btn_selection_id2",
          #             "text": "101分"
          #         }
          #     ],
          #     "selected_id": "btn_selection_id1"
          # },
          "button_list": [
              {
                  "text": "拒绝",
                  "style": 3,
                  "key": "button_key_1"
              },
              {
                  "text": "同意",
                  "style": 1,
                  "key": "button_key_2"
              }
          ]
      },
      "enable_id_trans": 0,
      "enable_duplicate_check": 0,
      "duplicate_check_interval": 1800
    }

    #     data = {
    #   "touser": "zhangsan|lisi",
    #   #  "toparty": "1|2",
    #   #  "totag": "1|2",
    #   "msgtype": "miniprogram_notice",
    #   "miniprogram_notice": {
    #         "appid": "wxfaf9060b99db8de5",
    #         "page": "pages/index?userid=zhangsan&orderid=123123123",
    #         "title": "会议室预订成功通知",
    #         "description": "4月27日 16:16",
    #         "emphasis_first_item": true,
    #         "content_item": [
    #             {
    #                 "key": "会议室",
    #                 "value": "402"
    #             },
    #             {
    #                 "key": "会议地点",
    #                 "value": "广州TIT-402会议室"
    #             },
    #             {
    #                 "key": "会议时间",
    #                 "value": "2018年8月1日 09:00-09:30"
    #             },
    #             {
    #                 "key": "参与人员",
    #                 "value": "周剑轩"
    #             }
    #         ]
    #     },
    #   "enable_id_trans": 0,
    #   "enable_duplicate_check": 0,
    #   "duplicate_check_interval": 1800
    # }
    user_ids = "ChenWei"
    department_ids = ""
    Weapi.new.message_send(user_ids, department_ids, data, 'ilocate')
    # Weapi.new.oa_text_message_send("Chenwei", "", "data", 'oa_file')
    
  end

  # System.send_card_msg(title, data, user, url)
  # title, data, user, url, image
  def send_card_msg(title, data, user, url, image,key=Setting.wx_webhook_key)
    data =  {
      "msgtype":"template_card",
      "template_card":{
          "card_type":"news_notice",
          "source":{
              "icon_url":"https://gdadmin.cn/assets/avatar-557d981af7318cd245244199f2ab2a0e78edab10fc252d6efe461f524bc8d335.png",
              "desc":"文件审批",
              "desc_color":0
          },
          "main_title":{
              "title": "#{title}",
          },
          "vertical_content_list":[
              {
                "title":"详情",
                "desc": "#{data}"
              }
          ],
          "horizontal_content_list":[
            {
                "keyname": "提交人",
                "value": "#{user}"
              },
              {
                "keyname": "详情",
                "value": "点击访问",
                "type":1,
                "url": "#{url}",
              }
          ],
          "card_image":{
              "url":"#{image}",
              "aspect_ratio":2.25
          },
          "card_action":{
              "type":1,
              "url":"#{url}",
          }
      }
    }
    url = "https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key="+key
    res = System.post_ssl(url, data)
  end
  

  # 创建 webDAV 目录
  # System.dav_mkdir("9999")
  # 
  def dav_mkdir(folder="9999")
    unless System.dav_folder_exists(Setting.dav_project_root)
      $dav.mkdir("#{Setting.dav_host}#{Setting.dav_project_root}")
    end
    folders  =folder.split("/")
    m = []
    folders.each do |single|
      m << single
      current_path = m.join("/")
      current_path_url = m.map{|e| CGI.escape(e)}.join("/")
      unless System.dav_folder_exists(current_path_url)
        $dav.mkdir("#{Setting.dav_host}#{current_path_url}")
      end
    end 

    # p folder = folder.split("/").map{|e| CGI.escape(e)}.join("/")
    # # folder = CGI.escape(folder)
    # p folder


    # folder_name = "#{Setting.dav_project_root}#{folder}"

    # # folder_name = URI.escape folder_name
    # url = "#{Setting.dav_host}#{folder_name}/"
    # p url
    # # URI.escape(url)

    # res = $dav.mkdir(url)
    return System.dav_folder_exists(folder)
  end

  def dav_folder_exists(folder = "/9999")


    # folder.each do |single|
    #   m << single
    #   p m
    #   current_path = m.join("/")
    #   current_path_url = m.map{|e| CGI.escape(e)}.join("/")
    #     p current_path_url

    #   unless System.dav_folder_exists(current_path_url)
    #     $dav.mkdir("#{Setting.dav_host}#{current_path_url}")
    #   end
    # end

    new_folder = folder.split("/").map{|e| CGI.escape(e)}.join("/")
    p new_folder

    $dav.exists?("#{Setting.dav_host}#{new_folder}")
  end

  # 创建 webDAV 目录
  # System.dav_upload_file(path, file, is_project=true)
  def dav_upload_file(path, file="/home/chenwei/icontract/Gemfile.lock", is_project=true)
    if path.include?('.')
      path = path.split('/')[0..-1].join('/')
    end

    path = "#{Setting.dav_project_root}#{path}" if is_project
    file_name = file.split("/").last
    file_name = CGI.escape(file_name)

    url = "#{Setting.dav_host}#{path}/#{file_name}"
    url = "#{Setting.dav_host}#{path}" if path.include?('.')

    File.open(file, "r") do |stream|
      $dav.put(url, stream, File.size(file))
    end
  end
  
  def dav_test_2
    # dav = Net::DAV.new(Setting.dav_host,:curl => false)
    # dav.verify_server = false
    # dav.credentials(Setting.dav_username,Setting.dav_password)
    $dav.mkdir("#{Setting.dav_host}/#{folder}/")
  end

  def dav_post_requrest(url)
    url = URI(url)
    http = Net::HTTP.new(url.host, url.port)
    request = Net::HTTP::Post.new(url)
    username = Setting.dav_username
    password = Setting.dav_password
    credentials = "#{username}:#{password}"
    encrypted_data = Base64.encode64(credentials).chomp 
      
    request["content-type"] = 'application/xml'
    request["Authorization"] = "Basic #{encrypted_data}"
    return http, request
  end
  

  # 共享文件
  # System.dav_share_file
  def dav_share_file(folder = "/projects/9999",email='')
    url = "http://dav.jianguoyun.com/nsdav/pubObject" 
    http, request = dav_post_requrest(url)

    if email.present?
      body = "<?xml version='1.0' encoding='utf-8'?><s:publish xmlns:s='http://ns.jianguoyun.com'><s:href>/dav#{folder}</s:href><s:acl><s:username>#{email}</s:username></s:acl><s:downloadDisabled>false</s:downloadDisabled></s:publish>"
    else
      body = "<?xml version='1.0' encoding='utf-8'?><s:publish xmlns:s='http://ns.jianguoyun.com'><s:href>/dav#{folder}</s:href><s:acl><s:group>0</s:group></s:acl><s:downloadDisabled>false</s:downloadDisabled></s:publish>"
    end

    p body
    request.body = body
    response = http.request(request)
    result =  response.read_body
    p result

    xml = Nokogiri::XML(result)
    # 使用XPath查找元素
    link = xml.children[0].children[0].children[0].text rescue ''
  end

  # 复制共享文件
  # System.dav_get_share_info
  def dav_get_share_info(share_url='https://www.jianguoyun.com/p/DVqrAMwQ9sqGDBjkqqgFIAA',share_password="")

    url = "http://dav.jianguoyun.com/nsdav/getPubObjectInfo" 
    # url = "https://www.jianguoyun.com/p/DbBIJMgQ9sqGDBj2rKgFIAA"
    http, request = dav_post_requrest(url)
    p share_url
    if share_password.present?
      body = "<?xml version='1.0' encoding='utf-8'?><s:pub_object xmlns:s='http://ns.jianguoyun.com'><s:href>#{share_url}</s:href><s:relative_path></s:relative_path><s:password>#{share_password}</s:password></s:pub_object>"
    else
      body = "<?xml version='1.0' encoding='utf-8'?><s:pub_object xmlns:s='http://ns.jianguoyun.com'><s:href>#{share_url}</s:href><s:relative_path></s:relative_path></s:pub_object>"
    end
    p body
    request.body = body
    response = http.request(request)
    result =  response.read_body
    p result

    xml = Nokogiri::XML(result)
    p xml
    # 使用XPath查找元素
    p link = xml.children[1] rescue ''
    p isDir = xml.children[0].children[0].text rescue ''
    p size = xml.children[0].children[1].text rescue ''
    p user = xml.children[0].children[2].text rescue ''
    p name = xml.children[0].children[3].text rescue ''
    [isDir, name]
    
  end
  

  # 复制共享文件
  # System.dav_copy_share_file
  # 目录: share_url = "https://www.jianguoyun.com/p/DbBIJMgQ9sqGDBj2rKgFIAA"
  # 单个文件复制： https://www.jianguoyun.com/p/DfLNjuIQ08GGDBiYw6oFIAA
  def dav_copy_share_file(folder = "/projects/9999/",share_url='https://www.jianguoyun.com/p/DbBIJMgQ9sqGDBj2rKgFIAA', share_password='')
    sub_file = ""
    # 1先判定文件类型，文件夹直接复制，文件需要修改名称
    result = System.dav_get_share_info(share_url)
    if result[0] == "true" #文件夹
      sub_file = result[1]
      folder = folder +sub_file
    else
      sub_file = result[1]
      folder = folder +sub_file
    end
    
    url = "http://dav.jianguoyun.com/nsdav/submitCopyPubObject" 
    http, request = dav_post_requrest(url)
    p folder
    if share_password.present?
      body = "<?xml version='1.0' encoding='utf-8'?><s:copy_pub xmlns:s='http://ns.jianguoyun.com'><s:href>/dav#{folder}/</s:href><s:published_object_url>#{share_url}</s:published_object_url><s:copy_password>#{share_password}</s:copy_password></s:copy_pub>"
    else
      body = "<?xml version='1.0' encoding='utf-8'?><s:copy_pub xmlns:s='http://ns.jianguoyun.com'><s:href>/dav#{folder}/</s:href><s:published_object_url>#{share_url}</s:published_object_url></s:copy_pub>"
    end
    p body
    request.body = body
    response = http.request(request)
    result =  response.read_body
    p result

    xml = Nokogiri::XML(result)
    p xml
    # 使用XPath查找元素
    p link = xml.children[0].children[0].text rescue ''
  end

  # 复制共享文件
  # System.dav_poll_copy_share_status(uuid)
  def dav_poll_copy_share_status(uuid="e5fXHr2fSF2sYhq2TOzeiA")

    url = "http://dav.jianguoyun.com/nsdav/pollCopyPubObject" 
    http, request = dav_post_requrest(url)

    # url = URI("http://dav.jianguoyun.com/nsdav/pollCopyPubObject")

    # http = Net::HTTP.new(url.host, url.port)
    # request = Net::HTTP::Post.new(url)
    # username = Setting.dav_username
    # password = Setting.dav_password
    # credentials = "#{username}:#{password}"
    # encrypted_data = Base64.encode64(credentials).chomp 
      
    # request["content-type"] = 'application/xml'
    # request["Authorization"] = "Basic #{encrypted_data}"

    body = "<?xml version='1.0' encoding='utf-8'?><s:copy_pub xmlns:s='http://ns.jianguoyun.com'><s:copy_uuid>#{uuid}</s:copy_uuid></s:copy_pub>"
    p body
    request.body = body
    response = http.request(request)
    result =  response.read_body
    p result
  end

  # pollCopyPubObject

  # 获取权限
  # System.dav_get_acl
  def dav_get_acl(folder = "/9999")
    url = "http://dav.jianguoyun.com/nsdav/getSandboxAcl" 
    http, request = dav_post_requrest(url)

    # url = URI("http://dav.jianguoyun.com/nsdav/getSandboxAcl")

    # http = Net::HTTP.new(url.host, url.port)
    # request = Net::HTTP::Post.new(url)
    # username = Setting.dav_username
    # password = Setting.dav_password
    # credentials = "#{username}:#{password}"
    # encrypted_data = Base64.encode64(credentials).chomp 
      
    # request["content-type"] = 'application/xml'
    # request["Authorization"] = "Basic #{encrypted_data}"

    request.body = "<?xml version=\"1.0\" encoding=\"utf-8\"?><s:get_acl xmlns:s=\"http://ns.jianguoyun.com\"><s:href>#{folder}</s:href></s:get_acl>"

    response = http.request(request)
    puts response.read_body
  end

  # 更新权限
  # System.dav_update_acl
  def dav_update_acl(folder = "/dav/9999",infos=[['cxhyun@126.com',1]])
    p ">>>dav_update_acl"

    url = "http://dav.jianguoyun.com/nsdav/getSandboxAcl" 
    http, request = dav_post_requrest(url)

    # url = URI("http://dav.jianguoyun.com/nsdav/updateSandboxAcl")
    # http = Net::HTTP.new(url.host, url.port)
    # request = Net::HTTP::Post.new(url)
    # username = Setting.dav_username
    # password = Setting.dav_password
    # credentials = "#{username}:#{password}"
    # encrypted_data = Base64.encode64(credentials).chomp 
    # request["content-type"] = 'application/xml'
    # request["Authorization"] = "Basic #{encrypted_data}"

    m_acl = ''
    infos.each do |single|
      p single
    m_acl = m_acl+ "<s:acl><s:username>#{single[0]}</s:username><s:perm>#{single[1]}</s:perm></s:acl>"
    end
    p m_acl
    
    body = "<?xml version='1.0' encoding='utf-8'?><s:sandbox xmlns:s='http://ns.jianguoyun.com'><s:href>/dav#{folder}</s:href>#{m_acl}</s:sandbox>"

    p body

    request.body = body
    response = http.request(request)
    puts response.read_body
  end


    def check_path_exist?(path)
      unless File.directory? path
        FileUtils.mkdir_p(path)
      end
    end

    # 压缩文件
    # System.zip_file(file_to_zip, output_file_name)
    def zip_file(file_to_zip, output_file_name)
      check_path_exist?(File.dirname(output_file_name))
      ::Zip::File.open(output_file_name, ::Zip::File::CREATE)  do |zip_file|
        if file_to_zip.class ==String
          file_name = file_to_zip.split("/").last
          zip_file.remove(file_name) rescue ''
          zip_file.add(file_name, file_to_zip)  rescue ''

          zip_file.close
        elsif file_to_zip.class == Array
          file_to_zip.each do |file|
            file_name = file.split("/").last
            zip_file.remove(file_name) rescue ''
            zip_file.add(file_name, file)  rescue ''

          end
          zip_file.close
        end
      end
    end

  
  # System.list_folder_file(folder)
  def list_folder_file(folder,folder_name='1')
    arr = []
    abs_url = "#{Setting.host}/#{folder_name}/"
    Dir.foreach(folder) do |file|
        if file != "." and file != ".." and file != ".DS_Store"
            file_info = {
                "id":(file.split(".")[0].split("_")[1] rescue 0),
                "src": abs_url + file,
            }
            arr << file_info
        end
    end
    return arr
  end

  # System.list_folder_and_file(folder)
  def list_folder_and_file(folder)
    # p File.dirname(folder)
    arr = []
    Dir.foreach(folder) do |file|
        if file != "." and file != ".." and file != ".DS_Store"
            current_file = "#{folder}/#{file}"
            modify_time = File.mtime(current_file).strftime("%Y-%m-%d %H:%M:%S") rescue '-'
            if File.directory?(current_file)
                # p ">" + file
                # p @file_list
                # @file_list = []
                file_ext = file_size = "-"
                file_icon = "folder"
            else
                # p "." + file
                # @file_list.push(file)
                file_size = File.size(current_file) rescue 0
                file_icon = "file"
                file_ext = System.code_file_ext(file)
            end 

            file_info = {
                "id":(file.split(".")[0].split("_")[1] rescue 0),
                "src":file,
                "name":file,
                "file_ext":file_ext,
                "modify_time": modify_time,
                "file_size":ActiveSupport::NumberHelper.number_to_human_size(file_size),
                "icon": file_icon
            }
            arr << file_info
        end
    end
    return arr
  end

  # 代码文件拓展名
  # System.code_file_ext()
  def code_file_ext(ext='.rb')
    ext_name = ext.split(".").last rescue ''
    res = 'text'
    code_language_info.each do |single|
      if single[:extensions].include?(".#{ext_name}")
        res = single[:id]
        break
      end
    end
    res
  end
  
  # 代码编程语言后缀信息
  def code_language_info 
    [{id:"abap",extensions:[".abap"],aliases:["abap","ABAP"]},{id:"apex",extensions:[".cls"],aliases:["Apex","apex"],mimetypes:["text/x-apex-source","text/x-apex"]},{id:"azcli",extensions:[".azcli"],aliases:["Azure CLI","azcli"]},{id:"bat",extensions:[".bat",".cmd"],aliases:["Batch","bat"]},{id:"bicep",extensions:[".bicep"],aliases:["Bicep"]},{id:"cameligo",extensions:[".mligo"],aliases:["Cameligo"]},{id:"clojure",extensions:[".clj",".cljs",".cljc",".edn"],aliases:["clojure","Clojure"]},{id:"coffeescript",extensions:[".coffee"],aliases:["CoffeeScript","coffeescript","coffee"],mimetypes:["text/x-coffeescript","text/coffeescript"]},{id:"c",extensions:[".c",".h"],aliases:["C","c"]},{id:"cpp",extensions:[".cpp",".cc",".cxx",".hpp",".hh",".hxx"],aliases:["C++","Cpp","cpp"]},{id:"csharp",extensions:[".cs",".csx",".cake"],aliases:["C#","csharp"]},{id:"csp",extensions:[],aliases:["CSP","csp"]},{id:"css",extensions:[".css"],aliases:["CSS","css"],mimetypes:["text/css"]},{id:"cypher",extensions:[".cypher",".cyp"],aliases:["Cypher","OpenCypher"]},{id:"dart",extensions:[".dart"],aliases:["Dart","dart"],mimetypes:["text/x-dart-source","text/x-dart"]},{id:"dockerfile",extensions:[".dockerfile"],filenames:["Dockerfile"],aliases:["Dockerfile"]},{id:"ecl",extensions:[".ecl"],aliases:["ECL","Ecl","ecl"]},{id:"elixir",extensions:[".ex",".exs"],aliases:["Elixir","elixir","ex"]},{id:"flow9",extensions:[".flow"],aliases:["Flow9","Flow","flow9","flow"]},{id:"fsharp",extensions:[".fs",".fsi",".ml",".mli",".fsx",".fsscript"],aliases:["F#","FSharp","fsharp"]},{id:"freemarker2",extensions:[".ftl",".ftlh",".ftlx"],aliases:["FreeMarker2","Apache FreeMarker2"]},{id:"go",extensions:[".go"],aliases:["Go"]},{id:"graphql",extensions:[".graphql",".gql"],aliases:["GraphQL","graphql","gql"],mimetypes:["application/graphql"]},{id:"handlebars",extensions:[".handlebars",".hbs"],aliases:["Handlebars","handlebars","hbs"],mimetypes:["text/x-handlebars-template"]},{id:"hcl",extensions:[".tf",".tfvars",".hcl"],aliases:["Terraform","tf","HCL","hcl"]},{id:"html",extensions:[".html",".htm",".shtml",".xhtml",".mdoc",".jsp",".asp",".aspx",".jshtm"],aliases:["HTML","htm","html","xhtml"],mimetypes:["text/html","text/x-jshtm","text/template","text/ng-template"]},{id:"ini",extensions:[".ini",".properties",".gitconfig"],filenames:["config",".gitattributes",".gitconfig",".editorconfig"],aliases:["Ini","ini"]},{id:"java",extensions:[".java",".jav"],aliases:["Java","java"],mimetypes:["text/x-java-source","text/x-java"]},{id:"javascript",extensions:[".js",".es6",".jsx",".mjs",".cjs"],aliases:["JavaScript","javascript","js"],mimetypes:["text/javascript"]},{id:"json",extensions:[".json"],aliases:["Json","json"]},{id:"julia",extensions:[".jl"],aliases:["julia","Julia"]},{id:"kotlin",extensions:[".kt"],aliases:["Kotlin","kotlin"],mimetypes:["text/x-kotlin-source","text/x-kotlin"]},{id:"less",extensions:[".less"],aliases:["Less","less"],mimetypes:["text/x-less","text/less"]},{id:"lexon",extensions:[".lex"],aliases:["Lexon"]},{id:"lua",extensions:[".lua"],aliases:["Lua","lua"]},{id:"liquid",extensions:[".liquid",".html.liquid"],aliases:["Liquid","liquid"],mimetypes:["application/liquid"]},{id:"m3",extensions:[".m3",".i3",".mg",".ig"],aliases:["Modula-3","Modula3","modula3","m3"]},{id:"markdown",extensions:[".md",".markdown",".mdown",".mkdn",".mkd",".mdwn",".mdtxt",".mdtext"],aliases:["Markdown","markdown"]},{id:"mips",extensions:[".s"],aliases:["MIPS","MIPS-V"],mimetypes:["text/x-mips","text/mips","text/plaintext"]},{id:"msdax",extensions:[".dax",".msdax"],aliases:["DAX","MSDAX"]},{id:"mysql",extensions:[],aliases:["MySQL","mysql"]},{id:"objective-c",extensions:[".m"],aliases:["Objective-C"]},{id:"pascal",extensions:[".pas",".p",".pp"],aliases:["Pascal","pas"],mimetypes:["text/x-pascal-source","text/x-pascal"]},{id:"pascaligo",extensions:[".ligo"],aliases:["Pascaligo","ligo"]},{id:"perl",extensions:[".pl"],aliases:["Perl","pl"]},{id:"pgsql",extensions:[],aliases:["PostgreSQL","postgres","pg","postgre"]},{id:"php",extensions:[".php",".php4",".php5",".phtml",".ctp"],aliases:["PHP","php"],mimetypes:["application/x-php"]},{id:"pla",extensions:[".pla"]},{id:"postiats",extensions:[".dats",".sats",".hats"],aliases:["ATS","ATS/Postiats"]},{id:"powerquery",extensions:[".pq",".pqm"],aliases:["PQ","M","Power Query","Power Query M"]},{id:"powershell",extensions:[".ps1",".psm1",".psd1"],aliases:["PowerShell","powershell","ps","ps1"]},{id:"proto",extensions:[".proto"],aliases:["protobuf","Protocol Buffers"]},{id:"pug",extensions:[".jade",".pug"],aliases:["Pug","Jade","jade"]},{id:"python",extensions:[".py",".rpy",".pyw",".cpy",".gyp",".gypi"],aliases:["Python","py"]},{id:"qsharp",extensions:[".qs"],aliases:["Q#","qsharp"]},{id:"r",extensions:[".r",".rhistory",".rmd",".rprofile",".rt"],aliases:["R","r"]},{id:"razor",extensions:[".cshtml"],aliases:["Razor","razor"],mimetypes:["text/x-cshtml"]},{id:"redis",extensions:[".redis"],aliases:["redis"]},{id:"redshift",extensions:[],aliases:["Redshift","redshift"]},{id:"restructuredtext",extensions:[".rst"],aliases:["reStructuredText","restructuredtext"]},{id:"ruby",extensions:[".rb",".rbx",".rjs",".gemspec",".pp",".erb"],filenames:["rakefile","Gemfile"],aliases:["Ruby","rb"]},{id:"rust",extensions:[".rs",".rlib"],aliases:["Rust","rust"]},{id:"sb",extensions:[".sb"],aliases:["Small Basic","sb"]},{id:"scala",extensions:[".scala",".sc",".sbt"],aliases:["Scala","scala","SBT","Sbt","sbt","Dotty","dotty"],mimetypes:["text/x-scala-source","text/x-scala","text/x-sbt","text/x-dotty"]},{id:"scheme",extensions:[".scm",".ss",".sch",".rkt"],aliases:["scheme","Scheme"]},{id:"scss",extensions:[".scss"],aliases:["Sass","sass","scss"],mimetypes:["text/x-scss","text/scss"]},{id:"shell",extensions:[".sh",".bash"],aliases:["Shell","sh"]},{id:"sol",extensions:[".sol"],aliases:["sol","solidity","Solidity"]},{id:"aes",extensions:[".aes"],aliases:["aes","sophia","Sophia"]},{id:"sparql",extensions:[".rq"],aliases:["sparql","SPARQL"]},{id:"sql",extensions:[".sql"],aliases:["SQL"]},{id:"st",extensions:[".st",".iecst",".iecplc",".lc3lib"],aliases:["StructuredText","scl","stl"]},{id:"swift",aliases:["Swift","swift"],extensions:[".swift"],mimetypes:["text/swift"]},{id:"systemverilog",extensions:[".sv",".svh"],aliases:["SV","sv","SystemVerilog","systemverilog"]},{id:"verilog",extensions:[".v",".vh"],aliases:["V","v","Verilog","verilog"]},{id:"tcl",extensions:[".tcl"],aliases:["tcl","Tcl","tcltk","TclTk","tcl/tk","Tcl/Tk"]},{id:"twig",extensions:[".twig"],aliases:["Twig","twig"],mimetypes:["text/x-twig"]},{id:"typescript",extensions:[".ts",".tsx"],aliases:["TypeScript","ts","typescript"],mimetypes:["text/typescript"]},{id:"vb",extensions:[".vb"],aliases:["Visual Basic","vb"]},{id:"xml",extensions:[".xml",".dtd",".ascx",".csproj",".config",".wxi",".wxl",".wxs",".xaml",".svg",".svgz",".opf",".xsl"], aliases:["XML","xml"],mimetypes:["text/xml","application/xml","application/xaml+xml","application/xml-dtd"]},{id:"yaml",extensions:[".yaml",".yml"],aliases:["YAML","yaml","YML","yml"],mimetypes:["application/x-yaml","text/x-yaml"]},{id:"image",extensions:['.png', '.jpg', '.jpeg', '.bmp', '.gif']},{id:"txt",extensions:['.txt']},{id:"excel",extensions:['.xls','.xlsx']},{id:"word",extensions:['.doc','.docx']},{id:"pdf",extensions:['.pdf']},{id:"ppt",extensions:['.ppt','.pptx']},{id:"zip",extensions:['.rar','.zip','.7z','.tar','.gz']},{id:"video",extensions:['.mp4', '.m2v', '.mkv', '.rmvb', '.wmv', '.avi', '.flv', '.mov', '.m4v']},{id:"video",extensions:['.mp3', '.wav', '.wmv', '.flac', '.ape']}]
  end
  # @private
  def ago_in_words_pair(secs)
    [[60, :秒], [60, :分钟], [24, :小时], [1.days.to_i, :天], [1.week.to_i, :周], [1.month.to_i, :月], [1.year.to_i, :年]].map{ |count, name|
      if secs > 0
        secs, n = secs.divmod(count)
        "#{n.to_i} #{name}"
      end
    }.compact.reverse[0..1]
  end

  # @private
  def ago_in_words_singularize(pair)
    # p pair
    if pair.size == 1
      pair.map! {|part| part[0, 2].to_i == 1 ? part.chomp('s') : part }
    else
      pair.map! {|part| part[0, 2].to_i == 1 ? part.chomp('s') : part[0, 2].to_i == 0 ? nil : part }
    end
    pair.compact
  end
  end
end



# Usage:
#   directory_to_zip = "/tmp/input"
#   output_file = "/tmp/out.zip"
#   zf = ZipFileGenerator.new(directory_to_zip, output_file)
#   zf.write()
class ZipFileGenerator
    # Initialize with the directory to zip and the location of the output archive.
    def initialize(input_dir, output_file)
      @input_dir = input_dir
      @output_file = output_file
    end

    # Zip the input directory.
    def write
      entries = Dir.entries(@input_dir) - %w[. ..]

      ::Zip::File.open(@output_file, ::Zip::File::CREATE) do |zipfile|
        write_entries entries, '', zipfile
      end
    end

  private

  # A helper method to make the recursion work.
  def write_entries(entries, path, zipfile)
    entries.each do |e|
      zipfile_path = path == '' ? e : File.join(path, e)
      disk_file_path = File.join(@input_dir, zipfile_path)

      if File.directory? disk_file_path
        recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
      else
        put_into_archive(disk_file_path, zipfile, zipfile_path)
      end
    end
  end

  def recursively_deflate_directory(disk_file_path, zipfile, zipfile_path)
    zipfile.mkdir zipfile_path
    subdir = Dir.entries(disk_file_path) - %w[. ..]
    write_entries subdir, zipfile_path, zipfile
  end

  def put_into_archive(disk_file_path, zipfile, zipfile_path)
    zipfile.add(zipfile_path, disk_file_path)
  end
end
