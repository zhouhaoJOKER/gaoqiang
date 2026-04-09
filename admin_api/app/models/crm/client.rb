class Crm::Client < ApplicationRecord

    # columns: parent_id,code,name,abbr,tax_no,address,phone,bank_name,bank_account,settlement_id,payment_terms,invoice_type_id,remark,user_id,updater_id,py,, created_at, updated_at
    # attr_accessor :sort
    # serialize :members
    attribute :created_time, :string
    attribute :updated_time, :string

    # validates :code, length: { in: 2..20 },  presence: true, uniqueness:true
    validates :name, length: { in: 2..20 },  presence: true

    validates_uniqueness_of :name, :scope => :parent_id

    # scope :company_projects, -> {where(company_id: company_id)}
    # scope :stars, -> {where(is_star: true)}


    # before_create :genereate_parent_code
    before_save :gen_py

    # after_create :generate_default_stages

    # mount_uploader :file, FileUploader
    has_one_attached :file
    has_many_attached :files

    belongs_to :settlement, class_name: "Settlement", foreign_key: "settlement_id", optional: true
    belongs_to :invoice_type, class_name: "InvoiceType", foreign_key: "invoice_type_id", optional: true
    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    belongs_to :parent, class_name: "Crm::Client", optional: true
    has_many :children, class_name: "Crm::Client", foreign_key: "parent_id"
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            parent_id: parent_id,
            code: code,
            name: name,
            abbr: abbr,
            tax_no: tax_no,
            address: address,
            phone: phone,
            bank_name: bank_name,
            bank_account: bank_account,
            settlement_id: settlement_id,
            settlement_name: (settlement.name rescue ""),
            payment_terms: payment_terms,
            invoice_type_id: invoice_type_id,
            invoice_type_name: (invoice_type.name rescue ""),
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
        code: code,
        name: name,
        parent_id: parent_id,
        }
    end
    

    #导入导出头部设置
    # Crm::Client.imp_exp_hander
    def self.imp_exp_hander
        %w(parent_id  code  name  abbr  tax_no  address  phone  bank_name  bank_account  settlement_id  payment_terms  invoice_type_id  remark  user_id  updater_id  py  created_at  updated_at)
    end

    # 示例计算金额
    # Crm::Client.last.sum_amount("receive_amount", 1000)
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
# #Crm/client clients
# match "clients"  => "clients#index", via: :get
# match "clients"  => "clients#create", via: :post
# match "clients/:id"  => "clients#update", via: :put
# match "clients/:id"  => "clients#show", via: :get
# match "clients/:id"  => "clients#destroy", via: :delete
# match "clients/batch_action"  => "clients#batch_action", via: :post
# match "clients/import"  => "clients#import", via: :post
