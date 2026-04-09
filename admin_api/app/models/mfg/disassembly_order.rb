class Mfg::DisassemblyOrder < ApplicationRecord

    # columns: code, product_id, item_id, lot_id, planned_qty, user_id, updater_id, created_at, updated_at
    attribute :created_time, :string
    attribute :updated_time, :string

    has_one_attached :file
    has_many_attached :files

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    belongs_to :item, class_name: "Mat::Item", foreign_key: "item_id", optional: true
    belongs_to :lot, class_name: "Inv::Lot", foreign_key: "lot_id", optional: true
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record

    def base_info
        {
            id: id,
            code: code,
            product_id: product_id,
            product_name: (product.name rescue ""),
            item_id: item_id,
            item_name: (item.name rescue ""),
            lot_id: lot_id,
            lot_code: (lot.code rescue ""),
            planned_qty: planned_qty,
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
        planned_qty: planned_qty,
        }
    end
    

    def self.imp_exp_hander
        %w(code  product_id  item_id  lot_id  planned_qty  user_id  updater_id  created_at  updated_at)
    end

    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end
end
