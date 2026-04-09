class Iqc::FdfLine < ApplicationRecord

    # columns: fdf_id,source,batch_number,yield_kl_t,sample_weight_mg,spectrum_id,peak_area_ratio,mass_fraction_percent,specific_gravity,mass_concentration_g_l,suspension_powder_weight_g,suspension_spectrum_id,suspension_peak_area_ratio,suspension_mass_fraction_percent,sort,user_id,, created_at, updated_at
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

    belongs_to :fdf, class_name: "Iqc::Fdf", foreign_key: "fdf_id", optional: true
    belongs_to :spectrum, class_name: "Spectrum", foreign_key: "spectrum_id", optional: true
    belongs_to :suspension_spectrum, class_name: "SuspensionSpectrum", foreign_key: "suspension_spectrum_id", optional: true
    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            fdf_id: fdf_id,
            fdf_name: (fdf.name rescue ""),
            source: source,
            batch_number: batch_number,
            yield_kl_t: yield_kl_t,
            sample_weight_mg: sample_weight_mg,
            spectrum_id: spectrum_id,
            spectrum_name: (spectrum.name rescue ""),
            peak_area_ratio: peak_area_ratio,
            mass_fraction_percent: mass_fraction_percent,
            specific_gravity: specific_gravity,
            mass_concentration_g_l: mass_concentration_g_l,
            suspension_powder_weight_g: suspension_powder_weight_g,
            suspension_spectrum_id: suspension_spectrum_id,
            suspension_spectrum_name: (suspension_spectrum.name rescue ""),
            suspension_peak_area_ratio: suspension_peak_area_ratio,
            suspension_mass_fraction_percent: suspension_mass_fraction_percent,
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
    # Iqc::FdfLine.imp_exp_hander
    def self.imp_exp_hander
        %w(fdf_id  source  batch_number  yield_kl_t  sample_weight_mg  spectrum_id  peak_area_ratio  mass_fraction_percent  specific_gravity  mass_concentration_g_l  suspension_powder_weight_g  suspension_spectrum_id  suspension_peak_area_ratio  suspension_mass_fraction_percent  sort  user_id  created_at  updated_at)
    end

    # 示例计算金额
    # Iqc::FdfLine.last.sum_amount("receive_amount", 1000)
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
# #Iqc/fdf line fdf_lines
# match "fdf_lines"  => "fdf_lines#index", via: :get
# match "fdf_lines"  => "fdf_lines#create", via: :post
# match "fdf_lines/:id"  => "fdf_lines#update", via: :put
# match "fdf_lines/:id"  => "fdf_lines#show", via: :get
# match "fdf_lines/:id"  => "fdf_lines#destroy", via: :delete
# match "fdf_lines/batch_action"  => "fdf_lines#batch_action", via: :post
# match "fdf_lines/import"  => "fdf_lines#import", via: :post
