class Api::V1::NodesController < Api::V1::BaseController
  before_action :set_node, only: [:delete_node, :update_node]
  before_action :check_authorize

  
  #访问目录
  # get api/v1/node_trees
  def node_trees
      nodes = Folder.includes(:company, :parent, :children).order("code desc")
      @q = nodes.ransack(params[:q])
      @nodes = @q.result().paginate(:page => params[:page], :per_page => per_page) #, :total_entries =>  Node.total_entries)
      if params[:expand_all]  == "true"

        gen_log(@current_user.id, @current_ip,  params[:action], 1, "访问节点列表")
        render json: {code: 200, success: 1 , msg: "ok", data: @nodes.map{|e|e.all_tree_info}, meta: { total: @nodes.total_entries, per_page: per_page, page: page }}
      else
        gen_log(@current_user.id, @current_ip,  params[:action], 1, "访问节点列表")
        render json: {code: 200, success: 1 , msg: "ok", data: @nodes.map{|e|e.tree_info}, meta: { total: @nodes.total_entries, per_page: per_page, page: page }}
      end
  end
  
  
  #访问节点
  # get api/v1/node_files
  def node_files
      nodes = Filer.includes(:company, :parent, :children).order("code desc")
      # if  ["1","2","3","4","5"].include?(params[:q][:parent_id_eq])
      #   params[:q][:root_id_eq] = params[:q][:parent_id_eq]
      #   params[:q][:parent_id_eq] = ""
      # end
      
      @q = nodes.ransack(params[:q])

      @nodes = @q.result().paginate(:page => params[:page], :per_page => per_page) #, :total_entries =>  Node.total_entries)
      gen_log(@current_user.id, @current_ip,  params[:action], 1, "访问节点列表")
      render json: {code: 200, success: 1 , msg: "ok", data: @nodes.map{|e|e.node_info}, meta: { total: @nodes.total_entries, per_page: per_page, page: page }}
  end
  

  

  #访问节点
  # get api/v1/nodes
  def nodes
    if params[:list]
      gen_log(@current_user.id, @current_ip,  params[:action], 1, "访问节点列表")
      @nodes = Node.includes(:company, :parent, :children).where(parent_id: nil)
      render json: {code: 200, success: 1 , msg: "ok", data: @nodes,  meta: { total: @nodes.size, per_page: per_page, page: page }}
    else

      nodes = Node.includes(:company, :parent, :children).order("code desc")
      @q = nodes.ransack(params[:q])
      @nodes = @q.result().paginate(:page => params[:page], :per_page => per_page) #, :total_entries =>  Node.total_entries)
      gen_log(@current_user.id, @current_ip,  params[:action], 1, "访问节点列表")
      render json: {code: 200, success: 1 , msg: "ok", data: @nodes.map{|e|e.base_info}, meta: { total: @nodes.total_entries, per_page: per_page, page: page }}
    end
  end



  #文件上传
  # post api/v1/upload
  def upload
    # 1.只上传文件
    # 2.只带父级id文件

    parent_id = params[:parent_id]

    if  parent_id.present?
      data = {
        parent_id: parent_id,
        type: "Filer",
        image: params[:file],
      }

    else
      data = {
        image: params[:file],
      }
    end
    p @current_user.id
    p @current_user

    @node = Node.new(data)
    @node.name = params[:file].original_filename
    @node.creater_id = @current_user.id


    if @node.save
      gen_log(@current_user.id, @current_ip,  params[:action], 1, "上传文件成功")
      render json: {code: 200, success: 1, msg: t('create_success'), data: @node.base_info } 
    else
      gen_log(@current_user.id, @current_ip,  params[:action], 0, "上传文件失败")
      render json: { code: 500, success: 0 , msg: @node.errors.full_messages.join(","), data: ""}
    end
    
  end
  


  #添加节点
  # post api/v1/create_node
  def create_node
    @node = Node.new(node_params)
    if @node.save
      gen_log(@current_user.id, @current_ip,  params[:action], 1, "添加节点#{node_params[:name]}成功")
      render json: {code: 200, success: 1, msg: t('create_success'), data: @node } 
    else
      gen_log(@current_user.id, @current_ip,  params[:action], 0, "添加节点#{node_params[:name]}失败")
      render json: { code: 500, success: 0 , msg: @node.errors.full_messages.join(","), data: ""}
    end
  end

  #节点删除功能
  # post api/v1/delete_node
  def delete_node
    gen_log(@current_user.id, @current_ip,  params[:action], 1, "节点删除#{@node.name}成功")

    @node.destroy
    render json: { code: 200, success: 1 , msg: "success", data: ""}
  end

  #节点修改
  # post api/v1/update_node
  def update_node
    if @node.update(node_params)
      render json: { code: 200, success: 1 , msg: "ok", data: @node}
      gen_log(@current_user.id, @current_ip,  params[:action], 1, "节点修改#{@node.name} 成功")

    else
      gen_log(@current_user.id, @current_ip,  params[:action], 0, "节点修改#{@node.name} 失败")
      render json: { code: 500, success: 0 , msg: @node.errors.full_messages.join(","), data: ""}
    end
  end

  private
    def set_node
      @node = Node.find(params[:id])  rescue nil
      if  @node.nil?
        msg = "记录不存在！"
        gen_log(@current_user.id, @current_ip,  params[:action], 0, "ID:#{params[:id]}, "+msg)
        render json: { code: 500, success: 0 , msg: msg, data: params[:action]}
      end
    end

    def node_params
      params.permit( :code, :name, :type, :root_id, :parent_id, :is_public, :file, :decrypt_file, :info, :remark, :creater_id, :updater_id, :created_at, :updated_at, :sort, :company_id)
    end

    def check_authorize
      begin
        authorize!(params[:action].to_sym, @node || Node)
      rescue CanCan::AccessDenied
        render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
      end
    end
end 