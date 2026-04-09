class Pur::Collection < ApplicationRecord

    # columns: purchase_contract_id,sort,product_id,product_name,length,width,height,unit,qty,price,amount_excl_tax,tax,amount,user_id,updater_id,remark,other,py,, created_at, updated_at
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

    belongs_to :purchase_contract, class_name: "Pur::Contract", foreign_key: "purchase_contract_id", optional: true
    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            purchase_contract_id: purchase_contract_id,
            purchase_contract_name: (purchase_contract.name rescue ""),
            sort: sort,
            product_id: product_id,
            product_name: (product.name rescue ""),
            product_name: product_name,
            length: length,
            width: width,
            height: height,
            unit: unit,
            qty: qty,
            price: price,
            amount_excl_tax: amount_excl_tax,
            tax: tax,
            amount: amount,
            user_id: user_id,
            user_name: (user.name rescue ""),
            updater_id: updater_id,
            updater_name: (updater.name rescue ""),
            remark: remark,
            other: other,
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
    # Pur::Collection.imp_exp_hander
    def self.imp_exp_hander
        %w(purchase_contract_id  sort  product_id  product_name  length  width  height  unit  qty  price  amount_excl_tax  tax  amount  user_id  updater_id  remark  other  py  created_at  updated_at)
    end

    # 示例计算金额
    # Pur::Collection.last.sum_amount("receive_amount", 1000)
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
# #Pur/collection collections
# match "collections"  => "collections#index", via: :get
# match "collections"  => "collections#create", via: :post
# match "collections/:id"  => "collections#update", via: :put
# match "collections/:id"  => "collections#show", via: :get
# match "collections/:id"  => "collections#destroy", via: :delete
# match "collections/batch_action"  => "collections#batch_action", via: :post
# match "collections/import"  => "collections#import", via: :post
