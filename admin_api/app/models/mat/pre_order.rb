# frozen_string_literal: true

class Mat::PreOrder < ApplicationRecord
  self.table_name = "mat_pre_orders"

  STATUS_PENDING = "pending"
  STATUS_PROCESSING = "processing"
  STATUS_CONVERTED = "converted"
  STATUS_CLOSED = "closed"

  belongs_to :crm_order, class_name: "Crm::Order", foreign_key: "crm_order_id", optional: true
  belongs_to :processor, class_name: "User", foreign_key: "processor_id", optional: true

  validates :customer_name, presence: true
  validates :line_items, presence: true
  validate :line_items_must_be_array

  before_validation :set_default_status

  def base_info
    {
      id: id,
      customer_name: customer_name,
      customer_code: customer_code,
      spec_requirements: spec_requirements,
      line_items: line_items,
      status: status,
      crm_order_id: crm_order_id,
      crm_order_code: (crm_order.code rescue ""),
      processor_id: processor_id,
      processor_name: (processor.name rescue ""),
      processed_at: processed_at,
      request_ip: request_ip,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  private

  def set_default_status
    self.status = STATUS_PENDING if status.blank?
  end

  def line_items_must_be_array
    return if line_items.is_a?(Array) && line_items.any?

    errors.add(:line_items, "不能为空")
  end
end
