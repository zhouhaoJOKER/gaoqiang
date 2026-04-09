class Mat::Supplier < ApplicationRecord

    # columns: labels,custom_fields,user_id,updater_id,company_id,product_id,name,code,py,pinyin,min_qty,price,currency_id,c,delay,is_main,sort,, created_at, updated_at
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

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    belongs_to :company, class_name: "Company", optional: true
    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    belongs_to :currency, class_name: "Currency", foreign_key: "currency_id", optional: true
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            labels: labels,
            custom_fields: custom_fields,
            user_id: user_id,
            user_name: (user.name rescue ""),
            updater_id: updater_id,
            updater_name: (updater.name rescue ""),
            company_id: company_id,
            company_name: (company.name rescue ""),
            product_id: product_id,
            product_name: (product.name rescue ""),
            name: name,
            code: code,
            py: py,
            pinyin: pinyin,
            min_qty: min_qty,
            price: price,
            currency_id: currency_id,
            currency_name: (currency.name rescue ""),
            c: c,
            delay: delay,
            is_main: is_main,
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
        code: code,
        name: name,
        }
    end
    

    #导入导出头部设置
    # Mat::Supplier.imp_exp_hander
    def self.imp_exp_hander
        %w(labels  custom_fields  user_id  updater_id  company_id  product_id  name  code  py  pinyin  min_qty  price  currency_id  c  delay  is_main  sort  created_at  updated_at)
    end

    # 示例计算金额
    # Mat::Supplier.last.sum_amount("receive_amount", 1000)
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