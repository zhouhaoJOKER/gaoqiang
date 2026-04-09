# frozen_string_literal: true

class Crm::OrderLine < ApplicationRecord
  self.table_name = "crm_order_lines"

  attribute :created_time, :string
  attribute :updated_time, :string

  belongs_to :order, class_name: "Crm::Order", foreign_key: "order_id", optional: true
  belongs_to :product, class_name: "Mat::Product", foreign_key: "product_id", optional: true
  belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true

  has_one_attached :file

  has_many :logs, class_name: "Log", as: :record
  has_many :activities, class_name: "Activity", as: :record

  def base_info
    {
      id: id,
      order_id: order_id,
      order: order.base_info,
      order_code: (order.code rescue ""),
      product_id: product_id,
      product_name: product_name.presence || (product.name rescue ""),
      model: model,
      color: color,
      weight: weight,
      qty: qty,
      unit: unit,
      stock_status: stock_status,
      color_master_status: color_master_status,
      remark: remark,
      sort: sort,
      user_id: user_id,
      user_name: (user.name rescue ""),
      file_url: line_file_url,
      product_image_url: product_image_url_for_list,
      unit_price: unit_price,
      line_amount: line_amount,
      ship_doc_unreturned: ship_doc_unreturned,
      ship_doc_returned: ship_doc_returned,
      delivery_qty: delivery_qty,
      loss_qty: loss_qty,
      line_delivery_date: line_delivery_date,
      production_machine: production_machine,
      injection_prod_code: injection_prod_code,
      injection_prod_date: injection_prod_date,
      gasket_machine: gasket_machine,
      gasket_prod_code: gasket_prod_code,
      gasket_prod_date: gasket_prod_date,
      closing_date: closing_date,
      semi_inventory: semi_inventory,
      semi_completed: semi_completed,
      semi_reserve: semi_reserve,
      original_inventory: original_inventory,
      outsourcing_qty: outsourcing_qty,
      unfinished_qty: unfinished_qty,
      finished_total: finished_total,
      created_at: created_at,
      updated_at: updated_at,
      created_time: created_time,
      updated_time: updated_time
    }
  end

  # 内跟单列表：订单头 + 明细行
  def internal_tracking_row
    o = order
    base_info.merge(
      receive_date: o&.receive_date&.strftime("%Y-%m-%d"),
      client_name: (o&.client&.name rescue ""),
      contract_code: o&.contract_code,
      order_status_name: (o&.status_property&.name rescue ""),
      order_status_color: (o&.status_property&.color rescue ""),
      customer_delivery_date: o&.customer_delivery_date&.strftime("%Y-%m-%d")
    )
  end

  def line_file_url
    return nil unless file.attached?

    Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true)
  rescue StandardError
    nil
  end

  def product_image_url_for_list
    return line_file_url if file.attached?

    u = product&.image_url
    return u if u.present?
    return nil unless product&.logo.present?

    product.logo
  rescue StandardError
    nil
  end
end
