# frozen_string_literal: true

class Wgd::Order < ApplicationRecord
  self.table_name = "wgd_orders"

  attribute :created_time, :string
  attribute :updated_time, :string

  belongs_to :client, class_name: "Crm::Client", foreign_key: "client_id", optional: true
  belongs_to :follower, class_name: "User", foreign_key: "follower_id", optional: true
  belongs_to :status_property, class_name: "Property", foreign_key: "status_id", optional: true
  belongs_to :user, class_name: "User", foreign_key: "user_id", optional: true
  belongs_to :updater, class_name: "User", foreign_key: "updater_id", optional: true

  has_many :order_lines,
           class_name: "Wgd::OrderLine",
           foreign_key: "order_id",
           dependent: :destroy

  has_many :logs, class_name: "Log", as: :record
  has_many :activities, class_name: "Activity", as: :record

  validates :code, length: { maximum: 40 }, allow_blank: true

  def name
    code
  end

  def base_info
    {
      id: id,
      code: code,
      receive_date: receive_date,
      client_id: client_id,
      client_name: client_name.presence || (client.name rescue ""),
      contract_code: contract_code,
      hazard_pack_month: hazard_pack_month,
      customer_delivery_date_text: customer_delivery_date_text,
      follow_at: follow_at,
      follow_progress: follow_progress,
      follower_id: follower_id,
      follower_name: follower_name.presence || (follower.name rescue ""),
      invoice_status: invoice_status,
      invoice_at: invoice_at,
      amount: amount,
      status_id: status_id,
      status_name: (status_property.name rescue ""),
      status_color: (status_property.color rescue ""),
      remark: remark,
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
