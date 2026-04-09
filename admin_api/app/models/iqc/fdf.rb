class Iqc::Fdf < ApplicationRecord

    # columns: contract_id,product_id,name,code,inspection_basis,instrument_number,customer_trademark_name,request_inspection_date,std_sample_1_m,std_sample_1_x,std_sample_1_spectrum_id,std_sample_1_a_r_1,std_sample_1_a_r_2,std_sample_2_m,std_sample_2_x,std_sample_2_spectrum_id,std_sample_2_a_r_1,std_sample_2_a_r_2,user_id,updater_id,py,, created_at, updated_at
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

    belongs_to :contract, class_name: "Pur::Contract", foreign_key: "contract_id", optional: true
    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    belongs_to :std_sample_1_spectrum, class_name: "StdSample1Spectrum", foreign_key: "std_sample_1_spectrum_id", optional: true
    belongs_to :std_sample_2_spectrum, class_name: "StdSample2Spectrum", foreign_key: "std_sample_2_spectrum_id", optional: true
    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            contract_id: contract_id,
            contract_name: (contract.name rescue ""),
            product_id: product_id,
            product_name: (product.name rescue ""),
            name: name,
            code: code,
            inspection_basis: inspection_basis,
            instrument_number: instrument_number,
            customer_trademark_name: customer_trademark_name,
            request_inspection_date: request_inspection_date,
            std_sample_1_m: std_sample_1_m,
            std_sample_1_x: std_sample_1_x,
            std_sample_1_spectrum_id: std_sample_1_spectrum_id,
            std_sample_1_spectrum_name: (std_sample_1_spectrum.name rescue ""),
            std_sample_1_a_r_1: std_sample_1_a_r_1,
            std_sample_1_a_r_2: std_sample_1_a_r_2,
            std_sample_2_m: std_sample_2_m,
            std_sample_2_x: std_sample_2_x,
            std_sample_2_spectrum_id: std_sample_2_spectrum_id,
            std_sample_2_spectrum_name: (std_sample_2_spectrum.name rescue ""),
            std_sample_2_a_r_1: std_sample_2_a_r_1,
            std_sample_2_a_r_2: std_sample_2_a_r_2,
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
    # Iqc::Fdf.imp_exp_hander
    def self.imp_exp_hander
        %w(contract_id  product_id  name  code  inspection_basis  instrument_number  customer_trademark_name  request_inspection_date  std_sample_1_m  std_sample_1_x  std_sample_1_spectrum_id  std_sample_1_a_r_1  std_sample_1_a_r_2  std_sample_2_m  std_sample_2_x  std_sample_2_spectrum_id  std_sample_2_a_r_1  std_sample_2_a_r_2  user_id  updater_id  py  created_at  updated_at)
    end

    # 示例计算金额
    # Iqc::Fdf.last.sum_amount("receive_amount", 1000)
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
# #Iqc/fdf fdfs
# match "fdfs"  => "fdfs#index", via: :get
# match "fdfs"  => "fdfs#create", via: :post
# match "fdfs/:id"  => "fdfs#update", via: :put
# match "fdfs/:id"  => "fdfs#show", via: :get
# match "fdfs/:id"  => "fdfs#destroy", via: :delete
# match "fdfs/batch_action"  => "fdfs#batch_action", via: :post
# match "fdfs/import"  => "fdfs#import", via: :post
