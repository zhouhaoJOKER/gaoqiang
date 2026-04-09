class Api::V1::MenusController < Api::V1::BaseController
  require 'set'
  before_action :set_menu, only: [:delete, :update, :show]
  before_action :check_authorize

  def menus
    current_menu_ids = @current_user.role.menu_ids
    menus = Menu.where(parent_id: nil, menu_type: "menu", is_enable: 1).includes(parent: :children).order("sort asc")
    render json: {
      "code": 200,
      "data": menus.map{|e|e.base_info},
      "msg": "请求成功"
    }
  end

  #访问菜单
  # get api/v1/menu_trees
  def menu_trees
      menus = Menu.includes(:company, :parent, :children).order("sort asc")
      @q = menus.ransack(params[:q])
      @menus = @q.result().paginate(:page => params[:page], :per_page => 2000) #, :total_entries =>  Menu.total_entries)
      gen_log(@current_user.id, @current_ip,  params[:action], 1, "访问树状菜单列表")
      render json: {code: 200, success: 1 , msg: "ok", data: @menus.map{|e|e.base_info}, meta: { total: @menus.total_entries, per_page: per_page, page: page }}
  end

  
  #访问菜单
  # get api/v1/menus
  def index
    if params[:list]
      gen_log(@current_user.id, @current_ip,  params[:action], 1, "访问菜单列表")
      menus = Menu.includes(:children).order("sort asc")
      @menus = Menu.ransack(params[:q]).result()
      # @menus = Menu.includes(parent: :children).where(parent_id: nil)
      render json: {code: 200, success: 1 , msg: "ok", data: @menus}
    elsif params[:mate]
      menus = Menu.includes(:children).order("sort asc")
      @q = menus.ransack(params[:q])
      @menus = @q.result().paginate(:page => params[:page], :per_page => per_page) #, :total_entries =>  Menu.total_entries)
      gen_log(@current_user.id, @current_ip,  params[:action], 1, "访问菜单列表")
      render json: {code: 200, success: 1 , msg: "ok", data: @menus.map{|e|e.base_info}, meta: { total: @menus.total_entries, per_page: per_page, page: page }}
    else
      menus = Menu.where(parent_id: nil).includes(:children).order("sort asc")
      @q = menus.ransack(params[:q])
      @menus = @q.result().paginate(:page => params[:page], :per_page => per_page) #, :total_entries =>  Menu.total_entries)
      gen_log(@current_user.id, @current_ip,  params[:action], 1, "访问菜单列表")
      render json: {code: 200, success: 1 , msg: "ok", data: @menus.map{|e|e.base_info}, meta: { total: @menus.total_entries, per_page: per_page, page: page }}
    end
  end

  #添加菜单
  # post api/v1/create
  def create
    if  params[:menu_type] == "btn"
      menu  = Menu.find_by(id: params["parent_id"])
      if menu.nil? and params[:permissions].length == 0
        render json: { code: 500, success: 0 , msg: "父级菜单不存在或权限不能为空", data: ""}
        return
      else
        menu.children.btns.delete_all
        i=0
        params[:permissions].each do |single|
          info = {
            parent_id: params["parent_id"],
            menu_type: "btn",
            title: single["title"],
            name: single["name"],
            is_enable: 1,
          }
          Menu.create(info)
          i+=1
        end
        gen_log(@current_user.id, @current_ip,  params[:action], 1, "创建成功#{i}个权限按钮成功")
        render json: {code: 200, success: 1, msg: t('create_success'), data: "创建成功#{i}个权限按钮" }
      end

    else
      @menu = Menu.new(menu_params)
      # @menu.title = params["name"]
      # @menu.signs = params["signs"].join(",") if params["signs"].present?  
      if @menu.save
        # 菜单创建后自动创建对应的文件夹目录，并更新目录id到菜单里面。
        if @menu.menu_type == "menu"
          folder = Folder.new(
            name: @menu.name,
            creater_id: @current_user.id,
            company_id: @menu.company_id,
          )
          if folder.save
            @menu.update_columns(folder_id: folder.id)
          end
        end

        gen_log(@current_user.id, @current_ip,  params[:action], 1, "添加菜单#{menu_params[:name]}成功")
        render json: {code: 200, success: 1, msg: t('create_success'), data: @menu } 
      else
        gen_log(@current_user.id, @current_ip,  params[:action], 0, "添加菜单#{menu_params[:name]}失败")
        render json: { code: 500, success: 0 , msg: @menu.errors.full_messages.join(","), data: ""}
      end
    end
    
  end

  def show

    gen_log(@current_user.id, @current_ip,  params[:action], 1, "菜单详情#{@menu.name}成功")
    render json: { code: 200, success: 1 , msg: "ok", data: @menu}
  end 

  #菜单删除功能
  # post api/v1/delete
  def delete
    gen_log(@current_user.id, @current_ip,  params[:action], 1, "菜单删除#{@menu.name}成功")
    @menu.destroy
    render json: { code: 200, success: 1 , msg: "success", data: ""}
  end

  #菜单修改
  # post api/v1/update
  def update
    if @menu.update(menu_params)
      signs = params["signs"].join(",") rescue ''
      @menu.update(signs: signs) if signs.present?

      # 禁用父菜单时，同步递归禁用所有子菜单（含按钮权限）
      if menu_params.key?(:is_enable) && !ActiveModel::Type::Boolean.new.cast(menu_params[:is_enable])
        disable_descendant_menus!(@menu.id)
      end

      render json: { code: 200, success: 1 , msg: "ok", data: @menu}
      gen_log(@current_user.id, @current_ip,  params[:action], 1, "菜单修改#{@menu.name} 成功")

    else
      gen_log(@current_user.id, @current_ip,  params[:action], 0, "菜单修改#{@menu.name} 失败")
      render json: { code: 500, success: 0 , msg: @menu.errors.full_messages.join(","), data: ""}
    end
  end


  # 根据用户菜单ID获取完整菜单树结构
  # get api/v1/user_menu_tree
  def menu
    if @current_user.id == 1
      current_menu_ids = Menu.where(is_enable: true).map(&:id)
    else
      current_menu_ids = @current_user.role.menu_ids
    end
    # 获取用户角色的所有菜单ID（包含menu和btn类型）
    # 获取所有相关的菜单记录
    all_relevant_menus = Menu.where(id: current_menu_ids)
    # 收集所有需要的菜单ID（包括用户有权限的菜单和所有父级菜单）
    all_needed_ids = Set.new
    all_relevant_menus.each do |menu|
      # 添加当前菜单ID
      all_needed_ids.add(menu.id)
      
      # 递归查找所有父级菜单
      parent = menu.parent
      while parent.present?
        all_needed_ids.add(parent.id)
        parent = parent.parent
      end
    end
    
    # 获取所有顶级菜单，预加载关联数据以提高性能
    root_menus = Menu.where(parent_id: nil, id: all_needed_ids.to_a)
                    .includes(:children, :parent, :company, folder: {})
                    .order(sort: :asc)
    
    # 构建菜单树，使用base_info方法确保数据格式一致
    menu_tree = build_permission_menu_tree(root_menus, all_needed_ids.to_a, current_menu_ids)
    
    render json: {
      "code": 200,
      "data": menu_tree,
      "msg": "请求成功"
    }
  end
  
  private
    
    # 使用base_info递归构建带有权限控制的菜单树
    def build_permission_menu_tree(menus, all_needed_ids, allowed_menu_ids)
      menus.map do |menu|
        # 只处理在需要ID列表中的菜单
        next unless all_needed_ids.include?(menu.id)
        
        # 使用模型的base_info方法获取基础数据结构
        menu_item = menu.base_info
        
        # 递归处理子菜单
        if menu.children.present?
          # 只处理菜单类型的子节点，过滤掉按钮类型
          filtered_children = menu.children.menus
                               .select { |child| all_needed_ids.include?(child.id) }
                               .sort_by(&:sort)
          
          menu_item[:children] = build_permission_menu_tree(filtered_children, all_needed_ids, allowed_menu_ids)
        else
          menu_item[:children] = []
        end
        
        # 筛选按钮权限，只保留用户有权限的按钮
        if menu_item[:meta] && menu_item[:meta][:authList]
          menu_item[:meta][:authList] = menu_item[:meta][:authList].select do |btn|
            allowed_menu_ids.include?(btn[:id])
          end
        end
        
        menu_item
      end.compact
    end


  private

    # 递归禁用后代节点（menu + btn）
    def disable_descendant_menus!(menu_id)
      parent_ids = [menu_id]

      loop do
        child_ids = Menu.where(parent_id: parent_ids).pluck(:id)
        break if child_ids.empty?

        Menu.where(id: child_ids).update_all(is_enable: false)
        parent_ids = child_ids
      end
    end

    def set_menu
      @menu = Menu.find(params[:id])  rescue nil
      if  @menu.nil?
        msg = "记录不存在！"
        gen_log(@current_user.id, @current_ip,  params[:action], 0, "ID:#{params[:id]}, "+msg)
        render json: { code: 500, success: 0 , msg: msg, data: params[:action]}
      end
    end

    def menu_params
      params.permit( :path,  :name,  :link,  :icon,  :title,  :is_link,  :is_hide,  :is_full_page,  :is_iframe,  :keep_alive,  :active_path,  :sort,  :remark,  :parent_id,  :user_id,  :component,  :company_id,  :signs,  :folder_id,  :menu_type,  :is_enable,  :show_badge,  :fixed_tab,  :is_hide_tab,  :show_text_badge,  :is_affix )
    end
 
    # 递归构建带有权限控制的菜单树
    def build_menu_tree_with_permissions(menus, all_menus_map, allowed_ids)
      menus.map do |menu|
        # 创建菜单项，包含目录信息
        menu_item = {
          id: menu.id,
          parent_id: menu.parent_id,
          company_id: menu.company_id,
          company_name: (menu.company.name rescue ''),
          folder_id: menu.folder_id,
          folder_info: menu.folder.present? ? {
            id: menu.folder.id,
            name: menu.folder.name,
            parent_id: menu.folder.parent_id
          } : nil,
          path: menu.path,
          name: menu.name,
          title: menu.title,
          component: menu.component,
          menu_type: menu.menu_type,
          sort: menu.sort,
          meta: {
            title: menu.title,
            icon: menu.icon,
            isLink: menu.is_link,
            isEnable: menu.is_enable,
            isHide: menu.is_hide,
            isHideTab: menu.is_hide_tab,
            isFullPage: menu.is_full_page,
            isAffix: menu.is_affix,
            keepAlive: menu.keep_alive,
            activePath: menu.active_path,
            showBadge: menu.show_badge,
            fixedTab: menu.fixed_tab,
            isIframe: menu.is_iframe,
            link: menu.link,
            showTextBadge: menu.show_text_badge,
            # 按钮权限列表，只包含用户有权限的按钮
            authList: []
          },
          children: []
        }
        
        # 添加按钮权限列表
        if menu.children.present?
          menu_item[:meta][:authList] = menu.children
                                           .select { |btn| btn.menu_type == 'btn' && allowed_ids.include?(btn.id) }
                                           .map { |btn| {
                                             id: btn.id,
                                             parent_id: btn.parent_id,
                                             title: btn.title,
                                             authMark: btn.name
                                           } }
        end
        
        # 递归构建子菜单，但只包含用户有权限的菜单或为了显示结构必要的父菜单
        if menu.children.present?
          menu_item[:children] = build_menu_tree_with_permissions(
            menu.children,
            all_menus_map,
            allowed_ids
          ).select { |child| child.present? }
        end
        
        # 如果这个菜单既不是用户有权限的，也没有任何有权限的子菜单，则不返回这个菜单项
        has_permission = allowed_ids.include?(menu.id)
        has_visible_children = menu_item[:children].present?
        has_auth_buttons = menu_item[:meta][:authList].present? && menu.menu_type == 'menu'
        
        if has_permission || has_visible_children || has_auth_buttons
          menu_item
        else
          nil
        end
      end.compact
    end

    def check_authorize
      begin
        authorize!(params[:action].to_sym, @menu || Menu)
      rescue CanCan::AccessDenied
        render json: { code: 403, success: 0, msg: "没有权限访问", data: "" }, status: :forbidden
      end
    end

end