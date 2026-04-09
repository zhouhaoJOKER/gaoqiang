class Mfg::WorkOrderLoss < ApplicationRecord

    # columns: work_order_id, bom_loss_id, product_id, plan_loss_qty, actual_loss_qty, user_id, updater_id, created_at, updated_at
    attribute :created_time, :string
    attribute :updated_time, :string

    has_one_attached :file
    has_many_attached :files

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    belongs_to :work_order, class_name: "Mfg::WorkOrder", foreign_key: "work_order_id", optional: true
    belongs_to :bom_loss, class_name: "Mfg::BomLoss", foreign_key: "bom_loss_id", optional: true
    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record

    def base_info
        {
            id: id,
            work_order_id: work_order_id,
            work_order_code: (work_order.code rescue ""),
            bom_loss_id: bom_loss_id,
            product_id: product_id,
            product_name: (product.name rescue ""),
            plan_loss_qty: plan_loss_qty,
            actual_loss_qty: actual_loss_qty,
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
        product_id: product_id,
        plan_loss_qty: plan_loss_qty,
        actual_loss_qty: actual_loss_qty,
        }
    end
    

    def self.imp_exp_hander
        %w(work_order_id  bom_loss_id  product_id  plan_loss_qty  actual_loss_qty  user_id  updater_id  created_at  updated_at)
    end

    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end
end
