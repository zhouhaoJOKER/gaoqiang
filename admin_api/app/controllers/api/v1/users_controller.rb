class Api::V1::UsersController < Api::V1::BaseController
  before_action :set_user, only: [ :delete, :update, :show, :change_password, :unlock, :reset_password, :send_reset_password_email ]
  # check_user
  before_action :check_authorize

  def info
    render json: {
      "code": 200,
      "data": {
        "userId": @current_user.id,
        "userName": @current_user.name,
        "avatar": @current_user.avatar.url,
        "email": @current_user.email
      },
      "msg": "请求成功"
    }
  end

  # GET /api/v1/users/index
  def index
    users = User.accessible_by(current_ability).order("id desc")
    @q = users.ransack(params[:q])
    @users = @q.result().paginate(page: params[:current], per_page: params[:size])
    gen_log(@current_user.id, @current_ip,  params[:action], 1, "获取用户列表，搜索条件#{params[:q]}.")
    render json: { code: 200, success: 1, msg: "ok", data:  @users.map { |e| e.index_info  }, "current": params[:current].to_i, "size": params[:size].to_i, "total": @users.total_entries  }
  end


  # 用户新建
  # post "api/v1/users/create"
  def create
    if User.find_by(name: params[:name])
      msg = "该姓名已存在!"
      gen_log(@current_user.id, @current_ip,  params[:action], 0, "创建用户[#{@user.name}]失败.#{msg}")
      render json: { code: 500, success: 0,  msg: msg }, status: 200
    elsif User.find_by(nickname: params[:nickname])
      msg = "该用户名已存在!"
      gen_log(@current_user.id, @current_ip,  params[:action], 0, "创建用户[#{@user.name}]失败.#{msg}")
      render json: { code: 500, success: 0,  msg: msg }, status: 200
    elsif User.find_by(cardnum: params[:cardnum])
      msg = "该身份证件号码已存在!"
      gen_log(@current_user.id, @current_ip,  params[:action], 0, "创建用户[#{@user.name}]失败.#{msg}")
      render json: { code: 500, success: 0,  msg: msg }, status: 200
    else
        @user = User.new(user_params)
        @user.approved =  @user.change_passowrd = 1
        @user.password =  Setting.default_password
        @user.avatar =  File.open("#{Rails.root}/public/icon.png")  rescue ""
        if @user.save!
          gen_log(@current_user.id, @current_ip,  params[:action], 1, "创建用户[#{@user.name}]成功.")
          render json: { code: 200, success: 1, msg: t("create_success"), data: @user.index_info }
        else
          gen_log(@current_user.id, @current_ip,  params[:action], 0, "创建用户[#{@user.name}]失败.#{@user.errors.full_messages.join(",")}")
          render json: { code: 500, success: 0, msg: @user.errors.full_messages.join(","),  data: "" }
        end
    end
  end



  # 用户修改
  # post "api/v1/users/show"
  def show
      if params[:tag].nil?
        gen_log(@current_user.id, @current_ip,  params[:action], 1, "访问用户[#{@user.name}]信息成功.")
        render json: { code: 200, success: 1, msg: "ok", data: @user }
      else
        gen_log(@current_user.id, @current_ip,  params[:action], 0, "修改用户[#{@user.name}]信息失败.")
        render json: { code: 500, success: 0, msg: @user.errors.full_messages.join(","), data: "" }
      end
  end

  # 用户修改
  # post "api/v1/users/update"
  def update
      if @user.update(user_params)
        gen_log(@current_user.id, @current_ip,  params[:action], 1, "修改用户[#{@user.name}]信息成功.")
        render json: { code: 200, success: 1, msg: "ok", data: @user }
      else
        gen_log(@current_user.id, @current_ip,  params[:action], 0, "修改用户[#{@user.name}]信息失败.")
        render json: { code: 500, success: 0, msg: @user.errors.full_messages.join(","), data: "" }
      end
  end


  # 用户删除
  # post "api/v1/user/delete"
  def delete
    @user.destroy
    gen_log(@current_user.id, @current_ip,  params[:action], 1, "删除用户[#{@user.name}]信息成功.")
    render json: { code: 200, success: 1, msg: "success", data: "" }
  end


  # 访问用户
  # get "api/v1/search_user"
  def search
    if params[:key] and params[:value]
      # value = eval("User.find_by(#{params[:key]}: #{params[:value]})")  rescue -1
      key = params[:key]
      value = params[:value]
      res = eval("User.find_by(#{key}: '#{value}')")  rescue nil
      if res&.present?
        render json: { code: 200, success: 0, msg: "#{params[:value]}已经存在", data: { success: 0 } }
      else
        render json: { code: 200, success: 1, msg: "校验成功", data: { success: 1 } }
      end
    else
      users = User.order("id desc")
      @q = users.ransack(params[:q])
      @users = @q.result().paginate(page: params[:page], per_page: params[:per_page]) # , :total_entries =>  User.total_entries)

      gen_log(@current_user.id, @current_ip,  params[:action], 1, "获取用户列表，搜索条件#{params[:q]}.")
      render json: { code: 200, success: 1, msg: "ok",  data: @users.map { |e| e.thin_info  } }
    end
  end

  # 获取用户属性
  # get "api/v1/property"
  def property
    roles = Role.all.map { |e| { title: e.name, value: e.id } }
    users = Department.all.map { |e| { title: e.name, value: e.id } }
    companies = Company.all.map { |e| { title: e.name, value: e.id } }
    render json: { code: 200, success: 1, msg: "成功", roles: roles, users: users, companies: companies }
  end


  # 访问用户
  # get "api/v1/users"
  def users
    users = User.order("id desc")
    @q = users.ransack(params[:q])
    @users = @q.result().paginate(page: params[:page], per_page: params[:per_page]) # , :total_entries =>  User.total_entries)
    online_user_count = User.online_user_count
    # check_result = User.check_mult_check_digit(@users.where(checked: 0))

    gen_log(@current_user.id, @current_ip,  params[:action], 1, "获取用户列表，搜索条件#{params[:q]}.")
    render json: { code: 200, success: 1, msg: "ok", online_user_count: online_user_count, data: @users.map { |e| e.index_info  }, meta: { total: @users.total_entries, per_page: per_page, page: page } }
    # render json: {code: 200, success: 1 , msg: "ok", data: @users.map { |e| e.index_info  }, meta: { total: @users.total_entries, per_page: per_page, page: page }},status:500
  end

  # 重置密码
  # post "api/v1/reset_password"
  def reset_password
    @user.password =  Setting.default_password
    @user.change_passowrd =  1
    @user.current_sign_in_ip =  ""
    @user.current_sign_in_at =  ""
    msg =  "重置用户【#{@user.name}】密码成功！"
    gen_log(@current_user.id, @current_ip,  params[:action], 1, msg)
    gen_security_log(@current_user.id, @current_ip,  params[:action], 1, msg)
    render json: { code: 200, success: 1, msg: msg }
  end


  # 修改密码
  # post "api/v1/change_password"
  def change_password
      old_password = params["old_password"] # 旧密码
      password = params["password"] # 密码解析

      # password_validate_ok  = password.match(/(?=.*[a-zA-Z])(?=.*[0-9])^[0-9a-zA-Z`~!@#$%^&*()+=|{}':;.',]{8,25}$/).nil? # nil 校验不成功
      password_validate_ok  = password.match(/^(?=.*\d)(?=.*[a-zA-Z])(?=.*[~!@#$%^&*()+=|{}':;.',])[\da-zA-Z~!@#$%^&*()+=|{}':;.',]{8,25}$/).nil? # nil 校验不成功
      password_min_num = Setting.password_min_length
      password_max_num = Setting.password_max_length

      # p password_validate_ok
      # p password_min_num
      # p password_max_num

      # @user.update(password: password)
      if password_min_num > password.size
        msg = "密码长度必须不小于#{password_min_num}位"
        gen_log(@current_user.id, @current_ip,  params[:action], 0, msg)
        render json: { code: 500, success: 0, msg: msg }, status: 200
      elsif password.size > password_max_num
        msg = "密码不能大于#{password_max_num}位"
        gen_log(@current_user.id, @current_ip,  params[:action], 0, msg)
        render json: { code: 500, success: 0, msg: msg }, status: 200
      elsif password_validate_ok
        msg = "密码必须包含字母，数字及字符"
        gen_log(@current_user.id, @current_ip,  params[:action], 0, msg)
        render json: { code: 500, success: 0, msg: msg }, status: 200
      else
        p @user.validate_current_password(old_password)
        if  @user.validate_current_password(old_password)
          @user.password = password
          @user.change_passowrd = 0
          @user.save!
          msg = "修改【#{@user.name}】账户密码成功."
          gen_log(@current_user.id, @current_ip,  params[:action], 1, msg)
          gen_security_log(@current_user.id, @current_ip,  params[:action], 1, msg)
          render json: { code: 200, success: 1, msg: "success", data: msg }
        else
          msg = "修改【#{@user.name}】账户密码失败，旧密码不正确."
          render json: { code: 200, success: 0, msg: msg, data: "" }
          gen_log(@current_user.id, @current_ip,  params[:action], 0, msg)
        end
      end
  end


  # 导入
  def import
    if params[:tag] == "import_template"
      column_names =  Department.imp_exp_hander
      i18n_column_names = Department.il8n_imp_exp_hander
      data = []
      if params[:file_ext] == "csv"
        file =  gen_export_csv_file(data, column_names, i18n_column_names)
      else
        file =  gen_export_xlsx_file(data, column_names, i18n_column_names)
      end
      # send_file file
      url = file.split("public/")[1]
      gen_log(@current_user.id, @current_ip,  "download_template", 1, "用户模板下载成功")
      render json: { code: 200, success: 1, msg: "success", url: url }
    elsif params[:tag] == "file"
     attachment = Attachment.create(
      file: params[:file],
      user_id: @current_user.id,
      name: "导入#{Department.table_name}",
      )
      file = attachment.file.path
      csv_data = CSV.read(file, skip_blanks: true)
      @il8n_headers = csv_data[0]
      @headers =headers = csv_data[1]
      data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
      @csv_data  = data

      gen_log(@current_user.id, @current_ip,  "import_preview", 1, "导入用户预览数据成功")
      render json: { code: 200, success: 1, msg: "success", data: @csv_data }
      # redirect_to params[:_back]+"?attachment_id=#{attachment.id}", notice: "上传成功，请预览并修改数据。"
    end
  end


  # 批量修改用户
  # post api/v1/users/batch_action
  def batch_action
    return render json: { code: 500, success: 0, msg: "请指定操作类型(actions)", data: "" } if params[:actions].blank?

    action = params[:actions]
    valid_actions = [ "create", "update", "delete" ]
    return render json: { code: 500, success: 0, msg: "无效的操作类型，支持的操作类型为：#{valid_actions.join(", ")}", data: "" } unless valid_actions.include?(action)
    data = []

    results = {
      success: 0,
      failed: 0,
      errors: []
    }

    case action
    when "create"
      return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if  params[:users].blank?

      User.transaction do
        params[:users].each do |dept_params|
          user = User.new(dept_params.to_unsafe_h)
          if user.save
            # user.update_columns(parent_id: dept_params[:parent_id]) if dept_params[:parent_id].present?
            results[:success] += 1
            data << user
            gen_log(@current_user.id, @current_ip,  "batch_create", 1, "批量新增用户#{user.name}成功")

          else
            results[:failed] += 1
            results[:errors] << { params: dept_params, errors: user.errors.full_messages }
            gen_log(@current_user.id, @current_ip,  "batch_create", 0, "批量新增用户#{dept_params[:name]}失败: #{user.errors.full_messages.join(",")}")
          end
        end
      end

    when "update"
      return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if params[:ids].blank? || params[:fields].blank? || params[:values].blank?

      selected_ids = params[:ids]
      fields = params[:fields]
      values = params[:values]

      # 过滤出需要更新的字段和值
      update_params = {}
      fields.each do |field|
        update_params[field.to_sym] = values[field] if values.key?(field)
      end

      return render json: { code: 500, success: 0, msg: "没有需要更新的字段", data: [], results: results } if update_params.empty?

      User.transaction do
        selected_ids.each do |dept_id|
          user = User.find_by(id: dept_id)
          if user
            if user.update(update_params)
              # 处理parent_id更新（如果需要）
              user.update_columns(parent_id: update_params[:parent_id]) if update_params[:parent_id].present?
              results[:success] += 1
              data << user
              gen_log(@current_user.id, @current_ip,  "batch_update", 1, "批量修改用户#{user.name}成功")
            else
              results[:failed] += 1
              results[:errors] << { id: dept_id, errors: user.errors.full_messages }
              gen_log(@current_user.id, @current_ip,  "batch_update", 0, "批量修改用户#{user.name}失败: #{user.errors.full_messages.join(",")}")
            end
          else
            results[:failed] += 1
            results[:errors] << { id: dept_id, errors: [ "用户不存在" ] }
            gen_log(@current_user.id, @current_ip,  "batch_update", 0, "批量修改用户失败: 用户ID #{dept_id} 不存在")
          end
        end
      end

    when "delete"
      User.transaction do
        params[:ids].each do |dept_id|
          user = User.find(dept_id)
          if user
            user.destroy
            results[:success] += 1
            gen_log(@current_user.id, @current_ip,  "batch_delete", 1, "批量删除用户#{user.name}成功")
          else
            results[:failed] += 1
            results[:errors] << { id: dept_id, errors: [ "用户不存在" ] }
            gen_log(@current_user.id, @current_ip,  "batch_delete", 0, "批量删除用户失败: 用户ID #{dept_id} 不存在")
          end
        end
      end
    end

    render json: {
      code: 200,
      success: 1,
      msg: "批量#{action}操作完成, 成功#{results[:success]}条, 失败#{results[:failed]}条",
      data: data,
      results: results
    }
  end


  # 发送重置密码邮件
  # post "api/v1/users/send_reset_password_email"
  def  send_reset_password_email
    @user.send_reset_password_email
    gen_log(@current_user.id, @current_ip,  "mail", 1, "对用户#{@user.name}发送重置密码邮件成功")
    render json: { code: 200, success: 1, msg: "操作成功！", data: "" }
  end


  private
    def set_user
      @user = User.find(params[:id]) rescue nil
      if  @user.nil?
        msg = "记录不存在！"
        gen_log(@current_user.id, @current_ip,  params[:action], 0, "ID:#{params[:id]}, "+msg)
        render json: { code: 500, success: 0, msg: msg, data: params[:action] }
      end
    end

    def check_bulks
      if request.get?
        redirect_to "/users", notice: t("select_data_then_bulk")
      end
    end

    def set_bulk_users
      @users = User.where(id: params[:bulk_ids]).order("id desc")
    end

    def user_params
      params.permit(:email, :encrypted_password, :reset_password_token, :reset_password_sent_at, :remember_created_at, :sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip, :last_sign_in_ip, :confirmation_token, :confirmed_at, :confirmation_sent_at, :unconfirmed_email, :failed_attempts, :unlock_token, :locked_at, :nickname, :name, :phone, :approved, :uuid, :code, :sex, :marriage, :cardnum, :brondate, :user_id, :post_id, :hire_date, :fire_date, :director_id, :role_id, :status, :avatar, :remark, :whitelists, :change_passowrd, :company_id, :current_company_id, :department_id)
    end

    # 用户表数据校验位
    def check_validate_check_digit
      new_check_digit = @user.check_check_digit
      if new_check_digit != @user.check_digit
        msg = "用户#{@user.name}数据校验位被篡改!"
        Log.gen_security_log(@user.id, "0.0.0.0", "数据完整性校验测", 0, msg,  "安全审计")
        render json: { code: 200, success: 0, msg: msg, data: "" }
      end
    end

    def check_authorize
      begin
        authorize!(params[:action].to_sym, @user || User)
      rescue CanCan::AccessDenied
        render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
      end
    end
end
