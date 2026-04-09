class Mfg::PkgHandover < ApplicationRecord

    # columns: contract_id,form_date,code,preparer_id,client_id,contract_code,product_id,product_name,sign_date,qty,specification,bottle_contract_id,bottle_info,label_contract_id,label_info,box_contract_id,box_info,remark,user_id,updater_id,py,, created_at, updated_at
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

    belongs_to :contract, class_name: "Pur::Contract", foreign_key: "contract_id", optional: true
    belongs_to :preparer, class_name: "Preparer", foreign_key: "preparer_id", optional: true
    belongs_to :client, class_name: "Crm::Client", foreign_key: "client_id", optional: true
    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    belongs_to :bottle_contract, class_name: "BottleContract", foreign_key: "bottle_contract_id", optional: true
    belongs_to :label_contract, class_name: "LabelContract", foreign_key: "label_contract_id", optional: true
    belongs_to :box_contract, class_name: "BoxContract", foreign_key: "box_contract_id", optional: true
    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    after_create :append_workflow_log_for_fm_contract
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            contract_id: contract_id,
            contract_name: (contract.name rescue ""),
            form_date: form_date,
            code: code,
            preparer_id: preparer_id,
            preparer_name: (preparer.name rescue ""),
            client_id: client_id,
            client_name: (client.name rescue ""),
            contract_code: contract_code,
            product_id: product_id,
            product_name: (product.name rescue ""),
            product_name: product_name,
            sign_date: sign_date,
            qty: qty,
            specification: specification,
            bottle_contract_id: bottle_contract_id,
            bottle_contract_name: (bottle_contract.name rescue ""),
            bottle_info: bottle_info,
            label_contract_id: label_contract_id,
            label_contract_name: (label_contract.name rescue ""),
            label_info: label_info,
            box_contract_id: box_contract_id,
            box_contract_name: (box_contract.name rescue ""),
            box_info: box_info,
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
    # Mfg::PkgHandover.imp_exp_hander
    def self.imp_exp_hander
        %w(contract_id  form_date  code  preparer_id  client_id  contract_code  product_id  product_name  sign_date  qty  specification  bottle_contract_id  bottle_info  label_contract_id  label_info  box_contract_id  box_info  remark  user_id  updater_id  py  created_at  updated_at)
    end

    # 示例计算金额
    # Mfg::PkgHandover.last.sum_amount("receive_amount", 1000)
    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end

    private

    def append_workflow_log_for_fm_contract
      fm_contract_id = contract_id.present? ? (Pur::Contract.find_by(id: contract_id)&.fm_contract_id) : nil
      return if fm_contract_id.blank?
      operator = user_id.present? ? User.find_by(id: user_id) : nil
      FmContractWorkflowService.append_log(
        fm_contract_id,
        step_key: "pack_setup",
        step_label: "包装准备/包装箱采购",
        action: "创建产品包装细节交接单 #{code.presence || id}",
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
# #Mfg/pkg handover pkg_handovers
# match "pkg_handovers"  => "pkg_handovers#index", via: :get
# match "pkg_handovers"  => "pkg_handovers#create", via: :post
# match "pkg_handovers/:id"  => "pkg_handovers#update", via: :put
# match "pkg_handovers/:id"  => "pkg_handovers#show", via: :get
# match "pkg_handovers/:id"  => "pkg_handovers#destroy", via: :delete
# match "pkg_handovers/batch_action"  => "pkg_handovers#batch_action", via: :post
# match "pkg_handovers/import"  => "pkg_handovers#import", via: :post
