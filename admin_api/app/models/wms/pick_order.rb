class Wms::PickOrder < ApplicationRecord

    # columns: code, work_order_id, order_category, status, warehouse_id, plan_date, company_id, description, user_id, updater_id, created_at, updated_at
    attribute :created_time, :string
    attribute :updated_time, :string

    has_one_attached :file
    has_many_attached :files

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    belongs_to :company, class_name: "Company", optional: true
    has_many :pick_order_lines, class_name: "Wms::PickOrderLine", foreign_key: "pick_order_id", dependent: :destroy
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record

    def base_info
        {
            id: id,
            code: code,
            work_order_id: work_order_id,
            order_category: order_category,
            status: status,
            warehouse_id: warehouse_id,
            plan_date: plan_date,
            company_id: company_id,
            company_name: (company.name rescue ""),
            description: description,
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
        %w(code  work_order_id  order_category  status  warehouse_id  plan_date  company_id  description  user_id  updater_id  created_at  updated_at)
    end

    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end
end
