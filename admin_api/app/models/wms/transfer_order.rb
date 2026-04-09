class Wms::TransferOrder < ApplicationRecord

    # columns: code, transfer_type, status, from_warehouse_id, to_warehouse_id, move_category, plan_date, user_id, updater_id, created_at, updated_at
    attribute :created_time, :string
    attribute :updated_time, :string

    has_one_attached :file
    has_many_attached :files

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    belongs_to :from_warehouse, class_name: "Wms::Warehouse", foreign_key: "from_warehouse_id", optional: true
    belongs_to :to_warehouse, class_name: "Wms::Warehouse", foreign_key: "to_warehouse_id", optional: true
    belongs_to :move_category, class_name: "Property", foreign_key: "move_category_id", optional: true
    has_many :transfer_order_lines, class_name: "Wms::TransferOrderLine", foreign_key: "transfer_order_id", dependent: :destroy
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record

    def base_info
        {
            id: id,
            code: code,
            transfer_type: transfer_type,
            status: status,
            from_warehouse_id: from_warehouse_id,
            to_warehouse_id: to_warehouse_id,
            from_warehouse_name: (from_warehouse.name rescue ""),
            to_warehouse_name: (to_warehouse.name rescue ""),
            move_category: move_category,
            plan_date: (bt(plan_date) rescue ""),
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
        transfer_type: transfer_type,
        status: status,
        }
    end
    

    def self.imp_exp_hander
        %w(code  transfer_type  status  from_warehouse_id  to_warehouse_id  move_category  plan_date  user_id  updater_id  created_at  updated_at)
    end

    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end
end
