class Mfg::WorkOrder < ApplicationRecord

    # columns: code, bom_id, product_id, plan_qty, actual_qty, status, plan_start, plan_finish, actual_start, actual_finish, warehouse_id, company_id, user_id, updater_id, created_at, updated_at
    attribute :created_time, :string
    attribute :updated_time, :string

    has_one_attached :file
    has_many_attached :files

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    belongs_to :company, class_name: "Company", optional: true
    belongs_to :bom, class_name: "Mfg::Bom", foreign_key: "bom_id", optional: true
    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    has_many :work_order_losses, class_name: "Mfg::WorkOrderLoss", foreign_key: "work_order_id", dependent: :destroy
    has_many :work_order_byproducts, class_name: "Mfg::WorkOrderByproduct", foreign_key: "work_order_id", dependent: :destroy
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record

    def base_info
        {
            id: id,
            code: code,
            bom_id: bom_id,
            bom_code: (bom.code rescue ""),
            product_id: product_id,
            product_name: (product.name rescue ""),
            plan_qty: plan_qty,
            actual_qty: actual_qty,
            status: status,
            plan_start: plan_start,
            plan_finish: plan_finish,
            actual_start: actual_start,
            actual_finish: actual_finish,
            warehouse_id: warehouse_id,
            company_id: company_id,
            company_name: (company.name rescue ""),
            user_id: user_id,
            user_name: (user.name rescue ""),
            updater_id: updater_id,
            updater_name: (updater.name rescue ""),
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
        status: status,
        }
    end
    

    def self.imp_exp_hander
        %w(code  bom_id  product_id  plan_qty  actual_qty  status  plan_start  plan_finish  actual_start  actual_finish  warehouse_id  company_id  user_id  updater_id  created_at  updated_at)
    end

    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end

    # 工单完成时同步库存：领料减、入库增
    # 仅当 status 为完成且未同步时执行，避免重复
    def sync_inventory_on_complete!(operator_id: nil)
        return false unless Inv::InventoryService.completed?(status)
        return false if inventory_synced == true

        operator_id ||= updater_id || user_id

        ActiveRecord::Base.transaction do
            # 入库单：增加成品/副产品库存
            Wms::ReceiveOrder.where(work_order_id: id).find_each do |ro|
                ro.receive_order_lines.where("received_qty > 0").find_each do |line|
                    next unless line.item_id.present? && line.location_id.present?
                    qty = line.received_qty.to_d
                    next if qty <= 0
                    Inv::InventoryService.increase(
                        item_id: line.item_id,
                        location_id: line.location_id,
                        quantity: qty,
                        related_order_type: "Wms::ReceiveOrder",
                        related_order_id: ro.id,
                        operator_id: operator_id,
                        remark: "工单#{code}完工入库"
                    )
                end
            end

            # 领料单：减少物料库存
            Wms::PickOrder.where(work_order_id: id).find_each do |po|
                po.pick_order_lines.where("picked_qty > 0").find_each do |line|
                    next unless line.item_id.present? && line.location_id.present?
                    qty = line.picked_qty.to_d
                    next if qty <= 0
                    Inv::InventoryService.decrease(
                        item_id: line.item_id,
                        location_id: line.location_id,
                        quantity: qty,
                        related_order_type: "Wms::PickOrder",
                        related_order_id: po.id,
                        operator_id: operator_id,
                        remark: "工单#{code}领料出库"
                    )
                end
            end

            update_columns(inventory_synced: true)
            true
        end
    rescue => e
        Rails.logger.error "WorkOrder#sync_inventory_on_complete! failed: #{e.message}"
        raise
    end
end
