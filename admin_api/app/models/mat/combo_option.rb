class Mat::ComboOption < ApplicationRecord

    # columns: combo_id, product_id, name, price, extra_price, created_at, updated_at
    # attr_accessor :sort
    # serialize :members
    attribute :created_time, :string
    attribute :updated_time, :string

    # validates :code, length: { in: 2..20 },  presence: true, uniqueness:true
    validates :name, length: { in: 2..20 },  presence: true

    # scope :company_projects, -> {where(company_id: company_id)}
    # scope :stars, -> {where(is_star: true)}


    # before_create :genereate_parent_code

    # after_create :generate_default_stages

    # mount_uploader :file, FileUploader
    has_one_attached :file
    has_many_attached :files

    belongs_to :combo, class_name: "Mat::Combo", foreign_key: "combo_id", optional: true
    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            combo_id: combo_id,
            combo_name: (combo.name rescue ""),
            product_id: product_id,
            product_name: (product.name rescue ""),
            name: name,
            price: price,
            extra_price: extra_price,
            created_at: created_at,
            updated_at: updated_at,
            created_time: created_time,
            updated_time: updated_time,
        }
    end

    def show_info
        {
        id: id,
        name: name,
        }
    end
    

    #导入导出头部设置
    # Mat::ComboOption.imp_exp_hander
    def self.imp_exp_hander
        %w(combo_id  product_id  name  price  extra_price  created_at  updated_at)
    end

    # 示例计算金额
    # Mat::ComboOption.last.sum_amount("receive_amount", 1000)
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
# #Mat/combo option combo_options
# match "combo_options"  => "combo_options#index", via: :get
# match "combo_options"  => "combo_options#create", via: :post
# match "combo_options/:id"  => "combo_options#update", via: :put
# match "combo_options/:id"  => "combo_options#show", via: :get
# match "combo_options/:id"  => "combo_options#destroy", via: :delete
# match "combo_options/batch_action"  => "combo_options#batch_action", via: :post
# match "combo_options/import"  => "combo_options#import", via: :post
