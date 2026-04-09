class Inv::Inventory < ApplicationRecord

    # columns: item_id, location_id, company_id, warehouse_id, on_hand_qty, available_qty, allocated_qty, in_transit_qty, status_id, last_count_date, user_id, updater_id, labels, custom_fields, created_at, updated_at
    attribute :created_time, :string
    attribute :updated_time, :string

    has_one_attached :file
    has_many_attached :files

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    belongs_to :company, class_name: "Company", optional: true
    belongs_to :item, class_name: "Mat::Item", foreign_key: "item_id", optional: true
    belongs_to :location, class_name: "Wms::Location", foreign_key: "location_id", optional: true
    belongs_to :warehouse, class_name: "Wms::Warehouse", foreign_key: "warehouse_id", optional: true
    has_many :inventory_transactions, class_name: "Inv::InventoryTransaction", foreign_key: "inventory_id", dependent: :nullify
    has_many :inventory_locks, class_name: "Inv::InventoryLock", foreign_key: "inventory_id", dependent: :destroy
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record

    def base_info
        {
            id: id,
            item_id: item_id,
            item_name: (item.name rescue ""),
            location_id: location_id,
            location_name: (location.name rescue ""),
            company_id: company_id,
            company_name: (company.name rescue ""),
            warehouse_id: warehouse_id,
            warehouse_name: (warehouse.name rescue ""),
            on_hand_qty: on_hand_qty,
            available_qty: available_qty,
            allocated_qty: allocated_qty,
            in_transit_qty: in_transit_qty,
            status_id: status_id,
            last_count_date: last_count_date,
            user_id: user_id,
            user_name: (user.name rescue ""),
            updater_id: updater_id,
            updater_name: (updater.name rescue ""),
            labels: labels,
            custom_fields: custom_fields,
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
            location_id: location_id,
            on_hand_qty: on_hand_qty,
            available_qty: available_qty,
        }
    end

    def self.imp_exp_hander
        %w(item_id  location_id  company_id  warehouse_id  on_hand_qty  available_qty  allocated_qty  in_transit_qty  status_id  last_count_date  user_id  updater_id  labels  custom_fields  created_at  updated_at)
    end

    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end
end
