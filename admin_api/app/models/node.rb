class Node < ApplicationRecord
  #  :code, :name, :type, :root_id, :parent_id, :is_public, :file, :decrypt_file, :info, :remark, :creater_id, :updater_id, :sort

    scope :folder, -> { where(:type => "Folder")}
    scope :filer, -> { where(:type => "Filer")}
    
    belongs_to :company, class_name: "Company", optional: true
    belongs_to :parent, class_name: "Node", optional: true
    belongs_to :root, class_name: "Node", optional: true
    has_many :children, class_name: "Node", foreign_key: "parent_id"

    belongs_to :creater, class_name: "::User", optional: true
    belongs_to :updater, class_name: "::User", optional: true

    # has_one_attached :file, service: :minio
    # has_one_attached :decrypt_file, service: :minio

    has_one_attached :image


  def self.ransackable_attributes(auth_object = nil)
    ["code", "parent", "creater_id", "decrypt_file", "file", "name", "id_value", "info", "is_public", "name", "parent_id", "remark", "root_id", "sort", "type", "updated_at", "updater_id", "created_at"]
  end


  def all_tree_info
    {
      id: id,
      pid: parent_id,
      pname: (parent.name rescue ''),
      name: name,
      is_public: is_public,
      isLeaf: !children.folder.present?,
      children: children.folder.map{|e|e.all_tree_info}
    }
  end
  

  def tree_info
    {
      id: id,
      pid: parent_id,
      pname: (parent.name rescue ''),
      name: name,
      is_public: is_public,
      isLeaf: !children.folder.present?
    }
  end
  

    def node_info
      f_name = name 
      f_name = (image.blob.filename rescue '') if type == "Filer"
        {
          id: id,
          code: code,
          name: f_name,
          type: type,
          file: image.blob,
          file_name: (image.blob.filename rescue ''),
          file_url: (image.blob.url rescue ''),
          parent_id: parent_id,
          is_public: is_public,
          creater_id: creater_id,
          updater_id: updater_id,
          sort: sort,
          children: children.folder.map{|e|e.node_info},
          # created_at: created_at,
          created_at: bst(created_at),
        }
    end
    
    def base_info
      f_name = name 
      f_name = (image.blob.filename rescue '') if type == "Filer"
        {
          id: id,
          code: code,
          name: f_name,
          type: type,
          file: image.blob,
          file_name: (image.blob.filename rescue ''),
          file_url: (image.blob.url rescue ''),
          parent_id: parent_id,
          is_public: is_public,
          creater_id: creater_id,
          updater_id: updater_id,
          remark: remark,
          sort: sort,
          # created_at: created_at,

          created_at: bst(created_at),

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
    #   super.order(:sort)  # 可按需要排序
    # end
end
