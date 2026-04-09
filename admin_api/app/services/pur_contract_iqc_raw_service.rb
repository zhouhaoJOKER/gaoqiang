# frozen_string_literal: true

# 根据原料采购合同（Pur::Contract）及其明细（collections）生成 Iqc::Raw 原料待检验记录
# 仅当合同为「原料采购」类型（sign = raw_material）时才创建；可单独调用，后续可配合状态判断再调用
class PurContractIqcRawService
  # 原料采购合同的 sign 取值
  RAW_MATERIAL_SIGN = "raw_material"

  class << self
    # 为采购合同生成原料待检验记录（每条明细一条 Raw）。仅原料采购合同会创建记录。
    # @param pur_contract [Pur::Contract]
    # @param options [Hash] force: 若为 true 则不跳过已存在记录，为对应 collection 再创建（默认 false 则已存在的不重复创建）
    # @return [Array<Iqc::Raw>] 本次创建的记录
    def generate_raws_for_contract(pur_contract, force: false)
      return [] unless pur_contract.is_a?(Pur::Contract)
      return [] unless raw_material_contract?(pur_contract)

      collections = pur_contract.collections.reload
      return [] if collections.empty?

      created = []
      collections.each do |collection|
        next if !force && already_has_raw?(pur_contract.id, collection.id)

        raw = build_raw_from_collection(pur_contract, collection)
        if raw.save
          created << raw
        end
      end
      created
    end

    private

    def raw_material_contract?(pur_contract)
      pur_contract.respond_to?(:sign) && pur_contract.sign.to_s == RAW_MATERIAL_SIGN
    end

    def already_has_raw?(pur_contract_id, pur_collection_id)
      return false if pur_collection_id.blank?
      Iqc::Raw.exists?(pur_contract_id: pur_contract_id, pur_collection_id: pur_collection_id)
    end

    def build_raw_from_collection(pur_contract, collection)
      product = collection.product
      name = (collection.product_name.presence || product&.name || "原料#{collection.product_id}").to_s.strip
      name = "原料-#{collection.product_id}" if name.blank?

      inspection_basis = pur_contract.inspection_method.presence || pur_contract.quality_standard.to_s.truncate(500)
      notes_parts = [pur_contract.remark, collection.remark]
      notes_parts << "采购合同: #{pur_contract.contract_title}" if pur_contract.contract_title.present?
      notes_parts << "合同编号: #{pur_contract.code}" if pur_contract.code.present?
      notes = notes_parts.compact.join("；").presence

      Iqc::Raw.new(
        contract_id: pur_contract.contract_id,
        pur_contract_id: pur_contract.id,
        pur_collection_id: collection.id,
        product_id: collection.product_id,
        name: name,
        code: DocNumberService.next_number("iqc_raws"),
        supplier_id: pur_contract.supplier_id,
        supplier_name: pur_contract.supplier_name.presence || pur_contract.supplier&.name&.to_s,
        inspection_qty: collection.qty.to_s.presence,
        request_inspection_date: pur_contract.receive_date.presence || Date.current,
        inspection_basis: inspection_basis,
        notes: notes,
        user_id: pur_contract.user_id.presence || collection.user_id
      )
    end
  end
end
