class Department < ApplicationRecord
    has_ancestry

    validates :code, length: { in: 2..20 },  presence: true, uniqueness:true
    validates :name, length: { in: 2..20 },  presence: true


    validates_uniqueness_of :name, :scope => :parent_id

    before_create :genereate_parent_code

    belongs_to :manager, class_name: "User", foreign_key: "manager_id", optional: true
    belongs_to :company, class_name: "Company", optional: true
    belongs_to :parent, class_name: "Department", optional: true
    

    has_many :children, class_name: "Department", foreign_key: "parent_id"

    attribute :created_time, :string
    attribute :updated_time, :string


  # def self.ransackable_associations(auth_object = nil)
  #   ["children", "company", "manager", "parent"]
  # end
  
  # def self.ransackable_attributes(auth_object = nil)
  #   ["code", "created_at", "id", "manager_id", "name", "parent_code", "parent_id","department_id", "remark", "status", "updated_at"]
  # end
    
    def skip_generate_code?
    # 返回 true 或false来决定是否跳过回调
        false # 或者 false 根据条件判断
    end

    def genereate_parent_code
        self.parent_code = parent.code rescue ''
    end


    def base_info
        {
          id: id,
          code: code,
          name: name,
          status: status,
          parent_id: parent_id,
          sort: sort,
          manager_id: manager_id,
          manager_name: manager.try(:name),
          parent_code: parent_code,
          remark: remark,
          created_time: created_time,
          updated_time: updated_time,
        }
    end


    def tree_info
      # 使用递归CTE获取所有后代部门
      if ActiveRecord::Base.connection.adapter_name.downcase.include?('mysql')
        # MySQL 8.0+ 的递归CTE
        query = <<~SQL
          WITH RECURSIVE department_tree AS (
            SELECT id, name, code, sort, status, parent_id, updated_at, remark, ancestry, 1 as level
            FROM departments
            WHERE id = #{id}
            UNION ALL
            SELECT d.id, d.name, d.code, d.sort, d.status, d.parent_id, d.updated_at, d.remark, d.ancestry, dt.level + 1
            FROM departments d
            INNER JOIN department_tree dt ON d.parent_id = dt.id
          )
          SELECT * FROM department_tree ORDER BY  sort asc
        SQL
      else
        # 其他数据库的递归查询
        query = <<~SQL
          WITH department_tree AS (
            SELECT id, name, code,sort, status, parent_id,updated_at, remark, ancestry, 1 as level
            FROM departments
            WHERE id = #{id}
            UNION ALL
            SELECT d.id, d.name, d.code, d.sort, d.status, d.parent_id, d.updated_at, d.remark, d.ancestry, dt.level + 1
            FROM departments d
            INNER JOIN department_tree dt ON d.parent_id = dt.id
          )
          SELECT * FROM department_tree ORDER BY  sort asc
        SQL
      end
      
      departments = Department.find_by_sql(query)
      departments_by_id = departments.index_by(&:id)
      
      build_tree(self, departments_by_id)
    end

    private

    def build_tree(department, departments_by_id)
      # 查找所有直接子部门
      children = departments_by_id.values.select { |d| d.parent_id == department.id }
      {
        id: department.id,
        name: department.name,
        children: children.sort_by(&:sort).map { |child| build_tree(child, departments_by_id) }
      }
    end

  # # 递归生成树形 JSON 结构
  # def as_json(options = {})
  #   super(options.merge(
  #     methods: [:children],
  #     except: [:created_at, :updated_at]
  #   ))
  # end

  # 自定义 children 方法返回子节点
  def children
    super.order(:code)  # 可按需要排序
  end



  #导入导出头部设置
  # Department.imp_exp_hander
  def self.imp_exp_hander
    %w( code name parent_id parent_code status manager_id remark company_id sort)
  end

end
