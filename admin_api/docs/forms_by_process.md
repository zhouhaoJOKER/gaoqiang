# 按流程整理的所需表单信息（可全部重新生成）

基于「订单流程」与「制造/质检流程图」整理，表单可独立设计，不依赖现有系统表。

---

## 流程表单总览（主表）

**主表名：** 流程表单总览 / 流程相关表单清单（Process Forms Overview）

| 序号 | 表单名称 | 所属模块 |
|------|----------|----------|
| 1 | 制剂销售合同（订购合同） | CRM |
| 2 | 外贸货物交接单 | CRM |
| 3 | 配方交接单 | CRM |
| 4-1 | 原料采购信息表（购销合同） | 采购 |
| 4-1-a | 原料检验原始记录 | 来料 |
| 4-1-b | 原料检验原始记录（同 4-1-a，多版本） | 来料 |
| 4-3 | 纸箱采购合同表 | 采购 |
| 4-4 | 包装瓶采购合同 | 采购 |
| 5 | 一周排产计划表（计划排产表/排产记录） | 生产计划 |
| 6 | 配料表（液体制剂配料操作票） | 生产执行 |
| 7 | 配料操作记录表（配制操作记录） | 生产执行 |
| 8-1 | 半成品检测记录1（有效成分、悬浮检验） | 生产执行 |
| 8-1 | 半成品检测记录2（副指标） | 生产执行 |
| 9-1 | 产品包装细节交接单 | 包装与成品 |
| 10-1 | 包装线操作记录 | 包装与成品 |
| 10-2 | 包装线抽样检测记录 | 包装与成品 |
| 11 | 生产车间入库数量记录 | 仓储与发货 |
| 12-1 | 进仓通知单 | 仓储与发货 |
| 12-2 | 解运单 | 仓储与发货 |
| 12-3 | 发货计划表 | 仓储与发货 |
| 12-4 | 每日发货记录 | 仓储与发货 |

---

## 按模块分类

以下按业务模块整理表单归属，并补充各模块缺失的表单（如 CRM 的客户、客户联系人等）。主表表名见各表单字段小节及文末一览表。

**表单命名规则（前缀 + 精简名）：** 主表表名采用「模块前缀_简短表名」，尽量精简。前缀约定：**crm_** 销售/客户，**pur_** 采购，**iqc_** 来料质检，**plan_** 生产计划，**mfg_** 生产执行，**pkg_** 包装与成品，**wh_** 仓储，**ship_** 发货，**crm_** 主数据。

**已有数据库表与可映射关系：** 以下系统表已存在，流程表单可优先映射使用并标记为「已存在」：

| 文档主表表名 | 已有表名 | 说明 |
|--------------|----------|------|
| pur_suppliers | mat_suppliers | 已存在 |
| wh_warehouses | wms_warehouses | 已存在 |
| wh_locations | wms_locations | 已存在 |
| crm_items | mat_items | 产品/物料主数据，已存在 |
| 产品/BOM 相关 | mat_products, mfg_boms, mfg_order_lines | 已存在 |
| 仓储/收发 | wms_receive_orders, wms_pick_orders, wms_transfer_orders, wms_return_orders | 已存在 |
| 生产 | mfg_orders, mfg_work_orders | 已存在 |
| 库存 | inv_inventories, inv_inventory_transactions, inv_inventory_locks | 已存在 |
| 主数据 | properties（类型/选项）、mat_items（产品/物料）、mat_products（产品） | 已存在 |

**字段命名说明（精简 + 避免 Rails 保留字）：** 字段名尽量简短；**禁止使用** Rails/ActiveRecord 保留字作为列名，否则易报错或冲突。常见保留字及替代建议：

- **type** → 用 **type_id**（关联 properties）或 **kind**、**category**
- **order** → 用 **sort**、**pos**、**seq**
- **class** → 用 **klass** 或 **category_id**
- **size** → 用 **qty**、**amount**、**capacity**
- **group** → 用 **group_id** 或 **batch**
- **format** → 用 **fmt** 或 **style**
- **attributes**、**errors**、**set**、**ref** 等 → 避免作为列名，改用 **attrs**、**err_msg**、**ref_no** 等

**表与字段约定：**

1. **主表**（除合同表自身外）均增加 **contract_id:integer**，与合同关联。
2. **所有表**（主表 + 子表）均增加：**user_id:integer**、**updater_id:integer**、**py:string**（创建人、更新人、拼音/检索）。
3. 字段以表格列出：**| 字段 | 类型 | 说明 |**；每个表下方附 **生成模型**、**生成接口** 示例命令（格式参考 `docs/dev.md`）。

以下各表单字段已按「精简 + 避免保留字」做了相应命名，实现时请统一遵循。

### CRM 模块（销售与客户）

| 表单名称 | 用途 | 主表表名 |
|----------|------|----------|
| 销售订单 | 客户订单落单 | crm_orders（与订购合同合并或独立） |
| 订购合同（销售订单合同） | 制剂销售合同 | crm_contracts |
| 订单取消记录 | 取消订单 | crm_cancel |
| 交接单（外贸货物交接单） | 外贸货物交接与签收 | crm_handovers |
| 配方确认单 | 确认/锁定生产用配方 | crm_recipe_confirm |
| 配方交接单 | 配方生产交接 | crm_recipe_handovers |
| 研发试验单 | 新配方或配方调整 | crm_rnd_trials |
| 检测报告（研发） | 研发阶段检测 | crm_rnd_reports |
| 配方调整申请 | 配方变更 | crm_recipe_changes |
| **客户** | 客户主数据 | **crm_clients** |
| **客户联系人** | 客户联系人 | **crm_contacts** |
| **客户收货地址** | 客户收货/开票地址 | **crm_addresses** |
| **报价** | 客户报价单及明细 | **crm_quotations** |
| **开票信息** | 客户/供应商开票抬头与账户（多态关联） | **crm_invoice** |

### 采购模块

| 表单名称 | 用途 | 主表表名 |
|----------|------|----------|
| 采购订单（原药/助剂） | 原药、助剂采购 | pur_orders |
| 采购订单（包材/喷头/标签） | 包材类采购 | pur_orders |
| 原料采购信息表（购销合同） | 原料购销合同 | pur_contracts |
| 纸箱采购合同表 | 纸箱定做合同 | pur_cartons |
| 包装瓶采购合同 | 包装瓶采购合同 | pur_bottles |
| 采购合同（框架） | 框架或单次合同 | pur_framework |
| **供应商** | 供应商主数据 | **pur_suppliers**（已存在，可映射 mat_suppliers） |
| **供应商联系人** | 供应商联系人 | **pur_contacts** |

### 来料模块（收货与来料质检）

| 表单名称 | 用途 | 主表表名 |
|----------|------|----------|
| 收货单 | 物料到货登记 | receive_orders / goods_receipts |
| 来料检验单（IQC） | 来料质量判定 | iqc_inspections |
| 原料检验原始记录 | 原药、助剂检验原始数据 | iqc_raw |
| 不合格处置单（来料） | 来料不合格处置 | incoming_disposition_orders |
| 退货单（退回供应商） | 不合格品退回 | return_to_vendor_orders |
| 降级使用审批单 | 来料降级使用 | downgrade_approvals |

### 生产计划模块

| 表单名称 | 用途 | 主表表名 |
|----------|------|----------|
| 生产计划 | 月度/周计划 | plan_plans |
| 计划排产表 | 按周/产线计划排产 | plan_schedules |
| 排产记录 | 实际排产条目 | plan_records |
| 一周排产记录表 | 按排产记录统计展示 | （无需建表，由 plan_records 汇总） |
| 排产单/工单 | 日排产与执行单位 | plan_work_orders |

### 生产执行模块（配制与过程质检）

| 表单名称 | 用途 | 主表表名 |
|----------|------|----------|
| 配料单/领料单 | 按排产单领料 | pick_orders / batching_requisitions |
| 配料表（液体制剂配料操作票） | 配料操作票 | mfg_batching |
| 配料操作记录表 | 配制过程操作日志 | mfg_batch_ops |
| 配制记录/批生产记录 | 配制过程记录 | mfg_batch_records |
| 返工单 | 返工任务 | mfg_rework |
| 过程检验单（IPQC） | 配制后检测 | mfg_ipqc |
| 半成品检测记录1 | 有效成分、悬浮检验 | mfg_semi1 |
| 半成品检测记录2 | 乳油/可溶液剂副指标 | mfg_semi2 |
| 包装调机记录 | 包装线调机 | mfg_setup |
| 首瓶确认单 | 首瓶检验 | mfg_first_bottle |
| 让步接收单（过程） | 过程让步放行 | mfg_concession |

### 包装与成品模块

| 表单名称 | 用途 | 主表表名 |
|----------|------|----------|
| 包装记录 | 包装生产记录 | packaging_records |
| 产品包装细节交接单 | 包装细节交接 | pkg_handovers |
| 包装线操作记录 | 包装线当日操作 | pkg_line |
| 包装线抽样检测记录 | 包装线抽样检验 | pkg_sampling |
| 包装不合格处置 | 包装不合格处置 | packaging_disposition_orders |
| 成品抽检单（FQC） | 包装后抽检 | fqc_inspections |
| 业务确认单 | 不合格品业务决策 | business_confirmations |
| 让步接收单（成品） | 成品让步放行 | product_concessions |
| 不合格评审处置单（成品） | 成品不合格处置 | ncr_dispositions |

### 仓储与发货模块

| 表单名称 | 用途 | 主表表名 |
|----------|------|----------|
| 生产车间入库数量记录 | 车间日报/入库数量依据 | wh_reports |
| 成品入库单 | 成品入库 | wh_receipts |
| 进仓通知单 | 通知对方按单送货至仓库 | wh_notices |
| 解运单（解运清单） | 发货解运清单、随货凭证 | ship_orders |
| 发货计划表 | 发货计划与进仓安排 | ship_plans |
| 每日发货记录 | 当日发货明细 | ship_daily |
| 发货单/出库单 | 销售发货 | ship_out / ship_confirm |
| 发货确认单 | 发货签收确认 | ship_confirm |
| **仓库** | 仓库主数据 | **wh_warehouses**（已存在，可映射 wms_warehouses） |
| **库位** | 库位/货位 | **wh_locations**（已存在，可映射 wms_locations） |

### 主数据模块（可选）

| 表单名称 | 用途 | 主表表名 |
|----------|------|----------|
| 客户 | 客户信息 | crm_clients |
| 客户联系人 | 客户联系人 | crm_contacts |
| 客户收货地址 | 客户地址 | crm_addresses |
| 供应商 | 供应商信息 | pur_suppliers |
| 供应商联系人 | 供应商联系人 | pur_contacts |
| 产品/物料 | 产品与物料 | crm_items |
| 配方/BOM | 配方库 | crm_boms |
| 检验项目 | 质检项目 | crm_inspection_items |
| 指标项目（spec_items） | 交接单/合同指标选项 | crm_spec_items |
| 仓库 | 仓库 | wh_warehouses（已存在，可映射 wms_warehouses） |
| 库位 | 库位 | wh_locations（已存在，可映射 wms_locations） |

---

### CRM 模块补充表单字段（客户、客户联系人、客户收货地址）

**客户（crm_clients）**

| 字段 | 类型 | 说明 |
|------|------|------|
| parent_id | integer | 父级客户（关联 crm_clients） |
| code | string | 客户编号 |
| name | string | 客户名称 |
| abbr | string | 简称 |
| settlement_id | integer | 结算方式（关联 properties） |
| payment_terms | string | 付款条款 |
| invoice_type_id | integer | 默认发票类型（专票/普票/数电票，关联 properties） |
| remark | text | 备注 |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |

**生成模型**

```bash
rails g model Crm::Client parent_id:integer code:string name:string abbr:string tax_no:string address:string phone:string bank_name:string bank_account:string settlement_id:integer payment_terms:string invoice_type_id:integer remark:text user_id:integer updater_id:integer py:string
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Crm::Clients --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes parent_id,code,name,abbr,tax_no,address,phone,bank_name,bank_account,settlement_id,payment_terms,invoice_type_id,remark,user_id,updater_id,py
```

**客户联系人（crm_contacts）**

| 字段 | 类型 | 说明 |
|------|------|------|
| client_id | references | 客户（关联 crm_clients） |
| name | string | 联系人姓名 |
| dept | string | 部门 |
| title | string | 职务 |
| phone | string | 电话 |
| mobile | string | 手机 |
| email | string | 邮箱 |
| is_primary | boolean | 是否主联系人 |
| remark | string | 备注 |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |

**生成模型**

```bash
rails g model Crm::Contact client_id:references name:string dept:string title:string phone:string mobile:string email:string is_primary:boolean remark:string user_id:integer updater_id:integer py:string
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Crm::Contacts --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes client_id,name,dept,title,phone,mobile,email,is_primary,remark,user_id,updater_id,py
```

**客户收货地址（crm_addresses）**

| 字段 | 类型 | 说明 |
|------|------|------|
| client_id | references | 客户（关联 crm_clients） |
| addr_kind | string | 地址类型（收货/开票等，避免 type） |
| contact | string | 收件人/联系人 |
| phone | string | 电话 |
| addr | text | 地址 |
| is_default | boolean | 是否默认 |
| remark | string | 备注 |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |

**生成模型**

```bash
rails g model Crm::Address client_id:references addr_kind:string contact:string phone:string addr:text is_default:boolean remark:string user_id:integer updater_id:integer py:string
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Crm::Addresses --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes client_id,addr_kind,contact,phone,addr,is_default,remark,user_id,updater_id,py
```

#### 报价模块（客户下）

**报价单主表（crm_quotations）**

| 字段 | 类型 | 说明 |
|------|------|------|
| contract_id | integer | 关联合同（主表） |
| client_id | references | 客户（关联 crm_clients） |
| code | string | 报价单号 |
| quote_date | date | 报价日期 |
| valid_until | date | 有效期至 |
| currency | string | 币种（如：CNY、USD） |
| status_id | integer | 状态（关联 properties） |
| tax_rate_id | integer | 税率（关联 properties，属性选择） |
| amount | decimal | 不含税总价 |
| total_amount | decimal | 含税总价 |
| remark | text | 备注 |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |

**生成模型**

```bash
rails g model Crm::Quotation contract_id:integer client_id:references code:string quote_date:date valid_until:date currency:string status_id:integer tax_rate_id:integer amount:decimal total_amount:decimal remark:text user_id:integer updater_id:integer py:string
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Crm::Quotations --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes contract_id,client_id,code,quote_date,valid_until,currency,status_id,tax_rate_id,amount,total_amount,remark,user_id,updater_id,py
```

**报价明细表（crm_quotation_lines，关联报价单）**

| 字段 | 类型 | 说明 |
|------|------|------|
| quotation_id | references | 报价单（关联 crm_quotations） |
| item_id | integer | 产品/物料（关联 mat_items，可选） |
| product_name | string | 产品名称（冗余或未关联时） |
| spec | string | 规格 |
| qty | decimal | 数量 |
| unit | string | 单位 |
| unit_price | decimal | 含税单价 |
| amount | decimal | 含税金额 |
| remark | string | 行备注 |
| sort | integer | 行序 |
| user_id | integer | 创建人 |

**生成模型**

```bash
rails g model Crm::QuotationLine quotation_id:references item_id:integer product_name:string spec:string qty:decimal unit:string  unit_price:decimal   amount:decimal remark:string sort:integer user_id:integer
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Crm::QuotationLines --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes quotation_id,item_id,product_name,spec,qty,unit,unit_price,amount,remark,sort,user_id
```

#### 开票信息（关联客户与供应商）

**开票信息表（crm_invoice）**：通过多态 **billable** 关联客户（crm_clients）或供应商（pur_suppliers），客户/供应商可维护多条开票信息（如不同抬头、不同地址）。

| 字段 | 类型 | 说明 |
|------|------|------|
| billable_type | string | 关联类型（Crm::Client / Pur::Supplier） |
| billable_id | integer | 关联 ID（客户或供应商） |
| title | string | 开票抬头 |
| tax_no | string | 税号 |
| address | string | 注册/开票地址 |
| phone | string | 注册/开票电话 |
| bank_name | string | 开户银行名称 |
| bank_account | string | 银行账号 |
| invoice_type_id | integer | 发票类型（专票/普票/数电票，关联 properties） |
| is_default | boolean | 是否默认 |
| remark | string | 备注 |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |

**生成模型**

```bash
rails g model Crm::Invoice billable_type:string billable_id:integer title:string tax_no:string address:string phone:string bank_name:string bank_account:string invoice_type_id:integer is_default:boolean remark:string user_id:integer updater_id:integer py:string
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Crm::Invoices --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes billable_type,billable_id,title,tax_no,address,phone,bank_name,bank_account,invoice_type_id,is_default,remark,user_id,updater_id,py
```

**关联说明**：客户模型 `has_many :invoices, as: :billable, class_name: 'Crm::Invoice'`；供应商模型 `has_many :invoices, as: :billable, class_name: 'Crm::Invoice'`。开票信息表（crm_invoice）模型 `belongs_to :billable, polymorphic: true`；若需表名为单数 `crm_invoice`，请在模型中设置 `self.table_name = 'crm_invoice'`。客户表/供应商表中原开票相关字段（税号、地址、电话、银行、发票类型等）可保留为冗余或逐步迁移至本表。

### 采购模块补充表单字段（供应商、供应商联系人）

**供应商（pur_suppliers）**（已存在，可映射 mat_suppliers）

| 字段 | 类型 | 说明 |
|------|------|------|
| contract_id | integer | 关联合同（主表） |
| code | string | 供应商编号 |
| name | string | 供应商名称 |
| abbr | string | 简称 |
| qual_notes | string | 资质说明 |
| remark | text | 备注 |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |

**生成模型**

```bash
rails g model Pur::Supplier contract_id:integer code:string name:string abbr:string  qual_notes:string remark:text user_id:integer updater_id:integer py:string
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Pur::Suppliers --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes contract_id,code,name,abbr,qual_notes,remark,user_id,updater_id,py
```

**供应商联系人（pur_contacts）**

| 字段 | 类型 | 说明 |
|------|------|------|
| supplier_id | references | 供应商（关联 pur_suppliers） |
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

**生成模型**

```bash
rails g model Pur::Contact supplier_id:references name:string dept:string phone:string mobile:string email:string is_primary:boolean remark:string user_id:integer updater_id:integer py:string
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Pur::Contacts --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes supplier_id,name,dept,phone,mobile,email,is_primary,remark,user_id,updater_id,py
```

---

## 一、订单与配方管理

### 1.1 订单

| 表单名称 | 用途 | 建议字段 | 备注 |
|----------|------|----------|------|
| 销售订单 | 客户订单落单 | 订单号、客户、产品、数量、单价、总金额、交期、付款条款、签订人、状态 | 流程起点 |
| 订单取消记录 | 取消订单 | 原订单号、取消原因、取消人、取消时间 | 从「订单」分支 |
| 交接单 | 外贸货物交接信息传递与签收 | 交接单号、订购公司、合同号、合同货物、规格、数量、包装、发货时间、指标要求、制单/审核/各部门签收 | 订单与生产/质检衔接 |

#### 订购合同（销售订单合同）字段

**主表表名：** fm_contracts（销售订单合同主表；合同表自身不加 contract_id）

| 字段 | 类型 | 说明 |
|------|------|------|
| code | string | 合同编号 |
| sign_at | date | 签订日期 |
| client_id | references | 客户/采购方（关联 crm_clients） |
| client_contact_id | string | 采购方联系人 |
| client_contact_name | string | 采购方联系人 |
| client_phone | string | 采购方电话 |
| client_fax | string | 采购方传真 |
| supplier_id | references | 供应方（关联 pur_suppliers） |
| supplier_contact_id | string | 供应方联系人 |
| supplier_contact_name | string | 供应方联系人 |
| supplier_phone | string | 供应方电话 |
| supplier_fax | string | 供应方传真 |
| product_en | string | 英文品名 |
| product_zh | string | 中文品名 |
| specs | text | 规格外观 |
| pack_req | text | 包装要求 |
| qty | decimal | 数量 |
| unit_price | decimal | 单价 |
| total | decimal | 合计金额 |
| tax_id | integer | 税率 |
| tax | decimal | 税额 |
| amount_net | decimal | 不含税金额 |
| total_cn | string | 人民币大写 |
| deliver_at | date | 交货时间 |
| deliver_addr | string | 交货地点 |
| indicator_req | string | 指标要求 |
| req_docs | string | 所需文件 |
| settlement_id | integer | 结算方式（关联 properties） |
| remarks | text | 备注条款 |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |

**生成模型**

```bash
rails g model Crm::Contract code:string sign_at:date client_id:references client_contact_id:integer  client_contact_name:string client_phone:string client_fax:string supplier_id:references supplier_contact_name:string  supplier_contact_id:integer supplier_phone:string supplier_fax:string product_en:string product_zh:string specs:text pack_req:text qty:decimal unit_price:decimal total:decimal tax:decimal amount_net:decimal total_cn:string deliver_at:date deliver_addr:string indicator_req:string req_docs:string settlement_id:integer remarks:text user_id:integer updater_id:integer py:string
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Crm::Contracts --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes code,sign_at,client_id,client_contact_name,client_contact_id,client_phone,client_fax,supplier_id,supplier_contact_id,supplier_contact_name,supplier_phone,supplier_fax,product_en,product_zh,specs,pack_req,qty,unit_price,total,tax,amount_net,total_cn,deliver_at,deliver_addr,indicator_req,req_docs,settlement_id,remarks,user_id,updater_id,py
```



**合同明细表**（fm_collections，关联购销合同）

| 字段 | 类型 | 说明 |
|------|------|------|
| contract_id | references | 合同 |
| sort | integer | 顺序 |
| product_id | integer | 产品（关联 mat_items） |
| name | string | 产品名称（冗余或未关联时） |
| unit_id | integer | 单位 |
| qty | decimal | 数量(KG) |
| price | decimal | 单价(RMB) |
| amount_excl_tax | decimal | 不含税金额(RMB) |
| tax | decimal | 税额(RMB) |
| amount | decimal | 总金额(RMB) |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| remark | string | 备注 |

**生成模型**

```bash
rails g model Crm::Collection contract_id:integer:index sort:integer product_id:integer name:string unit_id:integer qty:decimal price:decimal amount_excl_tax:decimal tax:decimal amount:decimal user_id:integer updater_id:integer remark:string 
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Crm::Collections --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes contract_id,sort,product_id,name,unit_id,qty,price,amount_excl_tax,tax,amount,user_id,updater_id,remark
```


#### 交接单（外贸货物交接单）字段

**主表表名：** crm_handovers（交接单主表）

| 字段 | 类型 | 说明 |
|------|------|------|
| contract_id | integer | 关联合同（主表） |
| doc_no | string | 交接单号 |
| order_company | string | 订购公司名称 |
| order_contract_no | string | 订购合同号 |
| goods_name | string | 合同货物名称 |
| specs | text | 货物详细规格 |
| order_kind | string | 订货性质 |
| special_note | string | 特殊订货说明 |
| qty | decimal | 数量 |
| qty_unit | string | 数量单位 |
| pack_specs | text | 包装规格 |
| deliver_at | date | 合同要求发货时间 |
| notes | text | 说明 |
| user_id | integer | 制单人（关联 users，默认取 user_id） |
| reviewer_id | integer | 审核人（关联 users） |
| review_at | date | 审核日期 |
| prod_signer_id | integer | 生产部签收人（关联 users） |
| tech_signer_id | integer | 技术部签收人（关联 users） |
| qa_signer_id | integer | 质检部签收人（关联 users） |
| user_id | integer | 制单人创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |

**生成模型**

```bash
rails g model Crm::Handover contract_id:integer doc_no:string order_company:string order_contract_no:string goods_name:string specs:text order_kind:string special_note:string qty:decimal qty_unit:string pack_specs:text deliver_at:date notes:text  reviewer_id:integer review_at:date prod_signer_id:integer tech_signer_id:integer qa_signer_id:integer user_id:integer updater_id:integer py:string
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Crm::Handovers --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes contract_id,doc_no,order_company,order_contract_no,goods_name,specs,order_kind,special_note,qty,qty_unit,pack_specs,deliver_at,notes,user_id,reviewer_id,review_at,prod_signer_id,tech_signer_id,qa_signer_id,user_id,updater_id,py
```

指标要求改为关联表：主表不再存平铺指标字段，通过**指标项目选项表** + **交接单指标要求明细表**，按选项选择项目并填写对应合同要求/内控要求。

**指标项目选项表**（crm_spec_items，主数据；避免用 type 作列名）

| 字段 | 类型 | 说明 |
|------|------|------|
| code | string | 项目编号 |
| name | string | 项目名称 |
| name_en | string | 英文名称 |
| sort | integer | 排序（不用 order 保留字） |
| remark | string | 备注 |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |

示例选项：外观、有效含量、水分、PH值、乳液稳定性、低温稳定性、热贮稳定性、其他。

**生成模型**（crm_spec_items）

```bash
rails g model Crm::SpecItem code:string name:string name_en:string sort:integer remark:string user_id:integer updater_id:integer py:string
```

**生成接口**（qa_spec_items）

```bash
rails g api:v1:scaffold_controller Crm::SpecItems --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes code,name,name_en,sort,remark,user_id,updater_id,py
```

**交接单指标要求明细表**（crm_handover_lines，关联 crm_handovers）

| 字段 | 类型 | 说明 |
|------|------|------|
| handover_id | references | 交接单 |
| spec_item_id | references | 指标项目（关联 crm_spec_items） |
| contract_req | string | 合同要求 |
| internal_req | string | 内控要求 |
| sort | integer | 行序 |
| user_id | integer | 创建人 |

**生成模型**

```bash
rails d model Crm::HandoverLine
rails g model Crm::HandoverLine handover_id:references spec_item_id:references contract_req:string internal_req:string sort:integer user_id:integer
```

**生成接口**

```bash
rails d api:v1:scaffold_controller Crm::HandoverLines 
rails g api:v1:scaffold_controller Crm::HandoverLines --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes handover_id,spec_item_id,contract_req,internal_req,sort,user_id
```

### 1.2 配方与研发

| 表单名称 | 用途 | 建议字段 | 备注 |
|----------|------|----------|------|
| 配方确认单 | 确认/锁定生产用配方 | 产品、配方版本、BOM/组分清单、单位用量、工艺说明、确认人、确认日期 | 无现成配方则走研发 |
| 配方交接单 | 配方产品生产交接（物料组成与要求） | 产品名称、配方单号、交接日期、订购公司、订货数量、指标要求（关联交接单）、制单人、接收人、通用备注；子表：原辅料品名、投料比例、备注 | 生产准备→物料配方交接 |
| 研发试验单 | 新配方或配方调整 | 项目/试验编号、产品、试验目的、原料/配比、工艺参数、试验人、开始/结束时间、结论（成功/不成功） | 无现成配方时使用 |
| 检测报告（研发） | 研发阶段检测 | 试验单号、样品、检测项目、检测结果、合格与否、分析人、日期 | 支持配方成熟判断 |
| 配方调整申请 | 配方变更 | 原配方、调整内容、原因、申请人、审批人、生效日期 | 配方不成功或迭代时 |

#### 配方交接单字段

**主表表名：** rms_handovers（配方交接单主表）

配方交接单通过**配方交接单合同关联表**关联多个合同（多对多）。

| 字段 | 类型 | 说明 |
|------|------|------|
| product_id | integer | 产品（关联 mat_items） |
| name | string | 产品名称（冗余或未关联时） |
| code | string | 配方单号 |
| handover_date | date | 交接日期 |
| ordering_companies_text | text | 订购公司信息 |
| order_qty | decimal | 订货数量 |
| order_qty_unit | string | 订货数量单位 |
| handover_order_id | references | 关联交接单（指标要求参阅交接单） |
| prepared_id | integer | 制单人（关联 users） |
| received_id | integer | 接收人（关联 users） |
| general_notes | text | 通用备注 |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |

**生成模型**

```bash
rails g model Rms::Handover product_id:integer name:string code:string handover_date:date ordering_companies_text:text order_qty:decimal order_qty_unit:string handover_order_id:references prepared_id:integer received_id:integer general_notes:text user_id:integer updater_id:integer py:string
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Rms::Handovers --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes product_id,name,code,handover_date,ordering_companies_text,order_qty,order_qty_unit,handover_order_id,prepared_id,received_id,general_notes,user_id,updater_id,py
```

**配方交接单合同关联表**（rms_handover_contracts，多对多：一个配方交接单可关联多个合同）

| 字段 | 类型 | 说明 |
|------|------|------|
| recipe_handover_id | references | 配方交接单（关联 rms_handovers） |
| contract_id | integer | 合同（关联 crm_contracts） |
| qty | decimal | 数量 |

**生成模型**

```bash
rails g model Rms::HandoverContract recipe_handover_id:references contract_id:references qty:decimal
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Rms::HandoverContracts --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes recipe_handover_id,contract_id,qty
```

**配方物料明细表**（rms_handover_lines，关联配方交接单）

| 字段 | 类型 | 说明 |
|------|------|------|
| handover_id | references | 配方交接单 |
| sort | integer | 序号 |
| name | string | 原辅料品名 |
| product_id | integer | 原辅料品名 |
| feeding_rate | decimal | 投料比例(g/L)（可为数值或“补足”等文字） |
| remark | string | 备注 |
| user_id | integer | 创建人 |

**生成模型**

```bash
rails g model Rms::HandoverLine handover_id:references sort:integer name:string product_id:integer feeding_rate:decimal remark:string user_id:integer
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Rms::HandoverLine --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes handover_id,sort,name,product_id,feeding_rate,remark,user_id
```

---

## 二、采购与来料

### 2.1 采购

| 表单名称 | 用途 | 建议字段 | 备注 |
|----------|------|----------|------|
| 采购订单（原药/助剂） | 原药、助剂采购 | 采购单号、供应商、物料、数量、单价、金额、交期、合同号、状态 | 原药、助剂一条线 |
| 采购订单（包材/喷头/标签） | 包材类采购 | 同上 + 规格/版次 | 包材、喷头、标签一条线 |
| 原料采购信息表（购销合同） | 原料采购合同信息 | 供方、需方、合同编号、签订地/时间、产品明细、合计、质量标准及交货/运输/包装/验收/结算等条款 | 原药/助剂采购合同 |
| 纸箱采购合同表（包装纸箱定做合同） | 包材纸箱定做合同 | 承揽方、定做方、签订日期/地址、定做物明细（标的名称、外径尺寸、单位、数量、单价、金额、备注）、合计、质量/交货/运输/结算/著作权/违约等条款、甲乙双方签章信息、合同有效期 | 包材采购合同 |
| 采购合同 | 框架或单次合同 | 合同号、供应商、物料范围、条款、签订人、有效期 | 可选，与采购订单关联 |

#### 原料采购信息表（购销合同）字段

**主表表名：** pur_contracts（购销合同主表）

| 字段 | 类型 | 说明 |
|------|------|------|
| contract_id | integer | 关联合同（主表，如销售合同） |
| contract_title | string | 合同名称 |
| supplier_id | string | 供方名称 |
| supplier_name | string | 供方名称 |
| client_id | string | 需方名称 |
| client_name | string | 需方名称 |
| sign | string | 标识  |
| kind_id | integer | 类别 关联属性 |
| status_id | integer | 状态 关联属性 |
| contract_number | string | 合同编号 |
| signing_location | string | 签定地点 |
| signing_date | date | 签定时间 |
| receive_date | date | 预计到货时间 |
| total_amount | decimal | 合计金额(RMB) |
| total_amount_chinese | string | 人民币金额大写 |
| related_item | string | 对应FML项下原药 |
| quality_standard | text | 质量标准、技术标准 |
| delivery_location_method | text | 交货地点及方式 |
| transportation_cost_bearer | string | 运输费用负担 |
| loss_calculation_method | string | 合理损耗及计算方法 |
| packaging_standard | text | 包装标准、包装物供应与回收及费用负担 |
| packaging_loss_responsibility | string | 包装质量损失责任 |
| inspection_method | text | 验收方式及提出异议期限 |
| reinspection_period | string | 复测期限 |
| objection_period | string | 异议期限 |
| quality_issue_responsibility | string | 质量问题责任 |
| spare_parts_supply | string | 随机备品、配件工具数量及供应方法 |
| settlement_method_term | text | 结算方式及期限 |
| breach_of_contract_liability | string | 违约责任 |
| dispute_resolution_method | string | 解决合同纠纷的方式 |
| other_agreements | text | 其它约定事项 |
| remark | text | 备注 |
| other | text | 其他 |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |
| validity_start_date | date | 合同有效期起 |
| validity_end_date | date | 合同有效期止 |

**生成模型**

```bash
rails g model Pur::Contract contract_id:integer contract_title:string supplier_id:integer supplier_name:string client_id:integer  sign:string  client_name:string kind_id:integer status_id:integer contract_number:string signing_location:string signing_date:date receive_date:date total_amount:decimal total_amount_chinese:string related_item:string quality_standard:text delivery_location_method:text transportation_cost_bearer:string loss_calculation_method:string packaging_standard:text packaging_loss_responsibility:string inspection_method:text reinspection_period:string objection_period:string quality_issue_responsibility:string spare_parts_supply:string settlement_method_term:text breach_of_contract_liability:string dispute_resolution_method:string other_agreements:text remark:text other:text user_id:integer updater_id:integer py:string validity_start_date:date validity_end_date:date
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Pur::Contracts --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes contract_id,contract_title,supplier_id,supplier_name,client_id,client_name,kind_id,status_id,contract_number,signing_location,signing_date,receive_date,total_amount,total_amount_chinese,related_item,quality_standard,delivery_location_method,transportation_cost_bearer,loss_calculation_method,packaging_standard,packaging_loss_responsibility,inspection_method,reinspection_period,objection_period,quality_issue_responsibility,spare_parts_supply,settlement_method_term,breach_of_contract_liability,dispute_resolution_method,other_agreements,remark,user_id,updater_id,py,other,validity_start_date,validity_end_date,sign
```

**购销合同产品明细表**（pur_collections，关联购销合同）

| 字段 | 类型 | 说明 |
|------|------|------|
| purchase_contract_id | references | 购销合同 |
| sort | integer | 顺序 |
| product_id | integer | 产品（关联 mat_items） |
| product_name | string | 产品名称（冗余或未关联时） |
| length | decimal | 外径尺寸-长 |
| width | decimal | 外径尺寸-宽 |
| height | decimal | 外径尺寸-高 |
| unit | string | 单位 |
| qty | decimal | 数量(KG) |
| price | decimal | 单价(RMB) |
| amount_excl_tax | decimal | 不含税金额(RMB) |
| tax | decimal | 税额(RMB) |
| amount | decimal | 总金额(RMB) |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| remark | string | 备注 |
| other | string | 其他 |

**生成模型**

```bash
rails g model Pur::Collection purchase_contract_id:references sort:integer product_id:integer product_name:string length:decimal width:decimal height:decimal unit:string qty:decimal price:decimal amount_excl_tax:decimal tax:decimal amount:decimal user_id:integer updater_id:integer remark:string other:string py:string
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Pur::Collections --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes purchase_contract_id,sort,product_id,product_name,length,width,height,unit,qty,price,amount_excl_tax,tax,amount,user_id,updater_id,remark,other,py
```

 

#### 纸箱采购合同表（同采购合同）字段

**主表表名：** pur_cartons（纸箱采购合同主表）
 
**纸箱定做明细表**（carton_contract_lines，关联纸箱采购合同）

#### 包装瓶采购合同表（包装纸箱定做合同）字段

**主表表名：** pur_cartons（同采购合同）
 
**纸箱定做明细表**（carton_contract_lines，关联纸箱采购合同）
 
### 2.2 仓库收货与来料验收

| 表单名称 | 用途 | 建议字段 | 备注 |
|----------|------|----------|------|
| 收货单 | 物料到货登记 | 收货单号、采购单号、供应商、到货日期、物料、到货数量、批次、货位、收货人 | 包材线与原药线均汇入此处 |
| 来料检验单（IQC） | 来料质量判定 | 收货单号、物料、批次、数量、检验项目、检验结果、合格/不合格、检验人、日期 | 验收环节 |
| 原料检验原始记录 | 原药、助剂来料检验原始数据 | 原料名称、供应商、批号、检验数量、请检/检验日期、检验依据、有效成分标样与样品读数、其它指标（PH/水分）、结论、是否开具不合格评审单、检验人、复核人 | 原药/助剂 IQC 原始记录，可关联 IQC |
| 不合格处置单（来料） | 来料不合格处置 | 检验单号、物料、批次、数量、不合格描述、处置方式（退回供应商/降级使用）、审批人、日期 | 不合格分支 |
| 退货单（退回供应商） | 不合格品退回 | 退货单号、供应商、物料、批次、数量、原因、退货人、日期 | 处置：退回供应商 |
| 降级使用审批单 | 来料降级使用 | 检验单号、物料、批次、数量、降级用途、审批人、日期 | 处置：降级使用 |

#### 原料检验原始记录（原药、助剂）字段

**主表表名：** iqc_raw（原料检验原始记录主表）

| 字段 | 类型 | 说明 |
|------|------|------|
| contract_id | integer | 关联合同（主表） |
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
| conclusion | string | 结论（合格/不合格） |
| issue_ncr | boolean | 是否开具不合格评审单 |
| notes | text | 备注 |
| inspector_id | integer | 检验（关联 users） |
| reviewer_id | integer | 复核（关联 users） |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |

**生成模型**

```bash
rails g model Iqc::Raw contract_id:integer product_id:integer name:string code:string supplier_id:string supplier_name:string batch_number:string inspection_qty:string request_inspection_date:date inspection_date:date inspection_basis:string std_sample_m:decimal std_sample_x:decimal std_sample_a_r_1:decimal std_sample_a_r_2:decimal ph_value:string moisture_percent:string other_indicators:string conclusion:string issue_ncr:boolean notes:text inspector_id:integer reviewer_id:integer user_id:integer updater_id:integer py:string
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Iqc::Raws --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes contract_id,product_id,name,code,supplier_id,supplier_name,batch_number,inspection_qty,request_inspection_date,inspection_date,inspection_basis,std_sample_m,std_sample_x,std_sample_a_r_1,std_sample_a_r_2,ph_value,moisture_percent,other_indicators,conclusion,issue_ncr,notes,inspector_id,reviewer_id,user_id,updater_id,py
```

**有效成分样品读数表**（iqc_raw_lines，关联原料检验原始记录）

| 字段 | 类型 | 说明 |
|------|------|------|
| raw_id | references | 原料检验原始记录 |
| sort | integer | 序号（平行样 1、2、3…） |
| content_percent | string | 含量（%） |
| m_value | decimal | 样品 m |
| a_r_value | decimal | 样品 A(r) |
| x_percent | string | 样品 X（%） |

**生成模型**

```bash
rails g model Iqc::RawLine raw_id:references sort:integer content_percent:string m_value:decimal a_r_value:decimal x_percent:string 
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Iqc::RawLines --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes raw_id,sort,content_percent,m_value,a_r_value,x_percent
```

---

## 三、生产计划与排产

| 表单名称 | 用途 | 建议字段 | 备注 |
|----------|------|----------|------|
| 生产计划 | 月度/周计划 | 计划编号、产品、计划数量、计划开始/结束、产线/车间、状态 | 合格来料后进入 |
| 计划排产表 | 按周/按产线的计划排产 | 计划标题、周期起止、车间/产线范围、计划明细（日期、产线、产品、数量、备注） | 先维护计划，再生成排产记录 |
| 排产记录 | 实际排产条目（按日、按产线） | 日期、产线、产品描述、剂型、数量单位、备注；可关联计划排产表 | 仅需生成并维护排产记录 |
| 一周排产记录表 | 按周、按产线的统计展示 | 由排产记录按周期、产线汇总查询得到 | 根据排产记录统计展示，无需单独建表 |
| 排产单/工单 | 日排产与执行单位 | 排产单号、生产计划号、产品、配方版本、计划数量、计划开始/结束、产线、状态 | 排单结果，驱动领料与配制 |

#### 计划排产表字段

**主表表名：** mfg_plan（计划排产表主表）

| 字段 | 类型 | 说明 |
|------|------|------|
| plan_title | string | 计划标题 |
| week_start_date | date | 周期开始日期 |
| week_end_date | date | 周期结束日期 |
| workshop_id | integer | 车间 六车间） |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |

**生成模型**

```bash
rails d model Mfg::Plan 
rails g model Mfg::Plan plan_title:string week_start_date:date week_end_date:date workshop_id:integer  user_id:integer updater_id:integer py:string
```

**生成接口**

```bash
rails d api:v1:scaffold_controller  Mfg::Plan
rails g api:v1:scaffold_controller  Mfg::Plan --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes plan_title,week_start_date,week_end_date,workshop_id,user_id,updater_id,py
```
 

#### 排产记录字段

**主表表名：** mfg_plan_lines（排产记录主表）

排产记录为实际产生的排产条目，可按计划排产表生成或手工录入；一周排产记录表仅据此统计展示。

| 字段 | 类型 | 说明 |
|------|------|------|
| contract_id | integer | 关联合同（主表） |
| plan_id | references | 关联计划排产表（可选） |
| date | date | 日期 |
| line_id | string | 生产线名称 |
| line_name | string | 生产线名称 |
| product_id | integer | 产品（关联 mat_items） |
| product_name | string | 产品名称/描述（冗余或未关联时） |
| name | string | 标题 |
| product_kind | string | 剂型 |
| qty_unit | string | 数量与单位 |
| remark | string | 备注 |
| sort | integer | 同日期同产线多条时的顺序 |
| user_id | integer | 创建人 | 

**生成模型**

```bash
rails g model Mfg::PlanLine contract_id:integer plan_id:references date:date line_id:string line_name:string product_id:integer product_name:string name:string product_kind:string qty_unit:string remark:string sort:integer user_id:integer 
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Mfg::PlanLines --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes contract_id,plan_id,date,line_id,line_name,product_id,product_name,name,product_kind,qty_unit,remark,sort,user_id
```

---

## 四、生产执行（配制与过程质检）

### 4.1 配制与返工

| 表单名称 | 用途 | 建议字段 | 备注 |
|----------|------|----------|------|
| 配料单/领料单 | 按排产单领料 | 排产单号、批次、物料、应领数量、实领数量、货位、领料人、日期 | 驱动物料出库 |
| 配料表（液体制剂配料操作票） | 液体制剂配料操作记录 | 产品名称、生产批号、配料比、配料数量、生产日期、原辅料明细（序号、类别、名称、批号、数量、含量、折百量、备注）、配料量复核、产要求及其他、下单/司磅/监磅/操作 | 配制环节配料操作票 |
| 配料操作记录表（液体制剂操作记录一） | 乳油/水剂/水乳剂等配制过程操作日志 | 产品名称、批号、数量(KL)、日期、原料与助剂明细、操作步骤（时间、釜温、操作记事）、取样送检结论、返工检测结论、放料数量、设备情况、配料人、操作人 | 适用于乳油、水剂、水乳剂、可溶液剂等配制加工 |
| 配制记录/批生产记录 | 配制过程记录 | 排产单号、批次、操作人、开始/结束时间、投料记录、实际产出、废料/损耗、日期 | 配制环节；不合格可返工 |
| 返工单 | 返工任务 | 返工单号、原排产单/批次、返工原因、返工工序（配制/首瓶/包装）、执行人、完成日期 | 可回到配制/首瓶确认/包装 |

#### 配料表（液体制剂配料操作票）字段

**主表表名：** mfg_batching（配料表主表）

| 字段 | 类型 | 说明 |
|------|------|------|
| contract_id | integer | 关联合同（主表） |
| product_id | integer | 产品（关联 mat_items） |
| product_name | string | 产品名称（冗余或未关联时） |
| production_batch_number | string | 生产批号 |
| batching_ratio | string | 配料比 |
| batching_qty | decimal | 配料数量（千克） |
| production_date | date | 生产日期 |
| batching_qty_recheck | decimal | 配料量复核（千克） |
| production_requirements_notes | text | 产要求及其他 |
| order_placed_id | integer | 下单（关联 users） |
| weighing_id | integer | 司磅（关联 users） |
| weighing_supervised_id | integer | 监磅（关联 users） |
| operator_id | integer | 操作（关联 users） |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |

**生成模型**

```bash
rails g model Mfg::Batching contract_id:integer product_id:integer product_name:string production_batch_number:string batching_ratio:string batching_qty:decimal production_date:date batching_qty_recheck:decimal production_requirements_notes:text order_placed_id:integer weighing_id:integer weighing_supervised_id:integer operator_id:integer user_id:integer updater_id:integer py:string
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Mfg::Batchings --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes contract_id,product_id,product_name,production_batch_number,batching_ratio,batching_qty,production_date,batching_qty_recheck,production_requirements_notes,order_placed_id,weighing_id,weighing_supervised_id,operator_id,user_id,updater_id,py
```

**配料明细表**（mfg_batching_lines，关联配料表）

| 字段 | 类型 | 说明 |
|------|------|------|
| batching_id | references | 配料表 |
| sort | integer | 序号 |
| category | string | 类别（如：原药一、原药二、溶剂、助剂） |
| name | string | 原辅材料名称 |
| product_id | integer | 原辅材料名称 |
| batch_number | string | 批号 |
| qty_kg | decimal | 数量（千克） |
| content_percent | decimal | 含量（%） |
| adjusted_qty_kg | decimal | 折百量（千克） |
| remark | string | 备注 |
| user_id | integer | 创建人 |

**生成模型**

```bash
rails g model Mfg::BatchingLine batching_id:references sort:integer category:string name:string product_id:integer batch_number:string qty_kg:decimal content_percent:decimal adjusted_qty_kg:decimal remark:string user_id:integer
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Mfg::BatchingLines --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes batching_id,sort,category,name,product_id,batch_number,qty_kg,content_percent,adjusted_qty_kg,remark,user_id
```

#### 配料操作记录表（液体制剂操作记录一）字段

**主表表名：** mfg_oprates（配料操作记录主表）

| 字段 | 类型 | 说明 |
|------|------|------|
| contract_id | integer | 关联合同（主表） |
| product_id | integer | 产品（关联 mat_items） |
| product_name | string | 产品名称（冗余或未关联时） |
| batch_number | string | 批号 |
| qty_kl | decimal | 数量(KL) |
| record_date | date | 日期 |
| discharge_qty | decimal | 放料数量 |
| inspection_result | string | 检测结论（合格/不合格） |
| rework_inspection_result | string | 返工检测结论（合格/不合格） |
| second_rework_inspection_result | string | 第二次返工检测结论（合格/不合格） |
| safety_env_result | boolean | 安环设施状态（关联 properties，如正常/异常） |
| shear_kettle_result | boolean | 配制剪切釜状态（关联 properties） |
| filter_result | boolean | 过滤器状态（关联 properties） |
| pump_result | boolean | 泵状态（关联 properties） |
| special_equipment_result | boolean | 特种设备状态（关联 properties） |
| equipment_status_notes | text | 其它设备说明（不正常时填） |
| remark | text | 备注 |
| batching_operator_id | integer | 配料人（关联 users） |
| operator_id | integer | 操作人（关联 users） |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |

**生成模型**

```bash
rails g model Mfg::Oprate contract_id:integer product_id:integer product_name:string batch_number:string qty_kl:decimal record_date:date discharge_qty:decimal inspection_result:string rework_inspection_result:string second_rework_inspection_result:string safety_env_result:boolean shear_kettle_result:boolean filter_result:boolean pump_result:boolean special_equipment_result:boolean equipment_status_notes:text remark:text batching_operator_id:integer operator_id:integer user_id:integer updater_id:integer py:string
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Mfg::Oprate --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes contract_id,product_id,product_name,batch_number,qty_kl,record_date,discharge_qty,inspection_result,rework_inspection_result,second_rework_inspection_result,safety_env_result,shear_kettle_result,filter_result,pump_result,special_equipment_result,equipment_status_notes,remark,batching_operator_id,operator_id,user_id,updater_id,py
```

**原料与助剂明细表**（mfg_oprate_lines，关联配料操作记录表）

| 字段 | 类型 | 说明 |
|------|------|------|
| operate_id | references | 配料操作记录表 |
| sort | integer | 序号（① ② …） |
| name | string | 原料或助剂名称 |
| batch_number | string | 批号 |
| qty_kg | decimal | 数量(Kg) |
| user_id | integer | 创建人 |

**生成模型**

```bash
rails g model Mfg::OprateLine operate_id:references sort:integer name:string batch_number:string qty_kg:decimal user_id:integer
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Mfg::OprateLines --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes operate_id,sort,name,batch_number,qty_kg,user_id
```

**操作步骤表**（mfg_oprate_step_lines 关联配料操作记录表）

| 字段 | 类型 | 说明 |
|------|------|------|
| operate_id | references | 配料操作记录表 |
| step_time | string | 时间（如：8:00、9:05） |
| kettle_temp | string | 釜温℃ |
| step_phase | string | 步骤阶段（配料前准备、配料投料、剪切搅拌、取样送检、返工、过滤、放料等） |
| step_notes | text | 操作记事 |
| is_edit_note | boolean | 操作记事可编辑 |
| sort | integer | 顺序 |
| user_id | integer | 创建人 |

**生成模型**

```bash
rails g model Mfg::OprateStepLine operate_id:references step_time:string kettle_temp:string step_phase:string step_notes:text is_edit_note:boolean sort:integer user_id:integer
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Mfg::OprateStepLines --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes operate_id,step_time,kettle_temp,step_phase,step_notes,is_edit_note,sort,user_id
```

### 4.2 过程检测与包装调机

| 表单名称 | 用途 | 建议字段 | 建议字段 |
|----------|------|----------|----------|
| 过程检验单（IPQC） | 配制后检测 | 排产单号、批次、检测项目、检测结果、合格/不合格、检验人、日期 | 不合格→返工回配制 |
| 包装调机记录 | 包装线调机 | 排产单号、产线、调机内容、调机人、开始/结束时间、结果（通过/不通过） | 不通过则继续调机 |
| 首瓶确认单 | 首瓶检验 | 排产单号、批次、首瓶样品、检验结果、通过/不通过、确认人、日期 | 不通过→回包装调机；可从返工进入 |
| 让步接收单（过程） | 过程让步放行 | 关联单号（IPQC/首瓶）、产品、批次、数量、不合格描述、让步原因、审批人、日期 | 质量指标不合格等分支 |
| 半成品检测记录（有效成分、悬浮检验原始记录） | 制剂半成品有效成分与悬浮检验 | 产品名称、检验依据、仪器编号、客户(商标)名称、请检日期、标样1/2（称样量、含量、谱图标识、峰面积比）、样品明细（来源、批号、称样量、谱图、峰面积比、质量分数、比重、质量浓、悬浮相关） | 半成品检测原始记录，可关联 IPQC |
| 半成品检测记录2（乳油、可溶液剂副指标检验原始记录） | 乳油/可溶液剂半成品副指标检验 | 产品名称、客户(商标)、样品颜色、副指标明细（日期、来源、批号、PH、比重、水分、闪点、粘度、分散稳定性、持泡性、倾倒性） | 适用于乳油、可溶液剂等半成品副指标 |

FDF（Finished Dosage Form）：在制药行业是“成品制剂”的标准术语，作为“制剂”的顶层缩写非常合适。

LDF（Liquid Dosage Form）：直接沿用 FDF 的命名逻辑，将 “Finished” 替换为 “Liquid”，既保留了“剂型”的含义，又明确了“液体”的形态。行业内也常用这种构词法（例如 Solid Dosage Form 简写为 SDF）。


#### 半成品检测记录（有效成分、悬浮检验原始记录）字段

**主表表名：** iqc_fdf（半成品检测记录主表）

| 字段 | 类型 | 说明 |
|------|------|------|
| contract_id | integer | 关联合同（主表） |
| product_id | integer | 产品（关联 mat_items） |
| name | string | 产品名称（冗余或未关联时） |
| code | string | 检验编号 |
| inspection_basis | string | 检验依据 |
| instrument_number | string | 仪器编号 |
| customer_trademark_name | string | 客户(商标)名称 |
| request_inspection_date | date | 请检(检验)日期 |
| std_sample_1_m | string | 标样1称样量 M1 |
| std_sample_1_x | decimal | 标样1含量 X1 |
| std_sample_1_spectrum_id | string | 标样1谱图标识 |
| std_sample_1_a_r_1 | string | 标样1峰面积/内标面积比 A1(r)-1 |
| std_sample_1_a_r_2 | string | 标样1峰面积/内标面积比 A1(r)-2 |
| std_sample_2_m | string | 标样2称样量 M2 |
| std_sample_2_x | decimal | 标样2含量 X2 |
| std_sample_2_spectrum_id | string | 标样2谱图标识 |
| std_sample_2_a_r_1 | string | 标样2峰面积/内标面积比 A2(r)-1 |
| std_sample_2_a_r_2 | string | 标样2峰面积/内标面积比 A2(r)-2 |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |
 
**生成模型**

```bash
rails g model Iqc::Fdf contract_id:integer product_id:integer name:string code:string inspection_basis:string instrument_number:string customer_trademark_name:string request_inspection_date:date std_sample_1_m:string std_sample_1_x:decimal std_sample_1_spectrum_id:string std_sample_1_a_r_1:string std_sample_1_a_r_2:string std_sample_2_m:string std_sample_2_x:decimal std_sample_2_spectrum_id:string std_sample_2_a_r_1:string std_sample_2_a_r_2:string user_id:integer updater_id:integer py:string
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Iqc::Fdfs --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes contract_id,product_id,name,code,inspection_basis,instrument_number,customer_trademark_name,request_inspection_date,std_sample_1_m,std_sample_1_x,std_sample_1_spectrum_id,std_sample_1_a_r_1,std_sample_1_a_r_2,std_sample_2_m,std_sample_2_x,std_sample_2_spectrum_id,std_sample_2_a_r_1,std_sample_2_a_r_2,user_id,updater_id,py
```

**检测样品明细表**（iqc_fdf_lines，关联半成品检测记录）

| 字段 | 类型 | 说明 |
|------|------|------|
| fdf_id | references | 半成品检测记录 |
| source | string | 来源（如：仓） |
| batch_number | string | 批号 |
| yield_kl_t | string | 产量(KL/t) |
| sample_weight_mg | decimal | 称样量(mg) |
| spectrum_id | string | 谱图标识（有效成分） |
| peak_area_ratio | string | 峰面积/内标峰面积比(A或r)（有效成分） |
| mass_fraction_percent | decimal | 质量分数(%)（有效成分） |
| specific_gravity | decimal | 比重(g/mL) |
| mass_concentration_g_l | decimal | 质量浓(g/L) |
| suspension_powder_weight_g | decimal | 悬浮粉样量(g) |
| suspension_spectrum_id | string | 谱图标识（悬浮） |
| suspension_peak_area_ratio | string | 峰面积/内标峰面积比（悬浮） |
| suspension_mass_fraction_percent | decimal | 质量分数(%)（悬浮） |
| sort | integer | 行序 |
| user_id | integer | 创建人 |

**生成模型**

```bash
rails g model Iqc::FdfLine fdf_id:references source:string batch_number:string yield_kl_t:string sample_weight_mg:decimal spectrum_id:string peak_area_ratio:string mass_fraction_percent:decimal specific_gravity:decimal mass_concentration_g_l:decimal suspension_powder_weight_g:decimal suspension_spectrum_id:string suspension_peak_area_ratio:string suspension_mass_fraction_percent:decimal sort:integer user_id:integer
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Iqc::FdfLines --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes fdf_id,source,batch_number,yield_kl_t,sample_weight_mg,spectrum_id,peak_area_ratio,mass_fraction_percent,specific_gravity,mass_concentration_g_l,suspension_powder_weight_g,suspension_spectrum_id,suspension_peak_area_ratio,suspension_mass_fraction_percent,sort,user_id
```

#### 半成品检测记录2（乳油、可溶液剂副指标检验原始记录）字段

**主表表名：** iqc_ldf（半成品副指标检测记录主表）

| 字段 | 类型 | 说明 |
|------|------|------|
| contract_id | integer | 关联合同（主表） |
| product_id | integer | 产品（关联 mat_items） |
| name | string | 产品名称（冗余或未关联时） |
| code | string | 检验编号 |
| customer_trademark | string | 客户(商标) |
| sample_color | string | 样品颜色 |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |
 
**生成模型**

```bash
rails g model Iqc::Ldf contract_id:integer product_id:integer name:string code:string customer_trademark:string sample_color:string user_id:integer updater_id:integer py:string
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Iqc::Ldfs --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes contract_id,product_id,name,code,customer_trademark,sample_color,user_id,updater_id,py
```

**副指标检测明细表**（iqc_ldf_lines，关联半成品检测记录2）

| 字段 | 类型 | 说明 |
|------|------|------|
| ldf_id | references | 半成品检测记录2 |
| inspection_date | date | 日期 |
| source | string | 来源 |
| batch_number | string | 批号 |
| ph_value | decimal | PH(酸/碱度) |
| specific_gravity_g_ml | decimal | 比重(g/mL) |
| moisture_percent | decimal | 水分(%) |
| flash_point_c | decimal | 闪点(°C) |
| viscosity | string | 粘度 |
| dispersion_stability_20_200 | string | 分散稳定性(20/200倍)（如：合格） |
| foam_retention_ml | string | 持泡性(mL) |
| pourability | string | 倾倒性 |
| sort | integer | 行序 |
| user_id | integer | 创建人 |

**生成模型**

```bash
rails g model Iqc::LdfLine ldf_id:references inspection_date:date source:string batch_number:string ph_value:decimal specific_gravity_g_ml:decimal moisture_percent:decimal flash_point_c:decimal viscosity:string dispersion_stability_20_200:string foam_retention_ml:string pourability:string sort:integer user_id:integer
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Iqc::LdfLines --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes ldf_id,inspection_date,source,batch_number,ph_value,specific_gravity_g_ml,moisture_percent,flash_point_c,viscosity,dispersion_stability_20_200,foam_retention_ml,pourability,sort,user_id
```

---

## 五、包装与成品质检

### 5.1 包装

| 表单名称 | 用途 | 建议字段 | 备注 |
|----------|------|----------|------|
| 包装记录 | 包装生产记录 | 排产单号、批次、成品、包装数量、包材消耗、操作人、日期 | 包装环节；可从返工进入 |
| 产品包装细节交接单 | 液体产品生产与包装细节交接 | 交接单编号、时间、制单人、公司、合同号、产品、签订时间、数量、规格、瓶明细（订瓶日期、灌装规格、瓶厂型号、数量、瓶盖封口、瓶身、防溢圈/量杯、备注、瓶厂资料）、标(标签)说明、箱说明、包装要求、留样与样品要求、分发说明 | 仓库与生产一式两份 |
| 包装线操作记录（液体制剂包装操作原始记录） | 包装线当日操作与设备、人员记录 | 日期、天气、气温、包装产品名称、客户或商标、计划数量/件数、批号、半成品批号、比重、包装规格、单瓶净重、灌装调试、正式灌装起止时间、本班包装件数、设备状态（贴标机/灌装机/旋盖机/封口机/喷码机等）、各岗位操作人、线长、其他事项 | 包装线原始记录 |
| 包装线抽样检测记录 | 包装线抽样检验原始记录 | 产品名称、批号、送检单位、检验依据、批数量、请检日期、报告日期、报告编号、记录（抽样/检测数据）、结论、复核人、检验人 | 包装线抽样检验，可关联 FQC |
| 包装不合格处置 | 包装不合格时的处置 | 关联包装记录、不合格描述、处置（返工/让步接收/业务确认） | 与业务确认、让步接收衔接 |

#### 产品包装细节交接单（9-1）字段

**主表表名：** mfg_pkg_handovers（产品包装细节交接单主表）

| 字段 | 类型 | 说明 |
|------|------|------|
| contract_id | integer | 关联合同（主表） |
| form_date | string | 时间 |
| code | string | 编号 |
| preparer_id | integer | 制单人（关联 users） |
| client_id | integer | 公司 |
| contract_id | string | 合同号 |
| product_id | integer | 产品（关联 mat_items） |
| product_name | string | 产品（冗余或未关联时） |
| sign_date | string | 签订时间 |
| qty | string | 数量 |
| specification | string | 规格 |
| bottle_contract_id | integer | 瓶合同 |
| bottle_info | text | 瓶信息 |
| label_contract_id | integer | 标合同 
| label_info  | text | 标-描述（卷标规格、覆膜、数量等） |
| box_contract_id | integer | 箱合同|
| box_info | text | 箱-描述（纸箱规格、垫片、数量等） |
| remark | text | 备注 | 
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |

**生成模型**

```bash
rails g model Mfg::PkgHandover contract_id:integer form_date:string code:string preparer_id:integer client_id:integer contract_code:string product_id:integer product_name:string sign_date:string qty:string specification:string bottle_contract_id:integer bottle_info:text label_contract_id:integer label_info:text box_contract_id:integer box_info:text remark:text user_id:integer updater_id:integer py:string
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Mfg::PkgHandovers --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes contract_id,form_date,code,preparer_id,client_id,contract_code,product_id,product_name,sign_date,qty,specification,bottle_contract_id,bottle_info,label_contract_id,label_info,box_contract_id,box_info,remark,user_id,updater_id,py
```


**主表表名：** mfg_pkg_line（包装线操作记录主表）

| 字段 | 类型 | 说明 |
|------|------|------|
| contract_id | integer | 关联合同（主表） |
| pkg_handover_id | integer | 关联产品包装细节交接单 |
| line_id | integer | 关联产品线 |
| record_date | date | 日期 |
| weather | string | 天气 |
| temperature | string | 气温 |
| product_id | integer | 产品（关联 mat_items） |
| name | string | 包装产品名称（冗余或未关联时） |
| code | string | 编号 |
| customer_trademark_name | string | 客户或商标名称 |
| planned_total_qty_kl | string | 计划包装总数量(KL) |
| planned_total_pieces | integer | 计划包装总件数 |
| packaging_batch_number | string | 包装批号 |
| semi_finished_batch_number | string | 包装用半成品批号 |
| specific_gravity | decimal | 比重(g/mL) |
| packaging_spec | string | 包装规格 |
| net_weight_per_bottle | string | 单瓶(桶)净重 |
| empty_bottle_weight | string | 空瓶(桶)重量 |
| filling_range | string | 灌装范围 |
| standard_weight_per_bottle | string | 单瓶(桶)标准重量 |
| standard_weight_per_box | string | 单箱标准重量 |
| packaging_key_points | text | 包装注意要点 |
| formal_filling_start_time | string | 正式灌装开始时间 |
| formal_filling_end_time | string | 正式灌装结束时间 |
| packages_this_shift | integer | 本班包装件数 |
| filling_debug_air_pressure | string | 灌装调试-气压 |
| filling_debug_temperature | string | 灌装调试-温度 |
| filling_debug_horizontal_temp | string | 灌装调试-横向温度 |
| filling_debug_vertical_temp | string | 灌装调试-纵向温度 |
| filling_debug_notes | string | 灌装调试-其它说明 |
| labeling_machine_result | boolean | 贴标机（正常=true/异常=false） |
| filling_machine_result | boolean | 灌装机（正常=true/异常=false） |
| capping_machine_result | boolean | 旋盖机（正常=true/异常=false） |
| sealing_machine_result | boolean | 封口机（正常=true/异常=false） |
| coding_machine_result | boolean | 喷码机（正常=true/异常=false） |
| shrink_film_machine_result | boolean | 缩膜机（正常=true/异常=false） |
| packing_machine_result | boolean | 打包机（正常=true/异常=false） |
| operator_info | string | 操作人 |
| line_foreman_id | integer | 本包装线线长 |
| other | text | 其他事项记载 |
| remark | text | 备注 |
| user_id | integer | 创建人 |

**生成模型**

```bash
rails g model Mfg::PkgLine contract_id:integer pkg_handover_id:integer line_id:integer record_date:date weather:string temperature:string product_id:integer name:string code:string customer_trademark_name:string planned_total_qty_kl:string planned_total_pieces:integer packaging_batch_number:string semi_finished_batch_number:string specific_gravity:decimal packaging_spec:string net_weight_per_bottle:string empty_bottle_weight:string filling_range:string standard_weight_per_bottle:string standard_weight_per_box:string packaging_key_points:text formal_filling_start_time:string formal_filling_end_time:string packages_this_shift:integer filling_debug_air_pressure:string filling_debug_temperature:string filling_debug_horizontal_temp:string filling_debug_vertical_temp:string filling_debug_notes:string labeling_machine_result:boolean filling_machine_result:boolean capping_machine_result:boolean sealing_machine_result:boolean coding_machine_result:boolean shrink_film_machine_result:boolean packing_machine_result:boolean operator_info:string line_foreman_id:integer other:text remark:text user_id:integer
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Mfg::PkgLines --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes contract_id,pkg_handover_id,line_id,record_date,weather,temperature,product_id,name,code,customer_trademark_name,planned_total_qty_kl,planned_total_pieces,packaging_batch_number,semi_finished_batch_number,specific_gravity,packaging_spec,net_weight_per_bottle,empty_bottle_weight,filling_range,standard_weight_per_bottle,standard_weight_per_box,packaging_key_points,formal_filling_start_time,formal_filling_end_time,packages_this_shift,filling_debug_air_pressure,filling_debug_temperature,filling_debug_horizontal_temp,filling_debug_vertical_temp,filling_debug_notes,labeling_machine_result,filling_machine_result,capping_machine_result,sealing_machine_result,coding_machine_result,shrink_film_machine_result,packing_machine_result,operator_info,line_foreman_id,other,remark,user_id
```

 
#### 包装线抽样检测记录字段

**主表表名：** iqc_pkg（包装线抽样检测记录主表）

| 字段 | 类型 | 说明 |
|------|------|------|
| contract_id | integer | 关联合同（主表） |
| product_id | integer | 产品（关联 mat_items） |
| name | string | 产品名称（冗余或未关联时） |
| code | string | 报告编号 |
| batch_number | string | 批号 |
| submitting_unit | string | 送检单位 |
| inspection_basis | string | 检验依据 |
| batch_qty | string | 批数量 |
| request_inspection_date | date | 请检日期 |
| report_date | date | 报告日期 |
| record_content | text | 记录（抽样/检测数据，多行文本或结构化数据） |
| conclusion | string | 结论 |
| remark | text | 备注 |
| reviewer_id | integer | 复核人（关联 users） |
| inspector_id | integer | 检验人（关联 users） |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |

**生成模型**

```bash
rails g model Iqc::Pkg contract_id:integer product_id:integer name:string code:string batch_number:string submitting_unit:string inspection_basis:string batch_qty:string request_inspection_date:date report_date:date record_content:text conclusion:string remark:text reviewer_id:integer inspector_id:integer user_id:integer updater_id:integer py:string
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Iqc::Pkgs --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes contract_id,product_id,name,code,batch_number,submitting_unit,inspection_basis,batch_qty,request_inspection_date,report_date,record_content,conclusion,remark,reviewer_id,inspector_id,user_id,updater_id,py
```

### 5.2 抽检与最终处置

| 表单名称 | 用途 | 建议字段 | 备注 |
|----------|------|----------|------|
| 成品抽检单（FQC） | 包装后抽检 | 排产单号、批次、抽检数量、检测项目、结果、合格/不合格、检验人、日期 | 不合格→业务确认 |
| 业务确认单 | 不合格品业务决策 | 抽检单/不合格单号、产品、批次、数量、不合格描述、业务决策（让步接收/退货/报废等）、确认人、日期 | 抽检或包装不合格后 |
| 让步接收单（成品） | 成品让步放行 | 业务确认单号、产品、批次、数量、让步条件、审批人、日期 | 可进入发货 |
| 不合格评审处置单（成品） | 成品不合格处置 | 抽检单号、产品、批次、数量、描述、处置（返工/报废/让步等）、审批人、日期 | 与业务确认、让步接收配合 |

---

## 六、入库与发货

| 表单名称 | 用途 | 建议字段 | 备注 |
|----------|------|----------|------|
| 生产车间入库数量记录（车间生产计划及完成情况日报） | 车间当日生产计划与实际完成数量 | 日报日期、车间名称、明细（机长/组长、产品名称、规格、时间段、工时、计划生产数量、实际生产数量、用工人数、未完成说明） | 实际生产数量即车间入库数量依据，可关联成品入库单 |
| 成品入库单 | 成品入库 | 入库单号、排产单号、产品、批次、数量、货位、入库人、日期 | 合格或让步接收后入库 |
| 进仓通知单 | 通知对方按单送货至指定仓库 | 收件方、物流费用与条件（卸货费/最低收费/进门费/夜间加收等）、谨记事项（MSDS/现金/包材限制）、进仓编号、送货截止时间、仓库名称与地址、联系人及电话、发出公司、发出日期、产品明细（订单号、产品名、数量、包装、件数） | 客户/物流进仓凭证 |
| 解运单（解运清单） | 发货解运清单、随货凭证 | 单号、日期、发货方、收货单位、收货联系人、电话、送货地址、产品明细（产品名称、包装规格、件数、净重、价格、金额）、承运人/车号、收货盖章签字、审批/制单、联单说明 | 多联：存根、财务开票、收货回执、收货留存、仓库记帐、出门证 |
| 发货计划表 | 发货计划与进仓安排 | 计划标识、明细（序号、计划发货日期、要求进仓日期、客户、合同号、品名、数量吨/千升、规格、外箱尺寸、跟单员、件数、进仓地址、是否备齐、备注/其他要求、进仓单、体积检测、毛重检测） | 可关联进仓通知单、解运单 |
| 每日发货记录 | 当日发货明细与用车、进仓安排 | 发货日期、明细（用车情况、直接件数/吨/备注、进合要求、客户、合同号、品名、数量、规格、外箱尺寸、跟单员、件数、进仓地址、备注/其他要求、进仓费、体积、毛重刻单） | 按日记录，可关联发货计划、解运单 |
| 发货单/出库单 | 销售发货 | 发货单号、订单号、客户、产品、数量、批次、发货日期、经办人 | 流程终点 |
| 发货确认单 | 发货签收确认 | 发货单号、实发数量、签收人、签收日期、物流信息 | 用于闭环与对账 |

#### 生产车间入库数量记录（车间生产计划及完成情况日报）字段
 

**生产明细表**（mfg_actual，关联生产车间入库数量记录）

| 字段 | 类型 | 说明 |
|------|------|------|
| leader | string | 机长或组长 |
| product_id | integer | 产品（关联 mat_items） |
| date | date | 日期 |
| name | string | 产品名称（冗余或未关联时） |
| code | string | 编号 |
| specification | string | 规格（如：1L×10瓶、5L×4桶） |
| spec | string | 单个规格 如：1L |
| qty | integer | 单位数量 |
| unit | string | 单位 |
| time_start | datetime | 时间段起（如：7:40） |
| time_end | datetime | 时间段止（如：17:30） |
| hour | decimal | 工时 |
| planned_production_qty | string | 计划生产数量 |
| actual_production_qty | decimal | 实际生产数量（数值） |
| actual_production_unit | string | 实际生产数量单位（箱/桶等） |
| worker_count | integer | 用工人数 |
| uncompleted_remark | string | 未完成计（未完成说明） |
| remark | text | 未完成计（未完成说明） |
| sort | integer | 行序 |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |

**生成模型**

```bash
rails g model Mfg::Actual leader:string product_id:integer date:date name:string code:string specification:string spec:string qty:integer unit:string time_start:datetime time_end:datetime hour:decimal planned_production_qty:string actual_production_qty:decimal actual_production_unit:string worker_count:integer uncompleted_remark:string remark:text sort:integer user_id:integer updater_id:integer py:string
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Mfg::Actuals --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes leader,product_id,date,name,code,specification,spec,qty,unit,time_start,time_end,hour,planned_production_qty,actual_production_qty,actual_production_unit,worker_count,uncompleted_remark,remark,sort,user_id,updater_id,py
```

#### 进仓通知单字段

**主表表名：** wms_notices（进仓通知单主表）

| 字段 | 类型 | 说明 |
|------|------|------|
| contract_id | integer | 关联合同（主表） |
| recipient | string | 收件方（如：南通金陵） |
| issuing_company | string | 发出公司（如：深圳精禾） |
| issue_date | date | 发出日期 |
| total_pieces | integer | 合计数量 |
| unloading_fee_per_cbm | string | 卸货费（如：80/方） |
| minimum_charge_per_shipment | string | 最低收费（如：500/票） |
| entry_fee_per_vehicle | string | 进门费（如：100/车） |
| nighttime_surcharge_note | text | 夜间卸货进仓费说明（如：17:00~20:00 加收30%，无特殊情况取消加班收货） |
| dangerous_goods_vehicle_fee | string | 危险品用普货车加费（如：300/车） |
| box_truck_surcharge_note | string | 厢式车、高栏车加费说明（如：加收30%卸货费） |
| important_notes | text | 谨记事项（MSDS、现金支付、包材限制等） |
| warehousing_number | string | 进仓号码 |
| delivery_deadline | datetime | 送货截止时间（务必送达时间） |
| warehouse_name | string | 仓库名称 |
| warehouse_address | text | 仓库地址（含门卫/换单说明） |
| contact_person | string | 联系人 |
| contact_phone | string | 电话 |
| contact_hours | string | 联系/收货时间（如：7:30~16:30） |
| dangerous_goods_receiving_note | string | 危险品仓库收货时间说明（如：9:00~17:00） |
| remarks_contact | string | 有疑问联系（如：武小姐 0755-232xxx） |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |

**生成模型**

```bash
rails g model Wms::Notice contract_id:integer recipient:string issuing_company:string issue_date:date total_pieces:integer unloading_fee_per_cbm:string minimum_charge_per_shipment:string entry_fee_per_vehicle:string nighttime_surcharge_note:text dangerous_goods_vehicle_fee:string box_truck_surcharge_note:string important_notes:text warehousing_number:string delivery_deadline:datetime warehouse_name:string warehouse_address:text contact_person:string contact_phone:string contact_hours:string dangerous_goods_receiving_note:string remarks_contact:string user_id:integer updater_id:integer py:string
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Wms::Notices --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes contract_id,recipient,issuing_company,issue_date,total_pieces,unloading_fee_per_cbm,minimum_charge_per_shipment,entry_fee_per_vehicle,nighttime_surcharge_note,dangerous_goods_vehicle_fee,box_truck_surcharge_note,important_notes,warehousing_number,delivery_deadline,warehouse_name,warehouse_address,contact_person,contact_phone,contact_hours,dangerous_goods_receiving_note,remarks_contact,user_id,updater_id,py
```

**进仓通知产品明细表**（wms_notice_lines，关联进仓通知单）

| 字段 | 类型 | 说明 |
|------|------|------|
| notice_id | references | 进仓通知单 |
| order_no | string | 订单号 |
| product_id | integer | 产品（关联 mat_items） |
| product_name | string | 产品名（冗余或未关联时） |
| qty | string | 数量 |
| qty_unit | string | 数量单位（如：升） |
| packaging_note | string | 包装（如：详情见合同） |
| pieces | integer | 件数（如：箱数） |
| sort | integer | 行序 |
| user_id | integer | 创建人 |
 

**生成模型**

```bash
rails g model Wms::NoticeLine notice_id:references order_no:string product_id:integer product_name:string qty:string qty_unit:string packaging_note:string pieces:integer sort:integer user_id:integer
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Wms::NoticeLines --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes notice_id,order_no,product_id,product_name,qty,qty_unit,packaging_note,pieces,sort,user_id
```

#### 解运单（解运清单）字段

**主表表名：** tms_orders（解运单主表）

| 字段 | 类型 | 说明 |
|------|------|------|
| contract_id | integer | 关联合同（主表） |
| document_number | string | 单号 |
| document_date | date | 日期 |
| company_name | string | 发货方/公司名称（如：南通金陵农化有限公司） |
| reference_code | string | 参考代码（如：订单号/合同号 GR2S11104/05/06/01） |
| consignee_name | string | 收货单位 |
| consignee_contact | string | 收货联系人 |
| consignee_phone | string | 电话 |
| delivery_address | text | 送货地址 |
| carrier_id_no | string | 承运人身份证号 |
| vehicle_no | string | 车号 |
| carrier_name | string | 承运人 |
| consignee_stamp_note | string | 收货单位(盖章) |
| consignee_signature_note | string | 收货人(签字) |
| approved_id | integer | 审批（关联 users） |
| prepared_id | integer | 制单（关联 users） |
| contract_note | string | 注（如：双方未签订书面合同时本单据为双方买卖合同） |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |

**生成模型**

```bash
rails g model Tms::Order contract_id:integer document_number:string document_date:date company_name:string reference_code:string consignee_name:string consignee_contact:string consignee_phone:string delivery_address:text carrier_id_no:string vehicle_no:string carrier_name:string consignee_stamp_note:string consignee_signature_note:string approved_id:integer prepared_id:integer contract_note:string user_id:integer updater_id:integer py:string
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Tms::Orders --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes contract_id,document_number,document_date,company_name,reference_code,consignee_name,consignee_contact,consignee_phone,delivery_address,carrier_id_no,vehicle_no,carrier_name,consignee_stamp_note,consignee_signature_note,approved_id,prepared_id,contract_note,user_id,updater_id,py
```

**解运单明细表**（tms_order_lines，关联解运单）

| 字段 | 类型 | 说明 |
|------|------|------|
| shipping_order_id | references | 解运单 |
| product_id | integer | 产品（关联 mat_items） |
| product_name | string | 产品名称（冗余或未关联时） |
| packaging_spec | string | 包装规格（如：1L×10瓶） |
| pieces_capitalized | string | 件数(大写)（如：贰佰件） |
| pieces | integer | 件数（数值，可选） |
| net_weight_display | string | 净重显示（如：2kL、1kL） |
| net_weight_ton | decimal | 净重(吨)（可选） |
| unit_price | decimal | 价格 |
| amount | decimal | 金额 |
| sort | integer | 行序 |
| user_id | integer | 创建人 |

**生成模型**

```bash
rails g model Tms::OrderLine shipping_order_id:references product_id:integer product_name:string packaging_spec:string pieces_capitalized:string pieces:integer net_weight_display:string net_weight_ton:decimal unit_price:decimal amount:decimal sort:integer user_id:integer
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Tms::OrderLines --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes shipping_order_id,product_id,product_name,packaging_spec,pieces_capitalized,pieces,net_weight_display,net_weight_ton,unit_price,amount,sort,user_id
```

主表可增加 total_pieces、total_net_weight、total_amount（合计，或由明细汇总）。

#### 发货计划表字段

**主表表名：** tms_plans（发货计划表主表）
 
| 字段 | 类型 | 说明 |
|------|------|------|
| contract_id | 合同 | 发货计划表 |
| code | string | 序号/编码（如：2-1） |
| name | string | 计划发货日期（如：1-29开始配/26、1-29下午100+140/车） |
| date | date | 计划发货日期 |
| required_warehouse_entry_date | string | 要求进仓日期（如：1-2号之前交齐最后1万件） |
| client_id | integer | 客户 |
| client_name | string | 客户 |
| contract_id | integer | 合同 |
| contract_code | string | 合同号 |
| product_id | integer | 产品（关联 mat_items） |
| product_name | string | 品名（冗余或未关联时） |
| qty | decimal | 数量(吨/千升) |
| specification | string | 规格（如：1L*12瓶、吨/桶100个） |
| outer_box_dimensions | string | 外箱尺寸长*宽*高(cm)（如：380x286x245） |
| merchandiser_id | string | 跟单员 |
| pieces | string | 件数（如：2万+2万、100、8000） |
| warehouse_address | text | 进仓地址（含门号、导航说明等） |
| is_ready | string | 是否备齐（是/否、在做） |
| kind_id | integer | 类别 |
| remark | text | 备注/其他要求 |
| warehouse_entry_note | string | 进仓费 |
| volume_inspection | decimal | 体积检测 |
| gross_weight_inspection | decimal | 毛重检测 |
| sort | integer | 行序 |
| user_id | integer | 创建人 |
| updater_id | integer | 更新人 |
| py | string | 拼音/检索 |
| status | integer | 发货状态 0 未发，1 已发 |
| ship_date | date | 发货日期 |
| shiper_id | date | 发货人 |
| vehicle_usage | string | 用车情况（如：1年-赵继辉、3年-林中军刘2） |
| direct_info | string | 直接（件数/吨/备注，如：2520件、26吨/、最后一款甲维拉已经灌浆、余的16件） |

**生成模型**

```bash
rails g model Tms::Plan contract_id:integer code:string name:string date:date required_warehouse_entry_date:string client_id:integer client_name:string contract_code:string product_id:integer product_name:string qty:decimal specification:string outer_box_dimensions:string merchandiser_id:string pieces:string warehouse_address:text is_ready:string kind_id:integer remark:text warehouse_entry_note:string volume_inspection:decimal gross_weight_inspection:decimal sort:integer user_id:integer updater_id:integer py:string status:integer ship_date:date shiper_id:integer vehicle_usage:string direct_info:string
```

**生成接口**

```bash
rails g api:v1:scaffold_controller Tms::Plans --skip-template-engine --skip-assets --skip-helper --skip-resources --skip-routes --skip-test --attributes contract_id,code,name,date,required_warehouse_entry_date,client_id,client_name,contract_code,product_id,product_name,qty,specification,outer_box_dimensions,merchandiser_id,pieces,warehouse_address,is_ready,kind_id,remark,warehouse_entry_note,volume_inspection,gross_weight_inspection,sort,user_id,updater_id,py,status,ship_date,shiper_id,vehicle_usage,direct_info
```

---

## 七、辅助与主数据（可选）

| 表单名称 | 用途 | 建议字段 |
|----------|------|----------|
| 客户主数据 | 客户信息 | 客户编号、名称、联系人、地址、结算方式 |
| 供应商主数据 | 供应商信息 | 供应商编号、名称、联系人、物料范围、资质 |
| 产品/物料主数据 | 产品与物料 | 编号、名称、规格、单位、类型（成品/半成品/原料/包材） |
| 配方/BOM主数据 | 配方库 | 产品、版本、组分、用量、工艺说明 |
| 检验项目主数据 | 质检项目 | 项目编号、名称、标准、检验方法 |
| 指标项目主数据（spec_items） | 交接单/合同指标选项 | 项目编号、项目名称、英文名、排序、备注；供交接单指标要求明细选择 |

---

## 八、流程与表单对应关系简表

| 流程节点 | 主要表单 | 分支/异常 |
|----------|----------|-----------|
| 订单 | 销售订单 | 取消→订单取消记录 |
| 配方确认 | 配方确认单 | 无配方→研发试验单、检测报告（研发）、配方调整申请 |
| 采购 | 采购订单（原药/助剂）、采购订单（包材等） | - |
| 仓库收货 | 收货单 | - |
| 验收 | 来料检验单（IQC） | 不合格→不合格处置单→退货单 / 降级使用审批单 |
| 生产计划 | 生产计划、排产单 | - |
| 排单 | 排产单 | - |
| 配制 | 配料单、配制记录 | 不合格/返工→返工单 |
| 检测（过程） | 过程检验单（IPQC） | 不合格→返工；质量指标不合格→让步接收单（过程） |
| 包装调机 | 包装调机记录 | 不通过→继续调机 |
| 首瓶确认 | 首瓶确认单 | 不通过→包装调机；返工可进入 |
| 包装 | 包装记录 | 不合格→包装不合格处置→业务确认/让步 |
| 抽检 | 成品抽检单（FQC） | 不合格→业务确认 |
| 业务确认 | 业务确认单 | →让步接收单（成品）或其它处置 |
| 让步接收 | 让步接收单（过程/成品） | →生产计划特殊标识或直接发货 |
| 返工 | 返工单 | →配制 / 首瓶确认 / 包装 |
| 发货 | 发货单、发货确认单 | - |

---

## 九、表单清单汇总（按模块）

- **CRM**：销售订单、订购合同、订单取消记录、交接单、配方确认单、配方交接单、研发试验单、检测报告（研发）、配方调整申请、**客户、客户联系人、客户收货地址、报价**  
- **采购**：采购订单（原药/包材）、原料采购信息表（购销合同）、纸箱采购合同表、包装瓶采购合同、采购合同（可选）、**供应商、供应商联系人**  
- **来料**：收货单、来料检验单（IQC）、原料检验原始记录、不合格处置单（来料）、退货单、降级使用审批单  
- **生产计划**：生产计划、计划排产表、排产记录、一周排产记录表（统计展示）、排产单  
- **生产执行**：配料单、配料表、配料操作记录表、配制记录、返工单、过程检验单（IPQC）、半成品检测记录、半成品检测记录2、包装调机记录、首瓶确认单、让步接收单（过程）  
- **包装与成品**：包装记录、产品包装细节交接单、包装线操作记录、包装线抽样检测记录、包装不合格处置、成品抽检单（FQC）、业务确认单、让步接收单（成品）、不合格评审处置单（成品）  
- **仓储与发货**：生产车间入库数量记录、成品入库单、进仓通知单、解运单、发货计划表、每日发货记录、发货单、发货确认单、**仓库、库位**  
- **主数据（可选）**：客户、客户联系人、客户收货地址、**开票信息**（关联客户与供应商）、供应商、供应商联系人、产品/物料、配方/BOM、检验项目、指标项目（spec_items）、仓库、库位  

**具体表单主表表名一览（带模块前缀、精简命名）：**

| 模块 | 表单名称 | 主表表名 |
|------|----------|----------|
| CRM | 订购合同（销售订单合同） | crm_contracts |
| CRM | 交接单（外贸货物交接单） | crm_handovers |
| CRM | 配方交接单 | crm_recipe_handovers |
| CRM | 客户 | crm_clients |
| CRM | 客户联系人 | crm_contacts |
| CRM | 客户收货地址 | crm_addresses |
| CRM | 报价 | crm_quotations |
| 通用 | 开票信息（关联客户/供应商） | crm_invoice |
| 采购 | 原料采购信息表（购销合同） | pur_contracts |
| 采购 | 纸箱采购合同表 | pur_cartons |
| 采购 | 供应商 | pur_suppliers（已存在，可映射 mat_suppliers） |
| 采购 | 供应商联系人 | pur_contacts |
| 来料 | 原料检验原始记录 | iqc_raw |
| 生产计划 | 计划排产表 / 排产记录 | plan_schedules / plan_records |
| 生产执行 | 配料表（液体制剂配料操作票） | mfg_batching |
| 生产执行 | 配料操作记录表 | mfg_batch_ops |
| 生产执行 | 半成品检测记录1 / 半成品检测记录2 | mfg_semi1 / mfg_semi2 |
| 包装与成品 | 产品包装细节交接单 | pkg_handovers |
| 包装与成品 | 包装线操作记录 | pkg_line |
| 包装与成品 | 包装线抽样检测记录 | pkg_sampling |
| 仓储与发货 | 生产车间入库数量记录 | wh_reports |
| 仓储与发货 | 进仓通知单 | wh_notices |
| 仓储与发货 | 解运单 | ship_orders |
| 仓储与发货 | 发货计划表 | ship_plans |
| 仓储与发货 | 每日发货记录 | ship_daily |
| 主数据 | 仓库 | wh_warehouses（已存在，可映射 wms_warehouses） |
| 主数据 | 库位 | wh_locations（已存在，可映射 wms_locations） |

以上表单均可按此清单重新生成，不依赖系统已有表结构；实现时再按需要映射到现有 Mfg/Wms/Inv/Mat 等模块。



出入库的逻辑 
原料是合同签完就行了？什么时候原料入库？

发完货后需不需回执单？ 每个流程结束后自动