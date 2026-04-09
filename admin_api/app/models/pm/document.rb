class Pm::Document < ApplicationRecord
    has_ancestry

  # :project_id, :parent_id, :kind, :name, :py, :content, :user_id, :updater_id, :is_public, :ancestry

    # validates :code, length: { in: 2..20 },  presence: true, uniqueness:true
    validates :name, length: { in: 2..256 },  presence: true
    validates_uniqueness_of :name, :scope => :project_id

    # before_create :genereate_parent_code
    before_save :gen_py
    # after_create :generate_default_stages

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    
    # belongs_to :company, class_name: "Company", optional: true
    belongs_to :project, class_name: "Pm::Project", optional: true
    belongs_to :parent, class_name: "Pm::File", optional: true
    has_many :children, class_name: "Pm::File", foreign_key: "parent_id"

    attribute :created_time, :string
    attribute :updated_time, :string

    def base_info
      {
        id: id,
        project_id: project_id,
        project_name: (project.name rescue ""),
        parent_id: parent_id,
        parent_name: (parent.name rescue ""),
        name: name,
        py: py,
        kind: kind,
        content: content,
        is_public: is_public,
        user_id: user_id,
        user_name: (user.name rescue ""),
        updater_id: updater_id,
        updater_name: (updater.name rescue ""),
        children: (children.map{|e|e.base_info} rescue []),
        ancestry: ancestry,
        created_at: created_at,
        updated_at: updated_at
      }
      
    end


    def tree_info
      # 使用递归CTE获取所有后代部门
      if ActiveRecord::Base.connection.adapter_name.downcase.include?('mysql')
        # MySQL 8.0+ 的递归CTE
        query = <<~SQL
          WITH RECURSIVE document_tree AS (
            SELECT id, name, is_public, kind, py, parent_id, updated_at,  ancestry, 1 as level
            FROM pm_documents
            WHERE id = #{id}
            UNION ALL
            SELECT d.id, d.name, d.is_public, d.kind, d.py, d.parent_id, d.updated_at, d.ancestry, dt.level + 1
            FROM pm_documents d
            INNER JOIN document_tree dt ON d.parent_id = dt.id
          )
          SELECT * FROM document_tree ORDER BY  kind asc
        SQL
      else
        # 其他数据库的递归查询
        query = <<~SQL
          WITH document_tree AS (
            SELECT id, name, is_public,kind, py, parent_id,updated_at, ancestry, 1 as level
            FROM pm_documents
            WHERE id = #{id}
            UNION ALL
            SELECT d.id, d.name, d.is_public, d.kind, d.py, d.parent_id, d.updated_at,  d.ancestry, dt.level + 1
            FROM pm_documents d
            INNER JOIN document_tree dt ON d.parent_id = dt.id
          )
          SELECT * FROM document_tree ORDER BY  kind asc
        SQL
      end
      
      documents = Department.find_by_sql(query)
      documents_by_id = documents.index_by(&:id)
      
      build_tree(self, documents_by_id)
    end

    private

    def build_tree(document, documents_by_id)
      # 查找所有直接子部门
      children = documents_by_id.values.select { |d| d.parent_id == document.id }
      {
        id: document.id,
        name: document.name,
        kind: document.kind,
        py: document.py,
        is_public: document.is_public,
        children: children.sort_by(&:kind).map { |child| build_tree(child, documents_by_id) }
      }
    end
    
end
