# frozen_string_literal: true

class RemoveUpdaterIdAndPyFromLinesTables < ActiveRecord::Migration[8.0]
  LINES_TABLES_WITH_BOTH = %w[
    iqc_ldf_lines
    iqc_fdf_lines
    mfg_oprate_step_lines
    crm_handover_lines
    rms_handover_lines
    wms_notice_lines
    mfg_pkg_lines
    mfg_oprate_lines
    tms_order_lines
  ].freeze

  LINES_TABLES_UPDATER_ID_ONLY = %w[
    crm_quotation_lines
    mfg_batching_lines
  ].freeze

  def up
    LINES_TABLES_WITH_BOTH.each do |table|
      remove_column table, :updater_id, :integer if column_exists?(table, :updater_id)
      remove_column table, :py, :string if column_exists?(table, :py)
    end
    LINES_TABLES_UPDATER_ID_ONLY.each do |table|
      remove_column table, :updater_id, :integer if column_exists?(table, :updater_id)
    end
  end

  def down
    LINES_TABLES_WITH_BOTH.each do |table|
      add_column table, :updater_id, :integer unless column_exists?(table, :updater_id)
      add_column table, :py, :string unless column_exists?(table, :py)
    end
    LINES_TABLES_UPDATER_ID_ONLY.each do |table|
      add_column table, :updater_id, :integer unless column_exists?(table, :updater_id)
    end
  end
end
