class Mfg::PlanLine < ApplicationRecord

    # columns: contract_id,plan_id,date,line_id,line_name,product_id,product_name,name,product_kind,qty_unit,remark,sort,user_id,, created_at, updated_at
    # attr_accessor :sort
    # serialize :members
    attribute :created_time, :string
    attribute :updated_time, :string

    # validates :code, length: { in: 2..20 },  presence: true, uniqueness:true
    validates :name, length: { in: 2..20 },  presence: true

    # scope :company_projects, -> {where(company_id: company_id)}
    # scope :stars, -> {where(is_star: true)}


    # before_create :genereate_parent_code

    # after_create :generate_default_stages

    # mount_uploader :file, FileUploader
    has_one_attached :file
    has_many_attached :files

    belongs_to :contract, class_name: "Pur::Contract", foreign_key: "contract_id", optional: true
    belongs_to :plan, class_name: "Mfg::Plan", foreign_key: "plan_id", optional: true
    belongs_to :line, class_name: "Line", foreign_key: "line_id", optional: true
    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            contract_id: contract_id,
            contract_name: (contract.name rescue ""),
            plan_id: plan_id,
            plan_name: (plan.name rescue ""),
            date: date,
            line_id: line_id,
            line_name: (line.name rescue ""),
            line_name: line_name,
            product_id: product_id,
            product_name: (product.name rescue ""),
            product_name: product_name,
            name: name,
            product_kind: product_kind,
            qty_unit: qty_unit,
            remark: remark,
            sort: sort,
            user_id: user_id,
            user_name: (user.name rescue ""),
            created_at: created_at,
            updated_at: updated_at,
            created_time: created_time,
            updated_time: updated_time,
        }
    end

    def show_info
        {
        id: id,
        name: name,
        }
    end
    

    #导入导出头部设置
    # Mfg::PlanLine.imp_exp_hander
    def self.imp_exp_hander
        %w(contract_id  plan_id  date  line_id  line_name  product_id  product_name  name  product_kind  qty_unit  remark  sort  user_id  created_at  updated_at)
    end

    # 示例计算金额
    # Mfg::PlanLine.last.sum_amount("receive_amount", 1000)
    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end


    # 生成默认的状态 这个不用生成
    # def generate_default_stages
    #     stages = [
    #         { project_id: id, sort: "1", name: "计划任务" },
    #         { project_id: id, sort: "2", name: "进行中" },
    #         { project_id: id, sort: "3", name: "开发完成待测试" },
    #         { project_id: id, sort: "4", name: "已完成" }
    #     ]
    #     stages.each do |single|
    #         Pm::Stage.create(single)
    #     end
    # end
end
# #Mfg/plan line plan_lines
# match "plan_lines"  => "plan_lines#index", via: :get
# match "plan_lines"  => "plan_lines#create", via: :post
# match "plan_lines/:id"  => "plan_lines#update", via: :put
# match "plan_lines/:id"  => "plan_lines#show", via: :get
# match "plan_lines/:id"  => "plan_lines#destroy", via: :delete
# match "plan_lines/batch_action"  => "plan_lines#batch_action", via: :post
# match "plan_lines/import"  => "plan_lines#import", via: :post
