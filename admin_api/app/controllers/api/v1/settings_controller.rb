class Api::V1::SettingsController < Api::V1::BaseController
  before_action :set_setting, only: [:delete, :update, :show]
  before_action :check_authorize
 
  def test
    if  params[:tag] == "test_mail"
      email = params[:email]
      subject = params[:subject] || "测试邮件发送"
      info = params[:info] || "这是测试的内容。"
      SendMailer.test(email, subject, info).deliver
      gen_log(@current_user.id, @current_ip,  params[:action], 1, "测试邮件已发送至 #{email}，请注意查收！", "测试邮件")
      render json: { code: 200, success: 1 , msg: "测试邮件已发送至 #{email}，请注意查收！", data: ""}
    else
      render json: { code: 500, success: 0 , msg: "无效的测试类型！", data: ""}
    end
  end
  
  #访问配置
  # get api/v1/settings   
  def index
    if params[:tag].present?
      # 如果tag参数为 base_info 获取 Setting.base_info 对应的字段，并把结果返回
      records = eval "Setting.#{params[:tag]}"
      base_info_settings = {}
      records.each do |field| 
        base_info_settings[field] = Setting.send(field)
      end
      settings = [base_info_settings]
      @settings = settings 
    else
      settings = Setting.order("id desc")
      @q = settings.ransack(params[:q])
      @settings = @q.result() 
    end

    gen_log(@current_user.id, @current_ip,  params[:action], 1, "访问配置列表")
    render json: {code: 200, success: 1 , msg: "ok", data: @settings}
  end


  #添加配置
  # post api/v1/create_setting
  def create
    if params["tag"].present?
      # 如果tag参数为 base_info 获取 Setting.base_info 对应的字段，并把params["tag"]对应的字段赋值给@setting
      # if params["tag"] == 'base_info'
        records = eval "Setting.#{params[:tag]}"
        records.each do |field| 
          p field
          p params["setting"]["#{field}"]
          value = params["setting"]["#{field}"]
          value = value.strip if value.is_a?(String)
          gen_log(@current_user.id, @current_ip,  params[:action], 1, "添加配置[#{field}]成功")
          Setting.send("#{field}=", value)
        end
        render json: { code: 200, success: 1 , msg: "ok", data: ""}
      # end
    else
      @setting = Setting.new(setting_params)
      # @setting.company_ids = params["company_ids"]
      @setting.user_id = @current_user.id  rescue ''

      @setting.company_ids = format_company_ids( params[:company_ids]) if params[:company_ids]

      if @setting.save
        render json: {code: 200, success: 1, msg: t('create_success'), data: @setting } 
        gen_log(@current_user.id, @current_ip,  params[:action], 1, "添加配置#{setting_params[:name]}成功")
      else
        gen_log(@current_user.id, @current_ip,  params[:action], 0, "添加配置#{setting_params[:name]}失败")
        render json: { code: 500, success: 0 , msg: @setting.errors.full_messages.join(","), data: ""}
      end
    end
  end

  def show
    gen_log(@current_user.id, @current_ip,  params[:action], 1, "访问配置#{@setting.name}")
    render json: { code: 200, success: 1 , msg: "ok", data: @setting}
  end
  

  #配置删除
  # post api/v1/delete
  def delete
    if params["id"] == "1"
      gen_security_log(@current_user.id, @current_ip,  params[:action], 0, "系统超级管理员不允许删除！")
      render json: { code: 500, success: 0 , msg: "系统超级管理员不允许删除！", data: ""}
    else
      gen_log(@current_user.id, @current_ip,  params[:action], 1, "配置删除#{@setting.name}成功")
      @setting.destroy
      render json: { code: 200, success: 1 , msg: "success", data: ""}
    end
  end

  #配置修改
  # post api/v1/update
  def update
    if params["id"] == "1"
      gen_security_log(@current_user.id, @current_ip,  params[:action], 0, "系统超级管理员不允许修改！")
      render json: { code: 500, success: 0 , msg: "系统超级管理员不允许修改！", data: ""}
    else

      if @setting.update!(setting_params)

      company_ids = format_company_ids(params[:company_ids]) if params[:company_ids]
       @setting.update!(company_ids: company_ids)

        render json: { code: 200, success: 1 , msg: "ok", data: @setting}
        gen_log(@current_user.id, @current_ip,  params[:action], 1, "配置修改#{@setting.name} 成功")
      else
        gen_log(@current_user.id, @current_ip,  params[:action], 0, "配置修改#{@setting.name} 失败")
        render json: { code: 500, success: 0 , msg: @setting.errors.full_messages.join(","), data: ""}
      end
    end
  end


  # 导入
  def import
    if params[:tag] == "import_template"
      column_names =  Setting.imp_exp_hander
      i18n_column_names = Setting.il8n_imp_exp_hander
      data = []
      if params[:file_ext] == "csv"
        file =  gen_export_csv_file(data, column_names, i18n_column_names)
      else
        file =  gen_export_xlsx_file(data, column_names, i18n_column_names)
      end
      # send_file file
      url = file.split("public/")[1]
      gen_log(@current_user.id, @current_ip,  'download_template', 1, "导入模板#{Setting.table_name}下载成功")
      render json: { code: 200, success: 1 , msg: "success", url: url}
    elsif params[:tag] == "file"
     attachment = Attachment.create(
      file: params[:file],
      user_id: @current_user.id,
      name: "导入#{Setting.table_name}",
      )
      file = attachment.file.path

      csv_data = CSV.read(file, skip_blanks: true)
      @il8n_headers = csv_data[0]
      @headers =headers = csv_data[1]
      data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
      @csv_data  = data

      gen_log(@current_user.id, @current_ip,  "import_preview", 1, "导入配置预览数据成功")
      render json: { code: 200, success: 1 , msg: "success", data: @csv_data}

      # redirect_to params[:_back]+"?attachment_id=#{attachment.id}", notice: "上传成功，请预览并修改数据。" 
    end
    
  end
  

  #批量修改配置
  # post api/v1/settings/batch_action
  def batch_action
    
    return render json: { code: 500, success: 0, msg: "请指定操作类型(actions)", data: "" } if params[:actions].blank? 
    
    action = params[:actions]
    valid_actions = ["create", "update", "delete"]
    return render json: { code: 500, success: 0, msg: "无效的操作类型，支持的操作类型为：#{valid_actions.join(", ")}", data: "" } unless valid_actions.include?(action)
    data = []
    
    results = {
      success: 0,
      failed: 0,
      errors: []
    }
    
    case action
    when "create"
      return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if  params[:settings].blank? 

      Setting.transaction do
        params[:settings].each do |item_params|
          item = Setting.new(item_params.to_unsafe_h)
          if item.save
            item.update_columns(parent_id: item_params[:parent_id]) if item_params[:parent_id].present?
            results[:success] += 1
            data << item
            gen_log(@current_user.id, @current_ip,  "batch_create", 1, "批量新增配置#{item.name}成功")
            
          else
            results[:failed] += 1
            results[:errors] << { params: item_params, errors: item.errors.full_messages }
            gen_log(@current_user.id, @current_ip,  "batch_create", 0, "批量新增配置#{item_params[:name]}失败: #{item.errors.full_messages.join(",")}")
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
      
      return render json: { code: 500, success: 0, msg: "没有需要更新的字段", data: [], results: results, } if update_params.empty?
      
      Setting.transaction do
        selected_ids.each do |dept_id|
          item = Setting.find_by(id: dept_id)
          if item
            if item.update(update_params)
              # 处理parent_id更新（如果需要）
              item.update_columns(parent_id: update_params[:parent_id]) if update_params[:parent_id].present?
              results[:success] += 1
              data << item
              gen_log(@current_user.id, @current_ip,  "batch_update", 1, "批量修改配置#{item.name}成功")
            else
              results[:failed] += 1
              results[:errors] << { id: dept_id, errors: item.errors.full_messages }
              gen_log(@current_user.id, @current_ip,  "batch_update", 0, "批量修改配置#{item.name}失败: #{item.errors.full_messages.join(",")}")
            end
          else
            results[:failed] += 1
            results[:errors] << { id: dept_id, errors: ["配置不存在"] }
            gen_log(@current_user.id, @current_ip,  "batch_update", 0, "批量修改配置失败: 配置ID #{dept_id} 不存在")
          end
        end
      end
    
    when "delete"
      Setting.transaction do
        params[:ids].each do |dept_id|
          item = Setting.find(dept_id)
          if item
            item.destroy
            results[:success] += 1
            gen_log(@current_user.id, @current_ip,  "batch_delete", 1, "批量删除配置#{item.name}成功")
          else
            results[:failed] += 1
            results[:errors] << { id: dept_id, errors: ["配置不存在"] }
            gen_log(@current_user.id, @current_ip,  "batch_delete", 0, "批量删除配置失败: 配置ID #{dept_id} 不存在")
          end
        end
      end
    end
    
    render json: {
      code: 200,
      success: 1,
      msg: "批量#{action}操作完成, 成功#{results[:success]}条, 失败#{results[:failed]}条",
      data: data,
      results: results,
    }
  end

  private

    def format_company_ids(company_ids)
      return "," if company_ids.empty?
      ",#{company_ids.join(',')},"
    end
    def set_setting
      @setting = Setting.find(params[:id]) rescue nil
      if  @setting.nil?
        msg = "记录不存在！"
        gen_log(@current_user.id, @current_ip,  params[:action], 0, "ID:#{params[:id]}, "+msg)
        render json: { code: 500, success: 0 , msg: msg, data: params[:action]}
      end
    end

    def setting_params
      params.permit(:var, :value)
    end

    def check_authorize
      begin
        authorize!(params[:action].to_sym, @setting || Setting)
      rescue CanCan::AccessDenied
        render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
      end
    end

end


