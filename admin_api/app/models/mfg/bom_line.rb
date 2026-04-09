class Mfg::BomLine < ApplicationRecord

    # columns: bom_id, product_id, product_qty, product_uom_id, operation_id, optional, alternative, sort, user_id, updater_id, created_at, updated_at
    attribute :created_time, :string
    attribute :updated_time, :string

    has_one_attached :file
    has_many_attached :files

    belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
    belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true
    belongs_to :bom, class_name: "Mfg::Bom", foreign_key: "bom_id", optional: true
    belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
    belongs_to :product_uom, class_name: "Property", foreign_key: "product_uom_id", optional: true
    has_many :bom_losses, class_name: "Mfg::BomLoss", foreign_key: "bom_line_id", dependent: :destroy
    has_many :logs, class_name: "Log", as: :record
    has_many :activities, class_name: "Activity", as: :record

    def base_info
        {
            id: id,
            bom_id: bom_id,
            bom_code: (bom.code rescue ""),
            product_id: product_id,
            product_name: (product.name rescue ""),
            product_qty: product_qty,
            product_uom_id: product_uom_id,
            product_uom: (product_uom rescue ""),
            operation_id: operation_id,
            optional: optional,
            alternative: alternative,
            sort: sort,
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
        product_qty: product_qty,
        }
    end
    

    def self.imp_exp_hander
        %w(bom_id  product_id  product_qty  product_uom_id  operation_id  optional  alternative  sort  user_id  updater_id  created_at  updated_at)
    end

    def sum_amount(column, amount)
        update_columns("#{column}": amount)
    end
end
