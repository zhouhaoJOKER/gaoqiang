# frozen_string_literal: true

# 流程模板初始化数据（基于 workflow_data_example.json）
# 执行: rails db:seed 或 rails runner db/seeds/workflow.rb

def seed_workflow
  template = Workflow::Template.find_or_initialize_by(code: "contract_full")
  template.assign_attributes(
    name: "订购合同全流程",
    description: "合同从订单到发货的完整流程",
    main_step_keys: %w[order formula purchase warehouse inspect plan schedule formulate test_qc pack_setup first_bottle packing sampling ship],
    is_default: true,
    sort: 0,
    is_active: true
  )
  template.save!

  nodes_data = [
    { key: "order", label: "订单", position_x: 140, position_y: 0, sort: 0 },
    { key: "cancel", label: "取消订单", position_x: 380, position_y: 0, sort: 1 },
    { key: "formula", label: "配方确认", position_x: 140, position_y: 70, sort: 2, has_result_options: true },
    { key: "rd", label: "研发试验", position_x: 20, position_y: 150, sort: 3 },
    { key: "test_rd", label: "检测", position_x: 20, position_y: 230, sort: 4 },
    { key: "purchase", label: "采购", position_x: 260, position_y: 150, sort: 5 },
    { key: "pack_m", label: "包材、硬头、标签", position_x: 80, position_y: 230, sort: 6 },
    { key: "raw_m", label: "原药、助剂", position_x: 280, position_y: 230, sort: 7 },
    { key: "warehouse", label: "仓库收货", position_x: 180, position_y: 310, sort: 8 },
    { key: "inspect", label: "验收", position_x: 180, position_y: 390, sort: 9, has_result_options: true },
    { key: "return_s", label: "退回供应商", position_x: 0, position_y: 470, sort: 10 },
    { key: "downgrade", label: "降级使用", position_x: 120, position_y: 470, sort: 11 },
    { key: "plan", label: "生产计划", position_x: 300, position_y: 470, sort: 12 },
    { key: "schedule", label: "排单", position_x: 180, position_y: 550, sort: 13 },
    { key: "formulate", label: "配制", position_x: 180, position_y: 630, sort: 14 },
    { key: "test_qc", label: "检测", position_x: 180, position_y: 710, sort: 15, has_result_options: true },
    { key: "pack_setup", label: "包装调机", position_x: 180, position_y: 790, sort: 16 },
    { key: "first_bottle", label: "首瓶确认", position_x: 180, position_y: 870, sort: 17, has_result_options: true },
    { key: "packing", label: "包装", position_x: 180, position_y: 950, sort: 18 },
    { key: "sampling", label: "抽检", position_x: 180, position_y: 1030, sort: 19, has_result_options: true },
    { key: "biz_confirm", label: "业务确认", position_x: 180, position_y: 1110, sort: 20, has_result_options: true },
    { key: "concession", label: "让步接收", position_x: 180, position_y: 1190, sort: 21 },
    { key: "ship", label: "发货", position_x: 180, position_y: 1270, sort: 22 }
  ]

  nodes_data.each do |attrs|
    Workflow::Node.find_or_initialize_by(template_id: template.id, key: attrs[:key]).tap do |n|
      n.assign_attributes(attrs.except(:key).merge(template_id: template.id))
      n.save!
    end
  end

  edges_data = [
    { source_key: "order", target_key: "formula" },
    { source_key: "order", target_key: "cancel" },
    { source_key: "formula", target_key: "rd", label: "无现成配方", result_value: "new" },
    { source_key: "formula", target_key: "purchase", label: "配方成熟", result_value: "existing" },
    { source_key: "rd", target_key: "test_rd" },
    { source_key: "test_rd", target_key: "rd", label: "不通过", result_value: "rework" },
    { source_key: "test_rd", target_key: "formula", label: "配方不成功", result_value: "fail" },
    { source_key: "purchase", target_key: "pack_m" },
    { source_key: "purchase", target_key: "raw_m" },
    { source_key: "pack_m", target_key: "warehouse" },
    { source_key: "raw_m", target_key: "warehouse" },
    { source_key: "warehouse", target_key: "inspect" },
    { source_key: "inspect", target_key: "return_s", label: "不合格", result_value: "reject" },
    { source_key: "inspect", target_key: "downgrade", label: "降级使用", result_value: "downgrade" },
    { source_key: "inspect", target_key: "plan", label: "合格", result_value: "pass" },
    { source_key: "plan", target_key: "schedule" },
    { source_key: "concession", target_key: "plan", label: "反馈" },
    { source_key: "schedule", target_key: "formulate" },
    { source_key: "formulate", target_key: "test_qc" },
    { source_key: "test_qc", target_key: "formulate", label: "不合格", result_value: "rework" },
    { source_key: "test_qc", target_key: "pack_setup", label: "合格", result_value: "pass" },
    { source_key: "pack_setup", target_key: "first_bottle" },
    { source_key: "first_bottle", target_key: "pack_setup", label: "不通过", result_value: "redo" },
    { source_key: "first_bottle", target_key: "packing", label: "通过", result_value: "pass" },
    { source_key: "first_bottle", target_key: "formulate", label: "返工", result_value: "rework" },
    { source_key: "packing", target_key: "sampling" },
    { source_key: "sampling", target_key: "biz_confirm", label: "不合格", result_value: "fail" },
    { source_key: "sampling", target_key: "ship", label: "合格", result_value: "pass" },
    { source_key: "biz_confirm", target_key: "concession" },
    { source_key: "biz_confirm", target_key: "ship" },
    { source_key: "concession", target_key: "ship" }
  ]

  edges_data.each_with_index do |attrs, idx|
    Workflow::Edge.find_or_initialize_by(
      template_id: template.id,
      source_key: attrs[:source_key],
      target_key: attrs[:target_key]
    ).tap do |e|
      e.assign_attributes(
        template_id: template.id,
        label: attrs[:label],
        result_value: attrs[:result_value],
        sort: idx
      )
      e.save!
    end
  end

  node_results_data = [
    { node_key: "formula", result_value: "existing", result_label: "现成配方", target_key: "purchase" },
    { node_key: "formula", result_value: "new", result_label: "需研发试验", target_key: "rd" },
    { node_key: "inspect", result_value: "pass", result_label: "合格", target_key: "plan" },
    { node_key: "inspect", result_value: "downgrade", result_label: "降级使用", target_key: "downgrade" },
    { node_key: "inspect", result_value: "reject", result_label: "不合格退回", target_key: "return_s" },
    { node_key: "test_qc", result_value: "pass", result_label: "合格", target_key: "pack_setup" },
    { node_key: "test_qc", result_value: "rework", result_label: "不合格返工", target_key: "formulate" },
    { node_key: "first_bottle", result_value: "pass", result_label: "通过", target_key: "packing" },
    { node_key: "first_bottle", result_value: "redo", result_label: "不通过重调", target_key: "pack_setup" },
    { node_key: "sampling", result_value: "pass", result_label: "合格", target_key: "ship" },
    { node_key: "sampling", result_value: "fail", result_label: "不合格", target_key: "biz_confirm" },
    { node_key: "biz_confirm", result_value: "concession", result_label: "让步接收", target_key: "concession" },
    { node_key: "biz_confirm", result_value: "ship", result_label: "直接发货", target_key: "ship" }
  ]

  node_results_data.each_with_index do |attrs, idx|
    Workflow::NodeResult.find_or_initialize_by(
      template_id: template.id,
      node_key: attrs[:node_key],
      result_value: attrs[:result_value]
    ).tap do |r|
      r.assign_attributes(
        template_id: template.id,
        result_label: attrs[:result_label],
        target_key: attrs[:target_key],
        sort: idx
      )
      r.save!
    end
  end

  puts "Workflow template '#{template.name}' (code: #{template.code}) seeded successfully."
  puts "  - Nodes: #{template.nodes.count}"
  puts "  - Edges: #{template.edges.count}"
  puts "  - Node results: #{template.node_results.count}"
end

seed_workflow
