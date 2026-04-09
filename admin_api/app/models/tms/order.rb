class Tms::Order < ApplicationRecord

    # columns: contract_id,document_number,document_date,company_name,reference_code,consignee_name,consignee_contact,consignee_phone,delivery_address,carrier_id_no,vehicle_no,carrier_name,consignee_stamp_note,consignee_signature_note,approved_id,prepared_id,contract_note,user_id,updater_id,py,, created_at, updated_at
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
    belongs_to :approved, class_name: "Approved", foreign_key: "approved_id", optional: true
    belongs_to :prepared, class_name: "Prepared", foreign_key: "prepared_id", optional: true
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
            document_number: document_number,
            document_date: document_date,
            company_name: company_name,
            reference_code: reference_code,
            consignee_name: consignee_name,
            consignee_contact: consignee_contact,
            consignee_phone: consignee_phone,
            delivery_address: delivery_address,
            carrier_id_no: carrier_id_no,
            vehicle_no: vehicle_no,
            carrier_name: carrier_name,
            consignee_stamp_note: consignee_stamp_note,
            consignee_signature_note: consignee_signature_note,
            approved_id: approved_id,
            approved_name: (approved.name rescue ""),
            prepared_id: prepared_id,
            prepared_name: (prepared.name rescue ""),
            contract_note: contract_note,
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
    # Tms::Order.imp_exp_hander
    def self.imp_exp_hander
        %w(contract_id  document_number  document_date  company_name  reference_code  consignee_name  consignee_contact  consignee_phone  delivery_address  carrier_id_no  vehicle_no  carrier_name  consignee_stamp_note  consignee_signature_note  approved_id  prepared_id  contract_note  user_id  updater_id  py  created_at  updated_at)
    end

    # 示例计算金额
    # Tms::Order.last.sum_amount("receive_amount", 1000)
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
# #Tms/order orders
# match "orders"  => "orders#index", via: :get
# match "orders"  => "orders#create", via: :post
# match "orders/:id"  => "orders#update", via: :put
# match "orders/:id"  => "orders#show", via: :get
# match "orders/:id"  => "orders#destroy", via: :delete
# match "orders/batch_action"  => "orders#batch_action", via: :post
# match "orders/import"  => "orders#import", via: :post
