# frozen_string_literal: true

class NormalizeAllDecimalColumns < ActiveRecord::Migration[8.0]
  DECIMAL_OPTIONS = { precision: 12, scale: 2, default: "0.0" }.freeze

  def up
    each_decimal_column do |table, column|
      change_column table, column, :decimal, **DECIMAL_OPTIONS
    end
  end

  def down
    # 无法精确回滚，保留空实现
    raise ActiveRecord::IrreversibleMigration
  end

  private

  def each_decimal_column
    connection.tables.each do |table|
      next if %w[schema_migrations ar_internal_metadata].include?(table)

      connection.columns(table).each do |col|
        yield table, col.name if col.type == :decimal
      end
    end
  end
end
