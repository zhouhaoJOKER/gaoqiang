class Menu < ApplicationRecord
    # :path, :name, :link, :icon, :title, :is_link, :is_hide, :is_full_page, :is_affix, :keep_alive, :active_path, :sort, :remark, :parent_id, :user_id, :signs
    # validates_uniqueness_of :name, :scope => :company_id

    # serialize :menu_ids
    # has_ancestry


    belongs_to :parent, class_name: "Menu", optional: true
    belongs_to :company, class_name: "Company", optional: true
    belongs_to :folder, class_name: "Node", optional: true

    has_many :children, class_name: "Menu", foreign_key: "parent_id", dependent: :destroy
    # has_many :children, class_name: "Department", foreign_key: "parent_id"
    # MenuSign
    belongs_to :user, class_name: "::User", optional: true

    default_scope { order(sort: :asc, created_at: :asc) }

    scope :menus, -> { where(:menu_type => "menu")}
    scope :btns, -> { where(:menu_type => "btn")}
    scope :zsk_folder, -> { where(:title => "企业知识库")}


  def check_zsk_folder(company_id)
    if self.folder_id and self.folder.children.present?
      p "check_zsk_folder 存在"
      result =  folder.children.last
      # result.update( company_id: company_id)
    else
      result = Node.create(
        type: "Folder",
        parent_id: self.folder_id,
        company_id: company_id,
        name: "问答知识库",
        ancestry: self.folder_id
      )
      result.update_columns(parent_id: self.folder_id)
      p "check_zsk_folder 不存在"
      
    end
    result
  end
  
 
  def self.ransackable_associations(auth_object = nil)
    ["children", "company", "parent", "user", "signs"]
  end

  def signs_arrary
    signs.split(",") rescue []
  end

  def auth_info
    {
      "id": id,
      "parent_id": parent_id,
      "title": title,
      "sort": sort,
      "authMark": name,
    }
  end

  def less_info
    {
      "id": id,
      "title": title,
    }
  end

  def thin_info
    {
      "id": id,
      "name": name,
      "title": title,
      children:( children.map{|e|e.thin_info} rescue [])
    }
  end

  def new_menu_info
    {
        "id": id,
        "parent_id": parent_id,
        "folder_id": folder_id,
        "path": path,
	      "link": link,
        "is_hide": is_hide,
      	"name": name,
        "component": component,
        "sort": sort,
        "menu_type": menu_type,
        "updated_time": updated_time,
      	"meta": {
          authList: (children.btns.map{|e|e.auth_info} rescue []),
          "icon": icon,
          "title": title,
          "activeMenu": active_path
        },
        children:( children.menus.map{|e|e.new_menu_info} rescue [])
    }
  end
  
    

    def base_info
      {
        id: id,
        parent_id: parent_id,
        company_id: company_id,
        company_name: (company.name rescue ''),
        folder_id: folder_id,
        path: path,
        name: name,
        component: component,
        updated_time: updated_time,
        menu_type: menu_type,
        meta: {
          title: title,
          authList: (children.includes(:children).btns.map{|e|e.auth_info} rescue []),
          icon: icon,
          isLink: is_link,
          isEnable: is_enable,
          isHide: is_hide,
          isHideTab: is_hide_tab,
          isFullPage: is_full_page,
          isAffix: is_affix,
          keepAlive: keep_alive,
          activePath: active_path,
          showBadge: show_badge,
          fixedTab: fixed_tab,
          isIframe: is_iframe,
          link: link,
          showTextBadge: show_text_badge,
          # isFirstLevel
        },
        sort: sort,
        children:( children.includes(:children).menus.map{|e|e.base_info} rescue [])
      }
    end
    

    # # 递归生成树形 JSON 结构
    # def as_json(options = {})
    #   super(options.merge(
    #     methods: [:children],
    #     except: [:created_at, :updated_at]
    #   ))
    # end

    # # 自定义 children 方法返回子节点
    # def children
    #   super.order("sort")  # 可按需要排序
    # end
 


  def build_ancestry_paths
    # 找到所有根节点 (parent_id 为 nil)
    roots = Menu.where(parent_id: nil)
    
    # 处理每个根节点及其后代
    roots.each do |root|
      process_node(root)
    end
  end

  def process_node(node)
    # 获取节点的所有直接子节点
    children = Menu.where(parent_id: node.id)
    
    children.each do |child|
      # 设置子节点的 ancestry 路径
      child_ancestry = if node.ancestry.present?
                         "#{node.ancestry}/#{node.id}"
                       else
                         node.id.to_s
                       end
      
      # 直接更新数据库（跳过回调和验证）
      child.update_columns(ancestry: child_ancestry)
      
      # 递归处理子节点
      process_node(child)
    end
  end
    
end
