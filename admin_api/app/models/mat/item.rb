class Mat::Item < ApplicationRecord

    # columns: labels, custom_fields, user_id, updater_id, company_id, name, logo, code, py, pinyin, barcode, type_id, category_id, price, cost_price, market_price, description, uom_id, uom_po_id, sale_tax_id, purchase_tax_id, is_sale, is_purchase, is_manufacture, is_stock, is_active, track_inventory, track_inventory_type, product_id, value_id, sku, weight, volume, qty_onhand, qty_available, qty_incoming, qty_outgoing, created_at, updated_at
    # attr_accessor :sort
    # serialize :members
    attribute :created_time, :string
    attribute :updated_time, :string

    # validates :code, length: { in: 2..20 },  presence: true, uniqueness:true
    validates :name, length: { minimum: 2, maximum: 255 }, presence: true

    # scope :company_projects, -> {where(company_id: company_id)}
    # scope :stars, -> {where(is_star: true)}


    # before_create :genereate_parent_code
    before_save :gen_py, :sync_track_inventory_from_product
    before_create :generate_sku, :generate_barcode, :generate_item_code

    # after_create :generate_default_stages

    # mount_uploader :file, FileUploader
    has_one_attached :file
    has_many_attached :files

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    belongs_to :company, class_name: "Company", optional: true
    # belongs_to :type, class_name: "Type", foreign_key: "type_id", optional: true
    belongs_to :category, class_name: "Property", foreign_key: "category_id", optional: true
    belongs_to :uom, class_name: "Property", foreign_key: "uom_id", optional: true
    belongs_to :uom_po, class_name: "UomPo", foreign_key: "uom_po_id", optional: true
    belongs_to :sale_tax, class_name: "SaleTax", foreign_key: "sale_tax_id", optional: true
    belongs_to :purchase_tax, class_name: "PurchaseTax", foreign_key: "purchase_tax_id", optional: true
    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    belongs_to :value, class_name: "Mat::Value", foreign_key: "value_id", optional: true
    has_many :inventories, class_name: "Inv::Inventory", foreign_key: "item_id", dependent: :nullify
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
            name: name,
            name_en: name_en,
            logo: logo,
            code: code,
            py: py,
            pinyin: pinyin,
            barcode: barcode,
            type_id: type_id,
            type_name: (type.name rescue ""),
            category_id: category_id,
            category_name: (category.name rescue ""),
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
            product_id: product_id,
            product_name: (product.name rescue ""),
            value_id: value_id,
            value_name: (value.name rescue ""),
            sku: sku,
            weight: weight,
            volume: volume,
            length: length,
            width: width,
            height: height,
            qty_onhand: qty_onhand,
            qty_available: qty_available,
            qty_incoming: qty_incoming,
            qty_outgoing: qty_outgoing,
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
    # Mat::Item.imp_exp_hander
    def self.imp_exp_hander
        %w(labels  custom_fields  user_id  updater_id  company_id  name  name_en  logo  code  py  pinyin  barcode  type_id  category_id  price  cost_price  market_price  description  uom_id  uom_po_id  sale_tax_id  purchase_tax_id  is_sale  is_purchase  is_manufacture  is_stock  is_active  track_inventory  track_inventory_type  product_id  value_id  sku  weight  volume  length  width  height  qty_onhand  qty_available  qty_incoming  qty_outgoing  created_at  updated_at)
    end

    # 示例计算金额
    # Mat::Item.last.sum_amount("receive_amount", 1000)
    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end

    # 根据 Inv::Inventory 汇总更新 Item 的 qty_onhand、qty_available
    # 库存变动后由 Inv::InventoryService 调用
    def self.sync_inventory_totals(item_id)
        return unless item_id.present?
        item = Mat::Item.find_by(id: item_id)
        return unless item
        return unless item.respond_to?(:qty_onhand)

        row = Inv::Inventory.where(item_id: item_id)
                            .select("COALESCE(SUM(on_hand_qty), 0) AS on_hand, COALESCE(SUM(available_qty), 0) AS available")
                            .take
        on_hand = (row.try(:on_hand) || 0).to_d
        available = (row.try(:available) || 0).to_d
        item.update_columns(qty_onhand: on_hand, qty_available: available)
    end

    # 覆盖 skip_generate_code? 方法，禁用 ApplicationRecord 的自动生成 code
    # 我们使用自己的 generate_item_code 方法
    def skip_generate_code?
        true
    end

    # 自动生成 SKU
    def generate_sku
        # 如果 SKU 已存在，则不重新生成
        return if sku.present?
        
        sku_prefix = nil
        product_id_for_query = nil
        
        # 尝试从产品信息生成 SKU 前缀
        if product_id.present?
            product = Mat::Product.find_by(id: product_id)
            if product
                sku_prefix = generate_sku_prefix(product)
                product_id_for_query = product_id
            else
                Rails.logger.warn "Mat::Item: Product not found (product_id: #{product_id}), using fallback SKU"
            end
        else
            Rails.logger.warn "Mat::Item: product_id is missing, using fallback SKU"
        end
        
        # 如果前缀为空，使用默认值
        if sku_prefix.blank?
            sku_prefix = "ITEM"
        end
        
        # 查找同一产品相同前缀的已有物品，获取最大序号
        # 如果没有 product_id，只查找相同前缀的物品
        max_sequence = if product_id_for_query.present?
            find_max_sku_sequence(sku_prefix, product_id_for_query)
        else
            find_max_sku_sequence_without_product(sku_prefix)
        end
        
        # 生成新的 SKU，序号+1
        sequence = max_sequence + 1
        self.sku = "#{sku_prefix}-#{sequence.to_s.rjust(3, '0')}"
        
        Rails.logger.debug "Mat::Item: Generated SKU: #{self.sku} (product_id: #{product_id}, prefix: #{sku_prefix})"
    end

    # 生成 SKU 前缀（基于产品信息和属性）
    def generate_sku_prefix(product)
        # 使用产品代码或产品名作为基础
        base_prefix = (product.code.presence || product.name || "PRODUCT").gsub(/\s+/, '-')
        
        # 从 custom_fields 中获取所有属性信息
        sku_attributes = []
        if custom_fields.present?
            if custom_fields.is_a?(Hash)
                sku_attributes = custom_fields['sku_attributes'] || custom_fields[:sku_attributes] || []
            elsif custom_fields.is_a?(Array)
                # 如果是数组格式，尝试查找 sku_attributes
                sku_attributes = []
            end
        end
        
        # 确保 sku_attributes 是数组
        sku_attributes = [] unless sku_attributes.is_a?(Array)
        
        if sku_attributes.any?
            # 如果有多个属性，构建完整的属性前缀
            attribute_parts = sku_attributes.map do |attr_info|
                # 支持字符串和符号键
                attr_info = attr_info.with_indifferent_access if attr_info.respond_to?(:with_indifferent_access)
                attribute_name = (attr_info['attribute_name'] || attr_info[:attribute_name] || "未知属性").to_s.gsub(/\s+/, '-')
                value_name = (attr_info['value_name'] || attr_info[:value_name] || "未知值").to_s.gsub(/\s+/, '-')
                "#{attribute_name}-#{value_name}"
            end.compact.reject(&:blank?)
            
            if attribute_parts.any?
                return "#{base_prefix}-#{attribute_parts.join('-')}"
            end
        end
        
        # 如果 custom_fields 中没有属性信息，尝试从 value_id 获取
        if value_id.present?
            begin
                value = Mat::Value.find_by(id: value_id)
                if value
                    attribute = value.attri
                    if attribute
                        attribute_name = (attribute.name || "未知属性").gsub(/\s+/, '-')
                        value_name = (value.name || "未知值").gsub(/\s+/, '-')
                        return "#{base_prefix}-#{attribute_name}-#{value_name}"
                    end
                end
            rescue => e
                Rails.logger.warn "Mat::Item: Error getting attribute from value_id #{value_id}: #{e.message}"
            end
        end
        
        # 如果没有属性值，只返回产品前缀
        base_prefix
    end

    # 查找同一产品相同前缀的最大 SKU 序号
    def find_max_sku_sequence(sku_prefix, product_id_param = nil)
        product_id_param ||= product_id
        return 0 unless product_id_param.present?
        
        # 查找同一产品的所有物品，匹配相同前缀
        # 使用 ESCAPE '|' 转义特殊字符，避免 SQL LIKE 注入（不用反斜杠，避免 MySQL 解析问题）
        escaped_prefix = sku_prefix.gsub(/[%_|]/, '|\0')
        
        # 查询条件：product_id 匹配，SKU 不为空，且匹配前缀模式
        items = Mat::Item.where(product_id: product_id_param)
                          .where.not(sku: nil)  # 排除 SKU 为空的记录
                          .where("sku LIKE ? ESCAPE '|'", "#{escaped_prefix}-%")
                          .order("sku DESC")
                          .limit(1)
        
        if items.any?
            last_sku = items.first.sku
            # 提取序号部分（最后3位数字）
            if last_sku.present? && last_sku =~ /-(\d{3})$/
                $1.to_i
            else
                0
            end
        else
            0
        end
    end

    # 查找相同前缀的最大 SKU 序号（不限制产品）
    def find_max_sku_sequence_without_product(sku_prefix)
        # 使用 ESCAPE '|' 转义特殊字符，避免 SQL LIKE 注入（不用反斜杠，避免 MySQL 解析问题）
        escaped_prefix = sku_prefix.gsub(/[%_|]/, '|\0')
        
        # 查询条件：SKU 不为空，且匹配前缀模式
        items = Mat::Item.where.not(sku: nil)
                          .where("sku LIKE ? ESCAPE '|'", "#{escaped_prefix}-%")
                          .order("sku DESC")
                          .limit(1)
        
        if items.any?
            last_sku = items.first.sku
            # 提取序号部分（最后3位数字）
            if last_sku.present? && last_sku =~ /-(\d{3})$/
                $1.to_i
            else
                0
            end
        else
            0
        end
    end

    # 自动生成物品编号
    def generate_item_code
        # 如果 code 已存在，则不重新生成
        return if code.present?
        
        # 优先使用 SKU 作为 code
        if sku.present?
            self.code = sku
        else
            # 否则使用自动生成的 code，确保唯一性
            generate_unique_code
        end
    end

    # 自动生成条形码
    def generate_barcode
        # 如果条形码已存在，则不重新生成
        return if barcode.present?
        
        self.barcode = generate_unique_barcode
    end

    # 生成唯一的编号
    def generate_unique_code
        loop do
            # 使用 ApplicationRecord 的 generate_code 逻辑生成基础 code
            this_year = Date.today.year
            last_record_year = self.class.last&.created_at&.year rescue nil
            if this_year == last_record_year && self.class.last&.code.present?
                base_code = self.class.last.code.next rescue "#{this_year.to_s[2..3]}0001"
            else
                base_code = "#{this_year.to_s[2..3]}0001"
            end
            
            # 检查 code 是否已存在，确保唯一性
            unless Mat::Item.exists?(code: base_code)
                self.code = base_code
                return
            end
            
            # 如果已存在，添加随机后缀
            random_suffix = rand(100..999)
            candidate_code = "#{base_code}#{random_suffix}"
            unless Mat::Item.exists?(code: candidate_code)
                self.code = candidate_code
                return
            end
        end
    end

    # 生成唯一的条形码
    def generate_unique_barcode
        loop do
            # 使用时间戳（毫秒）+ 随机数生成唯一条形码
            timestamp = (Time.now.to_f * 1000).to_i
            random = rand(1000..9999)
            candidate_barcode = "BC#{timestamp}#{random}"
            
            # 检查条形码是否已存在，确保唯一性
            unless Mat::Item.exists?(barcode: candidate_barcode)
                return candidate_barcode
            end
        end
    end
    private

    # 从产品同步 track_inventory 和 track_inventory_type 字段
    # 仅对实物(type_id=1)和服务(type_id=0)类型生效
    def sync_track_inventory_from_product
        # 只有当 type_id 为 0（服务）或 1（实物）时才同步
        if type_id.present? && (type_id == 0 || type_id == 1)
            if product_id.present?
                product = Mat::Product.find_by(id: product_id)
                if product
                    # 同步产品的 track_inventory 值（包括 false）
                    self.track_inventory = product.track_inventory unless product.track_inventory.nil?
                    # 同步产品的 track_inventory_type
                    self.track_inventory_type = product.track_inventory_type if product.track_inventory_type.present?
                end
            end
        else
            # 对于其他类型（如组合 type_id=2），设置为 false
            self.track_inventory = false
            self.track_inventory_type = nil
        end
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
# #Mat/item items
# match "items"  => "items#index", via: :get
# match "items"  => "items#create", via: :post
# match "items/:id"  => "items#update", via: :put
# match "items/:id"  => "items#show", via: :get
# match "items/:id"  => "items#destroy", via: :delete
# match "items/batch_action"  => "items#batch_action", via: :post
# match "items/import"  => "items#import", via: :post
