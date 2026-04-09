<template>
  <div class="workflow-log-tab">
    <div class="workflow-log-table-wrap">
      <table class="workflow-log-table">
        <thead>
          <tr>
            <th>时间</th>
            <th>操作人</th>
            <th>节点</th>
            <th>操作/备注</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(log, i) in processLogs" :key="i">
            <td>{{ log.at }}</td>
            <td>{{ log.operator }}</td>
            <td>{{ log.stepLabel }}</td>
            <td>{{ log.action }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, onMounted, watch } from 'vue'
  import { listContractWorkflowLogsApi } from '@/api/fm/workflow'

  const props = defineProps<{ contractId?: string | number }>()

  const processLogs = ref<
    Array<{
      at: string
      operator: string
      stepKey: string
      stepLabel: string
      action: string
    }>
  >([])

  const FALLBACK_LOGS = [
    {
      at: '2025-03-06 10:00',
      operator: '张三',
      stepKey: 'order',
      stepLabel: '订单',
      action: '创建合同，合同编号 HT20250306001'
    },
    {
      at: '2025-03-07 09:30',
      operator: '李四',
      stepKey: 'formula',
      stepLabel: '配方确认',
      action: '现成配方，走采购流程'
    },
    {
      at: '2025-03-08 14:00',
      operator: '王五',
      stepKey: 'purchase',
      stepLabel: '采购',
      action: '采购单已下达，预计 3 月 12 日到货'
    },
    {
      at: '2025-03-12 11:20',
      operator: '赵六',
      stepKey: 'warehouse',
      stepLabel: '仓库收货',
      action: '包材、原药已入库，质检待验'
    },
    {
      at: '2025-03-12 15:00',
      operator: '赵六',
      stepKey: 'inspect',
      stepLabel: '验收',
      action: '待验收（当前节点）'
    }
  ]

  async function loadLogs() {
    const cid = props.contractId
    if (!cid) {
      processLogs.value = [...FALLBACK_LOGS]
      return
    }
    try {
      const res = await listContractWorkflowLogsApi(cid)
      const logs = res?.data
      if (Array.isArray(logs) && logs.length > 0) {
        processLogs.value = logs
          .sort((a: any, b: any) => (b.sort ?? 0) - (a.sort ?? 0))
          .map((l: any) => ({
            at: (l.operated_at || '').slice(0, 16).replace('T', ' '),
            operator: l.operator_name || '',
            stepKey: l.step_key || '',
            stepLabel: l.step_label || '',
            action: l.action || ''
          }))
      } else {
        processLogs.value = [...FALLBACK_LOGS]
      }
    } catch {
      processLogs.value = [...FALLBACK_LOGS]
    }
  }

  onMounted(() => loadLogs())
  watch(
    () => props.contractId,
    () => loadLogs()
  )
</script>

<style scoped lang="scss">
  .workflow-log-tab {
    min-height: 200px;
  }

  .workflow-log-table-wrap {
    max-height: 400px;
    overflow: auto;
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 8px;
  }

  .workflow-log-table {
    width: 100%;
    font-size: 13px;
    border-collapse: collapse;
  }

  .workflow-log-table th,
  .workflow-log-table td {
    padding: 8px 12px;
    text-align: left;
    border-bottom: 1px solid var(--el-border-color-extra-light);
  }

  .workflow-log-table th {
    font-weight: 500;
    color: var(--el-text-color-secondary);
    background: var(--el-fill-color-light);
  }

  .workflow-log-table th:first-child {
    width: 140px;
  }

  .workflow-log-table th:nth-child(2) {
    width: 80px;
  }

  .workflow-log-table th:nth-child(3) {
    width: 90px;
  }

  .workflow-log-table tbody tr:last-child td {
    border-bottom: none;
  }
</style>
