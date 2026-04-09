class Pur::Contract < ApplicationRecord

    # columns: contract_id,contract_title,supplier_id,supplier_name,client_id,sign,client_name,kind_id,status_id,contract_number,signing_location,signing_date,receive_date,total_amount,total_amount_chinese,related_item,quality_standard,delivery_location_method,transportation_cost_bearer,loss_calculation_method,packaging_standard,packaging_loss_responsibility,inspection_method,reinspection_period,objection_period,quality_issue_responsibility,spare_parts_supply,settlement_method_term,breach_of_contract_liability,dispute_resolution_method,other_agreements,remark,other,user_id,updater_id,py,validity_start_date,validity_end_date,, created_at, updated_at
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

    belongs_to :contract, class_name: "Fm::Contract", foreign_key: "contract_id", optional: true
    belongs_to :supplier, class_name: "Pur::Supplier", foreign_key: "supplier_id", optional: true
    belongs_to :client, class_name: "Crm::Client", foreign_key: "client_id", optional: true
    belongs_to :kind, class_name: "Kind", foreign_key: "kind_id", optional: true
    belongs_to :status, class_name: "Property", optional: true, foreign_key: "status_id", optional: true
    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    has_many :collections, class_name: "Pur::Collection", foreign_key: "purchase_contract_id", dependent: :destroy
    after_create :append_workflow_log_for_fm_contract
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            contract_id: contract_id,
            contract_name: (contract.name rescue ""),
            fm_contract_id: fm_contract_id,
            fm_contract_name: (fm_contract.name rescue ""),
            contract_title: contract_title,
            supplier_id: supplier_id,
            supplier_name: (supplier.name rescue ""),
            client_id: client_id,
            client_name: (client.name rescue ""),
            sign: sign,
            kind_id: kind_id,
            kind_name: (kind.name rescue ""),
            status_id: status_id,
            status_name: (status.name rescue ""),
            code: code,
            contract_number: contract_number,
            signing_location: signing_location,
            signing_date: signing_date,
            receive_date: receive_date,
            total_amount: total_amount,
            total_amount_chinese: total_amount_chinese,
            related_item: related_item,
            quality_standard: quality_standard,
            delivery_location_method: delivery_location_method,
            transportation_cost_bearer: transportation_cost_bearer,
            loss_calculation_method: loss_calculation_method,
            packaging_standard: packaging_standard,
            packaging_loss_responsibility: packaging_loss_responsibility,
            inspection_method: inspection_method,
            reinspection_period: reinspection_period,
            objection_period: objection_period,
            quality_issue_responsibility: quality_issue_responsibility,
            spare_parts_supply: spare_parts_supply,
            settlement_method_term: settlement_method_term,
            breach_of_contract_liability: breach_of_contract_liability,
            dispute_resolution_method: dispute_resolution_method,
            other_agreements: other_agreements,
            remark: remark,
            other: other,
            user_id: user_id,
            user_name: (user.name rescue ""),
            updater_id: updater_id,
            updater_name: (updater.name rescue ""),
            py: py,
            validity_start_date: validity_start_date,
            validity_end_date: validity_end_date,
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
    # Pur::Contract.imp_exp_hander
    def self.imp_exp_hander
        %w(contract_id  fm_contract_id  contract_title  supplier_id  supplier_name  client_id  sign  client_name  kind_id  status_id  code  contract_number  signing_location  signing_date  receive_date  total_amount  total_amount_chinese  related_item  quality_standard  delivery_location_method  transportation_cost_bearer  loss_calculation_method  packaging_standard  packaging_loss_responsibility  inspection_method  reinspection_period  objection_period  quality_issue_responsibility  spare_parts_supply  settlement_method_term  breach_of_contract_liability  dispute_resolution_method  other_agreements  remark  other  user_id  updater_id  py  validity_start_date  validity_end_date  created_at  updated_at)
    end

    # 示例计算金额
    # Pur::Contract.last.sum_amount("receive_amount", 1000)
    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end

    # 是否原料采购合同（仅此类合同会生成 Iqc::Raw 待检验记录）
    def raw_material_contract?
      sign.to_s == PurContractIqcRawService::RAW_MATERIAL_SIGN
    end

    # 根据采购合同明细生成原料待检验记录（Iqc::Raw）。仅当为原料采购合同时才会创建，可单独调用，后续可配合状态判断调用
    def generate_iqc_raw_records!(force: false)
      PurContractIqcRawService.generate_raws_for_contract(self, force: force)
    end

    private

    def append_workflow_log_for_fm_contract
      return if fm_contract_id.blank?
      operator = user_id.present? ? User.find_by(id: user_id) : nil
      FmContractWorkflowService.append_log(
        fm_contract_id,
        step_key: "purchase",
        step_label: "采购",
        action: "创建采购合同 #{contract_title.presence || code.presence || contract_number.presence || id}",
        operator: operator
      )
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
# #Pur/contract contracts
# match "contracts"  => "contracts#index", via: :get
# match "contracts"  => "contracts#create", via: :post
# match "contracts/:id"  => "contracts#update", via: :put
# match "contracts/:id"  => "contracts#show", via: :get
# match "contracts/:id"  => "contracts#destroy", via: :delete
# match "contracts/batch_action"  => "contracts#batch_action", via: :post
# match "contracts/import"  => "contracts#import", via: :post
