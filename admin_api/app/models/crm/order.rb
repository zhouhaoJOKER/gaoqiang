# frozen_string_literal: true

class Crm::Order < ApplicationRecord
  include DocNumberable

  self.table_name = "crm_orders"
  self.doc_number_key = "crm_orders"

  attribute :created_time, :string
  attribute :updated_time, :string

  has_one_attached :file
  belongs_to :pre_order, class_name: "Mat::PreOrder", foreign_key: "pre_order_id", optional: true
  belongs_to :client, class_name: "Crm::Client", foreign_key: "client_id", optional: true
  belongs_to :status_property, class_name: "Property", foreign_key: "status_id", optional: true
  belongs_to :follower, class_name: "User", foreign_key: "follower_id", optional: true
  belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
  belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true

  has_many :order_lines,
           class_name: "Crm::OrderLine",
           foreign_key: "order_id",
           dependent: :destroy

  has_many :logs, class_name: "Log", as: :record
  has_many :activities, class_name: "Activity", as: :record

  validates :code, length: { in: 2..40 }, presence: true

  before_validation :ensure_code
  before_save :gen_py

  # 供缓存等通用逻辑使用；非数据库字段，无 name_changed?，不可走 ApplicationRecord#gen_py 的默认实现
  def name
    code
  end

  def gen_py
    return unless self.class.column_names.include?("py")
    return unless new_record? || will_save_change_to_attribute?(:code)

    self.py = Pinyin.t(code.to_s) { |letters| letters[0] } if code.present?
  end

  def ensure_code
    return if code.present?

    key = self.class.doc_number_key
    self.code = if DocNumberRule.exists?(key: key)
                  DocNumberService.next_number(key)
                else
                  DocNumberService.next_number(self.class.table_name)
                end
  end

  def client_logo_url
    c = client
    return nil unless c&.file&.attached?

    Rails.application.routes.url_helpers.rails_blob_path(c.file, only_path: true)
  rescue StandardError
    nil
  end

  def order_file_url
    return nil unless file.attached?

    Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true)
  rescue StandardError
    nil
  end

  def base_info
    {
      id: id,
      code: code,
      pre_order_id: pre_order_id,
      client_id: client_id,
      client_name: (client.name rescue ""),
      client_logo_url: client_logo_url,
      file_url: order_file_url,
      hazard_pack_month: hazard_pack_month,
      receive_date: receive_date,
      contract_code: contract_code,
      customer_delivery_date: customer_delivery_date,
      follower_id: follower_id,
      follower_name: (follower.name rescue ""),
      follow_at: follow_at,
      follow_progress: follow_progress,
      amount: amount,
      spec_requirements: spec_requirements,
      status_id: status_id,
      status_name: (status_property.name rescue ""),
      status_color: (status_property.color rescue ""),
      delivered_qty: delivered_qty,
      invoice_amount: invoice_amount,
      invoice_at: invoice_at,
      payment_amount: payment_amount,
      payment_at: payment_at,
      user_id: user_id,
      user_name: (user.name rescue ""),
      updater_id: updater_id,
      updater_name: (updater.name rescue ""),
      line_count: (order_lines.size rescue 0),
      created_at: created_at,
      updated_at: updated_at,
      created_time: created_time,
      updated_time: updated_time
    }
  end
end
