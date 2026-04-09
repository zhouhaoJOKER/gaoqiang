# frozen_string_literal: true

# 单号自动生成 Concern：模型 include 后，创建时若 code 为空则按配置规则自动生成
# 使用方式：include DocNumberable 并设置 doc_number_key（如 "fm_contracts"）
module DocNumberable
  extend ActiveSupport::Concern

  included do
    before_create :generate_doc_number, if: :should_generate_doc_number?

    # 使用 DocNumberable 时跳过 ApplicationRecord 的默认 generate_code
    def skip_generate_code?
      false
    end
  end

  class_methods do
    # 子类可覆盖，指定单号规则 key
    def doc_number_key
      @doc_number_key || default_doc_number_key
    end

    attr_writer :doc_number_key

    def default_doc_number_key
      # 默认根据表名推断，如 fm_contracts
      table_name
    end
  end

  # 生成下一个单号（供外部调用，如接口、表单预填）
  def self.next_code(key)
    DocNumberService.next_number(key)
  end

  # 预览下一个单号（不占用序列）
  def self.preview_code(key)
    DocNumberService.preview(key)
  end

  private

  def should_generate_doc_number?
    return false unless self.class.column_names.include?("code")
    return false if code.present?
    DocNumberRule.exists?(key: doc_number_key_for_record)
  end

  def doc_number_key_for_record
    self.class.doc_number_key
  end

  def generate_doc_number
    self.code = DocNumberService.next_number(doc_number_key_for_record)
  end
end
