class Iqc::Ldf < ApplicationRecord

    # columns: contract_id,product_id,name,code,customer_trademark,sample_color,user_id,updater_id,py,, created_at, updated_at
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
            customer_trademark: customer_trademark,
            sample_color: sample_color,
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
    # Iqc::Ldf.imp_exp_hander
    def self.imp_exp_hander
        %w(contract_id  product_id  name  code  customer_trademark  sample_color  user_id  updater_id  py  created_at  updated_at)
    end

    # 示例计算金额
    # Iqc::Ldf.last.sum_amount("receive_amount", 1000)
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
# #Iqc/ldf ldfs
# match "ldfs"  => "ldfs#index", via: :get
# match "ldfs"  => "ldfs#create", via: :post
# match "ldfs/:id"  => "ldfs#update", via: :put
# match "ldfs/:id"  => "ldfs#show", via: :get
# match "ldfs/:id"  => "ldfs#destroy", via: :delete
# match "ldfs/batch_action"  => "ldfs#batch_action", via: :post
# match "ldfs/import"  => "ldfs#import", via: :post
