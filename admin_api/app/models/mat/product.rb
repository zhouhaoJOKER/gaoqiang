class Mat::Product < ApplicationRecord

    # columns: labels, custom_fields, user_id, updater_id, company_id, name, logo, image_url, code, py, pinyin, type_id, category_id, material, full_capacity, nominal_capacity, gram_weight, caliber, cap_height, max_diameter, label_size, price, cost_price, market_price, description, uom_id, uom_po_id, sale_tax_id, purchase_tax_id, is_sale, is_purchase, is_manufacture, is_stock, is_active, track_inventory, track_inventory_type, on_hand_quantity, created_at, updated_at, combo_id
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

    after_create :generate_items_from_attribute_lines
    # after_create :generate_default_stages

    # mount_uploader :file, FileUploader
    has_one_attached :file
    has_many_attached :files

    belongs_to :user, class_name: "::User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "::User", foreign_key: "updater_id", optional: true
    belongs_to :company, class_name: "Company", optional: true
    # belongs_to :type, class_name: "Type", foreign_key: "type_id", optional: true
    # category_id 指向二级分类（规格），对应 Property.parent_id 为一级大类
    belongs_to :category, class_name: "Property", foreign_key: "category_id", optional: true
    belongs_to :uom, class_name: "Uom", foreign_key: "uom_id", optional: true
    belongs_to :uom_po, class_name: "UomPo", foreign_key: "uom_po_id", optional: true
    belongs_to :sale_tax, class_name: "SaleTax", foreign_key: "sale_tax_id", optional: true
    belongs_to :purchase_tax, class_name: "PurchaseTax", foreign_key: "purchase_tax_id", optional: true
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :attribute_lines, class_name: "Mat::AttributeLine", foreign_key: "product_id"
    has_many :items, class_name: "Mat::Item", foreign_key: "product_id"
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record


    def get_type_name
        case type_id
        when 0
            "服务"
        when 1
            "实物"
        when 2
            "组合"
        else
            '-'
        end
    end
    
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
            name: name,
            name_en: name_en,
            logo: logo,
            image_url: image_url,
            code: code,
            py: py,
            pinyin: pinyin,
            type_id: type_id,
            combo_id: combo_id,
            type_name: (get_type_name rescue ""),
            category_id: category_id,
            category_name: category_leaf_name,
            parent_category_id: category_parent_display_id,
            parent_category_name: category_parent_display_name,
            material: material,
            full_capacity: full_capacity,
            nominal_capacity: nominal_capacity,
            gram_weight: gram_weight,
            caliber: caliber,
            cap_height: cap_height,
            max_diameter: max_diameter,
            label_size: label_size,
            price: price,
            cost_price: cost_price,
            market_price: market_price,
            description: description,
            uom_id: uom_id,
            uom_name: (uom.name rescue ""),
            uom_po_id: uom_po_id,
            uom_po_name: (uom_po.name rescue ""),
            sale_tax_id: sale_tax_id,
            sale_tax_name: (sale_tax.name rescue ""),
            purchase_tax_id: purchase_tax_id,
            purchase_tax_name: (purchase_tax.name rescue ""),
            is_sale: is_sale,
            is_purchase: is_purchase,
            is_manufacture: is_manufacture,
            is_stock: is_stock,
            is_active: is_active,
            track_inventory: track_inventory,
            track_inventory_type: track_inventory_type,
            on_hand_quantity: on_hand_quantity,
            created_at: created_at,
            updated_at: updated_at,
            created_time: created_time,
            updated_time: updated_time
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
    # Mat::Product.imp_exp_hander
    def self.imp_exp_hander
        %w(labels  custom_fields  user_id  updater_id  company_id  name  name_en  logo  image_url  code  py  pinyin  type_id  category_id  material  full_capacity  nominal_capacity  gram_weight  caliber  cap_height  max_diameter  label_size  price  cost_price  market_price  description  uom_id  uom_po_id  sale_tax_id  purchase_tax_id  is_sale  is_purchase  is_manufacture  is_stock  is_active  track_inventory  track_inventory_type  on_hand_quantity  created_at  updated_at)
    end

    # 示例计算金额
    # Mat::Product.last.sum_amount("receive_amount", 1000)
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

    # 根据属性变体记录生成物品
    def generate_items_from_attribute_lines
        # 重新加载关联，确保获取最新的 attribute_lines
        reload if persisted?
        
        # 获取所有属性变体记录，并预加载关联的属性
        attribute_lines_list = attribute_lines.includes(:attri).order(:sort).to_a
        
        # 过滤出 is_variant 为 true 的属性变体记录
        variant_attribute_lines = attribute_lines_list.select do |attr_line|
            attr_line.attri&.is_variant == true
        end
        
        if variant_attribute_lines.empty?
            # 如果没有变体属性，生成一个默认的物品
            create_default_item
        else
            # 收集所有变体属性的 value_ids，同时保存属性信息用于生成 SKU
            variant_data = variant_attribute_lines.map do |attr_line|
                ids = attr_line.value_ids || []
                ids = ids.is_a?(Array) ? ids : []
                {
                    attribute_line: attr_line,
                    attribute: attr_line.attri,
                    value_ids: ids
                }
            end.reject { |data| data[:value_ids].empty? }
            
            if variant_data.empty?
                # 如果所有变体属性都没有 value_ids，生成一个默认的物品
                create_default_item
            else
                # 提取 value_ids 数组用于计算笛卡尔积
                value_ids_arrays = variant_data.map { |data| data[:value_ids] }
                
                # 计算所有属性值的笛卡尔积
                if value_ids_arrays.length == 1
                    # 只有一个属性变体时，直接使用其 value_ids
                    combinations = value_ids_arrays.first.map { |id| [id] }
                else
                    # 多个属性变体时，计算笛卡尔积
                    combinations = value_ids_arrays.first.product(*value_ids_arrays[1..-1])
                end
                
                # 为每个组合生成一个物品
                combinations.each do |value_ids_combo|
                    create_item_from_value_ids(value_ids_combo, variant_data)
                end
            end
        end
    end

    # 一级大类（当 category 为子级时取其 parent；扁平时无 parent）
    def category_parent
        return nil if category.blank?
        category.parent_id.present? ? category.parent : nil
    end

    # API：大类 id（扁平未拆规格时与 category_id 相同，便于级联选择器）
    def category_parent_display_id
        return nil if category.blank?
        p = category_parent
        p ? p.id : category.id
    end

    def category_parent_display_name
        return "" if category.blank?
        p = category_parent
        p ? p.name.to_s : category.name.to_s
    end

    def category_leaf_name
        return "" if category.blank?
        category.name.to_s
    end

    private

    # 创建默认物品（无属性变体）
    def create_default_item
        item_attrs = {
            product_id: id,
            name: name,
            user_id: user_id,
            company_id: company_id,
            type_id: type_id,
            category_id: category_id,
            price: price,
            cost_price: cost_price,
            market_price: market_price,
            description: description,
            uom_id: uom_id,
            uom_po_id: uom_po_id,
            sale_tax_id: sale_tax_id,
            purchase_tax_id: purchase_tax_id,
            is_sale: is_sale,
            is_purchase: is_purchase,
            is_manufacture: is_manufacture,
            is_stock: is_stock,
            is_active: is_active,
            value_id: nil,
            logo: logo,
            labels: labels,
            custom_fields: custom_fields
        }
        
        Mat::Item.create(item_attrs)
    end

    # 根据属性值ID组合创建物品
    def create_item_from_value_ids(value_ids_combo, variant_data)
        # 获取所有属性值对象
        values = Mat::Value.where(id: value_ids_combo).index_by(&:id)
        
        # 构建物品名称（产品名称 + 属性值名称）
        value_names = value_ids_combo.map do |value_id|
            values[value_id]&.name || "未知"
        end
        
        item_name = if value_names.any?
            "#{name} (#{value_names.join(' / ')})"
        else
            name
        end
        
        # 计算额外价格（所有属性值的额外价格之和）
        extra_price = value_ids_combo.sum do |value_id|
            values[value_id]&.extra_price || 0
        end
        
        # 使用最后一个属性值ID作为 value_id（因为 Item 只有一个 value_id 字段）
        last_value_id = value_ids_combo.last
        
        # 构建属性值组合的标识（用于生成 SKU）
        # 将所有属性值ID和属性信息保存到 custom_fields 中
        sku_attributes = variant_data.map.with_index do |data, index|
            value_id = value_ids_combo[index]
            value = values[value_id]
            if value && data[:attribute]
                {
                    attribute_id: data[:attribute].id,
                    attribute_name: data[:attribute].name,
                    value_id: value_id,
                    value_name: value.name
                }
            end
        end.compact
        
        # 合并到 custom_fields 中
        item_custom_fields = (custom_fields || {}).dup
        item_custom_fields['sku_attributes'] = sku_attributes
        
        item_attrs = {
            product_id: id,
            name: item_name,
            user_id: user_id,
            company_id: company_id,
            type_id: type_id,
            category_id: category_id,
            price: (price || 0) + extra_price,
            cost_price: cost_price,
            market_price: market_price,
            description: description,
            uom_id: uom_id,
            uom_po_id: uom_po_id,
            sale_tax_id: sale_tax_id,
            purchase_tax_id: purchase_tax_id,
            is_sale: is_sale,
            is_purchase: is_purchase,
            is_manufacture: is_manufacture,
            is_stock: is_stock,
            is_active: is_active,
            value_id: last_value_id,
            logo: logo,
            labels: labels,
            custom_fields: item_custom_fields
        }
        
        # 创建物品，SKU 会在 before_create 回调中自动生成
        Mat::Item.create(item_attrs)
    end
end
# #Mat/product products
# match "products"  => "products#index", via: :get
# match "products"  => "products#create", via: :post
# match "products/:id"  => "products#update", via: :put
# match "products/:id"  => "products#show", via: :get
# match "products/:id"  => "products#destroy", via: :delete
# match "products/batch_action"  => "products#batch_action", via: :post
# match "products/import"  => "products#import", via: :post
