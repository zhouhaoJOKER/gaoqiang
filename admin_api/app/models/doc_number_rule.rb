# frozen_string_literal: true

# 单号规则配置：支持固定值、日期、序列号组合
# 格式示例: "FM-{YYMMDD}-{seq:4}" => FM-260313-0001
class DocNumberRule < ApplicationRecord
  RESET_PERIODS = %w[none day month year].freeze

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
  validates :format, presence: true
  validates :reset_period, inclusion: { in: RESET_PERIODS }
  validates :current_sequence, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  attribute :created_time, :string
  attribute :updated_time, :string

  def base_info
    {
      id: id,
      key: key,
      name: name,
      format: format,
      current_sequence: current_sequence,
      reset_period: reset_period,
      last_date: last_date,
      created_at: created_at,
      updated_at: updated_at,
      created_time: created_time,
      updated_time: updated_time,
    }
  end

  def show_info
    { id: id, name: name, key: key }
  end

  def self.imp_exp_hander
    %w[key name format current_sequence reset_period last_date created_at updated_at]
  end
end
