class Wms::NoticeLine < ApplicationRecord

    # columns: notice_id,order_no,product_id,product_name,qty,qty_unit,packaging_note,pieces,sort,user_id,, created_at, updated_at
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

    belongs_to :notice, class_name: "Wms::Notice", foreign_key: "notice_id", optional: true
    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            notice_id: notice_id,
            notice_name: (notice.name rescue ""),
            order_no: order_no,
            product_id: product_id,
            product_name: (product.name rescue ""),
            product_name: product_name,
            qty: qty,
            qty_unit: qty_unit,
            packaging_note: packaging_note,
            pieces: pieces,
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
    # Wms::NoticeLine.imp_exp_hander
    def self.imp_exp_hander
        %w(notice_id  order_no  product_id  product_name  qty  qty_unit  packaging_note  pieces  sort  user_id  created_at  updated_at)
    end

    # 示例计算金额
    # Wms::NoticeLine.last.sum_amount("receive_amount", 1000)
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
# #Wms/notice line notice_lines
# match "notice_lines"  => "notice_lines#index", via: :get
# match "notice_lines"  => "notice_lines#create", via: :post
# match "notice_lines/:id"  => "notice_lines#update", via: :put
# match "notice_lines/:id"  => "notice_lines#show", via: :get
# match "notice_lines/:id"  => "notice_lines#destroy", via: :delete
# match "notice_lines/batch_action"  => "notice_lines#batch_action", via: :post
# match "notice_lines/import"  => "notice_lines#import", via: :post
