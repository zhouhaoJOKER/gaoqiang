class Iqc::LdfLine < ApplicationRecord

    # columns: ldf_id,inspection_date,source,batch_number,ph_value,specific_gravity_g_ml,moisture_percent,flash_point_c,viscosity,dispersion_stability_20_200,foam_retention_ml,pourability,sort,user_id,, created_at, updated_at
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

    belongs_to :ldf, class_name: "Iqc::Ldf", foreign_key: "ldf_id", optional: true
    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            ldf_id: ldf_id,
            ldf_name: (ldf.name rescue ""),
            inspection_date: inspection_date,
            source: source,
            batch_number: batch_number,
            ph_value: ph_value,
            specific_gravity_g_ml: specific_gravity_g_ml,
            moisture_percent: moisture_percent,
            flash_point_c: flash_point_c,
            viscosity: viscosity,
            dispersion_stability_20_200: dispersion_stability_20_200,
            foam_retention_ml: foam_retention_ml,
            pourability: pourability,
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
    # Iqc::LdfLine.imp_exp_hander
    def self.imp_exp_hander
        %w(ldf_id  inspection_date  source  batch_number  ph_value  specific_gravity_g_ml  moisture_percent  flash_point_c  viscosity  dispersion_stability_20_200  foam_retention_ml  pourability  sort  user_id  created_at  updated_at)
    end

    # 示例计算金额
    # Iqc::LdfLine.last.sum_amount("receive_amount", 1000)
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
# #Iqc/ldf line ldf_lines
# match "ldf_lines"  => "ldf_lines#index", via: :get
# match "ldf_lines"  => "ldf_lines#create", via: :post
# match "ldf_lines/:id"  => "ldf_lines#update", via: :put
# match "ldf_lines/:id"  => "ldf_lines#show", via: :get
# match "ldf_lines/:id"  => "ldf_lines#destroy", via: :delete
# match "ldf_lines/batch_action"  => "ldf_lines#batch_action", via: :post
# match "ldf_lines/import"  => "ldf_lines#import", via: :post
