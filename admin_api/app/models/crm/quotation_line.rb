class Crm::QuotationLine < ApplicationRecord

    # columns: quotation_id,item_id,product_name,spec,qty,unit,unit_price,amount,remark,sort,user_id,, created_at, updated_at
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

    belongs_to :quotation, class_name: "Crm::Quotation", foreign_key: "quotation_id", optional: true
    belongs_to :item, class_name: "Mat::Item", foreign_key: "item_id", optional: true
    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            quotation_id: quotation_id,
            quotation_name: (quotation.name rescue ""),
            item_id: item_id,
            item_name: (item.name rescue ""),
            product_name: product_name,
            spec: spec,
            qty: qty,
            unit: unit,
            unit_price: unit_price,
            amount: amount,
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
        }
    end
    

    #导入导出头部设置
    # Crm::QuotationLine.imp_exp_hander
    def self.imp_exp_hander
        %w(quotation_id  item_id  product_name  spec  qty  unit  unit_price  amount  remark  sort  user_id  created_at  updated_at)
    end

    # 示例计算金额
    # Crm::QuotationLine.last.sum_amount("receive_amount", 1000)
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
# #Crm/quotation line quotation_lines
# match "quotation_lines"  => "quotation_lines#index", via: :get
# match "quotation_lines"  => "quotation_lines#create", via: :post
# match "quotation_lines/:id"  => "quotation_lines#update", via: :put
# match "quotation_lines/:id"  => "quotation_lines#show", via: :get
# match "quotation_lines/:id"  => "quotation_lines#destroy", via: :delete
# match "quotation_lines/batch_action"  => "quotation_lines#batch_action", via: :post
# match "quotation_lines/import"  => "quotation_lines#import", via: :post
