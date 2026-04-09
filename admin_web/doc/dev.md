### 基础模块 base

**省（provinces）**

| 字段 | 类型    | 说明               |
| ---- | ------- | ------------------ |
| code | integer | 行政区划码（唯一） |
| name | string  | 省名称             |
| py   | string  | 拼音/检索          |

**市（cities）**

| 字段        | 类型       | 说明                 |
| ----------- | ---------- | -------------------- |
| province_id | references | 省（关联 provinces） |
| code        | integer    | 行政区划码（唯一）   |
| name        | string     | 市名称               |
| py          | string     | 拼音/检索            |

**县/区（counties）**

| 字段    | 类型       | 说明               |
| ------- | ---------- | ------------------ |
| city_id | references | 市（关联 cities）  |
| code    | integer    | 行政区划码（唯一） |
| name    | string     | 县/区名称          |
| py      | string     | 拼音/检索          |

**属性（properties）**

| 字段       | 类型     | 说明                |
| ---------- | -------- | ------------------- |
| sign       | string   | 标识/编码（有索引） |
| parent_id  | integer  | 父级属性 ID         |
| name       | string   | 属性名称            |
| py         | string   | 拼音/检索           |
| sort       | integer  | 排序                |
| color      | string   | 颜色                |
| is_open    | boolean  | 是否启用            |
| abbr       | string   | 缩写                |
| user_id    | integer  | 创建人              |
| created_at | datetime | 创建时间            |
| updated_at | datetime | 更新时间            |

### CRM 模块补充表单字段（客户、客户联系人、客户收货地址）

**客户（crm_clients）**

| 字段            | 类型    | 说明                                              |
| --------------- | ------- | ------------------------------------------------- |
| parent_id       | integer | 父级客户（关联 crm_clients）                      |
| code            | string  | 客户编号                                          |
| name            | string  | 客户名称                                          |
| abbr            | string  | 简称                                              |
| settlement_id   | integer | 结算方式（关联 properties）                       |
| payment_terms   | string  | 付款条款                                          |
| invoice_type_id | integer | 默认发票类型（专票/普票/数电票，关联 properties） |
| remark          | text    | 备注                                              |
| user_id         | integer | 创建人                                            |
| updater_id      | integer | 更新人                                            |
| py              | string  | 拼音/检索                                         |

**客户联系人（crm_contacts）**

| 字段       | 类型       | 说明                     |
| ---------- | ---------- | ------------------------ |
| client_id  | references | 客户（关联 crm_clients） |
| name       | string     | 联系人姓名               |
| dept       | string     | 部门                     |
| title      | string     | 职务                     |
| phone      | string     | 电话                     |
| mobile     | string     | 手机                     |
| email      | string     | 邮箱                     |
| is_primary | boolean    | 是否主联系人             |
| remark     | string     | 备注                     |
| user_id    | integer    | 创建人                   |
| updater_id | integer    | 更新人                   |
| py         | string     | 拼音/检索                |

**客户收货地址（crm_addresses）**

| 字段       | 类型       | 说明                               |
| ---------- | ---------- | ---------------------------------- |
| client_id  | references | 客户（关联 crm_clients）           |
| addr_kind  | string     | 地址类型（收货/开票等，避免 type） |
| contact    | string     | 收件人/联系人                      |
| phone      | string     | 电话                               |
| addr       | text       | 地址                               |
| is_default | boolean    | 是否默认                           |
| remark     | string     | 备注                               |
| user_id    | integer    | 创建人                             |
| updater_id | integer    | 更新人                             |
| py         | string     | 拼音/检索                          |

#### 报价模块（客户下）

**报价单主表（crm_quotations）**

| 字段         | 类型       | 说明                              |
| ------------ | ---------- | --------------------------------- |
| contract_id  | integer    | 关联合同（主表）                  |
| client_id    | references | 客户（关联 crm_clients）          |
| code         | string     | 报价单号                          |
| quote_date   | date       | 报价日期                          |
| valid_until  | date       | 有效期至                          |
| currency     | string     | 币种（如：CNY、USD）              |
| status_id    | integer    | 状态（关联 properties）           |
| tax_rate_id  | integer    | 税率（关联 properties，属性选择） |
| amount       | decimal    | 不含税总价                        |
| total_amount | decimal    | 含税总价                          |
| remark       | text       | 备注                              |
| user_id      | integer    | 创建人                            |
| updater_id   | integer    | 更新人                            |
| py           | string     | 拼音/检索                         |

**报价明细表（crm_quotation_lines，关联报价单）**

| 字段         | 类型       | 说明                              |
| ------------ | ---------- | --------------------------------- |
| quotation_id | references | 报价单（关联 crm_quotations）     |
| item_id      | integer    | 产品/物料（关联 mat_items，可选） |
| product_name | string     | 产品名称（冗余或未关联时）        |
| spec         | string     | 规格                              |
| qty          | decimal    | 数量                              |
| unit         | string     | 单位                              |
| unit_price   | decimal    | 含税单价                          |
| amount       | decimal    | 含税金额                          |
| remark       | string     | 行备注                            |
| sort         | integer    | 行序                              |
| user_id      | integer    | 创建人                            |

#### 开票信息（关联客户与供应商）

**开票信息表（crm_invoice）**：通过多态 **billable** 关联客户（crm_clients）或供应商（pur_suppliers），客户/供应商可维护多条开票信息（如不同抬头、不同地址）。

| 字段            | 类型    | 说明                                          |
| --------------- | ------- | --------------------------------------------- |
| billable_type   | string  | 关联类型（Crm::Client / Pur::Supplier）       |
| billable_id     | integer | 关联 ID（客户或供应商）                       |
| title           | string  | 开票抬头                                      |
| tax_no          | string  | 税号                                          |
| address         | string  | 注册/开票地址                                 |
| phone           | string  | 注册/开票电话                                 |
| bank_name       | string  | 开户银行名称                                  |
| bank_account    | string  | 银行账号                                      |
| invoice_type_id | integer | 发票类型（专票/普票/数电票，关联 properties） |
| is_default      | boolean | 是否默认                                      |
| remark          | string  | 备注                                          |
| user_id         | integer | 创建人                                        |
| updater_id      | integer | 更新人                                        |
| py              | string  | 拼音/检索                                     |

#### 订购合同（销售订单合同）字段

**主表表名：** fm_contracts（销售订单合同主表；合同表自身不加 contract_id）

| 字段                  | 类型       | 说明                                             |
| --------------------- | ---------- | ------------------------------------------------ |
| code                  | string     | 合同编号                                         |
| sign_at               | date       | 签订日期                                         |
| client_id             | references | 客户/采购方（关联 crm_clients）                  |
| client_contact_id     | string     | 采购方联系人                                     |
| client_contact_name   | string     | 采购方联系人                                     |
| client_phone          | string     | 采购方电话                                       |
| client_fax            | string     | 采购方传真                                       |
| supplier_id           | references | 供应方（关联 pur_suppliers）                     |
| supplier_contact_id   | string     | 供应方联系人                                     |
| supplier_contact_name | string     | 供应方联系人                                     |
| supplier_phone        | string     | 供应方电话                                       |
| supplier_fax          | string     | 供应方传真                                       |
| product_id            | integer    | 产品（关联 mat_items，可选）                     |
| product_en            | string     | 英文品名                                         |
| product_zh            | string     | 中文品名                                         |
| specs                 | text       | 规格外观                                         |
| pack_req              | text       | 包装要求                                         |
| qty                   | decimal    | 数量                                             |
| unit_price            | decimal    | 单价                                             |
| total                 | decimal    | 合计金额                                         |
| tax_id                | integer    | 税率（关联 properties，同 product_purchase_tax） |
| tax                   | decimal    | 税额                                             |
| amount_net            | decimal    | 不含税金额                                       |
| total_cn              | string     | 人民币大写                                       |
| deliver_at            | date       | 交货时间                                         |
| deliver_addr          | string     | 交货地点                                         |
| indicator_req         | string     | 指标要求                                         |
| req_docs              | string     | 所需文件                                         |
| settlement_id         | integer    | 结算方式（关联 properties）                      |
| remarks               | text       | 备注条款                                         |
| user_id               | integer    | 创建人                                           |
| updater_id            | integer    | 更新人                                           |
| py                    | string     | 拼音/检索                                        |

**合同明细表**（crm_collections，关联合同）

| 字段            | 类型       | 说明                       |
| --------------- | ---------- | -------------------------- |
| contract_id     | references | 合同                       |
| sort            | integer    | 顺序                       |
| product_id      | integer    | 产品（关联 mat_items）     |
| name            | string     | 产品名称（冗余或未关联时） |
| unit_id         | integer    | 单位 关联 properties       |
| qty             | decimal    | 数量(KG)                   |
| price           | decimal    | 单价(RMB)                  |
| amount_excl_tax | decimal    | 不含税金额(RMB)            |
| tax             | decimal    | 税额(RMB)                  |
| amount          | decimal    | 总金额(RMB)                |
| user_id         | integer    | 创建人                     |
| updater_id      | integer    | 更新人                     |
| remark          | string     | 备注                       |

#### 交接单（外贸货物交接单）字段

**主表表名：** crm_handovers（交接单主表）

| 字段              | 类型    | 说明                                 |
| ----------------- | ------- | ------------------------------------ |
| contract_id       | integer | 关联合同（主表）                     |
| doc_no            | string  | 交接单号                             |
| order_company     | string  | 订购公司名称                         |
| order_contract_no | string  | 订购合同号                           |
| goods_name        | string  | 合同货物名称                         |
| specs             | text    | 货物详细规格                         |
| order_kind        | string  | 订货性质                             |
| special_note      | string  | 特殊订货说明                         |
| qty               | decimal | 数量                                 |
| qty_unit          | string  | 数量单位                             |
| pack_specs        | text    | 包装规格                             |
| deliver_at        | date    | 合同要求发货时间                     |
| notes             | text    | 说明                                 |
| user_id           | integer | 制单人（关联 users，默认取 user_id） |
| reviewer_id       | integer | 审核人（关联 users）                 |
| review_at         | date    | 审核日期                             |
| prod_signer_id    | integer | 生产部签收人（关联 users）           |
| tech_signer_id    | integer | 技术部签收人（关联 users）           |
| qa_signer_id      | integer | 质检部签收人（关联 users）           |
| user_id           | integer | 制单人创建人                         |
| updater_id        | integer | 更新人                               |
| py                | string  | 拼音/检索                            |

指标要求改为关联表：主表不再存平铺指标字段，通过**指标项目选项表** + **交接单指标要求明细表**，按选项选择项目并填写对应合同要求/内控要求。

**交接单指标要求明细表**（crm_handover_lines，关联 crm_handovers）

| 字段         | 类型       | 说明                            |
| ------------ | ---------- | ------------------------------- |
| handover_id  | references | 交接单                          |
| spec_item_id | references | 指标项目（关联 crm_spec_items） |
| contract_req | string     | 合同要求                        |
| internal_req | string     | 内控要求                        |
| sort         | integer    | 行序                            |
| user_id      | integer    | 创建人                          |

#### 配方交接单字段

**主表表名：** rms_handovers（配方交接单主表）

配方交接单通过**配方交接单合同关联表**关联多个合同（多对多）。

| 字段                    | 类型       | 说明                                              |
| ----------------------- | ---------- | ------------------------------------------------- |
| product_id              | integer    | 产品（关联 mat_items）                            |
| name                    | string     | 产品名称（冗余或未关联时）                        |
| code                    | string     | 配方单号                                          |
| handover_date           | date       | 交接日期                                          |
| ordering_companies_text | text       | 订购公司信息                                      |
| order_qty               | decimal    | 订货数量                                          |
| order_qty_unit          | string     | 订货数量单位（冗余）                              |
| order_qty_unit_id       | integer    | 订货数量单位（关联 properties，sign=product_uom） |
| handover_order_id       | references | 关联交接单（指标要求参阅交接单）                  |
| prepared_id             | integer    | 制单人（关联 users）                              |
| received_id             | integer    | 接收人（关联 users）                              |
| general_notes           | text       | 通用备注                                          |
| user_id                 | integer    | 创建人                                            |
| updater_id              | integer    | 更新人                                            |
| py                      | string     | 拼音/检索                                         |

```

**配方物料明细表**（rms_handover_lines，关联配方交接单）

| 字段 | 类型 | 说明 |
|------|------|------|
| handover_id | references | 配方交接单 |
| sort | integer | 序号 |
| name | string | 原辅料品名 |
| product_id | integer | 原辅料品名 |
| feeding_rate | decimal | 投料比例(g/L)（可为数值或“补足”等文字） |
| remark | string | 备注（冗余） |
| remark_id | integer | 备注（关联 properties，sign=rms_handover_line_remark） |
| user_id | integer | 创建人 |

**配方交接单合同关联表**（rms_handover_contracts，多对多：一个配方交接单可关联多个合同）

| 字段 | 类型 | 说明 |
|------|------|------|
| recipe_handover_id | references | 配方交接单（关联 rms_handovers） |
| contract_id | integer | 合同（关联 fm_contracts） |
| qty | decimal | 数量 |





#### 采购合同（购销合同）字段

**主表表名：** pur_contracts（采购合同主表）

采购合同与 fm_contracts（销售合同）逻辑保持一致，通过 **sign** 区分类型：`raw_material`（原料采购）、`carton`（纸箱采购）、`bottle`（包装瓶采购）。不同 sign 的表单字段可能不同，前端按 sign 动态展示。

**通用字段**（与 fm_contracts 对齐）

| 字段 | 类型 | 说明 |
|------|------|------|
| code | string | 合同编号 |
| sign | string | 标识：raw_material / carton / bottle |
| sign_at | date | 签订日期 |
| client_id | references | 需方（关联 crm_clients） |
| client_contact_id | integer | 需方联系人 ID |
| client_contact_name | string | 需方联系人 |
| client_phone | string | 需方电话 |
| client_fax | string | 需方传真 |
| supplier_id | references | 供方（关联 pur_suppliers） |
| supplier_contact_id | integer | 供方联系人 ID |
| supplier_contact_name | string | 供方联系人 |
| supplier_phone | string | 供方电话 |
| supplier_fax | string | 供方传真 |
| fm_contract_id | integer | 关联销售合同（fm_contracts，可选） |
| kind_id | integer | 类别（关联 properties） |
| status_id | integer | 状态（关联 properties） |
| settlement_id | integer | 结算方式（关联 properties） |
| signing_location | string | 签订地点 |
| signing_date | date | 签订时间 |
| deliver_at | date | 预计到货/交货时间 |
| deliver_addr | string | 交货地点 |
| total_amount | decimal | 合计金额(RMB) |
| total_amount_chinese | string | 人民币金额大写 |
| validity_start_date | date | 合同有效期起 |
| validity_end_date | date | 合同有效期止 |
| remark | text | 备注 |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |

**按 sign 区分的字段**（仅对应类型展示/必填）

| 字段 | 类型 | 适用 sign | 说明 |
|------|------|-----------|------|
| related_item | string | raw_material | 对应 FML 项下原药 |
| quality_standard | text | raw_material | 质量标准、技术标准 |
| delivery_location_method | text | raw_material | 交货地点及方式 |
| transportation_cost_bearer | string | raw_material | 运输费用负担 |
| loss_calculation_method | string | raw_material | 合理损耗及计算方法 |
| packaging_standard | text | raw_material | 包装标准、包装物供应与回收及费用负担 |
| packaging_loss_responsibility | string | raw_material | 包装质量损失责任 |
| inspection_method | text | raw_material | 验收方式及提出异议期限 |
| reinspection_period | string | raw_material | 复测期限 |
| objection_period | string | raw_material | 异议期限 |
| quality_issue_responsibility | string | raw_material | 质量问题责任 |
| spare_parts_supply | string | raw_material | 随机备品、配件工具数量及供应方法 |
| settlement_method_term | text | raw_material | 结算方式及期限 |
| breach_of_contract_liability | string | raw_material | 违约责任 |
| dispute_resolution_method | string | raw_material | 解决合同纠纷的方式 |
| other_agreements | text | raw_material | 其它约定事项 |
| carton_spec | string | carton | 纸箱规格（如 长×宽×高） |
| bottle_spec | string | bottle | 包装瓶规格 |

---

**采购合同产品明细表**（pur_collections，关联 pur_contracts）

与 fm_contracts 的 crm_collections 逻辑一致，按 sign 区分明细字段。

**通用字段**

| 字段 | 类型 | 说明 |
|------|------|------|
| purchase_contract_id | references | 采购合同 |
| sort | integer | 顺序 |
| product_id | integer | 产品（关联 mat_items） |
| product_name | string | 产品名称（冗余或未关联时） |
| unit_id | integer | 单位（关联 properties） |
| unit | string | 单位（冗余） |
| qty | decimal | 数量 |
| price | decimal | 单价(RMB) |
| amount_excl_tax | decimal | 不含税金额(RMB) |
| tax | decimal | 税额(RMB) |
| amount | decimal | 总金额(RMB) |
| remark | string | 备注 |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |

**按 sign 区分的明细字段**

| 字段 | 类型 | 适用 sign | 说明 |
|------|------|-----------|------|
| length | decimal | carton | 外径尺寸-长 |
| width | decimal | carton | 外径尺寸-宽 |
| height | decimal | carton | 外径尺寸-高 |
| specs | string | raw_material | 规格外观 |
| bottle_body_color | string | bottle | 瓶身颜色 |
| lid | string | bottle | 盖子 |





**供应商（pur_suppliers）**

| 字段 | 类型 | 说明 |
|------|------|------|
| contract_id | integer | 关联pur_contract合同（主表） |
| code | string | 供应商编号 |
| name | string | 供应商名称 |
| abbr | string | 简称 |
| qual_notes | string | 资质说明 |
| remark | text | 备注 |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |

**供应商联系人（pur_contacts）**

| 字段 | 类型 | 说明 |
|------|------|------|
| supplier_id | integer | 供应商（关联 pur_suppliers） |
| name | string | 联系人姓名 |
| dept | string | 部门 |
| phone | string | 电话 |
| mobile | string | 手机 |
| email | string | 邮箱 |
| is_primary | boolean | 是否主联系人 |
| remark | string | 备注 |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |







#### 原料检验原始记录（原药、助剂）字段

**主表表名：** iqc_raw（原料检验原始记录主表）

| 字段 | 类型 | 说明 |
|------|------|------|
| contract_id | integer | 关联合同（fm_contracts） |
| product_id | integer | 产品/原料（关联 mat_items） |
| name | string | 原料名称（冗余或未关联时） |
| code | string | 检验编号 |
| supplier_id | string | 供应商 |
| supplier_name | string | 供应商 |
| batch_number | string | 原料批号 |
| inspection_qty | string | 检验数量 |
| request_inspection_date | date | 请检日期 |
| inspection_date | date | 检验日期 |
| inspection_basis | string | 检验依据 |
| std_sample_m | decimal | 标样 m₀ |
| std_sample_x | decimal | 标样 X₀ |
| std_sample_a_r_1 | decimal | 标样 A₀(r₀)-1 |
| std_sample_a_r_2 | decimal | 标样 A₀(r₀)-2 |
| ph_value | string | PH值（酸度/碱度，%） |
| moisture_percent | string | 水分（%） |
| other_indicators | string | 其它 |
| conclusion | string | 结论（冗余） |
| conclusion_id | integer | 结论（关联 properties，sign=iqc_raw_conclusion） |
| issue_ncr | boolean | 是否开具不合格评审单 |
| notes | text | 备注 |
| inspector_id | integer | 检验（关联 users） |
| reviewer_id | integer | 复核（关联 users） |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |

**有效成分样品读数表**（iqc_raw_lines，关联原料检验原始记录）

| 字段 | 类型 | 说明 |
|------|------|------|
| raw_id | references | 原料检验原始记录 |
| sort | integer | 序号（平行样 1、2、3…） |
| content_percent | string | 含量（%） |
| m_value | decimal | 样品 m |
| a_r_value | decimal | 样品 A(r) |
| x_percent | string | 样品 X（%） |


**指标项目选项表**（ crm_spec_items ，主数据；避免用 type 作列名）

| 字段       | 类型    | 说明                      |
| ---------- | ------- | ------------------------- |
| code       | string  | 项目编号                  |
| name       | string  | 项目名称                  |
| name_en    | string  | 英文名称                  |
| sort       | integer | 排序（不用 order 保留字） |
| remark     | string  | 备注                      |
| user_id    | integer | 创建人                    |
| updater_id | integer | 更新人                    |
| py         | string  | 拼音/检索                 |
| values         | text  | 值               |
```
