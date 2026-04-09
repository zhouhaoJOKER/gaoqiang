class Pm::Project < ApplicationRecord

    # columns: portfolio_id, parent_id, code, name, py, pinyin, logo, status_id, source_id, start_date, end_date, is_star, manager_id, description, degree, labels, custom_fields, user_id, updater_id, company_id, is_public, is_archived, is_suspended, suspend_at, suspender_id, ancestry, created_at, updated_at
    # attr_accessor :sort
    # serialize :members
    attribute :created_time, :string
    attribute :updated_time, :string

    # validates :code, length: { in: 2..20 },  presence: true, uniqueness:true
    validates :name, length: { in: 2..20 },  presence: true

    validates_uniqueness_of :name, :scope => :parent_id

    # scope :company_projects, -> {where(company_id: company_id)}
    scope :stars, -> {where(is_star: true)}


    # before_create :genereate_parent_code
    before_save :gen_py

    after_create :generate_default_stages

    # mount_uploader :file, FileUploader
    has_one_attached :file

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    belongs_to :company, class_name: "Company", optional: true

    belongs_to :manager, class_name: "User", foreign_key: "manager_id", optional: true
    belongs_to :portfolio, class_name: "Pm::Portfolio", foreign_key: "portfolio_id", optional: true

    belongs_to :status, class_name: "Property", optional: true, foreign_key: "status_id", optional: true
    belongs_to :source, class_name: "Property", foreign_key: "source_id", optional: true
    belongs_to :parent, class_name: "Pm::Project", optional: true
    
    has_many :children, class_name: "Pm::Project", foreign_key: "parent_id"
    has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            portfolio_id: portfolio_id,
            portfolio_name: (portfolio.name rescue ""),
            parent_id: parent_id,
            code: code,
            name: name,
            py: py,
            pinyin: pinyin,
            logo: logo,
            status_id: status_id,
            status_name: (status.name rescue ""),
            source_id: source_id,
            source_name: (source.name rescue ""),
            start_date: start_date,
            end_date: end_date,
            is_star: is_star,
            manager_id: manager_id,
            manager_name: (manager.name rescue ""),
            description: description,
            degree: degree,
            labels: labels,
            custom_fields: custom_fields,
            user_id: user_id,
            user_name: (user.name rescue ""),
            updater_name: (updater.name rescue ""),
            updater_id: updater_id,
            company_id: company_id,
            company_name: (company.name rescue ""),
            is_public: is_public,
            is_archived: is_archived,
            is_suspended: is_suspended,
            suspend_at: suspend_at,
            suspender_id: suspender_id,
            suspender_name: (suspender.name rescue ""),
            ancestry: ancestry,
            created_at: created_at,
            updated_at: updated_at,
            created_time: created_time,
            updated_time: updated_time,
            members: members.map{|m| m.base_info  rescue {} },
        }
    end

    def show_info
      {
        id: id,
        portfolio_id: portfolio_id,
        portfolio_name: (portfolio.name rescue ""),
        parent_id: parent_id,
        code: code,
        name: name,
      }
    end
    

    #导入导出头部设置
    # Department.imp_exp_hander
    def self.imp_exp_hander
        %w(portfolio_id  parent_id  code  name  py  pinyin  logo  status_id  source_id  start_date  end_date  is_star  manager_id  description  degree  labels  custom_fields  user_id  updater_id  company_id  is_public  is_archived  is_suspended  suspend_at  suspender_id  ancestry  created_at  updated_at)
    end

    # 示例计算金额
    # Crm::Client.last.sum_amount("receive_amount", 1000)
    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end


    # 生成默认的状态 这个不用生成
    def generate_default_stages
        stages = [
            { project_id: id, sort: "1", name: "计划任务" },
            { project_id: id, sort: "2", name: "进行中" },
            { project_id: id, sort: "3", name: "开发完成待测试" },
            { project_id: id, sort: "4", name: "已完成" }
        ]
        stages.each do |single|
            Pm::Stage.create(single)
        end
    end
end

# #项目 projects
# match "projects"  => "projects#index", via: :get
# match "projects"  => "projects#create", via: :post
# match "projects/:id"  => "projects#update", via: :put
# match "projects/:id"  => "projects#show", via: :get
# match "projects/:id"  => "projects#destroy", via: :delete
# match "projects/batch_action"  => "projects#batch_action", via: :post
# match "projects/import"  => "projects#import", via: :post
# match "projects_trees"  => "projects#company_trees", via: :get