class Iqc::RawLine < ApplicationRecord

    # columns: raw_id,sort,content_percent,m_value,a_r_value,x_percent,, created_at, updated_at
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

    belongs_to :raw, class_name: "Iqc::Raw", foreign_key: "raw_id", optional: true
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            raw_id: raw_id,
            raw_name: (raw.name rescue ""),
            sort: sort,
            content_percent: content_percent,
            m_value: m_value,
            a_r_value: a_r_value,
            x_percent: x_percent,
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
    # Iqc::RawLine.imp_exp_hander
    def self.imp_exp_hander
        %w(raw_id  sort  content_percent  m_value  a_r_value  x_percent  created_at  updated_at)
    end

    # 示例计算金额
    # Iqc::RawLine.last.sum_amount("receive_amount", 1000)
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
# #Iqc/raw line raw_lines
# match "raw_lines"  => "raw_lines#index", via: :get
# match "raw_lines"  => "raw_lines#create", via: :post
# match "raw_lines/:id"  => "raw_lines#update", via: :put
# match "raw_lines/:id"  => "raw_lines#show", via: :get
# match "raw_lines/:id"  => "raw_lines#destroy", via: :delete
# match "raw_lines/batch_action"  => "raw_lines#batch_action", via: :post
# match "raw_lines/import"  => "raw_lines#import", via: :post
