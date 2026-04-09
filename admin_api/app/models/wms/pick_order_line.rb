class Wms::PickOrderLine < ApplicationRecord

    # columns: pick_order_id, item_id, location_id, plan_qty, picked_qty, status, user_id, updater_id, created_at, updated_at
    attribute :created_time, :string
    attribute :updated_time, :string

    has_one_attached :file
    has_many_attached :files

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    belongs_to :pick_order, class_name: "Wms::PickOrder", foreign_key: "pick_order_id", optional: true
    belongs_to :item, class_name: "Mat::Item", foreign_key: "item_id", optional: true
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record

    def base_info
        {
            id: id,
            pick_order_id: pick_order_id,
            pick_order_code: (pick_order.code rescue ""),
            item_id: item_id,
            item_name: (item.name rescue ""),
            location_id: location_id,
            plan_qty: plan_qty,
            picked_qty: picked_qty,
            status: status,
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
        item_id: item_id,
        plan_qty: plan_qty,
        picked_qty: picked_qty,
        }
    end
    

    def self.imp_exp_hander
        %w(pick_order_id  item_id  location_id  plan_qty  picked_qty  status  user_id  updater_id  created_at  updated_at)
    end

    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end
end
