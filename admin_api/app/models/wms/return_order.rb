class Wms::ReturnOrder < ApplicationRecord

    # columns: code, return_category, status, original_order_id, warehouse_id, user_id, updater_id, created_at, updated_at
    attribute :created_time, :string
    attribute :updated_time, :string

    has_one_attached :file
    has_many_attached :files

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    has_many :return_order_lines, class_name: "Wms::ReturnOrderLine", foreign_key: "return_order_id", dependent: :destroy
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record

    def base_info
        {
            id: id,
            code: code,
            return_category: return_category,
            status: status,
            original_order_id: original_order_id,
            warehouse_id: warehouse_id,
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
        return_category: return_category,
        status: status,
        }
    end
    

    def self.imp_exp_hander
        %w(code  return_category  status  original_order_id  warehouse_id  user_id  updater_id  created_at  updated_at)
    end

    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end
end
