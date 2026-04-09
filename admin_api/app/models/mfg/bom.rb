class Mfg::Bom < ApplicationRecord

    # columns: code, product_id, type_id, product_qty, uom_id, is_active, is_default, ready_to_produce, picking_type_id, company_id, user_id, updater_id, created_at, updated_at
    attribute :created_time, :string
    attribute :updated_time, :string

    has_one_attached :file
    has_many_attached :files

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    belongs_to :company, class_name: "Company", optional: true
    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    belongs_to :uom, class_name: "Property", foreign_key: "uom_id", optional: true
    belongs_to :type, class_name: "Property", foreign_key: "type_id", optional: true
    has_many :bom_lines, class_name: "Mfg::BomLine", foreign_key: "bom_id", dependent: :destroy
    has_many :bom_byproducts, class_name: "Mfg::BomByproduct", foreign_key: "bom_id", dependent: :destroy
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record

    # type 对象结构: { sign, name, py, color, abbr }，来自 Property
    def type_info
        return nil unless type_id.present?
        type.present? ? type.base_info : nil
    end

    def base_info
        {
            id: id,
            code: code,
            product_id: product_id,
            product_name: (product.name rescue ""),
            type_id: type_id,
            type: type_info,
            product_qty: product_qty,
            uom_id: uom_id,
            uom: (uom.present? ? uom.base_info : nil),
            uom_name: (uom.name rescue ""),
            is_active: is_active,
            is_default: is_default,
            ready_to_produce: ready_to_produce,
            picking_type_id: picking_type_id,
            company_id: company_id,
            company_name: (company.name rescue ""),
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
            product_id: product_id,
            product_name: (product.name rescue ""),
            type_id: type_id,
            type: type_info,
            product_qty: product_qty,
            uom_id: uom_id,
            uom_name: (uom.name rescue ""),
        }
    end
    

    def self.imp_exp_hander
        %w(code  product_id  type_id  product_qty  uom_id  is_active  is_default  ready_to_produce  picking_type_id  company_id  user_id  updater_id  created_at  updated_at)
    end

    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end
end
