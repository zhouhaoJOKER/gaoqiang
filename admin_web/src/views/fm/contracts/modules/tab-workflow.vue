<template>
  <div class="workflow-steps-wrap">
    <div class="workflow-summary">
      <span class="summary-item"
        ><span class="dot dot-completed" />已完成 {{ completedCount }}/{{
          mainStepKeys.length
        }}</span
      >
      <span class="summary-item"><span class="dot dot-current" />进行中</span>
      <span class="summary-item"><span class="dot dot-pending" />待处理</span>
      <span class="summary-item"><span class="dot dot-failed" />异常/返工</span>
    </div>

    <!-- 流程步骤（主流程顺序） -->
    <div class="workflow-steps">
      <div
        v-for="(key, index) in mainStepKeys"
        :key="key"
        class="step-row"
        :class="[`step-row--${nodeStates[key] ?? 'pending'}`]"
      >
        <div class="step-indicator">
          <span v-if="nodeStates[key] === 'completed'" class="step-dot step-dot--completed">
            <ElIcon><Select /></ElIcon>
          </span>
          <span v-else-if="nodeStates[key] === 'current'" class="step-dot step-dot--current" />
          <span v-else class="step-dot step-dot--pending">{{ index + 1 }}</span>
          <span v-if="index < mainStepKeys.length - 1" class="step-line" />
        </div>
        <div class="step-body">
          <div class="step-header">
            <span class="step-label">{{ nodeMeta[key]?.label ?? key }}</span>
            <ElButton
              v-if="nodeStates[key] === 'current'"
              type="primary"
              size="small"
              class="step-confirm-btn"
              @click="onStepConfirm(key)"
            >
              确认
            </ElButton>
          </div>
          <div v-if="getStepLog(key).length" class="step-log-preview">
            <span v-for="(log, i) in getStepLog(key).slice(0, 2)" :key="i" class="step-log-line">
              {{ log.at }} {{ log.operator }} {{ log.action }}
            </span>
          </div>
        </div>
      </div>
    </div>

    <!-- 流程图弹窗 -->
    <ElDialog
      v-model="flowChartDialogVisible"
      title="流程图"
      width="90%"
      top="5vh"
      class="workflow-chart-dialog"
      destroy-on-close
      @opened="onFlowChartDialogOpened"
    >
      <div class="flow-chart-dialog-body">
        <VueFlow
          v-model:nodes="flowChartNodes"
          v-model:edges="flowChartEdges"
          :default-viewport="{ x: 0, y: 0, zoom: 0.85 }"
          :min-zoom="0.2"
          :max-zoom="1.5"
          fit-view-on-init
          :nodes-draggable="false"
          :nodes-connectable="false"
          :elements-selectable="false"
        >
          <Background pattern-color="#e5e7eb" :gap="16" />
          <template #node-workflow="slotProps">
            <WorkflowNode v-bind="slotProps" @confirm="onNodeConfirmInChart" />
          </template>
        </VueFlow>
      </div>
    </ElDialog>

    <!-- 确认弹窗（保留原有逻辑） -->
    <ElDialog
      v-model="confirmDialogVisible"
      :title="`${confirmNode?.label ?? ''} — 流程确认`"
      width="520px"
      :close-on-click-modal="false"
    >
      <div class="confirm-body">
        <div class="confirm-step-info">
          <div class="confirm-step-label">{{ confirmNode?.label }}</div>
          <div class="confirm-step-desc">{{ confirmNode?.description }}</div>
        </div>
        <ElForm ref="confirmFormRef" :model="confirmForm" label-width="80px" class="confirm-form">
          <ElFormItem label="完成日期" prop="completedAt">
            <ElDatePicker
              v-model="confirmForm.completedAt"
              type="date"
              placeholder="选择日期"
              style="width: 100%"
              value-format="YYYY-MM-DD"
            />
          </ElFormItem>
          <ElFormItem label="操作人">
            <ElInput v-model="confirmForm.operator" placeholder="操作人姓名" />
          </ElFormItem>
          <template v-if="confirmNode?.key === 'formula'">
            <ElFormItem label="配方状态">
              <ElRadioGroup v-model="confirmForm.formulaResult">
                <ElRadio value="existing">现成配方</ElRadio>
                <ElRadio value="new">需研发试验</ElRadio>
              </ElRadioGroup>
            </ElFormItem>
          </template>
          <template v-if="confirmNode?.key === 'inspect'">
            <ElFormItem label="验收结果">
              <ElRadioGroup v-model="confirmForm.inspectResult">
                <ElRadio value="pass">合格</ElRadio>
                <ElRadio value="downgrade">降级使用</ElRadio>
                <ElRadio value="reject">不合格退回</ElRadio>
              </ElRadioGroup>
            </ElFormItem>
          </template>
          <template v-if="confirmNode?.key === 'test_qc'">
            <ElFormItem label="检测结果">
              <ElRadioGroup v-model="confirmForm.qcResult">
                <ElRadio value="pass">合格</ElRadio>
                <ElRadio value="rework">不合格返工</ElRadio>
                <ElRadio value="concession">让步接收</ElRadio>
              </ElRadioGroup>
            </ElFormItem>
          </template>
          <template v-if="confirmNode?.key === 'first_bottle'">
            <ElFormItem label="确认结果">
              <ElRadioGroup v-model="confirmForm.bottleResult">
                <ElRadio value="pass">通过</ElRadio>
                <ElRadio value="redo">不通过重调</ElRadio>
              </ElRadioGroup>
            </ElFormItem>
          </template>
          <template v-if="confirmNode?.key === 'sampling'">
            <ElFormItem label="抽检结果">
              <ElRadioGroup v-model="confirmForm.samplingResult">
                <ElRadio value="pass">合格</ElRadio>
                <ElRadio value="fail">不合格</ElRadio>
                <ElRadio value="concession">让步接收</ElRadio>
              </ElRadioGroup>
            </ElFormItem>
          </template>
          <ElFormItem label="备注">
            <ElInput
              v-model="confirmForm.remark"
              type="textarea"
              :rows="2"
              placeholder="备注（可选）"
            />
          </ElFormItem>
        </ElForm>
      </div>
      <template #footer>
        <ElButton @click="confirmDialogVisible = false">取消</ElButton>
        <ElButton type="primary" @click="handleConfirm">确认提交</ElButton>
      </template>
    </ElDialog>
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, watch, onMounted } from 'vue'
  import { ElMessage } from 'element-plus'
  import { Select } from '@element-plus/icons-vue'
  import { VueFlow } from '@vue-flow/core'
  import { Background } from '@vue-flow/background'
  import type { Node } from '@vue-flow/core'
  import WorkflowNode from './workflow-node.vue'
  import {
    getContractWorkflowDefinitionApi,
    listContractWorkflowLogsApi,
    listContractWorkflowStatesApi,
    createContractWorkflowLogApi,
    updateContractWorkflowStatesApi
  } from '@/api/fm/workflow'

  const props = defineProps<{ contractId?: string | number }>()
  const emit = defineEmits<{ (e: 'updated'): void }>()

  const flowChartDialogVisible = ref(false)

  function openFlowChartDialog() {
    flowChartDialogVisible.value = true
  }

  function onFlowChartDialogOpened() {
    syncFlowChartNodes()
  }

  function onNodeConfirmInChart(node: unknown) {
    const key = (node as { data?: { key?: string } })?.data?.key
    if (key) onStepConfirm(key)
  }

  defineExpose({ openFlowChartDialog })

  const workflowLoading = ref(false)
  const mainStepKeys = ref<string[]>([
    'order',
    'formula',
    'purchase',
    'warehouse',
    'inspect',
    'plan',
    'schedule',
    'formulate',
    'test_qc',
    'pack_setup',
    'first_bottle',
    'packing',
    'sampling',
    'ship'
  ])
  const nodeMeta = ref<Record<string, { label: string; description: string }>>({})
  const nodeResultsMap = ref<Record<string, Record<string, string>>>({}) // node_key -> { result_value -> target_key }
  const flowNodeKeys = [
    'order',
    'formula',
    'rd',
    'test_rd',
    'purchase',
    'pack_m',
    'raw_m',
    'warehouse',
    'inspect',
    'return_s',
    'downgrade',
    'plan',
    'schedule',
    'formulate',
    'test_qc',
    'pack_setup',
    'first_bottle',
    'packing',
    'sampling',
    'biz_confirm',
    'concession',
    'ship',
    'cancel'
  ]

  const DEFAULT_NODE_META: Record<string, { label: string; description: string }> = {
    order: { label: '订单', description: '销售合同订单' },
    cancel: { label: '取消订单', description: '取消订单' },
    formula: { label: '配方确认', description: '确认产品配方，无现成配方需研发试验' },
    rd: { label: '研发试验', description: '研发试验' },
    test_rd: { label: '检测', description: '研发阶段检测' },
    purchase: { label: '采购', description: '采购原药、助剂、包材、硬头、标签' },
    pack_m: { label: '包材、硬头、标签', description: '包装材料等' },
    raw_m: { label: '原药、助剂', description: '原药与助剂' },
    warehouse: { label: '仓库收货', description: '仓库收货' },
    inspect: { label: '验收', description: '对入库物料进行质量验收' },
    return_s: { label: '退回供应商', description: '不合格退回供应商' },
    downgrade: { label: '降级使用', description: '降级使用' },
    plan: { label: '生产计划', description: '制定生产计划' },
    schedule: { label: '排单', description: '生产排单' },
    formulate: { label: '配制', description: '按配方配制' },
    test_qc: { label: '检测', description: '配制后质量检测' },
    pack_setup: { label: '包装调机', description: '包装设备调机' },
    first_bottle: { label: '首瓶确认', description: '首瓶样品确认' },
    packing: { label: '包装', description: '批量包装' },
    sampling: { label: '抽检', description: '包装后抽检' },
    biz_confirm: { label: '业务确认', description: '不合格时业务确认' },
    concession: { label: '让步接收', description: '让步接收' },
    ship: { label: '发货', description: '发货' }
  }

  const FALLBACK_NODES = [
    { key: 'order', label: '订单', position_x: 140, position_y: 0 },
    { key: 'cancel', label: '取消订单', position_x: 380, position_y: 0 },
    { key: 'formula', label: '配方确认', position_x: 140, position_y: 70 },
    { key: 'rd', label: '研发试验', position_x: 20, position_y: 150 },
    { key: 'test_rd', label: '检测', position_x: 20, position_y: 230 },
    { key: 'purchase', label: '采购', position_x: 260, position_y: 150 },
    { key: 'pack_m', label: '包材、硬头、标签', position_x: 80, position_y: 230 },
    { key: 'raw_m', label: '原药、助剂', position_x: 280, position_y: 230 },
    { key: 'warehouse', label: '仓库收货', position_x: 180, position_y: 310 },
    { key: 'inspect', label: '验收', position_x: 180, position_y: 390 },
    { key: 'return_s', label: '退回供应商', position_x: 0, position_y: 470 },
    { key: 'downgrade', label: '降级使用', position_x: 120, position_y: 470 },
    { key: 'plan', label: '生产计划', position_x: 300, position_y: 470 },
    { key: 'schedule', label: '排单', position_x: 180, position_y: 550 },
    { key: 'formulate', label: '配制', position_x: 180, position_y: 630 },
    { key: 'test_qc', label: '检测', position_x: 180, position_y: 710 },
    { key: 'pack_setup', label: '包装调机', position_x: 180, position_y: 790 },
    { key: 'first_bottle', label: '首瓶确认', position_x: 180, position_y: 870 },
    { key: 'packing', label: '包装', position_x: 180, position_y: 950 },
    { key: 'sampling', label: '抽检', position_x: 180, position_y: 1030 },
    { key: 'biz_confirm', label: '业务确认', position_x: 180, position_y: 1110 },
    { key: 'concession', label: '让步接收', position_x: 180, position_y: 1190 },
    { key: 'ship', label: '发货', position_x: 180, position_y: 1270 }
  ]

  const FALLBACK_NODE_RESULTS: Array<{
    node_key: string
    result_value: string
    target_key: string
  }> = [
    { node_key: 'formula', result_value: 'existing', target_key: 'purchase' },
    { node_key: 'formula', result_value: 'new', target_key: 'rd' },
    { node_key: 'inspect', result_value: 'pass', target_key: 'plan' },
    { node_key: 'inspect', result_value: 'downgrade', target_key: 'downgrade' },
    { node_key: 'inspect', result_value: 'reject', target_key: 'return_s' },
    { node_key: 'test_qc', result_value: 'pass', target_key: 'pack_setup' },
    { node_key: 'test_qc', result_value: 'rework', target_key: 'formulate' },
    { node_key: 'test_qc', result_value: 'concession', target_key: 'pack_setup' },
    { node_key: 'first_bottle', result_value: 'pass', target_key: 'packing' },
    { node_key: 'first_bottle', result_value: 'redo', target_key: 'pack_setup' },
    { node_key: 'sampling', result_value: 'pass', target_key: 'ship' },
    { node_key: 'sampling', result_value: 'fail', target_key: 'biz_confirm' },
    { node_key: 'sampling', result_value: 'concession', target_key: 'ship' }
  ]

  type NodeStatus = 'completed' | 'current' | 'pending' | 'failed'
  const nodeStates = ref<Record<string, NodeStatus>>({})

  const initialNodes: Node[] = [
    {
      id: 'order',
      type: 'workflow',
      position: { x: 140, y: 0 },
      data: { key: 'order', label: '订单', status: 'completed' }
    },
    {
      id: 'cancel',
      type: 'workflow',
      position: { x: 380, y: 0 },
      data: { key: 'cancel', label: '取消订单', status: 'pending' }
    },
    {
      id: 'formula',
      type: 'workflow',
      position: { x: 140, y: 70 },
      data: { key: 'formula', label: '配方确认', status: 'completed' }
    },
    {
      id: 'rd',
      type: 'workflow',
      position: { x: 20, y: 150 },
      data: { key: 'rd', label: '研发试验', status: 'pending' }
    },
    {
      id: 'test_rd',
      type: 'workflow',
      position: { x: 20, y: 230 },
      data: { key: 'test_rd', label: '检测', status: 'pending' }
    },
    {
      id: 'purchase',
      type: 'workflow',
      position: { x: 260, y: 150 },
      data: { key: 'purchase', label: '采购', status: 'completed' }
    },
    {
      id: 'pack_m',
      type: 'workflow',
      position: { x: 80, y: 230 },
      data: { key: 'pack_m', label: '包材、硬头、标签', status: 'pending' }
    },
    {
      id: 'raw_m',
      type: 'workflow',
      position: { x: 280, y: 230 },
      data: { key: 'raw_m', label: '原药、助剂', status: 'pending' }
    },
    {
      id: 'warehouse',
      type: 'workflow',
      position: { x: 180, y: 310 },
      data: { key: 'warehouse', label: '仓库收货', status: 'completed' }
    },
    {
      id: 'inspect',
      type: 'workflow',
      position: { x: 180, y: 390 },
      data: { key: 'inspect', label: '验收', status: 'current' }
    },
    {
      id: 'return_s',
      type: 'workflow',
      position: { x: 0, y: 470 },
      data: { key: 'return_s', label: '退回供应商', status: 'pending' }
    },
    {
      id: 'downgrade',
      type: 'workflow',
      position: { x: 120, y: 470 },
      data: { key: 'downgrade', label: '降级使用', status: 'pending' }
    },
    {
      id: 'plan',
      type: 'workflow',
      position: { x: 300, y: 470 },
      data: { key: 'plan', label: '生产计划', status: 'pending' }
    },
    {
      id: 'schedule',
      type: 'workflow',
      position: { x: 180, y: 550 },
      data: { key: 'schedule', label: '排单', status: 'pending' }
    },
    {
      id: 'formulate',
      type: 'workflow',
      position: { x: 180, y: 630 },
      data: { key: 'formulate', label: '配制', status: 'pending' }
    },
    {
      id: 'test_qc',
      type: 'workflow',
      position: { x: 180, y: 710 },
      data: { key: 'test_qc', label: '检测', status: 'pending' }
    },
    {
      id: 'pack_setup',
      type: 'workflow',
      position: { x: 180, y: 790 },
      data: { key: 'pack_setup', label: '包装调机', status: 'pending' }
    },
    {
      id: 'first_bottle',
      type: 'workflow',
      position: { x: 180, y: 870 },
      data: { key: 'first_bottle', label: '首瓶确认', status: 'pending' }
    },
    {
      id: 'packing',
      type: 'workflow',
      position: { x: 180, y: 950 },
      data: { key: 'packing', label: '包装', status: 'pending' }
    },
    {
      id: 'sampling',
      type: 'workflow',
      position: { x: 180, y: 1030 },
      data: { key: 'sampling', label: '抽检', status: 'pending' }
    },
    {
      id: 'biz_confirm',
      type: 'workflow',
      position: { x: 180, y: 1110 },
      data: { key: 'biz_confirm', label: '业务确认', status: 'pending' }
    },
    {
      id: 'concession',
      type: 'workflow',
      position: { x: 180, y: 1190 },
      data: { key: 'concession', label: '让步接收', status: 'pending' }
    },
    {
      id: 'ship',
      type: 'workflow',
      position: { x: 180, y: 1270 },
      data: { key: 'ship', label: '发货', status: 'pending' }
    }
  ]

  const baseNodesForChart = ref(initialNodes)

  const initialEdges = [
    { id: 'e-order-formula', source: 'order', target: 'formula' },
    { id: 'e-order-cancel', source: 'order', target: 'cancel' },
    { id: 'e-formula-rd', source: 'formula', target: 'rd', data: { label: '无现成配方' } },
    {
      id: 'e-formula-purchase',
      source: 'formula',
      target: 'purchase',
      data: { label: '配方成熟' }
    },
    { id: 'e-rd-test_rd', source: 'rd', target: 'test_rd' },
    { id: 'e-test_rd-rd', source: 'test_rd', target: 'rd', data: { label: '不通过' } },
    {
      id: 'e-test_rd-formula',
      source: 'test_rd',
      target: 'formula',
      data: { label: '配方不成功' }
    },
    { id: 'e-purchase-pack_m', source: 'purchase', target: 'pack_m' },
    { id: 'e-purchase-raw_m', source: 'purchase', target: 'raw_m' },
    { id: 'e-pack_m-warehouse', source: 'pack_m', target: 'warehouse' },
    { id: 'e-raw_m-warehouse', source: 'raw_m', target: 'warehouse' },
    { id: 'e-warehouse-inspect', source: 'warehouse', target: 'inspect' },
    { id: 'e-inspect-return_s', source: 'inspect', target: 'return_s', data: { label: '不合格' } },
    { id: 'e-inspect-downgrade', source: 'inspect', target: 'downgrade', data: { label: '合格' } },
    { id: 'e-inspect-plan', source: 'inspect', target: 'plan', data: { label: '合格' } },
    { id: 'e-plan-schedule', source: 'plan', target: 'schedule' },
    { id: 'e-concession-plan', source: 'concession', target: 'plan', data: { label: '反馈' } },
    { id: 'e-schedule-formulate', source: 'schedule', target: 'formulate' },
    { id: 'e-formulate-test_qc', source: 'formulate', target: 'test_qc' },
    {
      id: 'e-test_qc-formulate',
      source: 'test_qc',
      target: 'formulate',
      data: { label: '不合格' }
    },
    {
      id: 'e-test_qc-pack_setup',
      source: 'test_qc',
      target: 'pack_setup',
      data: { label: '合格' }
    },
    { id: 'e-pack_setup-first_bottle', source: 'pack_setup', target: 'first_bottle' },
    {
      id: 'e-first_bottle-pack_setup',
      source: 'first_bottle',
      target: 'pack_setup',
      data: { label: '不通过' }
    },
    {
      id: 'e-first_bottle-packing',
      source: 'first_bottle',
      target: 'packing',
      data: { label: '通过' }
    },
    {
      id: 'e-first_bottle-formulate',
      source: 'first_bottle',
      target: 'formulate',
      data: { label: '返工' }
    },
    { id: 'e-packing-sampling', source: 'packing', target: 'sampling' },
    {
      id: 'e-sampling-biz_confirm',
      source: 'sampling',
      target: 'biz_confirm',
      data: { label: '不合格' }
    },
    { id: 'e-sampling-ship', source: 'sampling', target: 'ship', data: { label: '合格' } },
    { id: 'e-biz_confirm-concession', source: 'biz_confirm', target: 'concession' },
    { id: 'e-biz_confirm-ship', source: 'biz_confirm', target: 'ship' },
    { id: 'e-concession-ship', source: 'concession', target: 'ship' }
  ]

  const flowChartEdges = ref(initialEdges)

  const flowChartNodes = ref<Node[]>([])

  function syncFlowChartNodes() {
    flowChartNodes.value = baseNodesForChart.value
      .filter((n) => n && (n.id ?? (n.data as any)?.key))
      .map((n) => {
        const key = (n.data as { key?: string })?.key ?? n.id
        const id = String(n.id ?? key ?? '')
        if (!id) return null
        return {
          ...n,
          id,
          data: { ...n.data, key: key ?? id, status: nodeStates.value[key] ?? 'pending' }
        }
      })
      .filter(Boolean) as Node[]
  }

  watch(nodeStates, () => syncFlowChartNodes(), { deep: true })

  type ProcessLogItem = {
    at: string
    operator: string
    stepKey: string
    stepLabel: string
    action: string
  }
  const processLogs = ref<ProcessLogItem[]>([
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
  ])

  function getStepLog(stepKey: string) {
    return processLogs.value.filter((log) => log.stepKey === stepKey)
  }

  const completedCount = computed(
    () => mainStepKeys.value.filter((k) => nodeStates.value[k] === 'completed').length
  )

  const confirmDialogVisible = ref(false)
  const confirmNode = ref<{ key: string; label: string; description: string } | null>(null)
  const confirmFormRef = ref()
  const confirmForm = ref({
    completedAt: '',
    operator: '',
    remark: '',
    formulaResult: 'existing',
    rdNote: '',
    inspectResult: 'pass',
    qcResult: 'pass',
    bottleResult: 'pass',
    samplingResult: 'pass'
  })

  function onStepConfirm(key: string) {
    const meta = nodeMeta.value[key]
    if (!meta || nodeStates.value[key] !== 'current') return
    confirmNode.value = { key, ...meta }
    confirmForm.value.completedAt = new Date().toISOString().slice(0, 10)
    confirmForm.value.operator = ''
    confirmForm.value.remark = ''
    confirmDialogVisible.value = true
  }

  function getResultFromForm(key: string) {
    const form = confirmForm.value
    if (key === 'formula') return form.formulaResult
    if (key === 'inspect') return form.inspectResult
    if (key === 'test_qc') return form.qcResult
    if (key === 'first_bottle') return form.bottleResult
    if (key === 'sampling') return form.samplingResult
    return ''
  }

  function getNextNodeKey(key: string, result: string): string | null {
    const map = nodeResultsMap.value[key]
    if (map && result) return map[result] ?? null
    const idx = flowNodeKeys.indexOf(key)
    const nextKeys = flowNodeKeys.slice(idx + 1).filter((k) => nodeStates.value[k] !== 'completed')
    return nextKeys[0] ?? null
  }

  async function loadWorkflowData() {
    const cid = props.contractId
    if (!cid) {
      applyFallbackData()
      return
    }
    workflowLoading.value = true
    try {
      const [defRes, logsRes, statesRes] = await Promise.allSettled([
        getContractWorkflowDefinitionApi(cid),
        listContractWorkflowLogsApi(cid),
        listContractWorkflowStatesApi(cid)
      ])

      const def = defRes.status === 'fulfilled' && defRes.value?.data ? defRes.value.data : null
      const logs = logsRes.status === 'fulfilled' && logsRes.value?.data ? logsRes.value.data : null
      const states =
        statesRes.status === 'fulfilled' && statesRes.value?.data ? statesRes.value.data : null

      const nodes = def?.nodes ?? def?.workflow_definition?.nodes ?? []
      const edges = def?.edges ?? def?.workflow_definition?.edges ?? []
      const hasValidDef =
        Array.isArray(nodes) && nodes.length >= 10 && Array.isArray(edges) && edges.length >= 5
      if (hasValidDef) {
        applyDefinitionMeta({ ...def, nodes, edges })
        applyFallbackChartData()
      } else {
        applyFallbackData()
      }
      if (states?.length) {
        const map: Record<string, 'completed' | 'current' | 'pending' | 'failed'> = {}
        for (const s of states) {
          map[s.step_key] =
            (s.status as 'completed' | 'current' | 'pending' | 'failed') || 'pending'
        }
        nodeStates.value = map
      }
      if (logs?.length) {
        processLogs.value = logs
          .sort((a: any, b: any) => (b.sort ?? 0) - (a.sort ?? 0))
          .map((l: any) => ({
            at: (l.operated_at || '').slice(0, 16).replace('T', ' '),
            operator: l.operator_name || '',
            stepKey: l.step_key || '',
            stepLabel: l.step_label || '',
            action: l.action || ''
          }))
      }
      syncFlowChartNodes()
    } catch {
      applyFallbackData()
    } finally {
      workflowLoading.value = false
    }
  }

  /** 仅从 API 更新元数据（步骤顺序、节点标签、分支结果），不更新流程图 */
  function applyDefinitionMeta(def: any) {
    const nodes = def.nodes ?? def.workflow_definition?.nodes ?? []
    const nodeResults = def.node_results ?? def.workflow_definition?.node_results ?? []
    const template = def.template || {}

    mainStepKeys.value = template.main_step_keys || mainStepKeys.value
    const meta: Record<string, { label: string; description: string }> = {}
    for (const n of nodes) {
      meta[n.key] = { label: n.label || n.key, description: n.description || '' }
    }
    nodeMeta.value = { ...DEFAULT_NODE_META, ...meta }

    const resultsMap: Record<string, Record<string, string>> = {}
    for (const r of nodeResults) {
      if (!resultsMap[r.node_key]) resultsMap[r.node_key] = {}
      resultsMap[r.node_key][r.result_value] = r.target_key
    }
    nodeResultsMap.value = resultsMap
  }

  /** 始终使用本地完整数据渲染流程图，保证节点位置正确、显示完整 */
  function applyFallbackChartData() {
    baseNodesForChart.value = FALLBACK_NODES.map((n) => ({
      id: String(n.key),
      type: 'workflow',
      position: { x: n.position_x, y: n.position_y },
      data: { key: n.key, label: n.label, status: nodeStates.value[n.key] ?? 'pending' }
    }))
    flowChartEdges.value = initialEdges.map((e) => ({
      id: e.id,
      source: e.source,
      target: e.target,
      data: { label: (e as any).data?.label || '' }
    }))
  }

  function applyFallbackData() {
    nodeMeta.value = { ...DEFAULT_NODE_META }
    mainStepKeys.value = [
      'order',
      'formula',
      'purchase',
      'warehouse',
      'inspect',
      'plan',
      'schedule',
      'formulate',
      'test_qc',
      'pack_setup',
      'first_bottle',
      'packing',
      'sampling',
      'ship'
    ]
    const resultsMap: Record<string, Record<string, string>> = {}
    for (const r of FALLBACK_NODE_RESULTS) {
      if (!resultsMap[r.node_key]) resultsMap[r.node_key] = {}
      resultsMap[r.node_key][r.result_value] = r.target_key
    }
    nodeResultsMap.value = resultsMap
    applyFallbackChartData()
    if (Object.keys(nodeStates.value).length === 0) {
      nodeStates.value = {
        order: 'completed',
        formula: 'completed',
        purchase: 'completed',
        warehouse: 'completed',
        inspect: 'current',
        plan: 'pending',
        schedule: 'pending',
        formulate: 'pending',
        test_qc: 'pending',
        pack_setup: 'pending',
        first_bottle: 'pending',
        packing: 'pending',
        sampling: 'pending',
        ship: 'pending',
        cancel: 'pending',
        rd: 'pending',
        test_rd: 'pending',
        pack_m: 'pending',
        raw_m: 'pending',
        return_s: 'pending',
        downgrade: 'pending',
        biz_confirm: 'pending',
        concession: 'pending'
      }
    }
    if (processLogs.value.length === 0) {
      processLogs.value = [
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
    }
    syncFlowChartNodes()
  }

  onMounted(() => loadWorkflowData())
  watch(
    () => props.contractId,
    () => loadWorkflowData()
  )

  async function handleConfirm() {
    if (!confirmNode.value) return
    const key = confirmNode.value.key
    const form = confirmForm.value
    const result = getResultFromForm(key)
    const nextKey = getNextNodeKey(key, result)

    const isRework =
      (key === 'test_qc' && form.qcResult === 'rework') ||
      (key === 'first_bottle' && form.bottleResult === 'redo')
    const currStatus = isRework ? 'pending' : 'completed'

    const statesToUpdate: Array<{
      step_key: string
      status: string
      result?: string
      completed_at?: string
    }> = [
      {
        step_key: key,
        status: currStatus,
        result: result || undefined,
        completed_at: form.completedAt || undefined
      }
    ]
    if (nextKey) {
      statesToUpdate.push({ step_key: nextKey, status: 'current' })
    }

    nodeStates.value[key] = currStatus as 'completed' | 'pending'
    if (nextKey) nodeStates.value[nextKey] = 'current'

    const at = form.completedAt
      ? `${form.completedAt} ${new Date().toTimeString().slice(0, 5)}`
      : new Date().toISOString().slice(0, 16).replace('T', ' ')
    const operator = form.operator || '当前用户'
    const action = form.remark || '已完成'

    const cid = props.contractId
    if (cid) {
      try {
        await createContractWorkflowLogApi(cid, {
          step_key: key,
          step_label: confirmNode.value.label,
          operated_at: at.replace(' ', 'T') + ':00',
          operator_name: operator,
          action,
          result: result || undefined
        })
        await updateContractWorkflowStatesApi(cid, { states: statesToUpdate })
        await loadWorkflowData()
        emit('updated')
        ElMessage.success(confirmNode.value ? `【${confirmNode.value.label}】已完成` : '已保存')
      } catch {
        ElMessage.error('保存失败，请重试')
        return
      }
    } else {
      processLogs.value.unshift({
        at,
        operator,
        stepKey: key,
        stepLabel: confirmNode.value.label,
        action
      })
      ElMessage.success(confirmNode.value ? `【${confirmNode.value.label}】已完成` : '已保存')
    }

    confirmDialogVisible.value = false
  }
</script>

<style scoped lang="scss">
  .workflow-steps-wrap {
    display: flex;
    flex: 1;
    flex-direction: column;
    min-height: 0;
    overflow-y: auto;
  }

  .workflow-summary {
    display: flex;
    flex-shrink: 0;
    flex-wrap: wrap;
    gap: 12px;
    align-items: center;
    padding: 8px 0 12px;
    font-size: 12px;
    color: var(--el-text-color-secondary);
  }

  .summary-item {
    display: inline-flex;
    gap: 6px;
    align-items: center;
  }

  .dot {
    display: inline-block;
    width: 8px;
    height: 8px;
    border-radius: 50%;
  }

  .dot-completed {
    background: var(--el-color-success);
  }

  .dot-current {
    background: var(--el-color-primary);
  }

  .dot-pending {
    background: var(--el-border-color);
  }

  .dot-failed {
    background: var(--el-color-danger);
  }

  .workflow-steps {
    flex: 1 1 0;
    min-height: 120px;
    max-height: 50vh;
    padding: 8px 0 16px;
    overflow-y: auto;
  }

  .step-row {
    display: flex;
    gap: 12px;
    align-items: flex-start;
    padding: 6px 0;
  }

  .step-indicator {
    display: flex;
    flex-direction: column;
    flex-shrink: 0;
    align-items: center;
    width: 24px;
  }

  .step-dot {
    display: inline-flex;
    flex-shrink: 0;
    align-items: center;
    justify-content: center;
    width: 24px;
    min-width: 24px;
    height: 24px;
    min-height: 24px;
    font-size: 11px;
    font-weight: 600;
    color: #fff;
    background: var(--el-border-color);
    border-radius: 50%;
  }

  .step-dot--completed {
    font-size: 12px;
    color: #fff;
    background: var(--el-color-success);
  }

  .step-dot--current {
    background: var(--el-color-primary);
    box-shadow: 0 0 0 3px var(--el-color-primary-light-7);
  }

  .step-dot--pending {
    color: var(--el-text-color-placeholder);
    background: var(--el-fill-color);
  }

  .step-line {
    flex: 1;
    align-self: center;
    width: 2px;
    min-height: 12px;
    margin-top: 4px;
    background: var(--el-border-color-lighter);
  }

  .step-row--completed .step-line {
    background: var(--el-color-success-light-5);
  }

  .step-body {
    flex: 1;
    min-width: 0;
    padding-bottom: 4px;
  }

  .step-header {
    display: flex;
    gap: 8px;
    align-items: center;
    justify-content: space-between;
  }

  .step-label {
    font-size: 14px;
    font-weight: 500;
    color: var(--el-text-color-primary);
  }

  .step-row--pending .step-label {
    color: var(--el-text-color-placeholder);
  }

  .step-confirm-btn {
    flex-shrink: 0;
  }

  .step-log-preview {
    padding-left: 0;
    margin-top: 6px;
    font-size: 12px;
    color: var(--el-text-color-secondary);
  }

  .step-log-line {
    display: block;
    margin-top: 2px;
  }

  .confirm-body {
    padding: 0 4px;
  }

  .confirm-step-info {
    padding: 12px 16px;
    margin-bottom: 16px;
    background: var(--el-fill-color-lighter);
    border-radius: 8px;
  }

  .confirm-step-label {
    font-size: 15px;
    font-weight: 600;
    color: var(--el-text-color-primary);
  }

  .confirm-step-desc {
    margin-top: 4px;
    font-size: 13px;
    color: var(--el-text-color-secondary);
  }

  .confirm-form {
    margin-top: 8px;
  }
</style>

<style lang="scss">
  @import '@vue-flow/core/dist/style.css';
  @import '@vue-flow/core/dist/theme-default.css';

  .workflow-chart-dialog .el-dialog__body {
    height: 75vh;
    min-height: 400px;
    padding: 12px;
  }

  .flow-chart-dialog-body {
    width: 100%;
    height: 100%;
    min-height: 380px;
    overflow: hidden;
    background: var(--el-fill-color-lighter);
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 8px;
  }

  .flow-chart-dialog-body .vue-flow {
    width: 100%;
    height: 100%;
  }
</style>
