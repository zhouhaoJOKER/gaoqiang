class Mfg::Order < ApplicationRecord

    # columns: code, product_id, item_id, bom_id, plan_qty, finish_qty, scrap_qty, status, demand_date, source_order_type, source_order_id, company_id, warehouse_id, user_id, updater_id, created_at, updated_at
    attribute :created_time, :string
    attribute :updated_time, :string

    has_one_attached :file
    has_many_attached :files

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    belongs_to :company, class_name: "Company", optional: true
    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    belongs_to :item, class_name: "Mat::Item", foreign_key: "item_id", optional: true
    belongs_to :bom, class_name: "Mfg::Bom", foreign_key: "bom_id", optional: true
    has_many :order_lines, class_name: "Mfg::OrderLine", foreign_key: "order_id", dependent: :destroy
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
            bom_id: bom_id,
            bom_name: (bom.name rescue ""),
            bom_code: (bom.code rescue ""),
            plan_qty: plan_qty,
            finish_qty: finish_qty,
            scrap_qty: scrap_qty,
            status: status,
            demand_date: demand_date,
            source_order_type: source_order_type,
            source_order_id: source_order_id,
            source_order_name: (source_order.name rescue ""),
            company_id: company_id,
            company_name: (company.name rescue ""),
            warehouse_id: warehouse_id,
            warehouse_name: (warehouse.name rescue ''),
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
        %w(code  product_id  item_id  bom_id  plan_qty  finish_qty  scrap_qty  status  demand_date  source_order_type  source_order_id  company_id  warehouse_id  user_id  updater_id  created_at  updated_at)
    end

    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end
end
