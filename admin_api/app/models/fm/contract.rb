class Fm::Contract < ApplicationRecord
    include DocNumberable

    self.table_name = "fm_contracts"
    self.doc_number_key = "fm_contracts"

    # columns: code,sign_at,client_id,client_contact_id,client_contact_name,client_phone,client_fax,supplier_id,supplier_contact_name,supplier_contact_id,supplier_phone,supplier_fax,product_en,product_zh,specs,pack_req,qty,unit_price,total,tax,amount_net,total_cn,deliver_at,deliver_addr,indicator_req,req_docs,settlement_id,remarks,user_id,updater_id,py,, created_at, updated_at
    # attr_accessor :sort
    # serialize :members
    attribute :created_time, :string
    attribute :updated_time, :string

    validates :code, length: { in: 2..20 },  presence: true

    # 供 contract_name 等展示使用（与 Crm::Contract 兼容）
    def name
      code
    end

    # scope :company_projects, -> {where(company_id: company_id)}
    # scope :stars, -> {where(is_star: true)}


    # before_create :genereate_parent_code

    # after_create :generate_default_stages

    # mount_uploader :file, FileUploader
    has_one_attached :file
    has_many_attached :files

    belongs_to :client, class_name: "Crm::Client", foreign_key: "client_id", optional: true
    belongs_to :client_contact, class_name: "Crm::Contact", foreign_key: "client_contact_id", optional: true
    belongs_to :supplier, class_name: "Pur::Supplier", foreign_key: "supplier_id", optional: true
    belongs_to :supplier_contact, class_name: "Pur::Contact", foreign_key: "supplier_contact_id", optional: true
    belongs_to :settlement, class_name: "Property", foreign_key: "settlement_id", optional: true
    belongs_to :unit, class_name: "Property", foreign_key: "unit_id", optional: true
    belongs_to :tax_rate, class_name: "Property", foreign_key: "tax_id", optional: true
    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    belongs_to :workflow_template, class_name: "Workflow::Template", foreign_key: "workflow_template_id", optional: true
    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    has_many :workflow_logs, class_name: "FmContractWorkflowLog", foreign_key: :contract_id, dependent: :destroy
    has_many :workflow_states, class_name: "FmContractWorkflowState", foreign_key: :contract_id, dependent: :destroy
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record

    after_create :init_workflow_records
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            code: code,
            sign_at: sign_at,
            client_id: client_id,
            client_name: (client.name rescue ""),
            client_contact_id: client_contact_id,
            client_contact_name: (client_contact.name rescue ""),
            client_contact_name: client_contact_name,
            client_phone: client_phone,
            client_fax: client_fax,
            supplier_id: supplier_id,
            supplier_name: (supplier.name rescue ""),
            supplier_contact_id: supplier_contact_id,
            supplier_contact_name: (supplier_contact.name rescue ""),
            supplier_phone: supplier_phone,
            supplier_fax: supplier_fax,
            product_id: product_id,
            product_name: (product.name rescue ""),
            product_en: product_en,
            product_zh: product_zh,
            specs: specs,
            pack_req: pack_req,
            unit_id: unit_id,
            unit_name: (unit.name rescue ""),
            qty: qty,
            unit_price: unit_price,
            total: total,
            tax: tax,
            tax_name: (tax_rate.name rescue ""),
            amount_net: amount_net,
            total_cn: total_cn,
            deliver_at: deliver_at,
            deliver_addr: deliver_addr,
            indicator_req: indicator_req,
            req_docs: req_docs,
            settlement_id: settlement_id,
            settlement_name: (settlement.name rescue ""),
            tax_id: tax_id,
            remarks: remarks,
            user_id: user_id,
            user_name: (user.name rescue ""),
            updater_id: updater_id,
            updater_name: (updater.name rescue ""),
            py: py,
            created_at: created_at,
            updated_at: updated_at,
            created_time: created_time,
            updated_time: updated_time,
            workflow_template_id: workflow_template_id,
        }
    end

    def show_info
        {
        id: id,
        code: code,
        }
    end
    

    #导入导出头部设置
    # Fm::Contract.imp_exp_hander
    def self.imp_exp_hander
        %w(code  sign_at  client_id  client_contact_id  client_contact_name  client_phone  client_fax  supplier_id  supplier_contact_name  supplier_contact_id  supplier_phone  supplier_fax  product_id  product_en  product_zh  specs  pack_req  unit_id  qty  unit_price  total  tax  tax_id  amount_net  total_cn  deliver_at  deliver_addr  indicator_req  req_docs  settlement_id  remarks  user_id  updater_id  py  created_at  updated_at)
    end

    # 示例计算金额
    # Fm::Contract.last.sum_amount("receive_amount", 1000)
    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end

    private

    def init_workflow_records
      FmContractWorkflowService.init_workflow_for_contract(self, operator: user)
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
# #Fm/contract contracts
# match "contracts"  => "contracts#index", via: :get
# match "contracts"  => "contracts#create", via: :post
# match "contracts/:id"  => "contracts#update", via: :put
# match "contracts/:id"  => "contracts#show", via: :get
# match "contracts/:id"  => "contracts#destroy", via: :delete
# match "contracts/batch_action"  => "contracts#batch_action", via: :post
# match "contracts/import"  => "contracts#import", via: :post
