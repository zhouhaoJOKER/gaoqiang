# frozen_string_literal: true

# Usage:
#   cd admin_api
#   rails runner db/seeds/wgd_test_data.rb

now = Time.current

orders = [
  {
    code: "WGD-DEMO-20260510-001",
    receive_date: Date.new(2026, 5, 10),
    client_name: "001金陵",
    contract_code: "0510上海新易CIE20260510001（谭）",
    hazard_pack_month: "已办26.05",
    customer_delivery_date_text: "5月底前送到",
    follower_name: "Z",
    invoice_status: "未开票",
    amount: 13_650,
    remark: "外跟单演示订单-阻隔瓶",
    line_items: [
      {
        product_name: "1L 阻隔瓶",
        model: "1L-013",
        foil_pad_status: "",
        color: "白",
        requirements: "白瓶绿盖，瓶套收缩膜，瓶盖喷码，纸箱套防尘袋",
        weight: "120G",
        color_master_status: "",
        product_image_text: "参考客户样图",
        qty: 10_000,
        unit: "只",
        unit_price: 1.2,
        line_amount: 12_000,
        delivered_qty: 2_000,
        undelivered_qty: 8_000,
        sort: 1,
        remark: "主容器"
      },
      {
        product_name: "小喇叭盖",
        model: "阻隔铝箔垫37.2",
        foil_pad_status: "已订",
        color: "40657绿",
        requirements: "盖子颜色与瓶身要求一致",
        weight: "14G",
        color_master_status: "有结存",
        qty: 10_000,
        unit: "只",
        unit_price: 0.15,
        line_amount: 1_500,
        delivered_qty: 2_010,
        undelivered_qty: 7_990,
        sort: 2,
        remark: "配套瓶盖"
      },
      {
        product_name: "40ML量杯",
        model: "",
        foil_pad_status: "",
        color: "透明",
        requirements: "配套量杯",
        weight: "",
        color_master_status: "",
        qty: 10_000,
        unit: "只",
        unit_price: 0.015,
        line_amount: 150,
        delivered_qty: 2_000,
        undelivered_qty: 8_000,
        sort: 3,
        remark: "配套量杯"
      }
    ]
  },
  {
    code: "WGD-DEMO-20260510-002",
    receive_date: Date.new(2026, 5, 11),
    client_name: "浙江新安进出口有限公司",
    contract_code: "0511新安Q/B WIE-HT PW-10953-2026（张）",
    hazard_pack_month: "不办",
    customer_delivery_date_text: "按客户通知分批送",
    follower_name: "张",
    invoice_status: "已开电子发票",
    invoice_at: Time.zone.local(2026, 5, 20, 10, 30),
    amount: 3_800,
    remark: "外跟单演示订单-PE桶",
    line_items: [
      {
        product_name: "20L PE桶",
        model: "20L-304",
        color: "白",
        requirements: "白桶白盖，带防盗圈，不带UN",
        weight: "1600G",
        color_master_status: "",
        qty: 500,
        unit: "只",
        unit_price: 7.2,
        line_amount: 3_600,
        delivered_qty: 500,
        undelivered_qty: 0,
        sort: 1,
        remark: "已送完"
      },
      {
        product_name: "大桶盖",
        model: "",
        color: "白",
        requirements: "配套大桶盖",
        weight: "25G",
        color_master_status: "",
        qty: 500,
        unit: "只",
        unit_price: 0.4,
        line_amount: 200,
        delivered_qty: 505,
        undelivered_qty: -5,
        sort: 2,
        remark: "多发5只"
      }
    ]
  },
  {
    code: "WGD-DEMO-20260510-003",
    receive_date: Date.new(2026, 5, 12),
    client_name: "江苏赛诺科生物科技",
    contract_code: "0512江苏赛诺科SC20260512-01（於）",
    hazard_pack_month: "已办26.06",
    customer_delivery_date_text: "6月10日前备货",
    follower_name: "於",
    invoice_status: "未开票",
    amount: 6_900,
    remark: "外跟单演示订单-PET瓶",
    line_items: [
      {
        product_name: "500ML PET瓶",
        model: "500ML-101",
        foil_pad_status: "",
        color: "透明",
        requirements: "透明瓶白盖，标签按客户新版",
        weight: "44G",
        color_master_status: "",
        product_image_text: "新版标签",
        qty: 8_000,
        unit: "只",
        unit_price: 0.75,
        line_amount: 6_000,
        delivered_qty: 0,
        undelivered_qty: 8_000,
        sort: 1,
        remark: "新订单"
      },
      {
        product_name: "45口径PET盖",
        model: "PET铝箔垫43.5",
        foil_pad_status: "有结存",
        color: "白",
        requirements: "配套PET瓶",
        weight: "9G",
        color_master_status: "",
        qty: 8_000,
        unit: "只",
        unit_price: 0.1125,
        line_amount: 900,
        delivered_qty: 0,
        undelivered_qty: 8_000,
        sort: 2,
        remark: "新订单"
      }
    ]
  }
]

created_orders = 0
created_lines = 0

Wgd::Order.transaction do
  orders.each do |attrs|
    line_items = attrs.delete(:line_items)
    order = Wgd::Order.find_or_initialize_by(code: attrs[:code])
    order.assign_attributes(attrs.merge(updated_at: now))
    order.created_at ||= now
    order.save!

    order.order_lines.destroy_all
    line_items.each do |line_attrs|
      order.order_lines.create!(line_attrs)
      created_lines += 1
    end

    created_orders += 1
  end
end

puts "外跟单测试数据已生成：#{created_orders} 个订单，#{created_lines} 条明细。"
