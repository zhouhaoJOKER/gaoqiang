class Iqc::Raw < ApplicationRecord

    # columns: contract_id,product_id,name,code,supplier_id,supplier_name,batch_number,inspection_qty,request_inspection_date,inspection_date,inspection_basis,std_sample_m,std_sample_x,std_sample_a_r_1,std_sample_a_r_2,ph_value,moisture_percent,other_indicators,conclusion,issue_ncr,notes,inspector_id,reviewer_id,user_id,updater_id,py,, created_at, updated_at
    # attr_accessor :sort
    # serialize :members
    attribute :created_time, :string
    attribute :updated_time, :string

    # validates :code, length: { in: 2..20 },  presence: true, uniqueness:true
    validates :name, length: { minimum: 2, maximum: 255 }, presence: true

    # scope :company_projects, -> {where(company_id: company_id)}
    # scope :stars, -> {where(is_star: true)}


    # before_create :genereate_parent_code
    before_save :gen_py

    # after_create :generate_default_stages

    # mount_uploader :file, FileUploader
    has_one_attached :file
    has_many_attached :files

    belongs_to :contract, class_name: "Fm::Contract", foreign_key: "contract_id", optional: true
    belongs_to :pur_contract, class_name: "Pur::Contract", foreign_key: "pur_contract_id", optional: true
    belongs_to :pur_collection, class_name: "Pur::Collection", foreign_key: "pur_collection_id", optional: true
    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    belongs_to :supplier, class_name: "Pur::Supplier", foreign_key: "supplier_id", optional: true
    belongs_to :inspector, class_name: "Inspector", foreign_key: "inspector_id", optional: true
    belongs_to :reviewer, class_name: "Reviewer", foreign_key: "reviewer_id", optional: true
    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record


    def skip_generate_code?
        # 返回 true 或false来决定是否跳过回调
        false # 或者 false 根据条件判断
    end

    def base_info
        {
            id: id,
            contract_id: contract_id,
            contract_name: (contract.name rescue ""),
            pur_contract_id: pur_contract_id,
            pur_contract_name: (pur_contract.contract_title rescue ""),
            pur_collection_id: pur_collection_id,
            product_id: product_id,
            product_name: (product.name rescue ""),
            name: name,
            code: code,
            supplier_id: supplier_id,
            supplier_name: (supplier.name rescue ""),
            supplier_name: supplier_name,
            batch_number: batch_number,
            inspection_qty: inspection_qty,
            request_inspection_date: request_inspection_date,
            inspection_date: inspection_date,
            inspection_basis: inspection_basis,
            std_sample_m: std_sample_m,
            std_sample_x: std_sample_x,
            std_sample_a_r_1: std_sample_a_r_1,
            std_sample_a_r_2: std_sample_a_r_2,
            ph_value: ph_value,
            moisture_percent: moisture_percent,
            other_indicators: other_indicators,
            conclusion: conclusion,
            issue_ncr: issue_ncr,
            notes: notes,
            inspector_id: inspector_id,
            inspector_name: (inspector.name rescue ""),
            reviewer_id: reviewer_id,
            reviewer_name: (reviewer.name rescue ""),
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
    # Iqc::Raw.imp_exp_hander
    def self.imp_exp_hander
        %w(contract_id  pur_contract_id  pur_collection_id  product_id  name  code  supplier_id  supplier_name  batch_number  inspection_qty  request_inspection_date  inspection_date  inspection_basis  std_sample_m  std_sample_x  std_sample_a_r_1  std_sample_a_r_2  ph_value  moisture_percent  other_indicators  conclusion  issue_ncr  notes  inspector_id  reviewer_id  user_id  updater_id  py  created_at  updated_at)
    end

    # 示例计算金额
    # Iqc::Raw.last.sum_amount("receive_amount", 1000)
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
# #Iqc/raw raws
# match "raws"  => "raws#index", via: :get
# match "raws"  => "raws#create", via: :post
# match "raws/:id"  => "raws#update", via: :put
# match "raws/:id"  => "raws#show", via: :get
# match "raws/:id"  => "raws#destroy", via: :delete
# match "raws/batch_action"  => "raws#batch_action", via: :post
# match "raws/import"  => "raws#import", via: :post
