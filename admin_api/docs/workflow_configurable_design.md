# 可配置流程表结构设计

当需要支持多套流程、可视化编排或后台配置时，可采用如下表结构。

---

## 一、整体架构

```
workflow_templates (流程模板)
    ├── workflow_nodes (节点，按模板)
    │       └── workflow_node_results (节点可选结果，用于分支)
    └── workflow_edges (边，按模板)

fm_contracts (合同)
    └── workflow_template_id (可选，关联使用的流程模板)

fm_contract_workflow_logs (流程日志，已存在)
fm_contract_workflow_states (流程状态，可选)
```

---

## 二、流程模板表

**表名：** `workflow_templates`

用于定义多套流程（如：订购合同流程、简化流程、定制流程等）。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint (PK) | 主键 |
| code | string | 模板编码，唯一，如 `contract_full`、`contract_simple` |
| name | string | 模板名称，如「订购合同全流程」「订购合同简化流程」 |
| description | text | 描述 |
| main_step_keys | jsonb | 主流程节点顺序，如 `["order","formula","purchase",...]`，用于步骤条展示 |
| is_default | boolean | 是否默认模板 |
| sort | integer | 排序 |
| is_active | boolean | 是否启用 |
| user_id | integer | 创建人 |
| created_at | datetime | 创建时间 |
| updated_at | datetime | 更新时间 |

---

## 三、流程节点表

**表名：** `workflow_nodes`

存储每个模板下的节点定义，包含流程图中的 position。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint (PK) | 主键 |
| template_id | references | 关联 workflow_templates |
| key | string | 节点标识，模板内唯一，如 order、formula、inspect |
| label | string | 节点名称，如 订单、配方确认、验收 |
| description | text | 节点描述，用于确认弹窗 |
| position_x | integer | 画布 x 坐标（Vue Flow 用） |
| position_y | integer | 画布 y 坐标（Vue Flow 用） |
| sort | integer | 节点顺序 |
| has_result_options | boolean | 是否有分支结果（确认时需选择） |
| node_type | string | 节点类型，如 workflow、start、end（可扩展） |
| created_at | datetime | 创建时间 |
| updated_at | datetime | 更新时间 |

**唯一约束：** `(template_id, key)`

**position 说明：** 单位 px，原点在画布左上角。x 水平向右，y 垂直向下。节点左上角坐标。

---

## 四、节点结果选项表（分支配置）

**表名：** `workflow_node_results`

用于配置有分支的节点（如 formula、inspect、test_qc），每个结果对应下一步的 target 节点。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint (PK) | 主键 |
| template_id | references | 关联 workflow_templates |
| node_key | string | 所属节点 key |
| result_value | string | 结果值，如 existing、pass、reject、downgrade |
| result_label | string | 结果标签，如「现成配方」「合格」「不合格退回」 |
| target_key | string | 选择该结果后跳转的节点 key |
| sort | integer | 排序 |
| created_at | datetime | 创建时间 |
| updated_at | datetime | 更新时间 |

**唯一约束：** `(template_id, node_key, result_value)`

**示例：**

| node_key | result_value | result_label | target_key |
|----------|--------------|--------------|------------|
| formula | existing | 现成配方 | purchase |
| formula | new | 需研发试验 | rd |
| inspect | pass | 合格 | plan |
| inspect | downgrade | 降级使用 | downgrade |
| inspect | reject | 不合格退回 | return_s |
| test_qc | pass | 合格 | pack_setup |
| test_qc | rework | 不合格返工 | formulate |
| test_qc | concession | 让步接收 | pack_setup |
| first_bottle | pass | 通过 | packing |
| first_bottle | redo | 不通过重调 | pack_setup |
| sampling | pass | 合格 | ship |
| sampling | fail | 不合格 | biz_confirm |
| sampling | concession | 让步接收 | ship |

---

## 五、流程边表

**表名：** `workflow_edges`

定义节点之间的连接关系。

| 字段 | 类型 | 说明 |
|------|------|------|
| id | bigint (PK) | 主键 |
| template_id | references | 关联 workflow_templates |
| source_key | string | 源节点 key |
| target_key | string | 目标节点 key |
| label | string | 边的标签（可选），如「配方成熟」「不合格」 |
| result_value | string | 条件结果（可选），当 source 节点完成且 result 为该值时，走此边 |
| sort | integer | 排序 |
| created_at | datetime | 创建时间 |
| updated_at | datetime | 更新时间 |

**唯一约束：** `(template_id, source_key, target_key)` 或放宽为允许多边同源同目标（通过 result_value 区分）

**逻辑说明：**

- **无条件边**：`result_value` 为空，表示 source 完成后直接到 target
- **条件边**：`result_value` 有值，表示 source 完成且用户选择该 result 时，走此边到 target

**示例：**

| source_key | target_key | label | result_value |
|------------|------------|-------|--------------|
| order | formula | | |
| order | cancel | | |
| formula | purchase | 配方成熟 | existing |
| formula | rd | 无现成配方 | new |
| rd | test_rd | | |
| test_rd | rd | 不通过 | rework |
| test_rd | formula | 配方不成功 | fail |
| purchase | pack_m | | |
| purchase | raw_m | | |
| pack_m | warehouse | | |
| raw_m | warehouse | | |
| warehouse | inspect | | |
| inspect | return_s | 不合格 | reject |
| inspect | downgrade | 降级 | downgrade |
| inspect | plan | 合格 | pass |
| ... | ... | ... | ... |

---

## 六、合同关联流程模板（可选）

若不同合同使用不同流程模板，可在合同表增加字段：

**fm_contracts 表新增：**

| 字段 | 类型 | 说明 |
|------|------|------|
| workflow_template_id | references | 关联 workflow_templates，为空则用默认模板 |

---

## 七、流程日志与状态表关联

`fm_contract_workflow_logs` 和 `fm_contract_workflow_states` 的 `step_key` 与 `workflow_nodes.key` 对应。通过合同找到其 `workflow_template_id`，再从该模板的 nodes 中取 `step_label` 等信息。

---

## 八、建表 SQL

```sql
-- 流程模板
CREATE TABLE workflow_templates (
  id BIGSERIAL PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  main_step_keys JSONB DEFAULT '[]',
  is_default BOOLEAN DEFAULT false,
  sort INT DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  user_id BIGINT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 流程节点
CREATE TABLE workflow_nodes (
  id BIGSERIAL PRIMARY KEY,
  template_id BIGINT NOT NULL REFERENCES workflow_templates(id) ON DELETE CASCADE,
  key VARCHAR(50) NOT NULL,
  label VARCHAR(100) NOT NULL,
  description TEXT,
  position_x INT DEFAULT 0,
  position_y INT DEFAULT 0,
  sort INT DEFAULT 0,
  has_result_options BOOLEAN DEFAULT false,
  node_type VARCHAR(30) DEFAULT 'workflow',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (template_id, key)
);
CREATE INDEX idx_workflow_nodes_template ON workflow_nodes(template_id);

-- 节点结果选项（分支）
CREATE TABLE workflow_node_results (
  id BIGSERIAL PRIMARY KEY,
  template_id BIGINT NOT NULL REFERENCES workflow_templates(id) ON DELETE CASCADE,
  node_key VARCHAR(50) NOT NULL,
  result_value VARCHAR(50) NOT NULL,
  result_label VARCHAR(100),
  target_key VARCHAR(50),
  sort INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (template_id, node_key, result_value)
);
CREATE INDEX idx_workflow_results_template ON workflow_node_results(template_id);

-- 流程边
CREATE TABLE workflow_edges (
  id BIGSERIAL PRIMARY KEY,
  template_id BIGINT NOT NULL REFERENCES workflow_templates(id) ON DELETE CASCADE,
  source_key VARCHAR(50) NOT NULL,
  target_key VARCHAR(50) NOT NULL,
  label VARCHAR(100),
  result_value VARCHAR(50),
  sort INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
CREATE INDEX idx_workflow_edges_template ON workflow_edges(template_id);

-- 合同表增加流程模板关联（可选）
ALTER TABLE fm_contracts ADD COLUMN workflow_template_id BIGINT REFERENCES workflow_templates(id);
```

---

## 九、API 设计

| 方法 | 路径 | 说明 |
|------|------|------|
| GET | /api/v1/workflow/templates | 流程模板列表 |
| GET | /api/v1/workflow/templates/:id | 模板详情（含 nodes、edges、node_results） |
| POST | /api/v1/workflow/templates | 创建模板 |
| PUT | /api/v1/workflow/templates/:id | 更新模板 |
| GET | /api/v1/workflow/templates/:id/nodes | 节点列表 |
| POST | /api/v1/workflow/templates/:id/nodes | 新增节点 |
| PUT | /api/v1/workflow/templates/:id/nodes/:key | 更新节点（含 position） |
| GET | /api/v1/workflow/templates/:id/edges | 边列表 |
| POST | /api/v1/workflow/templates/:id/edges | 新增边 |
| GET | /api/v1/contracts/:id/workflow_definition | 获取合同使用的流程定义（nodes+edges+results，供前端 Vue Flow 使用） |

---

## 十、前端对接

从 API 获取 `workflow_definition` 后，转换为 Vue Flow 格式：

```js
// nodes: workflow_nodes -> Vue Flow nodes
nodes = nodes.map(n => ({
  id: n.key,
  type: 'workflow',
  position: { x: n.position_x, y: n.position_y },
  data: { key: n.key, label: n.label, status: 'pending' } // status 来自 contract workflow_states
}))

// edges: workflow_edges -> Vue Flow edges
edges = edges.map(e => ({
  id: `e-${e.source_key}-${e.target_key}${e.result_value ? '-' + e.result_value : ''}`,
  source: e.source_key,
  target: e.target_key,
  data: e.label ? { label: e.label } : undefined
}))
```

流程推进逻辑：根据当前节点完成时的 `result`，从 `workflow_edges` 或 `workflow_node_results` 查找下一节点 `target_key`，更新状态并写入流程日志。
