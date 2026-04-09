# 单号配置与自动生成

项目支持可配置的单号生成逻辑，每个业务模块可单独配置规则，支持固定值、日期、序列号组合。

## 一、配置表结构

表名：`doc_number_rules`

| 字段             | 类型    | 说明                                            |
| ---------------- | ------- | ----------------------------------------------- |
| key              | string  | 唯一标识，如 `fm_contracts`、`crm_quotations`   |
| name             | string  | 规则名称，用于展示                              |
| format           | string  | 格式模板，支持占位符                            |
| current_sequence | integer | 当前序列号，默认 0                              |
| reset_period     | string  | 序号重置周期：`none` / `day` / `month` / `year` |
| last_date        | date    | 上次生成日期，用于按周期重置序号                |

## 二、格式占位符

### 2.1 固定值

格式中非占位符部分为固定值，直接输出。例如：`FM-`、`QT-`、`JH-`。

### 2.2 日期占位符

| 占位符       | 说明        | 示例     |
| ------------ | ----------- | -------- |
| `{YYYY}`     | 四位年份    | 2026     |
| `{YY}`       | 两位年份    | 26       |
| `{MM}`       | 两位月份    | 03       |
| `{DD}`       | 两位日期    | 13       |
| `{YYYYMMDD}` | 年月日      | 20260313 |
| `{YYMMDD}`   | 两位年+月日 | 260313   |
| `{YYYYMM}`   | 年月        | 202603   |
| `{YYMM}`     | 两位年+月   | 2603     |

### 2.3 序列号占位符

| 占位符    | 说明     | 示例                   |
| --------- | -------- | ---------------------- |
| `{seq}`   | 不补零   | 1, 2, 100              |
| `{seq:N}` | N 位补零 | `{seq:4}` → 0001, 0002 |

### 2.4 格式示例

| 格式                    | 生成示例           |
| ----------------------- | ------------------ |
| `FM-{YYMMDD}-{seq:4}`   | FM-260313-0001     |
| `QT-{YYYYMMDD}-{seq:6}` | QT-20260313-000001 |
| `JH{YYMM}{seq:3}`       | JH2603001          |
| `ORD-{seq}`             | ORD-1              |

## 三、序号重置周期

| 值      | 说明                    |
| ------- | ----------------------- |
| `none`  | 不重置，序列号持续递增  |
| `day`   | 按日重置，每天从 1 开始 |
| `month` | 按月重置，每月从 1 开始 |
| `year`  | 按年重置，每年从 1 开始 |

## 四、API 接口

### 4.1 生成单号（消耗序列）

生成下一个单号并更新序列。

```
POST /api/v1/doc_number_rules/generate
Content-Type: application/json

{ "key": "fm_contracts" }
```

响应示例：

```json
{
  "code": 200,
  "success": 1,
  "msg": "ok",
  "data": {
    "key": "fm_contracts",
    "code": "FM-260313-0001"
  }
}
```

### 4.2 预览单号（不消耗序列）

预览下一个单号，不更新序列，适用于表单预填等场景。

```
GET /api/v1/doc_number_rules/preview?key=fm_contracts
```

响应示例：

```json
{
  "code": 200,
  "success": 1,
  "msg": "ok",
  "data": {
    "key": "fm_contracts",
    "code": "FM-260313-0002"
  }
}
```

### 4.3 规则 CRUD

- `GET /api/v1/doc_number_rules` - 列表
- `GET /api/v1/doc_number_rules/:id` - 详情
- `POST /api/v1/doc_number_rules` - 创建
- `PUT /api/v1/doc_number_rules/:id` - 更新
- `DELETE /api/v1/doc_number_rules/:id` - 删除
- `POST /api/v1/doc_number_rules/batch_action` - 批量操作

## 五、模型接入

### 5.1 自动生成（创建时）

在模型中 `include DocNumberable` 并设置 `doc_number_key`，创建时若 `code` 为空则自动生成：

```ruby
class Fm::Contract < ApplicationRecord
  include DocNumberable
  self.doc_number_key = "fm_contracts"
  # ...
end
```

### 5.2 代码中调用

```ruby
# 生成下一个单号（消耗序列）
code = DocNumberService.next_number("fm_contracts")

# 或通过 Concern
code = DocNumberable.next_code("fm_contracts")

# 预览下一个单号（不消耗序列）
code = DocNumberService.preview("fm_contracts")
code = DocNumberable.preview_code("fm_contracts")
```

## 六、核心实现

### 6.1 生成流程

1. 根据 `key` 查找 `DocNumberRule`
2. 按 `reset_period` 判断是否需要重置序列
3. 序列号 +1
4. 按 `format` 替换占位符生成单号
5. 更新 `current_sequence` 和 `last_date`

### 6.2 并发安全

生成时使用 `lock!` 对规则记录加锁，保证同一 key 下序列号不重复。

### 6.3 相关文件

| 文件                                                    | 说明         |
| ------------------------------------------------------- | ------------ |
| `app/models/doc_number_rule.rb`                         | 规则模型     |
| `app/services/doc_number_service.rb`                    | 生成服务     |
| `app/models/concerns/doc_numberable.rb`                 | 模型 Concern |
| `app/controllers/api/v1/doc_number_rules_controller.rb` | API 控制器   |

## 七、初始化默认规则

执行：

```bash
bin/rails db:seed
```

或单独创建：

```bash
bin/rails runner "
DocNumberRule.find_or_create_by!(key: 'fm_contracts') do |r|
  r.name = 'FM合同单号'
  r.format = 'FM-{YYMMDD}-{seq:4}'
  r.reset_period = 'day'
  r.current_sequence = 0
end
"
```

## 八、为新模块添加单号

1. 在 `doc_number_rules` 中新增规则（key 建议与表名一致，如 `crm_quotations`）
2. 在对应模型中 `include DocNumberable` 并设置 `self.doc_number_key = "crm_quotations"`
