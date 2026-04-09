# frozen_string_literal: true

# 单号生成服务：根据 DocNumberRule 配置生成下一个单号
# 支持占位符：固定值、日期({YYYY}{YY}{MM}{DD}{YYYYMMDD}{YYMMDD}{YYYYMM}{YYMM})、序列号({seq} 或 {seq:N})
class DocNumberService
  class ConfigurationNotFound < StandardError; end

  # 根据 key 生成默认规则（规则不存在时自动创建）
  def self.find_or_create_default_rule(key)
    prefix = key.to_s.split("_").first.to_s.upcase.presence || "DOC"
    prefix = "PUR" if key.to_s.start_with?("pur_")
    prefix = "FM" if key.to_s.start_with?("fm_")
    prefix = "CRM" if key.to_s.start_with?("crm_")
    prefix = "RMS" if key.to_s.start_with?("rms_")
    prefix = "IQC" if key.to_s.start_with?("iqc_")
    prefix = "MAT" if key.to_s.start_with?("mat_")

    DocNumberRule.find_or_create_by!(key: key) do |r|
      r.name = "单号规则 #{key}"
      r.format = "#{prefix}-{YYMMDD}-{seq:4}"
      r.current_sequence = 0
      r.reset_period = "day"
    end
  end

  DATE_PLACEHOLDERS = {
    "YYYY" => -> { Date.current.year.to_s },
    "YY" => -> { Date.current.year.to_s[-2..] },
    "MM" => -> { Date.current.month.to_s.rjust(2, "0") },
    "DD" => -> { Date.current.day.to_s.rjust(2, "0") },
    "YYYYMMDD" => -> { Date.current.strftime("%Y%m%d") },
    "YYMMDD" => -> { Date.current.strftime("%y%m%d") },
    "YYYYMM" => -> { Date.current.strftime("%Y%m") },
    "YYMM" => -> { Date.current.strftime("%y%m") },
  }.freeze

  # @param key [String] 规则 key，如 "fm_contracts"
  # @return [String] 生成的单号
  def self.next_number(key)
    new.next_number(key)
  end

  def next_number(key)
    rule = DocNumberRule.find_by(key: key) || DocNumberService.find_or_create_default_rule(key)

    DocNumberRule.transaction do
      rule.lock!
      apply_reset_if_needed(rule)
      seq = (rule.current_sequence || 0) + 1
      number = build_number(rule.format, seq)
      rule.update!(
        current_sequence: seq,
        last_date: Date.current
      )
      number
    end
  end

  # 预览下一个单号（不占用序列号）；规则不存在时自动创建默认规则
  def self.preview(key)
    rule = DocNumberRule.find_by(key: key) || find_or_create_default_rule(key)

    seq = next_sequence_without_saving(rule)
    new.send(:build_number, rule.format, seq)
  end

  def self.next_sequence_without_saving(rule)
    today = Date.current
    last = rule.last_date
    period = (rule.reset_period || "none").to_s.downcase
    need_reset = case period
                 when "day" then last != today
                 when "month" then last.nil? || last.year != today.year || last.month != today.month
                 when "year" then last.nil? || last.year != today.year
                 else false
                 end
    need_reset ? 1 : (rule.current_sequence || 0) + 1
  end

  private

  def apply_reset_if_needed(rule)
    today = Date.current
    last = rule.last_date
    period = (rule.reset_period || "none").to_s.downcase
    case period
    when "day"
      rule.update_column(:current_sequence, 0) if last != today
    when "month"
      rule.update_column(:current_sequence, 0) if last.nil? || last.year != today.year || last.month != today.month
    when "year"
      rule.update_column(:current_sequence, 0) if last.nil? || last.year != today.year
    end
  end

  def build_number(format_str, sequence)
    s = format_str.dup
    # 日期占位符（长串优先，避免 YYYY 被 YYYYMMDD 的子串误替换）
    DATE_PLACEHOLDERS.keys.sort_by { |k| -k.length }.each do |placeholder|
      s.gsub!("{#{placeholder}}", DATE_PLACEHOLDERS[placeholder].call)
    end
    # 序列号 {seq} 或 {seq:N}
    s.gsub!(/\{seq:(\d+)\}/) { sequence.to_s.rjust(Regexp.last_match(1).to_i, "0") }
    s.gsub!("{seq}", sequence.to_s)
    s
  end
end
