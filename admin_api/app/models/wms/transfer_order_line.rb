class Wms::TransferOrderLine < ApplicationRecord

    # columns: transfer_order_id, item_id, from_location_id, to_location_id, plan_qty, moved_qty, received_qty, created_at, updated_at
    attribute :created_time, :string
    attribute :updated_time, :string

    has_one_attached :file
    has_many_attached :files

    belongs_to :transfer_order, class_name: "Wms::TransferOrder", foreign_key: "transfer_order_id", optional: true
    belongs_to :item, class_name: "Mat::Item", foreign_key: "item_id", optional: true
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record

    def base_info
        {
            id: id,
            transfer_order_id: transfer_order_id,
            transfer_order_code: (transfer_order.code rescue ""),
            item_id: item_id,
            item_name: (item.name rescue ""),
            from_location_id: from_location_id,
            to_location_id: to_location_id,
            plan_qty: plan_qty,
            moved_qty: moved_qty,
            received_qty: received_qty,
            created_at: created_at,
            updated_at: updated_at,
            created_time: created_time,
            updated_time: updated_time,
        }
    end

    def show_info
        {
        id: id,
        item_id: item_id,
        plan_qty: plan_qty,
        moved_qty: moved_qty,
        received_qty: received_qty,
        }
    end
    

    def self.imp_exp_hander
        %w(transfer_order_id  item_id  from_location_id  to_location_id  plan_qty  moved_qty  received_qty  created_at  updated_at)
    end

    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end
end
