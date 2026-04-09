class Crm::Invoice < ApplicationRecord

    # columns: billable_type,billable_id,title,tax_no,address,phone,bank_name,bank_account,invoice_type_id,is_default,remark,user_id,updater_id,py,, created_at, updated_at
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

    belongs_to :billable, class_name: "Billable", foreign_key: "billable_id", optional: true
    belongs_to :invoice_type, class_name: "InvoiceType", foreign_key: "invoice_type_id", optional: true
    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            billable_type: billable_type,
            billable_id: billable_id,
            billable_name: (billable.name rescue ""),
            title: title,
            tax_no: tax_no,
            address: address,
            phone: phone,
            bank_name: bank_name,
            bank_account: bank_account,
            invoice_type_id: invoice_type_id,
            invoice_type_name: (invoice_type.name rescue ""),
            is_default: is_default,
            remark: remark,
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
    # Crm::Invoice.imp_exp_hander
    def self.imp_exp_hander
        %w(billable_type  billable_id  title  tax_no  address  phone  bank_name  bank_account  invoice_type_id  is_default  remark  user_id  updater_id  py  created_at  updated_at)
    end

    # 示例计算金额
    # Crm::Invoice.last.sum_amount("receive_amount", 1000)
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
# #Crm/invoice invoices
# match "invoices"  => "invoices#index", via: :get
# match "invoices"  => "invoices#create", via: :post
# match "invoices/:id"  => "invoices#update", via: :put
# match "invoices/:id"  => "invoices#show", via: :get
# match "invoices/:id"  => "invoices#destroy", via: :delete
# match "invoices/batch_action"  => "invoices#batch_action", via: :post
# match "invoices/import"  => "invoices#import", via: :post
