class Api::V1::PermissionsController < Api::V1::BaseController
  before_action :set_permission, only: [:delete_permission, :update_permission]
  before_action :check_authorize

  #访问权限
  # get api/v1/permissions   
  def permissions
    permissions = Permission.order("id desc")
    @q = permissions.ransack(params[:q])
    @permissions = @q.result().paginate(:page => params[:page], :per_page => per_page) #, :total_entries =>  Permission.total_entries)
    if params[:list]
      render json: {code: 200, success: 1 , msg: "ok", data: @permissions.map { |e| e.base_info  }, meta: { total: @permissions.total_entries, per_page: per_page, page: page }}
    else
      gen_log(@current_user.id, @current_ip,  params[:action], 1, "访问权限列表")
      render json: {code: 200, success: 1 , msg: "ok", data: @permissions.map { |e| e.index_info  }, meta: { total: @permissions.total_entries, per_page: per_page, page: page }}
    end
  end


  #添加权限
  # post api/v1/create_permission
  def create_permission
    @permission = Permission.new(permission_params)
    if @permission.save
      gen_log(@current_user.id, @current_ip,  params[:action], 1, "添加权限#{permission_params[:name]}成功")
      render json: {code: 200, success: 1, msg: t('create_success'), data: @permission } 
    else
      gen_log(@current_user.id, @current_ip,  params[:action], 0, "添加权限#{permission_params[:name]}失败")
      render json: { code: 500, success: 0 , msg: @permission.errors.full_messages.join(","), data: ""}
    end
  end

  #权限删除功能
  # post api/v1/delete_permission
  def delete_permission
    gen_log(@current_user.id, @current_ip,  params[:action], 1, "权限删除#{@permission.name}成功")

    @permission.destroy
    render json: { code: 200, success: 1 , msg: "success", data: ""}
  end

  #权限修改
  # post api/v1/update_permission
  def update_permission
    if @permission.update(permission_params)
      render json: { code: 200, success: 1 , msg: "ok", data: @permission}
      gen_log(@current_user.id, @current_ip,  params[:action], 1, "权限修改#{@permission.name} 成功")

    else
      gen_log(@current_user.id, @current_ip,  params[:action], 0, "权限修改#{@permission.name} 失败")
      render json: { code: 500, success: 0 , msg: @permission.errors.full_messages.join(","), data: ""}
    end
  end

  private
    def set_permission
      @permission = Permission.find(params[:id])  rescue nil
      if  @permission.nil?
        msg = "记录不存在！"
        gen_log(@current_user.id, @current_ip,  params[:action], 0, "ID:#{params[:id]}, "+msg)
        render json: { code: 500, success: 0 , msg: msg, data: params[:action]}
      end
    end

    def permission_params
      params.permit(:code, :name, :category, :act, :ctrl, :sign, :core, :user_id)
    end

    def check_authorize
      begin
        authorize!(params[:action].to_sym, @permission || Permission)
      rescue CanCan::AccessDenied
        render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
      end
    end
end