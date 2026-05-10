# frozen_string_literal: true

class Wgd::OrderLine < ApplicationRecord
  self.table_name = "wgd_order_lines"

  attribute :created_time, :string
  attribute :updated_time, :string

  belongs_to :order, class_name: "Wgd::Order", foreign_key: "order_id"

  has_many :logs, class_name: "Log", as: :record
  has_many :activities, class_name: "Activity", as: :record

  def base_info
    {
      id: id,
      order_id: order_id,
      order_code: (order.code rescue ""),
      product_name: product_name,
      model: model,
      foil_pad_status: foil_pad_status,
      color: color,
      requirements: requirements,
      weight: weight,
      color_master_status: color_master_status,
      product_image_text: product_image_text,
      qty: qty,
      unit: unit,
      unit_price: unit_price,
      line_amount: line_amount,
      delivered_qty: delivered_qty,
      undelivered_qty: undelivered_qty,
      sort: sort,
      remark: remark,
      created_at: created_at,
      updated_at: updated_at,
      created_time: created_time,
      updated_time: updated_time
    }
  end
end
