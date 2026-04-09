class RemoveAllForeignKeys < ActiveRecord::Migration[8.0]
  def up
    connection = ActiveRecord::Base.connection
    connection.tables.each do |table_name|
      connection.foreign_keys(table_name).each do |fk|
        remove_foreign_key table_name, name: fk.name
      end
    end
  end

  def down
    add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
    add_foreign_key "cities", "provinces"
    add_foreign_key "counties", "cities"
    add_foreign_key "crm_addresses", "crm_clients", column: "client_id"
    add_foreign_key "crm_contacts", "crm_clients", column: "client_id"
    add_foreign_key "crm_contracts", "crm_clients", column: "client_id"
    add_foreign_key "crm_contracts", "pur_suppliers", column: "supplier_id"
    add_foreign_key "crm_handover_lines", "crm_handovers", column: "handover_id"
    add_foreign_key "crm_handover_lines", "crm_spec_items", column: "spec_item_id"
    add_foreign_key "crm_quotation_lines", "crm_quotations", column: "quotation_id"
    add_foreign_key "crm_quotations", "crm_clients", column: "client_id"
    add_foreign_key "iqc_fdf_lines", "iqc_fdfs", column: "fdf_id"
    add_foreign_key "iqc_ldf_lines", "iqc_ldfs", column: "ldf_id"
    add_foreign_key "iqc_raw_lines", "iqc_raws", column: "raw_id"
    add_foreign_key "mfg_batching_lines", "mfg_batchings", column: "batching_id"
    add_foreign_key "mfg_oprate_lines", "mfg_oprates", column: "operate_id"
    add_foreign_key "mfg_oprate_step_lines", "mfg_oprates", column: "operate_id"
    add_foreign_key "mfg_plan_lines", "mfg_plans", column: "plan_id"
    add_foreign_key "pur_collections", "pur_contracts", column: "purchase_contract_id"
    add_foreign_key "pur_contacts", "pur_suppliers", column: "supplier_id"
    add_foreign_key "rms_handover_contracts", "crm_contracts", column: "contract_id"
    add_foreign_key "rms_handover_contracts", "rms_handovers", column: "recipe_handover_id"
    add_foreign_key "rms_handover_lines", "rms_handovers", column: "handover_id"
    add_foreign_key "rms_handovers", "crm_contracts", column: "handover_order_id"
    add_foreign_key "tms_order_lines", "tms_orders", column: "shipping_order_id"
    add_foreign_key "wms_notice_lines", "wms_notices", column: "notice_id"
  end
end
