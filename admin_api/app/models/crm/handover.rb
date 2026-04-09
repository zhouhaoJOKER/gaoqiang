class Crm::Handover < ApplicationRecord

    # columns: contract_id,doc_no,order_company,order_contract_no,goods_name,specs,order_kind,special_note,qty,qty_unit,pack_specs,deliver_at,notes,reviewer_id,review_at,prod_signer_id,tech_signer_id,qa_signer_id,user_id,updater_id,py,, created_at, updated_at
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
    belongs_to :reviewer, class_name: "Reviewer", foreign_key: "reviewer_id", optional: true
    belongs_to :prod_signer, class_name: "ProdSigner", foreign_key: "prod_signer_id", optional: true
    belongs_to :tech_signer, class_name: "TechSigner", foreign_key: "tech_signer_id", optional: true
    belongs_to :qa_signer, class_name: "QaSigner", foreign_key: "qa_signer_id", optional: true
    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    has_many :handover_lines, class_name: "Crm::HandoverLine", foreign_key: "handover_id", dependent: :destroy
    after_create :append_workflow_log_for_contract
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            handover_lines: handover_lines.map { |l| l.base_info },
            contract_id: contract_id,
            contract_name: (contract.name rescue ""),
            doc_no: doc_no,
            order_company: order_company,
            order_contract_no: order_contract_no,
            goods_name: goods_name,
            specs: specs,
            order_kind: order_kind,
            special_note: special_note,
            qty: qty,
            qty_unit: qty_unit,
            pack_specs: pack_specs,
            deliver_at: deliver_at,
            notes: notes,
            reviewer_id: reviewer_id,
            reviewer_name: (reviewer.name rescue ""),
            review_at: review_at,
            prod_signer_id: prod_signer_id,
            prod_signer_name: (prod_signer.name rescue ""),
            tech_signer_id: tech_signer_id,
            tech_signer_name: (tech_signer.name rescue ""),
            qa_signer_id: qa_signer_id,
            qa_signer_name: (qa_signer.name rescue ""),
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
    # Crm::Handover.imp_exp_hander
    def self.imp_exp_hander
        %w(contract_id  doc_no  order_company  order_contract_no  goods_name  specs  order_kind  special_note  qty  qty_unit  pack_specs  deliver_at  notes  reviewer_id  review_at  prod_signer_id  tech_signer_id  qa_signer_id  user_id  updater_id  py  created_at  updated_at)
    end

    # 示例计算金额
    # Crm::Handover.last.sum_amount("receive_amount", 1000)
    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end


    private

    def append_workflow_log_for_contract
      return if contract_id.blank?
      operator = user_id.present? ? User.find_by(id: user_id) : nil
      FmContractWorkflowService.append_log(
        contract_id,
        step_key: "ship",
        step_label: "发货/交接",
        action: "创建交接单#{doc_no.presence || "（外贸货物交接）"}",
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
# #Crm/handover handovers
# match "handovers"  => "handovers#index", via: :get
# match "handovers"  => "handovers#create", via: :post
# match "handovers/:id"  => "handovers#update", via: :put
# match "handovers/:id"  => "handovers#show", via: :get
# match "handovers/:id"  => "handovers#destroy", via: :delete
# match "handovers/batch_action"  => "handovers#batch_action", via: :post
# match "handovers/import"  => "handovers#import", via: :post
