class Wms::Notice < ApplicationRecord

    # columns: contract_id,recipient,issuing_company,issue_date,total_pieces,unloading_fee_per_cbm,minimum_charge_per_shipment,entry_fee_per_vehicle,nighttime_surcharge_note,dangerous_goods_vehicle_fee,box_truck_surcharge_note,important_notes,warehousing_number,delivery_deadline,warehouse_name,warehouse_address,contact_person,contact_phone,contact_hours,dangerous_goods_receiving_note,remarks_contact,user_id,updater_id,py,, created_at, updated_at
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
            recipient: recipient,
            issuing_company: issuing_company,
            issue_date: issue_date,
            total_pieces: total_pieces,
            unloading_fee_per_cbm: unloading_fee_per_cbm,
            minimum_charge_per_shipment: minimum_charge_per_shipment,
            entry_fee_per_vehicle: entry_fee_per_vehicle,
            nighttime_surcharge_note: nighttime_surcharge_note,
            dangerous_goods_vehicle_fee: dangerous_goods_vehicle_fee,
            box_truck_surcharge_note: box_truck_surcharge_note,
            important_notes: important_notes,
            warehousing_number: warehousing_number,
            delivery_deadline: delivery_deadline,
            warehouse_name: warehouse_name,
            warehouse_address: warehouse_address,
            contact_person: contact_person,
            contact_phone: contact_phone,
            contact_hours: contact_hours,
            dangerous_goods_receiving_note: dangerous_goods_receiving_note,
            remarks_contact: remarks_contact,
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
    # Wms::Notice.imp_exp_hander
    def self.imp_exp_hander
        %w(contract_id  recipient  issuing_company  issue_date  total_pieces  unloading_fee_per_cbm  minimum_charge_per_shipment  entry_fee_per_vehicle  nighttime_surcharge_note  dangerous_goods_vehicle_fee  box_truck_surcharge_note  important_notes  warehousing_number  delivery_deadline  warehouse_name  warehouse_address  contact_person  contact_phone  contact_hours  dangerous_goods_receiving_note  remarks_contact  user_id  updater_id  py  created_at  updated_at)
    end

    # 示例计算金额
    # Wms::Notice.last.sum_amount("receive_amount", 1000)
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
# #Wms/notice notices
# match "notices"  => "notices#index", via: :get
# match "notices"  => "notices#create", via: :post
# match "notices/:id"  => "notices#update", via: :put
# match "notices/:id"  => "notices#show", via: :get
# match "notices/:id"  => "notices#destroy", via: :delete
# match "notices/batch_action"  => "notices#batch_action", via: :post
# match "notices/import"  => "notices#import", via: :post
