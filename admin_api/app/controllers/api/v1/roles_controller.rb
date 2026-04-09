class Api::V1::RolesController < Api::V1::BaseController
  before_action :set_role, only: [:delete, :update, :show]
  before_action :check_authorize

  #访问当前用户角色
  # get api/v1/roles/my_role   
  def my_role
    @user = @current_user
    # gen_log(@current_user.id, @current_ip,  params[:action], 1, "访问当前用户角色")
    if @user.id < 5
      roles = Permission.all.map{|e|e.sign}
    else
      roles = @user.my_role_names
    end
    render json: {code: 200, success: 1 , msg: "ok", data: @user.show_info, roles: roles}
  end

  #访问角色
  # get api/v1/roles   
  def index
    roles = Role.order("id desc")
    @q = roles.ransack(params[:q])
    @roles = @q.result().paginate(:page => params[:page], :per_page => per_page) #, :total_entries =>  Role.total_entries)

    gen_log(@current_user.id, @current_ip,  params[:action], 1, "访问角色列表")
    render json: {code: 200, success: 1 , msg: "ok", data: @roles.map { |e| e.base_info  }, meta: { total: @roles.total_entries, per_page: per_page, page: page }}
  end


  #添加角色
  # post api/v1/create_role
  def create
    # if !params["company_ids"].present? || (params["company_ids"].present? and params["company_ids"].size == 0)
    #     render json: { code: 500, success: 0 , msg: "公司至少选择一个！", data: ""}
    # else
      @role = Role.new(role_params)
      # @role.company_ids = params["company_ids"]
      @role.user_id = @current_user.id  rescue ''

      @role.company_ids = format_company_ids( params[:company_ids]) if params[:company_ids]

      if @role.save
        render json: {code: 200, success: 1, msg: t('create_success'), data: @role } 
        gen_log(@current_user.id, @current_ip,  params[:action], 1, "添加角色#{role_params[:name]}成功")
      else
        gen_log(@current_user.id, @current_ip,  params[:action], 0, "添加角色#{role_params[:name]}失败")
        render json: { code: 500, success: 0 , msg: @role.errors.full_messages.join(","), data: ""}
      end
    # end
  end

  def show
    gen_log(@current_user.id, @current_ip,  params[:action], 1, "角色详情#{@role.name}获取成功")
    render json: { code: 200, success: 1 , msg: "ok", data: @role}
  end
  

  #角色删除
  # post api/v1/delete
  def delete
    if params["id"] == "1"
      gen_security_log(@current_user.id, @current_ip,  params[:action], 0, "系统超级管理员不允许删除！")
      render json: { code: 500, success: 0 , msg: "系统超级管理员不允许删除！", data: ""}
    else
      gen_log(@current_user.id, @current_ip,  params[:action], 1, "角色删除#{@role.name}成功")
      @role.destroy
      render json: { code: 200, success: 1 , msg: "success", data: ""}
    end
  end

  #角色修改
  # post api/v1/update
  def update
    if params["id"] == "1"
      gen_security_log(@current_user.id, @current_ip,  params[:action], 0, "系统超级管理员不允许修改！")
      render json: { code: 500, success: 0 , msg: "系统超级管理员不允许修改！", data: ""}
    else
      if @role.update!(role_params)
      company_ids = format_company_ids(params[:company_ids]) if params[:company_ids]
       @role.update!(company_ids: company_ids)
        render json: { code: 200, success: 1 , msg: "ok", data: @role}
        gen_log(@current_user.id, @current_ip,  params[:action], 1, "角色修改#{@role.name} 成功")
      else
        gen_log(@current_user.id, @current_ip,  params[:action], 0, "角色修改#{@role.name} 失败")
        render json: { code: 500, success: 0 , msg: @role.errors.full_messages.join(","), data: ""}
      end
    end
  end


  # 导入
  def import
    if params[:tag] == "import_template"
				column_names =  Role.imp_exp_hander
				i18n_column_names = Role.il8n_imp_exp_hander
        data = []
        if params[:file_ext] == "csv"
          file =  gen_export_csv_file(data, column_names, i18n_column_names)
        else
          file =  gen_export_xlsx_file(data, column_names, i18n_column_names)
        end
        
				# send_file file
        url = file.split("public/")[1]

        gen_log(@current_user.id, @current_ip,  'download_template', 1, "导出角色模板成功")
        render json: { code: 200, success: 1 , msg: "success", url: url}

    elsif params[:tag] == "file"
     attachment = Attachment.create(
      file: params[:file],
      user_id: @current_user.id,
      name: "导入#{Role.table_name}",
      )
      file = attachment.file.path

      csv_data = CSV.read(file, skip_blanks: true)
      @il8n_headers = csv_data[0]
      @headers =headers = csv_data[1]
      data = csv_data[2..-1].map { |row| Hash[*headers.zip(row).flatten] }
      @csv_data  = data
      gen_log(@current_user.id, @current_ip,  "import_preview", 1, "导入角色预览数据成功")
      
      render json: { code: 200, success: 1 , msg: "success", data: @csv_data}

      # redirect_to params[:_back]+"?attachment_id=#{attachment.id}", notice: "上传成功，请预览并修改数据。" 
    end
    
  end
  

  #批量修改角色
  # post api/v1/roles/batch_action
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
      return render json: { code: 500, success: 0, msg: "请求参数不能为空", data: "" } if  params[:roles].blank? 

      Role.transaction do
        params[:roles].each do |item_params|
          item = Role.new(item_params.to_unsafe_h)
          if item.save
            item.update_columns(parent_id: item_params[:parent_id]) if item_params[:parent_id].present?
            results[:success] += 1
            data << item
            gen_log(@current_user.id, @current_ip,  "batch_create", 1, "批量新增角色#{item.name}成功")
          else
            results[:failed] += 1
            results[:errors] << { params: item_params, errors: item.errors.full_messages }
            gen_log(@current_user.id, @current_ip,  "batch_create", 0, "批量新增角色#{item_params[:name]}失败: #{item.errors.full_messages.join(",")}")
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
      
      Role.transaction do
        selected_ids.each do |dept_id|
          item = Role.find_by(id: dept_id)
          if item
            if item.update(update_params)
              # 处理parent_id更新（如果需要）
              item.update_columns(parent_id: update_params[:parent_id]) if update_params[:parent_id].present?
              results[:success] += 1
              data << item
              gen_log(@current_user.id, @current_ip,  "batch_update", 1, "批量修改角色#{item.name}成功")
            else
              results[:failed] += 1
              results[:errors] << { id: dept_id, errors: item.errors.full_messages }
              gen_log(@current_user.id, @current_ip,  "batch_update", 0, "批量修改角色#{item.name}失败: #{item.errors.full_messages.join(",")}")
            end
          else
            results[:failed] += 1
            results[:errors] << { id: dept_id, errors: ["角色不存在"] }
            gen_log(@current_user.id, @current_ip,  "batch_update", 0, "批量修改角色失败: 角色ID #{dept_id} 不存在")
          end
        end
      end
    
    when "delete"
      Role.transaction do
        params[:ids].each do |dept_id|
          item = Role.find(dept_id)
          if item
            item.destroy
            results[:success] += 1
            gen_log(@current_user.id, @current_ip,  "batch_delete", 1, "批量删除角色#{item.name}成功")
          else
            results[:failed] += 1
            results[:errors] << { id: dept_id, errors: ["角色不存在"] }
            gen_log(@current_user.id, @current_ip,  "batch_delete", 0, "批量删除角色失败: 角色ID #{dept_id} 不存在")
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
    def set_role
      @role = Role.find(params[:id]) rescue nil
      if  @role.nil?
        msg = "记录不存在！"
        gen_log(@current_user.id, @current_ip,  params[:action], 0, "ID:#{params[:id]}, "+msg)
        render json: { code: 500, success: 0 , msg: msg, data: params[:action]}
      end
    end

    def role_params
      params.permit(:sign, :name, :category, :sort, :describe, :user_id,:company_id, :is_open, menu_ids: [])
    end

    def check_authorize
      begin
        authorize!(params[:action].to_sym, @role || Role)
      rescue CanCan::AccessDenied
        render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
      end
    end

end


