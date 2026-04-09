class Crm::Quotation < ApplicationRecord

    # columns: contract_id,client_id,code,quote_date,valid_until,currency,status_id,tax_rate_id,amount,total_amount,remark,user_id,updater_id,py,, created_at, updated_at
    # attr_accessor :sort
    # serialize :members
    attribute :created_time, :string
    attribute :updated_time, :string

    validates :code, length: { in: 2..20 },  presence: true

    # scope :company_projects, -> {where(company_id: company_id)}
    # scope :stars, -> {where(is_star: true)}


    # before_create :genereate_parent_code

    # after_create :generate_default_stages

    # mount_uploader :file, FileUploader
    has_one_attached :file
    has_many_attached :files

    belongs_to :contract, class_name: "Fm::Contract", foreign_key: "contract_id", optional: true
    belongs_to :client, class_name: "Crm::Client", foreign_key: "client_id", optional: true
    belongs_to :status, class_name: "Property", optional: true, foreign_key: "status_id", optional: true
    belongs_to :tax_rate, class_name: "TaxRate", foreign_key: "tax_rate_id", optional: true
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
            client_id: client_id,
            client_name: (client.name rescue ""),
            code: code,
            quote_date: quote_date,
            valid_until: valid_until,
            currency: currency,
            status_id: status_id,
            status_name: (status.name rescue ""),
            tax_rate_id: tax_rate_id,
            tax_rate_name: (tax_rate.name rescue ""),
            amount: amount,
            total_amount: total_amount,
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
        }
    end
    

    #导入导出头部设置
    # Crm::Quotation.imp_exp_hander
    def self.imp_exp_hander
        %w(contract_id  client_id  code  quote_date  valid_until  currency  status_id  tax_rate_id  amount  total_amount  remark  user_id  updater_id  py  created_at  updated_at)
    end

    # 示例计算金额
    # Crm::Quotation.last.sum_amount("receive_amount", 1000)
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
# #Crm/quotation quotations
# match "quotations"  => "quotations#index", via: :get
# match "quotations"  => "quotations#create", via: :post
# match "quotations/:id"  => "quotations#update", via: :put
# match "quotations/:id"  => "quotations#show", via: :get
# match "quotations/:id"  => "quotations#destroy", via: :delete
# match "quotations/batch_action"  => "quotations#batch_action", via: :post
# match "quotations/import"  => "quotations#import", via: :post
