class Mfg::Batching < ApplicationRecord

    # columns: contract_id,product_id,product_name,production_batch_number,batching_ratio,batching_qty,production_date,batching_qty_recheck,production_requirements_notes,order_placed_id,weighing_id,weighing_supervised_id,operator_id,user_id,updater_id,py,, created_at, updated_at
    # attr_accessor :sort
    # serialize :members
    attribute :created_time, :string
    attribute :updated_time, :string


    # scope :company_projects, -> {where(company_id: company_id)}
    # scope :stars, -> {where(is_star: true)}


    # before_create :genereate_parent_code

    # after_create :generate_default_stages

    # mount_uploader :file, FileUploader
    has_one_attached :file
    has_many_attached :files

    belongs_to :contract, class_name: "Pur::Contract", foreign_key: "contract_id", optional: true
    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    belongs_to :order_placed, class_name: "OrderPlaced", foreign_key: "order_placed_id", optional: true
    belongs_to :weighing, class_name: "Weighing", foreign_key: "weighing_id", optional: true
    belongs_to :weighing_supervised, class_name: "WeighingSupervised", foreign_key: "weighing_supervised_id", optional: true
    belongs_to :operator, class_name: "Operator", foreign_key: "operator_id", optional: true
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
            product_name: product_name,
            production_batch_number: production_batch_number,
            batching_ratio: batching_ratio,
            batching_qty: batching_qty,
            production_date: production_date,
            batching_qty_recheck: batching_qty_recheck,
            production_requirements_notes: production_requirements_notes,
            order_placed_id: order_placed_id,
            order_placed_name: (order_placed.name rescue ""),
            weighing_id: weighing_id,
            weighing_name: (weighing.name rescue ""),
            weighing_supervised_id: weighing_supervised_id,
            weighing_supervised_name: (weighing_supervised.name rescue ""),
            operator_id: operator_id,
            operator_name: (operator.name rescue ""),
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
        }
    end
    

    #导入导出头部设置
    # Mfg::Batching.imp_exp_hander
    def self.imp_exp_hander
        %w(contract_id  product_id  product_name  production_batch_number  batching_ratio  batching_qty  production_date  batching_qty_recheck  production_requirements_notes  order_placed_id  weighing_id  weighing_supervised_id  operator_id  user_id  updater_id  py  created_at  updated_at)
    end

    # 示例计算金额
    # Mfg::Batching.last.sum_amount("receive_amount", 1000)
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
# #Mfg/batching batchings
# match "batchings"  => "batchings#index", via: :get
# match "batchings"  => "batchings#create", via: :post
# match "batchings/:id"  => "batchings#update", via: :put
# match "batchings/:id"  => "batchings#show", via: :get
# match "batchings/:id"  => "batchings#destroy", via: :delete
# match "batchings/batch_action"  => "batchings#batch_action", via: :post
# match "batchings/import"  => "batchings#import", via: :post
