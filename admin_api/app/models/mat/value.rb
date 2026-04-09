class Mat::Value < ApplicationRecord

    # columns: user_id, updater_id, attribute_id, name, color, extra_price, sort, created_at, updated_at
    # attr_accessor :sort
    # serialize :members
    attribute :created_time, :string
    attribute :updated_time, :string

    # validates :code, length: { in: 2..20 },  presence: true, uniqueness:true
    validates :name, length: { in: 1..50 },  presence: true

    # scope :company_projects, -> {where(company_id: company_id)}
    # scope :stars, -> {where(is_star: true)}


    # before_create :genereate_parent_code

    # after_create :generate_default_stages

    # mount_uploader :file, FileUploader
    has_one_attached :file
    has_many_attached :files

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    belongs_to :attri, class_name: "Mat::Attribute", foreign_key: "attribute_id", optional: true
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            user_id: user_id,
            user_name: (user.name rescue ""),
            updater_id: updater_id,
            updater_name: (updater.name rescue ""),
            attribute_id: attribute_id,
            attribute_name: (attribute.name rescue ""),
            name: name,
            color: color,
            extra_price: extra_price,
            sort: sort,
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


    def thin_info
        {
            name: name,
            extra_price: extra_price,
            color: color,
        }
    end
    

    #导入导出头部设置
    # Mat::Value.imp_exp_hander
    def self.imp_exp_hander
        %w(user_id  updater_id  attribute_id  name  color  extra_price  sort  created_at  updated_at)
    end

    # 示例计算金额
    # Mat::Value.last.sum_amount("receive_amount", 1000)
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
# #Mat/value values
# match "values"  => "values#index", via: :get
# match "values"  => "values#create", via: :post
# match "values/:id"  => "values#update", via: :put
# match "values/:id"  => "values#show", via: :get
# match "values/:id"  => "values#destroy", via: :delete
# match "values/batch_action"  => "values#batch_action", via: :post
# match "values/import"  => "values#import", via: :post
