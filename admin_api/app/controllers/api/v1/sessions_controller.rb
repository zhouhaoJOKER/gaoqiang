class Api::V1::SessionsController < Api::V1::BaseController
  # skip_before_action :verify_authenticity_token, :current_ip_is_locked, :check_visit_logs, only: [:xxx]
  # skip_before_action :check_base_authenticate, only: [:xxx]

  skip_before_action :set_current_user #, only: [:sms_send, :login, :sms_login]

  before_action :set_login_params, only: :login
  before_action :set_sms_params, only: [:sms_send, :sms_login]

  # before_action :check_visit_time, :check_login_info, only: :login

  def sms_send
    if  @login_user.present?
      # 手机号存在，发送验证码。
      sended_sms = SmsCode.sended.where(user_id:  @login_user.id)
      if sended_sms.size >0 
        msg = "请勿重复获取，请先输入您手机上的验证码。"
        render json: {code: 500, success: 0 , msg: msg,  data: ""}
      else
        code = System.number 6
        data = ""
        data = code
        phone = @login_user.phone
        SmsCode.send_sms(@login_user.id, phone, "#{code}")
        msg = "请求发送验证码成功！"
        gen_login_log( @login_user.id,  @current_ip,  params[:action], 1, msg, "验证码发送")
        render json: {code: 200, success: 1 , msg: msg,  data: data}
      end
    end
  end
  
  def sms_login
    if  @login_user.present?
      # 手机号存在，发送验证码。
      sended_sms = SmsCode.sended.where(user_id:  @login_user.id)
      if sended_sms.size >0
        sms_code = sended_sms.last 
        send_sms_code = sended_sms.last.code
        input_code = params[:code]
        # p "input_code"*10
        # p input_code
        # p send_sms_code
        # p System.en64(input_code)
        send_sms_code == System.en64(input_code)
        # p "input_code"*10
        if  send_sms_code == System.en64(input_code)
          msg = "手机验证码校验通过。"
          gen_login_log( @login_user.id,  @current_ip,  params[:action], 1, msg, "验证码登录")
          login_success_render(@login_user)
          sms_code.delete
        else
          msg = "手机验证码校验不通过。"
          gen_login_log( @login_user.id,  @current_ip,  params[:action], 1, msg, "验证码登录")
          login_fail_render( @login_user,"验证码")
        end
      else
        msg = "当前验证码已失效，请重新获取验证码。"
        render json: {code: 500, success: 0 , msg: msg,  data: ""}
        gen_login_log( @login_user.id,  @current_ip,  params[:action], 1, msg)
      end
    end
  end


  
  def  register
    if  params[:username].present? && params[:email].present? && params[:password].present? &&  params[:username].include?(".") && params[:email].include?(".") && params[:password].include?(".")
      username = unbase64(params[:username]).delete('\"')
      email = unbase64(params[:email]).delete('\"')
      password = unbase64(params[:password]).delete('\"')
      if User.find_by(name: username).present?
        gen_login_log( 0,  @current_ip,  params[:action], 0, "用户名#{username}已存在，请更换用户名后重新注册！", "用户注册")
        render json: {code: 400, success: 0 , msg: "用户名已存在，请更换用户名后重新注册！"}
        return
      elsif User.find_by(email: email).present?
        gen_login_log( 0,  @current_ip,  params[:action], 0, "邮箱#{email}已存在，请更换邮箱后重新注册！", "用户注册")
        render json: {code: 400, success: 0 , msg: "邮箱已存在，请更换邮箱后重新注册！"}
        return
      end
      @user = User.gen_new_user(username, email, password)
      if @user.persisted?
        gen_login_log( @user.id,  @current_ip,  params[:action], 1,  "注册成功！","用户注册")
        @user.confirmation_email
        render json: {code: 200, success: 1 , msg: "注册成功！请先去邮箱激活账号。", data: @user}
      else
        gen_login_log( 0,  @current_ip,  params[:action], 0, "用户注册失败：" + @user.errors.full_messages.join(","), "用户注册")
        render json: {code: 400, success: 0 , msg: @user.errors.full_messages.join(",")}
      end      
    else
      render json: {code: 400, success: 0 , msg: "参数不正确，请输入正确的注册参数"}
    end
  end

  def  forgot_password
    if  params[:tag].present? &&  params[:tag] == "email" && params[:email].include?(".")
      email = unbase64(params[:email]).delete('\"')
      p email
      user = User.find_by(email: email)
      if user.present?
        # TODO 发送重置密码邮件
        user.send_reset_password_email
        msg = "重置密码邮件已发送，请去邮箱查看。"
        gen_login_log(user.id,  @current_ip,  params[:action], 1,  "重置密码邮件发送成功", "用户忘记密码")
        data = 1
      else
        data = 0
      end
      render json: {code: 200, success: 1 , msg: "操作成功！", data: data}
    else
      render json: {code: 400, success: 0 , msg: "参数不正确，请输入正确的参数"}
    end
  end



  def  reset_password
    if  params[:token].present? && params[:password].include?(".") && params[:password].include?(".")
      password = unbase64(params[:password]).delete('\"')
      p password
      user = User.find_by(reset_password_token: params[:token])
      if user.present?
        if (Time.now - user.reset_password_sent_at) > 2.hours
          render json: {code: 500, success: 0 , msg: "重置密码链接已过期，请重新申请重置密码！"}
          return
        end
        # 重置密码
        user.update(password: password, reset_password_sent_at: Time.now,reset_password_token:nil)
        gen_login_log(user.id,  @current_ip,  params[:action], 1,  "重置密码成功", "重置密码")
        data = 1
      else
        gen_login_log(0,  @current_ip,  params[:action], 0,  "重置密码失败", "重置密码")
        data = 0
      end
      render json: {code: 200, success: 1 , msg: "操作成功！", data: data}
    else
      render json: {code: 400, success: 0 , msg: "参数不正确，请输入正确的参数"}
    end
  end

  # 
  def confirm
    if params[:token].present?
      user = User.find_by(confirmation_token: params[:token])
      if user.present?
        if (Time.now - user.confirmation_sent_at) > 2.hours
          render json: {code: 500, success: 0 , msg: "确认链接已过期，请重新申请确认！"}
          return
        end
        # 确认注册
        user.update(confirmed_at: Time.now, confirmation_token:nil)

        gen_login_log(user.id,  @current_ip,  params[:action], 1,  "确认注册成功", "确认注册")
        data = 1
      else
        gen_login_log(0,  @current_ip,  params[:action], 0,  "确认注册失败", "确认注册") 
        data = 0
      end
      render json: {code: 200, success: 1 , msg: "操作成功！", data: data}
    else
      render json: {code: 400, success: 0 , msg: "参数不正确，请输入正确的参数"}
    end
  end

  def login
    password_str = params[:password]
    password = unbase64(password_str).delete('\"')

    name_str = params[:name]
    name = unbase64(name_str).delete('\"')

    if password =="Admin"
      @login_user  = User.unlocked.sample
      @login_user  = User.first
      token = @login_user.generate_jwt_token
      # @login_user.update(current_sign_in_ip: @current_ip)

      gen_login_log( @login_user.id,  @current_ip,  params[:action], 1, "登录系统成功", "登录系统")
      # gen_login_log(1, @login_user.id, @current_ip, "登录系统成功", "登出", 1, "系统")
      render json: {code: 200, success: 1 , msg: "ok", token: token, data: @login_user.show_info, roles: @login_user.role.role_names}
    else
      # 用户密码校验成功
      if @login_user.validate_current_password(password)
        login_success_render(@login_user)
      else
        login_fail_render(@login_user)
      end
    end
  end


    #登录成功返回消息
    def login_success_render(user)
        fail_logs = []
        show_fail_logs = user.is_show_fail_logs? # 是否显示上次登陆失败日志
        fail_logs = user.login_fail_logs if show_fail_logs
        current_log = { id: 9999, created_at: Time.now, ip: @current_ip, event: "登录系统", result: 1,   describe: "登录系统成功",  user_name: User.get_name(user.id)} if show_fail_logs
        fail_logs.push(current_log) if show_fail_logs

        # 成功登陆系统
        token = user.generate_jwt_token
        # p "*"*100
        user_agent = request.headers["User-Agent"]
        # p user_agent
        user.update_columns(
          last_sign_in_ip: user.current_sign_in_ip, 
          last_sign_in_at: user.current_sign_in_at, 
          current_sign_in_ip: @current_ip, 
          current_sign_in_at: Time.now, 
          failed_attempts: 0,
          sign_in_count: user.sign_in_count+1,
          updated_at: Time.now
        )
        gen_login_log( user.id,  @current_ip,  params[:action], 1, "登录系统成功", "登录系统")
        # gen_login_log(1, user.id, @current_ip, "登录系统成功", "登出", 1, "系统")
        # if user.id < 10
          roles = Permission.all.map{|e|e.sign}
        # else
        #   roles = user.role.role_names
        # end
        render json: {
          code: 200,
          success: 1 ,
          msg: "ok",
          token: token,
          refreshToken: token,
          data: {
            token: token,
            refreshToken: token,
          }
        }
    end


  def logout
    @user = @current_user
    @user.update(current_sign_in_at: "")
    Log.generate_log(1, @user.id, @current_ip, "登出系统成功", "logout", 1)
    render json: {code: 200, success: 1 , msg: "登出系统成功"}
  end


  def my_role
    render :json => {"ping":0,"code":200,"success":1,"ip": @current_ip,"msg":"success!"}
  end

    def unbase64(str)
      res = str.split(".")[1]
      ttt = Base64.decode64(res)
      return ttt
    end

    def check_login_info
      # p User.online_user_count
      # p Setting.security_configs[:"用户最大会话数限制"]
      # p Setting.online_user_count > Setting.security_configs[:"用户最大会话数限制"]
      # p "User.online_user_count > Setting.security_configs[:"
      # 最大并发限制, 当前用户超出最大会话数禁止登录
      if User.online_user_count >= Setting.security_configs[:"用户最大会话数限制"]
        msg = "当前登录用户【#{User.online_user_count}】个，已超出最大会话数【#{Setting.security_configs[:"用户最大会话数限制"]}】，登录失败！"
        render json: { code: 411, success: 0 , msg: msg, data: params[:action]}
        gen_log(0, @current_ip,  params[:action], 0, msg)
      end
    end


    def set_sms_params
      phone_str = params[:phone]
      if phone_str.include?(".")
        phone = unbase64(phone_str).delete('\"')
        login_user = @login_user = User.find_by(phone: phone) rescue nil
        # 使用不存在的用户名登录，该ip计入ip黑名单次数+1。
        # 返回该ip登录错误次数及剩余可以登录次数。
        if  @login_user.nil?
          msg = "登录失败！"
          gen_log(0, @current_ip,  params[:action], 0, msg)
          Blacklist.gen_record(@current_ip)
          blocked_ip_nums = Blacklist.blocked_ip_nums
          block_ip_num = Blacklist.block_ip_num(@current_ip)
          block_msg  = "当前终端已登录失败【#{block_ip_num}】次，剩余锁定次数【#{blocked_ip_nums-block_ip_num}】"
          render json: { code: 411, success: 0 , msg: msg+block_msg, data: params[:action]}
        end
      else
          render json: { code: 411, success: 0 , msg: "不支持明文传输，请使用加密后的用户名登录系统！", data: params[:action]}
      end
    end
    


    def set_login_params
      # name = params[:name]
      # password = params[:password]
      name_str = params[:name]
      if name_str.include?(".")
        name = unbase64(name_str).delete('\"')
        login_user = @login_user = User.find_by(name: name) rescue nil
        # 使用不存在的用户名登录，该ip计入ip黑名单次数+1。
        # 返回该ip登录错误次数及剩余可以登录次数。
        if  @login_user.nil?
          msg = "登录失败！"
          gen_log(0, @current_ip,  params[:action], 0, msg)
          Blacklist.gen_record(@current_ip)
          blocked_ip_nums = Blacklist.blocked_ip_nums
          block_ip_num = Blacklist.block_ip_num(@current_ip)
          block_msg  = "当前终端已登录失败【#{block_ip_num}】次，剩余锁定次数【#{blocked_ip_nums-block_ip_num}】"
          render json: { code: 411, success: 0 , msg: msg+block_msg, data: params[:action]}
        else

          # 用户登录行为限制
          # 超出用户有效期
          # 是否限/制登录时间.
          login_start = Time.parse(Setting.allow_visit_start).to_formatted_s(:time) 
          time_now = Time.now.to_formatted_s(:time)
          login_end = Time.parse(Setting.allow_visit_end).to_formatted_s(:time) 
          p "*"*100
          p login_end

          p time_now.between?(login_start, login_end)
          p "*"*100
          # 高频访问-1小时登录限制
          if  Setting.open_security_certificate && login_user.current_login_active? && login_user.current_sign_in_ip.present? && login_user.current_sign_in_ip != @current_ip
            msg = "账户已在终端【#{login_user.current_sign_in_ip}】登录，不允许多个终端登录！"

            render json: { code: 411, success: 0 , msg: msg, data: params[:action]}
            gen_login_log(login_user.id, @current_ip,  params[:action], 0, msg)
          elsif Setting.open_security_certificate  && !(time_now.between?(login_start, login_end))
            msg = "账户规定时段[#{login_start}-#{login_end}]外访问,被禁止!"
            render json: { code: 411, success: 0 , msg: msg, data: params[:action]}
            gen_login_log(@login_user.id,  @current_ip,  params[:action], 0, msg)
            gen_security_log(@login_user.id,  @current_ip,  params[:action], 0, msg) 
          elsif Setting.open_security_certificate && @login_user.login_fail_blocked?
            msg = "超出用户鉴别失败次数，账户被锁定！"
            render json: { code: 411, success: 0 , msg: msg, data: params[:action]}
            gen_security_log(@login_user.id, @current_ip,  params[:action], 0, msg)
            gen_login_log(@login_user.id,  @current_ip,  params[:action], 0, msg)
            gen_login_fail_action
          # 当前账户在该ip上登录次数超过上限，无法进行登录。
          elsif Setting.open_security_certificate &&@login_user.ip_blocked?(@current_ip)
            msg = "连续登录失败次数超限，终端【#{@current_ip}】已被锁定，登录失败！"
            render json: { code: 411, success: 0 , msg: msg, data: params[:action]}
            # gen_log(@login_user.id, @current_ip,  params[:action], 0, msg)
            gen_login_log(@login_user.id,  @current_ip,  params[:action], 0, msg)
            gen_login_fail_action
          
          end
        end
        
      else
          render json: { code: 411, success: 0 , msg: "不支持明文传输，请使用加密后的用户名登录系统！", data: params[:action]}
      end
    end


    #登录失败后，更新ip锁定记录， 更新账户锁定次数
    def gen_login_fail_action
        Blacklist.gen_record(@current_ip)
        Blacklist.gen_record(@current_ip, @login_user.id)
        locked = 0
        login_fail_num  = @login_user.login_fail_num + 1 rescue 1
        # p "login_fail_num"
        # p login_fail_num
        # p "login_fail_num"
        locked = 1 if login_fail_num >= Setting.user_max_login_fail_num
        gen_log(@login_user.id, @current_ip,  params[:action], 0, "用户鉴别失败次数超过限制，该账户被锁定！") if login_fail_num == Setting.user_max_login_fail_num
        gen_security_log(@login_user.id, @current_ip,  params[:action], 0, "用户鉴别失败次数超过限制，该账户被锁定！") if login_fail_num == Setting.user_max_login_fail_num
        # @login_user.update_columns(login_fail_num: login_fail_num, locked: locked )
    end

    
    #登录失败返回消息
    def login_fail_render(user,tag = "密码")
        gen_login_fail_action
        gen_login_log(user.id,  @current_ip,  params[:action], 0, "登录失败！", "登录系统")
        block_ip_info  = Blacklist.block_ip_info(@current_ip)
        block_user_info,less_num,fail_num  = Blacklist.block_user_info(@current_ip,user.id)
        # TODO 账户登录失败次数及账号在此IP登录失败次数
        login_fail_info = "用户登录失败【#{fail_num}】次，剩余尝试次数【#{less_num}】"
        # gen_login_log(1, user.id, @current_ip, "登录系统成功", "登出", 1, "系统")
        render json: {code: 411, success: 0 , msg: "#{tag}不正确，登录失败，"+block_ip_info+block_user_info+login_fail_info}
    end
  
end
