class Crm::HandoverLine < ApplicationRecord

    # columns: handover_id,spec_item_id,contract_req,internal_req,sort,user_id,, created_at, updated_at
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

    belongs_to :handover, class_name: "Crm::Handover", foreign_key: "handover_id", optional: true
    belongs_to :spec_item, class_name: "Crm::SpecItem", foreign_key: "spec_item_id", optional: true
    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            handover_id: handover_id,
            handover_name: (handover.name rescue ""),
            spec_item_id: spec_item_id,
            spec_item_name: (spec_item.name rescue ""),
            contract_req: contract_req,
            internal_req: internal_req,
            sort: sort,
            user_id: user_id,
            user_name: (user.name rescue ""),
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
    # Crm::HandoverLine.imp_exp_hander
    def self.imp_exp_hander
        %w(handover_id  spec_item_id  contract_req  internal_req  sort  user_id  created_at  updated_at)
    end

    # 示例计算金额
    # Crm::HandoverLine.last.sum_amount("receive_amount", 1000)
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
# #Crm/handover line handover_lines
# match "handover_lines"  => "handover_lines#index", via: :get
# match "handover_lines"  => "handover_lines#create", via: :post
# match "handover_lines/:id"  => "handover_lines#update", via: :put
# match "handover_lines/:id"  => "handover_lines#show", via: :get
# match "handover_lines/:id"  => "handover_lines#destroy", via: :delete
# match "handover_lines/batch_action"  => "handover_lines#batch_action", via: :post
# match "handover_lines/import"  => "handover_lines#import", via: :post
