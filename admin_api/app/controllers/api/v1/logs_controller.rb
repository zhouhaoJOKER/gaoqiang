class Api::V1::LogsController < Api::V1::BaseController
  before_action :check_authorize
  
  def index
    logs = Log.accessible_by(current_ability).order("id desc")
    @q = logs.ransack(params[:q]).result()
    @logs = @q.paginate(:page => params[:current], :per_page => params[:size])
    gen_log(@current_user.id, @current_ip,  params[:action], 1, "获取日志列表，搜索条件#{params[:q]}.")
    render json: {code: 200, success: 1 , msg: "ok", data: @logs.map{|e|e.index_info}, total: @q.size, size: per_page, current: params[:current] }
  end
  
  private
  
  def check_authorize
    begin
      authorize!(params[:action].to_sym, Log)
    rescue CanCan::AccessDenied
      render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
    end
  end
end
