class Mat::AttributeLine < ApplicationRecord

    # columns: user_id, product_id, attribute_id, name, values, value_ids, sort, created_at, updated_at
    # attr_accessor :sort
    # serialize :members
    attribute :created_time, :string
    attribute :updated_time, :string

    # validates :code, length: { in: 2..20 },  presence: true, uniqueness:true
    validates :name, length: { in: 2..20 },  presence: true
    validates_uniqueness_of :attribute_id, :scope => :product_id


    # scope :company_projects, -> {where(company_id: company_id)}
    # scope :stars, -> {where(is_star: true)}
    before_save :auto_update_values_by_id

    after_create :regenerate_product_items
    after_update :regenerate_product_items, if: :should_regenerate_items?
    after_destroy :regenerate_product_items

    # before_create :genereate_parent_code

    # after_create :generate_default_stages

    # mount_uploader :file, FileUploader
    has_one_attached :file
    has_many_attached :files

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    belongs_to :attri, class_name: "Mat::Attribute", foreign_key: "attribute_id", optional: true
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            user_id: user_id,
            user_name: (user.name rescue ""),
            product_id: product_id,
            product_name: (product.name rescue ""),
            attribute_id: attribute_id,
            attribute_name: (attribute.name rescue ""),
            name: name,
            values: values,
            value_ids: value_ids,
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

    def auto_update_values_by_id
        if value_ids.present?
            values = ::Mat::Value.where(id: value_ids).map{|e|e.thin_info}
            self.values = values
        end
    end

    # 判断是否需要重新生成物品（当影响物品生成的字段变化时）
    def should_regenerate_items?
        saved_change_to_value_ids? || saved_change_to_product_id? || saved_change_to_attribute_id?
    end

    # 重新生成产品的物品
    def regenerate_product_items
        return unless product_id.present?
        
        product = ::Mat::Product.find_by(id: product_id)
        return unless product
        
        # 删除现有的物品
        product.items.destroy_all
        
        # 重新生成物品
        product.generate_items_from_attribute_lines
    end
    

    #导入导出头部设置
    # Mat::AttributeLine.imp_exp_hander
    def self.imp_exp_hander
        %w(user_id  product_id  attribute_id  name  values  value_ids  sort  created_at  updated_at)
    end

    # 示例计算金额
    # Mat::AttributeLine.last.sum_amount("receive_amount", 1000)
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
# #Mat/attribute line attribute_lines
# match "attribute_lines"  => "attribute_lines#index", via: :get
# match "attribute_lines"  => "attribute_lines#create", via: :post
# match "attribute_lines/:id"  => "attribute_lines#update", via: :put
# match "attribute_lines/:id"  => "attribute_lines#show", via: :get
# match "attribute_lines/:id"  => "attribute_lines#destroy", via: :delete
# match "attribute_lines/batch_action"  => "attribute_lines#batch_action", via: :post
# match "attribute_lines/import"  => "attribute_lines#import", via: :post
