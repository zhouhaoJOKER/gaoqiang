class Mfg::OprateStepLine < ApplicationRecord

    # columns: operate_id,step_time,kettle_temp,step_phase,step_notes,is_edit_note,sort,user_id,, created_at, updated_at
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

    belongs_to :operate, class_name: "Operate", foreign_key: "operate_id", optional: true
    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            operate_id: operate_id,
            operate_name: (operate.name rescue ""),
            step_time: step_time,
            kettle_temp: kettle_temp,
            step_phase: step_phase,
            step_notes: step_notes,
            is_edit_note: is_edit_note,
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
    # Mfg::OprateStepLine.imp_exp_hander
    def self.imp_exp_hander
        %w(operate_id  step_time  kettle_temp  step_phase  step_notes  is_edit_note  sort  user_id  created_at  updated_at)
    end

    # 示例计算金额
    # Mfg::OprateStepLine.last.sum_amount("receive_amount", 1000)
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
# #Mfg/oprate step line oprate_step_lines
# match "oprate_step_lines"  => "oprate_step_lines#index", via: :get
# match "oprate_step_lines"  => "oprate_step_lines#create", via: :post
# match "oprate_step_lines/:id"  => "oprate_step_lines#update", via: :put
# match "oprate_step_lines/:id"  => "oprate_step_lines#show", via: :get
# match "oprate_step_lines/:id"  => "oprate_step_lines#destroy", via: :delete
# match "oprate_step_lines/batch_action"  => "oprate_step_lines#batch_action", via: :post
# match "oprate_step_lines/import"  => "oprate_step_lines#import", via: :post
