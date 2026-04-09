class Inv::Lot < ApplicationRecord

    # columns: code, item_id, product_id, company_id, ref, qty, unit_cost, expiration_date, alert_date, removal_date, order_type, order_id, order_line_id, user_id, description, created_at, updated_at
    # attr_accessor :sort
    # serialize :members
    attribute :created_time, :string
    attribute :updated_time, :string

    # validates :code, length: { in: 2..20 },  presence: true, uniqueness:true
    # validates :name, length: { in: 2..20 },  presence: true
    
    # 覆盖 skip_generate_code? 方法，禁用 ApplicationRecord 的自动生成 code
    # 我们使用自己的 generate_lot_code 方法
    def skip_generate_code?
        true
    end

    # scope :company_projects, -> {where(company_id: company_id)}
    # scope :stars, -> {where(is_star: true)}


    # before_create :genereate_parent_code
    # before_save :gen_py
    before_create :generate_lot_code

    # after_create :generate_default_stages

    # mount_uploader :file, FileUploader
    has_one_attached :file
    has_many_attached :files

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :company, class_name: "Company", optional: true
    belongs_to :item, class_name: "Mat::Item", foreign_key: "item_id", optional: true
    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    # has_many :members, class_name: "Pm::Member", as: :record
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record



    def base_info
        {
            id: id,
            code: code,
            item_id: item_id,
            item_name: (item.name rescue ""),
            product_id: product_id,
            product_name: (product.name rescue ""),
            company_id: company_id,
            company_name: (company.name rescue ""),
            ref: ref,
            qty: qty,
            unit_cost: unit_cost,
            expiration_date: expiration_date,
            alert_date: alert_date,
            removal_date: removal_date,
            order_type: order_type,
            order_id: order_id,
            order_line_id: order_line_id,
            user_id: user_id,
            user_name: (user.name rescue ""),
            description: description,
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
        ref: ref,
        }
    end
    

    #导入导出头部设置
    # Inv::Lot.imp_exp_hander
    def self.imp_exp_hander
        %w(code  item_id  product_id  company_id  ref  qty  unit_cost  expiration_date  alert_date  removal_date  order_type  order_id  order_line_id  user_id  description  created_at  updated_at)
    end

    # 示例计算金额
    # Inv::Lot.last.sum_amount("receive_amount", 1000)
    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end

    private

    # 生成批次号或序列号
    # 根据 track_inventory 和 track_inventory_type 来决定生成批次号（lot）还是序列号（serial）
    def generate_lot_code
        # 如果 code 已存在，则不重新生成
        return if code.present?

        # 获取关联的 item 或 product
        source_item = item
        source_product = product || (source_item&.product)

        # 检查是否需要追踪库存
        # 优先使用 item 的值，如果没有则使用 product 的值
        track_inventory_flag = if source_item
            source_item.track_inventory
        elsif source_product
            source_product.track_inventory
        else
            false
        end

        track_inventory_type_value = if source_item && source_item.track_inventory_type.present?
            source_item.track_inventory_type
        elsif source_product && source_product.track_inventory_type.present?
            source_product.track_inventory_type
        else
            nil
        end

        # 如果不需要追踪库存，使用默认编号生成逻辑
        unless track_inventory_flag == true && track_inventory_type_value.present?
            generate_default_code
            return
        end

        # 根据 track_inventory_type 生成不同的编号
        case track_inventory_type_value.to_s.downcase.strip
        when 'lot', '批次', 'batch', '批次号'
            generate_lot_number
        when 'serial', '序列', 'serial_number', '序列号', 'sn'
            generate_serial_number
        else
            # 未知类型，使用默认编号
            Rails.logger.warn "Inv::Lot: Unknown track_inventory_type: #{track_inventory_type_value}, using default code generation"
            generate_default_code
        end
    end

    # 生成批次号（多个物品可以共享同一个批次号）
    def generate_lot_number
        # 批次号格式：LOT + 年份后两位 + 6位序号，例如：LOT26000001
        this_year = Date.today.year.to_s[2..3]
        
        # 查找同一年份的最大批次号
        last_lot = Inv::Lot.where("code LIKE ?", "LOT#{this_year}%")
                          .where.not(code: nil)
                          .order("code DESC")
                          .first
        
        if last_lot && last_lot.code.present? && last_lot.code.match(/^LOT#{this_year}(\d+)$/)
            # 提取序号并递增
            sequence = last_lot.code.gsub(/^LOT#{this_year}/, '').to_i
            sequence += 1
        else
            sequence = 1
        end
        
        # 生成批次号，序号部分6位，不足补0
        self.code = "LOT#{this_year}#{sequence.to_s.rjust(6, '0')}"
        
        # 确保唯一性，如果已存在则递增
        while Inv::Lot.exists?(code: self.code)
            sequence += 1
            self.code = "LOT#{this_year}#{sequence.to_s.rjust(6, '0')}"
        end
    end

    # 生成序列号（每个物品唯一）
    def generate_serial_number
        # 序列号格式：SN + 年份后两位 + 8位序号，例如：SN2600000001
        this_year = Date.today.year.to_s[2..3]
        
        # 查找同一年份的最大序列号
        last_serial = Inv::Lot.where("code LIKE ?", "SN#{this_year}%")
                              .where.not(code: nil)
                              .order("code DESC")
                              .first
        
        if last_serial && last_serial.code.present? && last_serial.code.match(/^SN#{this_year}(\d+)$/)
            # 提取序号并递增
            sequence = last_serial.code.gsub(/^SN#{this_year}/, '').to_i
            sequence += 1
        else
            sequence = 1
        end
        
        # 生成序列号，序号部分8位，不足补0
        self.code = "SN#{this_year}#{sequence.to_s.rjust(8, '0')}"
        
        # 确保唯一性，如果已存在则递增
        while Inv::Lot.exists?(code: self.code)
            sequence += 1
            self.code = "SN#{this_year}#{sequence.to_s.rjust(8, '0')}"
        end
    end

    # 生成默认编号（当不需要追踪库存或类型未知时）
    def generate_default_code
        # 使用 ApplicationRecord 的默认生成逻辑
        this_year = Date.today.year.to_s[2..3]
        last_record_year = self.class.last&.created_at&.year rescue nil
        
        if this_year.to_i == last_record_year && self.class.last&.code.present?
            self.code = self.class.last.code.next rescue "#{this_year}0001"
        else
            self.code = "#{this_year}0001"
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
# #Inv/lot lots
# match "lots"  => "lots#index", via: :get
# match "lots"  => "lots#create", via: :post
# match "lots/:id"  => "lots#update", via: :put
# match "lots/:id"  => "lots#show", via: :get
# match "lots/:id"  => "lots#destroy", via: :delete
# match "lots/batch_action"  => "lots#batch_action", via: :post
# match "lots/import"  => "lots#import", via: :post
