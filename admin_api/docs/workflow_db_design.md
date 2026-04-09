# 合同流程数据表设计

根据 `tab-workflow.vue` 和 `tab-workflow-log.vue` 的流程逻辑，整理出以下数据库表结构。

---

## 一、流程日志表（主表）

**表名建议：** `fm_contract_workflow_logs` 

用于存储每次节点确认产生的日志记录。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint (PK) | 主键 |
| contract_id | references | 关联合同（crm_contracts.id） |
| step_key | string | 节点标识，如 order、formula、inspect、test_qc 等 |
| step_label | string | 节点名称（冗余），如 订单、配方确认、验收 |
| operated_at | datetime | 操作时间 |
| operator_id | references | 操作人 ID（关联 users.id，可选） |
| operator_name | string | 操作人姓名（冗余，便于展示） |
| action | text | 操作/备注内容 |
| result | string | 节点结果（见下方枚举） |
| result_extra | jsonb/text | 扩展结果（如 rd_note 等，JSON 存储） |
| sort | integer | 排序（默认 0） |
| user_id | integer | 创建人 |
| created_at | datetime | 创建时间 |
| updated_at | datetime | 更新时间 |

### 节点结果 (result) 枚举

不同节点有不同的 result 取值：

| step_key | result 取值 | 说明 |
|----------|-------------|------|
| formula | existing / new | 现成配方 / 需研发试验 |
| inspect | pass / downgrade / reject | 合格 / 降级使用 / 不合格退回 |
| test_qc | pass / rework / concession | 合格 / 不合格返工 / 让步接收 |
| first_bottle | pass / redo | 通过 / 不通过重调 |
| sampling | pass / fail / concession | 合格 / 不合格 / 让步接收 |
| 其他 | - | 可为空或默认 completed |

---

## 二、流程状态表（可选）

**表名建议：** `fm_contract_workflow_states`

用于存储每个合同在各节点的当前状态，便于快速查询和展示。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint (PK) | 主键 |
| contract_id | references | 关联合同 |
| step_key | string | 节点标识 |
| status | string | 状态：pending / current / completed / failed |
| completed_at | datetime | 完成时间（status=completed 时） |
| result | string | 该节点最终结果（同日志表 result） |
| user_id | integer | 更新人 |
| created_at | datetime | 创建时间 |
| updated_at | datetime | 更新时间 |

**唯一约束：** `(contract_id, step_key)`

> 也可不建此表，通过日志表按时间倒序推导各节点最新状态。

---

## 三、节点定义表（可选，用于配置化）

**表名建议：** `fm_workflow_steps` 或使用 properties 表

若希望节点可配置，可单独建表；否则在代码中写死即可。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint (PK) | 主键 |
| key | string | 节点标识，唯一 |
| label | string | 节点名称 |
| description | text | 节点描述 |
| sort | integer | 主流程顺序 |
| flow_keys | jsonb | 主流程顺序数组，如 ["order","formula",...] |
| created_at | datetime | 创建时间 |
| updated_at | datetime | 更新时间 |

---

## 四、推荐最小实现

若先实现流程日志持久化，**只需创建流程日志表**：

```sql
-- 流程日志表
CREATE TABLE fm_contract_workflow_logs (
  id BIGSERIAL PRIMARY KEY,
  contract_id BIGINT NOT NULL REFERENCES crm_contracts(id) ON DELETE CASCADE,
  step_key VARCHAR(50) NOT NULL,
  step_label VARCHAR(100),
  operated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  operator_id BIGINT REFERENCES users(id),
  operator_name VARCHAR(100),
  action TEXT,
  result VARCHAR(50),
  result_extra JSONB,
  sort INT DEFAULT 0,
  user_id BIGINT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_workflow_logs_contract ON fm_contract_workflow_logs(contract_id);
CREATE INDEX idx_workflow_logs_operated ON fm_contract_workflow_logs(operated_at DESC);
```

---

## 五、前端对接字段映射

| 前端字段 | 数据库字段 |
|----------|------------|
| log.at | operated_at |
| log.operator | operator_name（或通过 operator_id 关联 users 取 name） |
| log.stepKey | step_key |
| log.stepLabel | step_label |
| log.action | action |
| confirmForm.completedAt | operated_at |
| confirmForm.operator | operator_name |
| confirmForm.remark | action |
| confirmForm.formulaResult | result |
| confirmForm.inspectResult | result |
| confirmForm.qcResult | result |
| confirmForm.bottleResult | result |
| confirmForm.samplingResult | result |
| confirmForm.rdNote | result_extra.rd_note |

---

## 六、流程图弹窗：节点与 position 说明

### 6.1 流程图节点数据是否需要存储？

**结论：通常不需要存储。**

| 数据类型 | 是否需要存储 | 说明 |
|----------|--------------|------|
| **节点定义**（id、key、label、position、edges） | 否 | 流程拓扑对所有合同一致，在代码中写死即可 |
| **节点状态**（status: pending/current/completed） | 是 | 每个合同不同，通过流程日志表或流程状态表存储 |
| **边的定义**（source、target、label） | 否 | 流程拓扑的一部分，与节点一起在代码中维护 |

**何时需要存储节点定义？**

- 需要**可配置流程**：不同业务类型不同流程图
- 需要**可视化编排**：后台拖拽设计流程
- 需要**多套流程模板**：如 A 产品线、B 产品线不同流程

若流程固定、所有合同共用同一套图，**保持当前做法（代码中写死）即可**。

---

### 6.2 position 如何定义？

`position` 是 Vue Flow 画布坐标系，用于决定节点在流程图中的位置。

**坐标系：**

- 单位：像素 (px)
- 原点 `(0, 0)`：画布左上角
- `x`：水平方向，从左到右递增
- `y`：垂直方向，从上到下递增
- 节点的 `position` 表示该节点**左上角**在画布中的坐标

**当前布局规律（参考 tab-workflow.vue）：**

| 区域 | x 范围 | y 步长 | 说明 |
|------|--------|--------|------|
| 主流程（竖排） | 约 140–180 | 约 80 | 主流程节点垂直排列 |
| 分支（左侧） | 0–120 | 约 80 | 如 return_s、downgrade、rd、test_rd |
| 分支（右侧） | 260–380 | 约 80 | 如 purchase、pack_m、raw_m、cancel |
| 节点间距 | - | 约 80 | 避免节点重叠，节点高度约 50–60px |

**定义建议：**

1. **固定布局**：在代码中维护 `baseNodesForChart`，position 按上述规律手动排布
2. **可配置布局**：若存库，可增加 `fm_workflow_steps` 或 `fm_workflow_nodes` 表：

| 字段 | 类型 | 说明 |
|------|------|------|
| key | string | 节点标识 |
| position_x | integer | 画布 x 坐标 |
| position_y | integer | 画布 y 坐标 |

**边的定义**：edges 同样可存到 `fm_workflow_edges` 表（source_key、target_key、label），用于可配置流程。

---

## 七、API 接口建议

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | /fm/contracts/:id/workflow_logs | 获取合同流程日志列表 |
| POST | /fm/contracts/:id/workflow_logs | 新增流程日志（节点确认时调用） |
| GET | /fm/contracts/:id/workflow_states | 获取合同各节点状态（若用状态表） |

---

## 八、流程数据示例

可直接使用的示例数据见：

- **JSON 格式**：`doc/workflow_data_example.json`（含 nodes、edges、logs、states、Vue Flow 格式）
- **SQL seed**：`doc/workflow_logs_seed.sql`（流程日志表插入示例）
