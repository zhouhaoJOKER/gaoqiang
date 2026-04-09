class Rms::HandoverContract < ApplicationRecord

    # columns: recipe_handover_id,contract_id,qty,, created_at, updated_at
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

    belongs_to :recipe_handover, class_name: "Rms::Handover", foreign_key: "recipe_handover_id", optional: true
    belongs_to :contract, class_name: "Fm::Contract", foreign_key: "contract_id", optional: true
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            recipe_handover_id: recipe_handover_id,
            recipe_handover_name: (recipe_handover.name rescue ""),
            recipe_handover: recipe_handover.present? ? recipe_handover_base_info : nil,
            contract_id: contract_id,
            contract_name: (contract.name rescue ""),
            qty: qty,
            created_at: created_at,
            updated_at: updated_at,
            created_time: created_time,
            updated_time: updated_time,
        }
    end

    # 配方交接单关键信息（用于列表展示）
    def recipe_handover_base_info
        return nil unless recipe_handover
        h = recipe_handover
        {
            id: h.id,
            name: h.name,
            code: h.code,
            handover_date: h.handover_date,
            product_id: h.product_id,
            product_name: (h.product&.name rescue ""),
            order_qty: h.order_qty,
            order_qty_unit: h.order_qty_unit,
            handover_order_id: h.handover_order_id,
            handover_order_name: (h.handover_order&.name rescue ""),
            prepared_id: h.prepared_id,
            prepared_name: (safe_prepared_name(h)),
            ordering_companies_text: h.ordering_companies_text,
            general_notes: h.general_notes,
        }
    end

    def safe_prepared_name(handover)
        return "" unless handover.prepared_id.present?
        return "" unless Object.const_defined?("Prepared")
        handover.prepared&.name.to_s
    rescue NameError, LoadError
        ""
    end

    def show_info
        {
        id: id,
        }
    end
    

    #导入导出头部设置
    # Rms::HandoverContract.imp_exp_hander
    def self.imp_exp_hander
        %w(recipe_handover_id  contract_id  qty  created_at  updated_at)
    end

    # 示例计算金额
    # Rms::HandoverContract.last.sum_amount("receive_amount", 1000)
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
# #Rms/handover contract handover_contracts
# match "handover_contracts"  => "handover_contracts#index", via: :get
# match "handover_contracts"  => "handover_contracts#create", via: :post
# match "handover_contracts/:id"  => "handover_contracts#update", via: :put
# match "handover_contracts/:id"  => "handover_contracts#show", via: :get
# match "handover_contracts/:id"  => "handover_contracts#destroy", via: :delete
# match "handover_contracts/batch_action"  => "handover_contracts#batch_action", via: :post
# match "handover_contracts/import"  => "handover_contracts#import", via: :post
