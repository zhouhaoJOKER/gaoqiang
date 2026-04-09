class Rms::Handover < ApplicationRecord

    # columns: product_id,name,code,handover_date,ordering_companies_text,order_qty,order_qty_unit,handover_order_id,prepared_id,received_id,general_notes,user_id,updater_id,py,, created_at, updated_at
    # attr_accessor :sort
    # serialize :members
    attribute :created_time, :string
    attribute :updated_time, :string

    # validates :code, length: { in: 2..20 },  presence: true, uniqueness:true
    validates :name, length: { in: 2..20 },  presence: true

    # scope :company_projects, -> {where(company_id: company_id)}
    # scope :stars, -> {where(is_star: true)}


    # before_create :genereate_parent_code
    before_save :gen_py

    # after_create :generate_default_stages

    # mount_uploader :file, FileUploader
    has_one_attached :file
    has_many_attached :files

    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    belongs_to :handover_order, class_name: "Fm::Contract", foreign_key: "handover_order_id", optional: true
    belongs_to :prepared, class_name: "Prepared", foreign_key: "prepared_id", optional: true
    belongs_to :received, class_name: "Received", foreign_key: "received_id", optional: true
    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    has_many :handover_lines, class_name: "Rms::HandoverLine", foreign_key: "handover_id", dependent: :destroy
    has_many :handover_contracts, class_name: "Rms::HandoverContract", foreign_key: "recipe_handover_id", dependent: :destroy
    after_create :append_workflow_log_for_contract
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            product_id: product_id,
            product_name: (product.name rescue ""),
            name: name,
            code: code,
            handover_date: handover_date,
            ordering_companies_text: ordering_companies_text,
            order_qty: order_qty,
            order_qty_unit: order_qty_unit,
            handover_order_id: handover_order_id,
            handover_order_name: (handover_order.name rescue ""),
            prepared_id: prepared_id,
            prepared_name: (prepared.name rescue ""),
            received_id: received_id,
            received_name: (received.name rescue ""),
            general_notes: general_notes,
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
        }
    end
    

    #导入导出头部设置
    # Rms::Handover.imp_exp_hander
    def self.imp_exp_hander
        %w(product_id  name  code  handover_date  ordering_companies_text  order_qty  order_qty_unit  handover_order_id  prepared_id  received_id  general_notes  user_id  updater_id  py  created_at  updated_at)
    end

    # 示例计算金额
    # Rms::Handover.last.sum_amount("receive_amount", 1000)
    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end

    private

    def append_workflow_log_for_contract
      return if handover_order_id.blank?
      operator = user_id.present? ? User.find_by(id: user_id) : nil
      FmContractWorkflowService.append_log(
        handover_order_id,
        step_key: "formula",
        step_label: "配方交接",
        action: "创建配方交接单 #{name.presence || code.presence || id}",
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
# #Rms/handover handovers
# match "handovers"  => "handovers#index", via: :get
# match "handovers"  => "handovers#create", via: :post
# match "handovers/:id"  => "handovers#update", via: :put
# match "handovers/:id"  => "handovers#show", via: :get
# match "handovers/:id"  => "handovers#destroy", via: :delete
# match "handovers/batch_action"  => "handovers#batch_action", via: :post
# match "handovers/import"  => "handovers#import", via: :post
