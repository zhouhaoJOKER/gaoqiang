# frozen_string_literal: true

# 库存服务：统一处理库存增减，保证 Inv::Inventory、Inv::InventoryTransaction、Mat::Item 联动
# 所有库存变动必须通过本服务，确保可追溯、数据一致
module Inv
  class InventoryService
    # 完成状态值（工单/报废单等）
    COMPLETED_STATUSES = %w[done completed finished 完成 已完成].freeze

    class << self
      # 增加库存（入库、生产完工等）
      # @param item_id [Integer]
      # @param location_id [Integer]
      # @param quantity [Numeric] 正数
      # @param options [Hash] company_id, warehouse_id, related_order_type, related_order_id, operator_id, remark
      # @return [Inv::Inventory, Inv::InventoryTransaction] 或 raise
      def increase(item_id:, location_id:, quantity:, **options)
        raise ArgumentError, "quantity must be positive" if quantity.to_d <= 0
        _adjust(item_id: item_id, location_id: location_id, quantity_change: quantity.to_d, **options)
      end

      # 减少库存（出库、领料、报废等）
      # @param item_id [Integer]
      # @param location_id [Integer]
      # @param quantity [Numeric] 正数（实际减少量）
      # @param options [Hash] 同上
      # @return [Inv::Inventory, Inv::InventoryTransaction] 或 raise
      def decrease(item_id:, location_id:, quantity:, **options)
        raise ArgumentError, "quantity must be positive" if quantity.to_d <= 0
        _adjust(item_id: item_id, location_id: location_id, quantity_change: -quantity.to_d, **options)
      end

      # 检查是否为完成状态
      def completed?(status)
        return false if status.blank?
        COMPLETED_STATUSES.include?(status.to_s.strip.downcase)
      end

      private

      def _adjust(item_id:, location_id:, quantity_change:, company_id: nil, warehouse_id: nil,
                  related_order_type: nil, related_order_id: nil, operator_id: nil, remark: nil)
        inventory = find_or_create_inventory(item_id, location_id, company_id, warehouse_id)
        qty_before = inventory.on_hand_qty.to_d
        qty_after = qty_before + quantity_change

        raise "库存不足: item_id=#{item_id}, location_id=#{location_id}, 现有=#{qty_before}, 需减=#{quantity_change.abs}" if qty_after < 0

        ActiveRecord::Base.transaction do
          # 更新 Inv::Inventory
          inv_attrs = {
            on_hand_qty: qty_after,
            available_qty: inventory.available_qty.to_d + quantity_change, # 简化：available 同步
            updater_id: operator_id
          }
          inventory.update!(inv_attrs)

          # 创建 Inv::InventoryTransaction
          tx = Inv::InventoryTransaction.create!(
            code: generate_tx_code,
            item_id: item_id,
            location_id: location_id,
            inventory_id: inventory.id,
            transaction_type: quantity_change > 0 ? "in" : "out",
            related_order_type: related_order_type,
            related_order_id: related_order_id,
            quantity_before: qty_before,
            quantity_change: quantity_change,
            quantity_after: qty_after,
            operator_id: operator_id,
            transaction_time: Time.current,
            remark: remark,
            user_id: operator_id
          )

          # 同步 Mat::Item 汇总
          Mat::Item.sync_inventory_totals(item_id)

          [inventory, tx]
        end
      end

      def find_or_create_inventory(item_id, location_id, company_id, warehouse_id)
        inv = Inv::Inventory.find_by(item_id: item_id, location_id: location_id)
        return inv if inv

        loc = Wms::Location.find_by(id: location_id)
        item = Mat::Item.find_by(id: item_id)
        wh_id = warehouse_id || loc&.warehouse_id
        co_id = company_id || item&.company_id

        Inv::Inventory.create!(
          item_id: item_id,
          location_id: location_id,
          company_id: co_id,
          warehouse_id: wh_id,
          on_hand_qty: 0,
          available_qty: 0,
          allocated_qty: 0,
          in_transit_qty: 0
        )
      end

      def generate_tx_code
        "TX#{Time.current.strftime('%Y%m%d%H%M%S')}#{SecureRandom.hex(2).upcase}"
      end
    end
  end
end
