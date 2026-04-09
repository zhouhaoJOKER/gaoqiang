class Api::V1::ConfigsController < Api::V1::BaseController
  before_action :set_config, only: [:delete_config, :update_config]
  before_action :check_authorize

  #访问配置
  # get api/v1/configs
  def configs
    configs = Config.order("id desc")
    @q = configs.ransack(params[:q])
    @configs = @q.result().paginate(:page => params[:page], :per_page => params[:per_page]) #, :total_entries =>  Config.total_entries)
    render json: {code: 200, success: 1 , msg: "ok", data: @configs, meta: { total: @configs.total_entries, per_page: per_page, page: page }}
  end


  #添加配置
  # post api/v1/create_config
  def create_config
    @config = Config.new(config_params)

    # @config.configs config_ids  = params["configs"][1..-2].split(", ")  rescue ''
    # sign_arr = params["configs"][1..-2].split(", ")  rescue ''
    # config_ids = Permission.where(sign: sign_arr).map{|e|e.id} rescue ''
    #@config.user_id = current_user.id  rescue ''
    #@config.department_id = current_user.department_id
    if @config.save!
      render json: {code: 200, success: 1, msg: t('create_success'), data: @config } 
    #   gen_log(@current_user.id, @current_ip,  params[:action], 1, "添加配置#{config_params[:name]}成功")
    else
    #   gen_log(@current_user.id, @current_ip,  params[:action], 0, "添加配置#{config_params[:name]}失败")
      render json: { code: 500, success: 0 , msg: @config.errors.full_messages.join(","), data: ""}
    end
  end

  #配置删除
  # post api/v1/delete_config
  def delete_config
    # gen_log(@current_user.id, @current_ip,  params[:action], 1, "配置删除#{@config.name}成功")
    @config.destroy
    render json: { code: 200, success: 1 , msg: "success", data: ""}
  end

  #配置修改
  # post api/v1/update_config
  def update_config
    # sign_arr = params["configs"][1..-2].split(", ")  rescue ''
    # config_ids = Permission.where(sign: sign_arr).map{|e|e.id} rescue ''
    # config_params[:configs] = config_ids
    # config_params[:remark] = params[:remark]

    if @config.update(config_params)
      # @config.update(remark: params[:remark])
      # @config.update(configs: params["configs"])
      render json: { code: 200, success: 1 , msg: "ok", data: @config}
    #   gen_log(@current_user.id, @current_ip,  params[:action], 1, "配置修改#{@config.name} 成功")
    else
    #   gen_log(@current_user.id, @current_ip,  params[:action], 0, "配置修改#{@config.name} 失败")
      render json: { code: 500, success: 0 , msg: @config.errors.full_messages.join(","), data: ""}
    end
  end

  

  #配置修改
  # post api/v1/update_config_value
  def update_value
    # p value_params["value"]
    # p "  params[:value]"
    # svue = params[:value].to_s.gsub("<ActionController::Parameters","").gsub(" permitted: false>","")
    # p JSON.parse(svue)
    if @config.update(value: params[:value])
      render json: { code: 200, success: 1 , msg: "ok", data: @config}
    #   gen_log(@current_user.id, @current_ip,  params[:action], 1, "配置修改#{@config.name} 成功")
    else
    #   gen_log(@current_user.id, @current_ip,  params[:action], 0, "配置修改#{@config.name} 失败")
      render json: { code: 500, success: 0 , msg: @config.errors.full_messages.join(","), data: ""}
    end
  end


  private
    def set_config
      @config = Config.find(params[:id]) rescue nil
      if  @config.nil?
        msg = "记录不存在！"
        # gen_log(@current_user.id, @current_ip,  params[:action], 0, "ID:#{params[:id]}, "+msg)
        render json: { code: 500, success: 0 , msg: msg, data: params[:action]}
      end
    end

    def config_params
      params.permit(:var, :value)
    end
    def value_params
      params.permit(:id, :value)
    end

    def check_authorize
      begin
        authorize!(params[:action].to_sym, @config || Config)
      rescue CanCan::AccessDenied
        render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
      end
    end
end
