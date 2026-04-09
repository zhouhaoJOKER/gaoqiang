class Tms::Plan < ApplicationRecord

    # columns: contract_id,code,name,date,required_warehouse_entry_date,client_id,client_name,contract_code,product_id,product_name,qty,specification,outer_box_dimensions,merchandiser_id,pieces,warehouse_address,is_ready,kind_id,remark,warehouse_entry_note,volume_inspection,gross_weight_inspection,sort,user_id,updater_id,py,status,ship_date,shiper_id,vehicle_usage,direct_info,, created_at, updated_at
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
    belongs_to :client, class_name: "Crm::Client", foreign_key: "client_id", optional: true
    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    belongs_to :merchandiser, class_name: "Merchandiser", foreign_key: "merchandiser_id", optional: true
    belongs_to :kind, class_name: "Kind", foreign_key: "kind_id", optional: true
    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    belongs_to :shiper, class_name: "Shiper", foreign_key: "shiper_id", optional: true
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            contract_id: contract_id,
            contract_name: (contract.name rescue ""),
            code: code,
            name: name,
            date: date,
            required_warehouse_entry_date: required_warehouse_entry_date,
            client_id: client_id,
            client_name: (client.name rescue ""),
            client_name: client_name,
            contract_code: contract_code,
            product_id: product_id,
            product_name: (product.name rescue ""),
            product_name: product_name,
            qty: qty,
            specification: specification,
            outer_box_dimensions: outer_box_dimensions,
            merchandiser_id: merchandiser_id,
            merchandiser_name: (merchandiser.name rescue ""),
            pieces: pieces,
            warehouse_address: warehouse_address,
            is_ready: is_ready,
            kind_id: kind_id,
            kind_name: (kind.name rescue ""),
            remark: remark,
            warehouse_entry_note: warehouse_entry_note,
            volume_inspection: volume_inspection,
            gross_weight_inspection: gross_weight_inspection,
            sort: sort,
            user_id: user_id,
            user_name: (user.name rescue ""),
            updater_id: updater_id,
            updater_name: (updater.name rescue ""),
            py: py,
            status: status,
            ship_date: ship_date,
            shiper_id: shiper_id,
            shiper_name: (shiper.name rescue ""),
            vehicle_usage: vehicle_usage,
            direct_info: direct_info,
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
    # Tms::Plan.imp_exp_hander
    def self.imp_exp_hander
        %w(contract_id  code  name  date  required_warehouse_entry_date  client_id  client_name  contract_code  product_id  product_name  qty  specification  outer_box_dimensions  merchandiser_id  pieces  warehouse_address  is_ready  kind_id  remark  warehouse_entry_note  volume_inspection  gross_weight_inspection  sort  user_id  updater_id  py  status  ship_date  shiper_id  vehicle_usage  direct_info  created_at  updated_at)
    end

    # 示例计算金额
    # Tms::Plan.last.sum_amount("receive_amount", 1000)
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
# #Tms/plan plans
# match "plans"  => "plans#index", via: :get
# match "plans"  => "plans#create", via: :post
# match "plans/:id"  => "plans#update", via: :put
# match "plans/:id"  => "plans#show", via: :get
# match "plans/:id"  => "plans#destroy", via: :delete
# match "plans/batch_action"  => "plans#batch_action", via: :post
# match "plans/import"  => "plans#import", via: :post
