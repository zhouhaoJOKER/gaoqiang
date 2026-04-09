class Mfg::Actual < ApplicationRecord

    # columns: leader,product_id,date,name,code,specification,spec,qty,unit,time_start,time_end,hour,planned_production_qty,actual_production_qty,actual_production_unit,worker_count,uncompleted_remark,remark,sort,user_id,updater_id,py,, created_at, updated_at
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

    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            leader: leader,
            product_id: product_id,
            product_name: (product.name rescue ""),
            date: date,
            name: name,
            code: code,
            specification: specification,
            spec: spec,
            qty: qty,
            unit: unit,
            time_start: time_start,
            time_end: time_end,
            hour: hour,
            planned_production_qty: planned_production_qty,
            actual_production_qty: actual_production_qty,
            actual_production_unit: actual_production_unit,
            worker_count: worker_count,
            uncompleted_remark: uncompleted_remark,
            remark: remark,
            sort: sort,
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
    # Mfg::Actual.imp_exp_hander
    def self.imp_exp_hander
        %w(leader  product_id  date  name  code  specification  spec  qty  unit  time_start  time_end  hour  planned_production_qty  actual_production_qty  actual_production_unit  worker_count  uncompleted_remark  remark  sort  user_id  updater_id  py  created_at  updated_at)
    end

    # 示例计算金额
    # Mfg::Actual.last.sum_amount("receive_amount", 1000)
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
# #Mfg/actual actuals
# match "actuals"  => "actuals#index", via: :get
# match "actuals"  => "actuals#create", via: :post
# match "actuals/:id"  => "actuals#update", via: :put
# match "actuals/:id"  => "actuals#show", via: :get
# match "actuals/:id"  => "actuals#destroy", via: :delete
# match "actuals/batch_action"  => "actuals#batch_action", via: :post
# match "actuals/import"  => "actuals#import", via: :post
