class Iqc::Pkg < ApplicationRecord

    # columns: contract_id,product_id,name,code,batch_number,submitting_unit,inspection_basis,batch_qty,request_inspection_date,report_date,record_content,conclusion,remark,reviewer_id,inspector_id,user_id,updater_id,py,, created_at, updated_at
    # attr_accessor :sort
    # serialize :members
    attribute :created_time, :string
    attribute :updated_time, :string

    # validates :code, length: { in: 2..20 },  presence: true, uniqueness:true
    validates :name, length: { in: 2..20 },  presence: true

    # scope :company_projects, -> {where(company_id: company_id)}
    # scope :stars, -> {where(is_star: true)}


    # before_create :genereate_parent_code
    before_save :gen_py

    # after_create :generate_default_stages

    # mount_uploader :file, FileUploader
    has_one_attached :file
    has_many_attached :files

    belongs_to :contract, class_name: "Pur::Contract", foreign_key: "contract_id", optional: true
    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    belongs_to :reviewer, class_name: "Reviewer", foreign_key: "reviewer_id", optional: true
    belongs_to :inspector, class_name: "Inspector", foreign_key: "inspector_id", optional: true
    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            contract_id: contract_id,
            contract_name: (contract.name rescue ""),
            product_id: product_id,
            product_name: (product.name rescue ""),
            name: name,
            code: code,
            batch_number: batch_number,
            submitting_unit: submitting_unit,
            inspection_basis: inspection_basis,
            batch_qty: batch_qty,
            request_inspection_date: request_inspection_date,
            report_date: report_date,
            record_content: record_content,
            conclusion: conclusion,
            remark: remark,
            reviewer_id: reviewer_id,
            reviewer_name: (reviewer.name rescue ""),
            inspector_id: inspector_id,
            inspector_name: (inspector.name rescue ""),
            user_id: user_id,
            user_name: (user.name rescue ""),
            updater_id: updater_id,
            updater_name: (updater.name rescue ""),
            py: py,
            created_at: created_at,
            updated_at: updated_at,
            created_time: created_time,
            updated_time: updated_time,
        }
    end

    def show_info
        {
        id: id,
        code: code,
        name: name,
        }
    end
    

    #导入导出头部设置
    # Iqc::Pkg.imp_exp_hander
    def self.imp_exp_hander
        %w(contract_id  product_id  name  code  batch_number  submitting_unit  inspection_basis  batch_qty  request_inspection_date  report_date  record_content  conclusion  remark  reviewer_id  inspector_id  user_id  updater_id  py  created_at  updated_at)
    end

    # 示例计算金额
    # Iqc::Pkg.last.sum_amount("receive_amount", 1000)
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
# #Iqc/pkg pkgs
# match "pkgs"  => "pkgs#index", via: :get
# match "pkgs"  => "pkgs#create", via: :post
# match "pkgs/:id"  => "pkgs#update", via: :put
# match "pkgs/:id"  => "pkgs#show", via: :get
# match "pkgs/:id"  => "pkgs#destroy", via: :delete
# match "pkgs/batch_action"  => "pkgs#batch_action", via: :post
# match "pkgs/import"  => "pkgs#import", via: :post
