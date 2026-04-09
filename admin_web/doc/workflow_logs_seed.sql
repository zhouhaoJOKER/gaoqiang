-- 流程日志表 seed 示例（假设 contract_id=1 已存在）
-- 表结构参考 workflow_db_design.md

INSERT INTO fm_contract_workflow_logs (contract_id, step_key, step_label, operated_at, operator_id, operator_name, action, result, result_extra, sort, user_id, created_at, updated_at) VALUES
(1, 'order', '订单', '2025-03-06 10:00:00', 1, '张三', '创建合同，合同编号 HT20250306001', NULL, NULL, 0, 1, NOW(), NOW()),
(1, 'formula', '配方确认', '2025-03-07 09:30:00', 2, '李四', '现成配方，走采购流程', 'existing', NULL, 1, 2, NOW(), NOW()),
(1, 'purchase', '采购', '2025-03-08 14:00:00', 3, '王五', '采购单已下达，预计 3 月 12 日到货', NULL, NULL, 2, 3, NOW(), NOW()),
(1, 'warehouse', '仓库收货', '2025-03-12 11:20:00', 4, '赵六', '包材、原药已入库，质检待验', NULL, NULL, 3, 4, NOW(), NOW()),
(1, 'inspect', '验收', '2025-03-12 15:00:00', 4, '赵六', '待验收（当前节点）', NULL, NULL, 4, 4, NOW(), NOW());
