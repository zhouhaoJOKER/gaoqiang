class Mfg::OrderLine < ApplicationRecord

    # columns: order_id, product_id, item_id, bom_line_id, required_date, required_qty, allocated_qty, available_qty, shortage_qty, status, is_alternative, alternative_for_id, created_at, updated_at
    attribute :created_time, :string
    attribute :updated_time, :string

    has_one_attached :file
    has_many_attached :files

    belongs_to :order, class_name: "Mfg::Order", foreign_key: "order_id", optional: true
    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    belongs_to :item, class_name: "Mat::Item", foreign_key: "item_id", optional: true
    belongs_to :bom_line, class_name: "Mfg::BomLine", foreign_key: "bom_line_id", optional: true
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record

    def base_info
        {
            id: id,
            order_id: order_id,
            order_code: (order.code rescue ""),
            product_id: product_id,
            product_name: (product.name rescue ""),
            item_id: item_id,
            item_name: (item.name rescue ""),
            bom_line_id: bom_line_id,
            required_date: required_date,
            required_qty: required_qty,
            allocated_qty: allocated_qty,
            available_qty: available_qty,
            shortage_qty: shortage_qty,
            status: status,
            is_alternative: is_alternative,
            alternative_for_id: alternative_for_id,
            created_at: created_at,
            updated_at: updated_at,
            created_time: created_time,
            updated_time: updated_time,
        }
    end

    def show_info
        {
        id: id,
        product_id: product_id,
        required_qty: required_qty,
        }
    end
    

    def self.imp_exp_hander
        %w(order_id  product_id  item_id  bom_line_id  required_date  required_qty  allocated_qty  available_qty  shortage_qty  status  is_alternative  alternative_for_id  created_at  updated_at)
    end

    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end
end
