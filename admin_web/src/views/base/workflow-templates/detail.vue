<template>
  <div class="workflow-template-detail">
    <div class="detail-header">
      <ElButton text type="primary" @click="goBack">
        <ElIcon><ArrowLeft /></ElIcon>
        返回
      </ElButton>
      <h4 class="detail-title">{{ templateInfo?.name || '流程编排' }}</h4>
      <div class="detail-actions">
        <ElButton type="primary" size="small" @click="openAddNodeDialog">
          <ElIcon><Plus /></ElIcon>
          添加节点
        </ElButton>
      </div>
    </div>

    <div class="detail-body">
      <div class="flow-container">
        <VueFlow
          v-model:nodes="nodes"
          v-model:edges="edges"
          :default-viewport="{ x: 0, y: 0, zoom: 0.85 }"
          :min-zoom="0.2"
          :max-zoom="1.5"
          fit-view-on-init
          :nodes-draggable="true"
          :nodes-connectable="true"
          :elements-selectable="true"
          :select-nodes-on-drag="false"
          @connect="onConnect"
          @node-drag-stop="(e: any, n?: any) => onNodeDragStop(e, n)"
          @node-click="(e: any, n?: any) => onNodeClick(e, n)"
          @edge-click="(e: any, ed?: any) => onEdgeClick(e, ed)"
          @pane-click="onPaneClick"
        >
          <Background pattern-color="#e5e7eb" :gap="16" />
          <template #node-workflow="slotProps">
            <WorkflowConfigNode v-bind="slotProps" />
          </template>
        </VueFlow>
      </div>

      <div v-show="selectedNode || selectedEdge" class="side-panel">
        <div v-if="selectedNode" class="side-panel-header">
          <span>节点配置</span>
          <ElButton link type="danger" size="small" @click="handleDeleteNode">删除节点</ElButton>
        </div>
        <div v-else-if="selectedEdge" class="side-panel-header">
          <span>边配置</span>
          <ElButton link type="danger" size="small" @click="handleDeleteEdge">删除边</ElButton>
        </div>
        <ElForm v-if="selectedNode" :model="nodeForm" label-width="90px" class="node-form">
          <ElFormItem label="节点 key">
            <ElInput v-model="nodeForm.key" disabled placeholder="节点标识" />
          </ElFormItem>
          <ElFormItem label="节点名称">
            <ElInput
              v-model="nodeForm.label"
              placeholder="如 订单、配方确认"
              @blur="saveNodeForm"
            />
          </ElFormItem>
          <ElFormItem label="描述">
            <ElInput
              v-model="nodeForm.description"
              type="textarea"
              :rows="2"
              placeholder="节点描述（可选）"
              @blur="saveNodeForm"
            />
          </ElFormItem>
          <ElFormItem label="有分支结果">
            <ElSwitch v-model="nodeForm.has_result_options" @change="saveNodeForm" />
            <span class="form-hint">确认时需选择结果（如合格/不合格）</span>
          </ElFormItem>
        </ElForm>

        <div v-if="selectedNode && nodeForm.has_result_options" class="node-results-section">
          <div class="section-title">分支结果配置</div>
          <ElTable :data="nodeResultsForSelected" border size="small" max-height="240">
            <ElTableColumn prop="result_value" label="结果值" width="90" />
            <ElTableColumn prop="result_label" label="结果标签" min-width="100" />
            <ElTableColumn prop="target_key" label="跳转节点" width="100" />
            <ElTableColumn label="操作" width="80" fixed="right">
              <template #default="{ row }">
                <ElButton link type="danger" size="small" @click="deleteNodeResult(row)"
                  >删除</ElButton
                >
              </template>
            </ElTableColumn>
          </ElTable>
          <ElButton size="small" class="mt-2" @click="openAddResultDialog">添加结果</ElButton>
        </div>

        <div v-if="selectedEdge" class="edge-section">
          <ElForm :model="edgeForm" label-width="90px" size="small">
            <ElFormItem label="标签">
              <ElInput
                v-model="edgeForm.label"
                placeholder="如 合格、不合格"
                @blur="saveEdgeForm"
              />
            </ElFormItem>
            <ElFormItem label="条件结果">
              <ElInput
                v-model="edgeForm.result_value"
                placeholder="如 pass、reject"
                @blur="saveEdgeForm"
              />
            </ElFormItem>
          </ElForm>
        </div>
      </div>
    </div>

    <!-- 添加节点弹窗 -->
    <ElDialog
      v-model="addNodeDialogVisible"
      title="添加节点"
      width="440px"
      :close-on-click-modal="false"
    >
      <ElForm ref="addNodeFormRef" :model="addNodeForm" :rules="addNodeRules" label-width="100px">
        <ElFormItem label="节点 key" prop="key">
          <ElInput v-model="addNodeForm.key" placeholder="如 order、formula，英文唯一" />
        </ElFormItem>
        <ElFormItem label="节点名称" prop="label">
          <ElInput v-model="addNodeForm.label" placeholder="如 订单、配方确认" />
        </ElFormItem>
        <ElFormItem label="描述" prop="description">
          <ElInput v-model="addNodeForm.description" type="textarea" :rows="2" placeholder="可选" />
        </ElFormItem>
        <ElFormItem label="有分支结果" prop="has_result_options">
          <ElSwitch v-model="addNodeForm.has_result_options" />
        </ElFormItem>
      </ElForm>
      <template #footer>
        <ElButton @click="addNodeDialogVisible = false">取消</ElButton>
        <ElButton type="primary" @click="handleAddNode">确定</ElButton>
      </template>
    </ElDialog>

    <!-- 添加节点结果弹窗 -->
    <ElDialog
      v-model="addResultDialogVisible"
      title="添加分支结果"
      width="440px"
      :close-on-click-modal="false"
    >
      <ElForm
        ref="addResultFormRef"
        :model="addResultForm"
        :rules="addResultRules"
        label-width="100px"
      >
        <ElFormItem label="结果值" prop="result_value">
          <ElInput v-model="addResultForm.result_value" placeholder="如 pass、reject" />
        </ElFormItem>
        <ElFormItem label="结果标签" prop="result_label">
          <ElInput v-model="addResultForm.result_label" placeholder="如 合格、不合格退回" />
        </ElFormItem>
        <ElFormItem label="跳转节点" prop="target_key">
          <ElSelect
            v-model="addResultForm.target_key"
            placeholder="选择目标节点"
            filterable
            style="width: 100%"
          >
            <ElOption
              v-for="n in nodes"
              :key="n.id"
              :label="`${n.id} (${(n.data as any)?.label || ''})`"
              :value="n.id"
            />
          </ElSelect>
        </ElFormItem>
      </ElForm>
      <template #footer>
        <ElButton @click="addResultDialogVisible = false">取消</ElButton>
        <ElButton type="primary" @click="handleAddResult">确定</ElButton>
      </template>
    </ElDialog>
  </div>
</template>

<script setup lang="ts">
  import { ref, reactive, computed, onMounted } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import { ElMessage, ElMessageBox } from 'element-plus'
  import { ArrowLeft, Plus } from '@element-plus/icons-vue'
  import type { FormInstance, FormRules } from 'element-plus'
  import {
    ElButton,
    ElIcon,
    ElForm,
    ElFormItem,
    ElInput,
    ElSwitch,
    ElTable,
    ElTableColumn,
    ElDialog,
    ElSelect,
    ElOption
  } from 'element-plus'
  import { VueFlow } from '@vue-flow/core'
  import { Background } from '@vue-flow/background'
  import type { Node, Edge, Connection } from '@vue-flow/core'
  import WorkflowConfigNode from './modules/workflow-config-node.vue'
  import {
    viewWorkflowTemplateApi,
    createWorkflowNodeApi,
    updateWorkflowNodeApi,
    deleteWorkflowNodeApi,
    createWorkflowEdgeApi,
    updateWorkflowEdgeApi,
    deleteWorkflowEdgeApi,
    createWorkflowNodeResultApi,
    deleteWorkflowNodeResultApi
  } from '@/api/fm/workflow'

  defineOptions({ name: 'BaseWorkflowTemplateDetail' })

  const route = useRoute()
  const router = useRouter()
  const templateId = computed(() => Number(route.params.id))

  const templateInfo = ref<any>(null)
  const nodes = ref<Node[]>([])
  const edges = ref<Edge[]>([])
  const nodeResults = ref<any[]>([])
  const loading = ref(false)

  const selectedNode = ref<Node | null>(null)
  const selectedEdge = ref<Edge | null>(null)

  const nodeForm = reactive({
    key: '',
    label: '',
    description: '',
    has_result_options: false
  })

  const edgeForm = reactive({
    label: '',
    result_value: ''
  })

  const nodeResultsForSelected = computed(() => {
    const key = selectedNode.value?.id
    if (!key) return []
    return nodeResults.value.filter((r) => r.node_key === key)
  })

  const addNodeDialogVisible = ref(false)
  const addNodeFormRef = ref<FormInstance>()
  const addNodeForm = reactive({
    key: '',
    label: '',
    description: '',
    has_result_options: false
  })
  const addNodeRules: FormRules = {
    key: [{ required: true, message: '请输入节点 key', trigger: 'blur' }],
    label: [{ required: true, message: '请输入节点名称', trigger: 'blur' }]
  }

  const addResultDialogVisible = ref(false)
  const addResultFormRef = ref<FormInstance>()
  const addResultForm = reactive({
    result_value: '',
    result_label: '',
    target_key: ''
  })
  const addResultRules: FormRules = {
    result_value: [{ required: true, message: '请输入结果值', trigger: 'blur' }],
    result_label: [{ required: true, message: '请输入结果标签', trigger: 'blur' }],
    target_key: [{ required: true, message: '请选择跳转节点', trigger: 'change' }]
  }

  function goBack() {
    router.push({ name: 'BaseWorkflowTemplates' })
  }

  async function loadData() {
    const id = templateId.value
    if (!id) return
    loading.value = true
    try {
      const res = await viewWorkflowTemplateApi({ id })
      const d = (res as any).data || {}
      const tpl = d.template || d
      templateInfo.value = tpl

      const nodesData = d.nodes || tpl.nodes || []
      const edgesData = d.edges || tpl.edges || []
      const resultsData = d.node_results || tpl.node_results || []

      nodeResults.value = resultsData

      nodes.value = nodesData.map((n: any) => ({
        id: n.key || n.id,
        type: 'workflow',
        position: { x: n.position_x ?? 0, y: n.position_y ?? 0 },
        data: {
          key: n.key || n.id,
          label: n.label || n.key,
          description: n.description,
          has_result_options: n.has_result_options
        }
      }))

      edges.value = edgesData.map((e: any) => {
        const src = e.source_key || e.source
        const tgt = e.target_key || e.target
        const rv = e.result_value
        return {
          id: `e-${src}-${tgt}${rv ? `-${rv}` : ''}`,
          source: src,
          target: tgt,
          data: { label: e.label || '', result_value: rv || '' },
          sourceHandle: null,
          targetHandle: null
        }
      })
    } catch {
      ElMessage.error('加载失败')
    } finally {
      loading.value = false
    }
  }

  function onConnect(conn: Connection) {
    const id = templateId.value
    if (!id || !conn.source || !conn.target) return
    createWorkflowEdgeApi(id, {
      source_key: conn.source,
      target_key: conn.target,
      label: '',
      result_value: null
    })
      .then(() => {
        edges.value.push({
          id: `e-${conn.source}-${conn.target}`,
          source: conn.source,
          target: conn.target,
          sourceHandle: conn.sourceHandle,
          targetHandle: conn.targetHandle
        })
        ElMessage.success('连接已添加')
      })
      .catch(() => ElMessage.error('添加连接失败'))
  }

  function onNodeDragStop(ev: any, nodeArg?: Node) {
    const node = nodeArg ?? ev?.node ?? ev
    const id = templateId.value
    if (!id || !node?.id) return
    const pos = node.position
    updateWorkflowNodeApi(id, node.id, {
      position_x: Math.round(pos.x),
      position_y: Math.round(pos.y)
    }).catch(() => ElMessage.error('保存位置失败'))
  }

  function onNodeClick(ev: any, nodeArg?: Node) {
    const node = nodeArg ?? ev?.node ?? ev
    if (!node) return
    selectedNode.value = node
    selectedEdge.value = null
    nodeForm.key = node.id
    const d = node.data as any
    nodeForm.label = d?.label || ''
    nodeForm.description = d?.description || ''
    nodeForm.has_result_options = d?.has_result_options ?? false
  }

  function onEdgeClick(ev: any, edgeArg?: Edge) {
    const edge = edgeArg ?? ev?.edge ?? ev
    if (!edge) return
    selectedEdge.value = edge
    selectedNode.value = null
    const d = edge.data as any
    edgeForm.label = d?.label || ''
    edgeForm.result_value = d?.result_value || ''
  }

  function onPaneClick() {
    selectedNode.value = null
    selectedEdge.value = null
  }

  function openAddNodeDialog() {
    addNodeForm.key = ''
    addNodeForm.label = ''
    addNodeForm.description = ''
    addNodeForm.has_result_options = false
    addNodeDialogVisible.value = true
  }

  async function handleAddNode() {
    if (!addNodeFormRef.value) return
    try {
      await addNodeFormRef.value.validate()
      const id = templateId.value
      if (!id) return

      const maxY = nodes.value.length ? Math.max(...nodes.value.map((n) => n.position.y)) : 0
      await createWorkflowNodeApi(id, {
        key: addNodeForm.key.trim(),
        label: addNodeForm.label.trim(),
        description: addNodeForm.description?.trim() || '',
        has_result_options: addNodeForm.has_result_options,
        position_x: 180,
        position_y: maxY + 80
      })

      nodes.value.push({
        id: addNodeForm.key.trim(),
        type: 'workflow',
        position: { x: 180, y: maxY + 80 },
        data: {
          key: addNodeForm.key.trim(),
          label: addNodeForm.label.trim(),
          description: addNodeForm.description?.trim(),
          has_result_options: addNodeForm.has_result_options
        }
      })
      addNodeDialogVisible.value = false
      ElMessage.success('节点已添加')
    } catch (e) {
      if ((e as Error).message) return
    }
  }

  function saveNodeForm() {
    const node = selectedNode.value
    const id = templateId.value
    if (!node || !id) return
    updateWorkflowNodeApi(id, node.id, {
      label: nodeForm.label,
      description: nodeForm.description,
      has_result_options: nodeForm.has_result_options
    }).then(() => {
      const n = nodes.value.find((x) => x.id === node.id)
      if (n && n.data) {
        ;(n.data as any).label = nodeForm.label
        ;(n.data as any).description = nodeForm.description
        ;(n.data as any).has_result_options = nodeForm.has_result_options
      }
      ElMessage.success('已保存')
    })
  }

  function handleDeleteNode() {
    const node = selectedNode.value
    const id = templateId.value
    if (!node || !id) return
    ElMessageBox.confirm(
      `确定删除节点「${(node.data as any)?.label || node.id}」吗？`,
      '删除确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
      .then(() =>
        deleteWorkflowNodeApi(id, node.id).then(() => {
          nodes.value = nodes.value.filter((n) => n.id !== node.id)
          edges.value = edges.value.filter((e) => e.source !== node.id && e.target !== node.id)
          nodeResults.value = nodeResults.value.filter((r) => r.node_key !== node.id)
          selectedNode.value = null
          ElMessage.success('已删除')
        })
      )
      .catch(() => {})
  }

  function openAddResultDialog() {
    addResultForm.result_value = ''
    addResultForm.result_label = ''
    addResultForm.target_key = ''
    addResultDialogVisible.value = true
  }

  async function handleAddResult() {
    if (!addResultFormRef.value || !selectedNode.value) return
    try {
      await addResultFormRef.value.validate()
      const id = templateId.value
      if (!id) return

      await createWorkflowNodeResultApi(id, {
        node_key: selectedNode.value.id,
        result_value: addResultForm.result_value.trim(),
        result_label: addResultForm.result_label.trim(),
        target_key: addResultForm.target_key || null
      })

      nodeResults.value.push({
        node_key: selectedNode.value.id,
        result_value: addResultForm.result_value.trim(),
        result_label: addResultForm.result_label.trim(),
        target_key: addResultForm.target_key
      })
      addResultDialogVisible.value = false
      ElMessage.success('分支结果已添加')
    } catch (e) {
      if ((e as Error).message) return
    }
  }

  function deleteNodeResult(row: any) {
    const id = templateId.value
    if (!id || !row.id) return
    ElMessageBox.confirm('确定删除该分支结果吗？', '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() =>
        deleteWorkflowNodeResultApi(id, row.id).then(() => {
          nodeResults.value = nodeResults.value.filter((r) => r.id !== row.id)
          ElMessage.success('已删除')
        })
      )
      .catch(() => {})
  }

  function saveEdgeForm() {
    const edge = selectedEdge.value
    const id = templateId.value
    if (!edge || !id) return
    updateWorkflowEdgeApi(id, edge.source, edge.target, {
      label: edgeForm.label,
      result_value: edgeForm.result_value || null
    }).then(() => {
      const e = edges.value.find((x) => x.id === edge.id)
      if (e && e.data) {
        ;(e.data as any).label = edgeForm.label
      }
      ;(edge as any).result_value = edgeForm.result_value
      ElMessage.success('已保存')
    })
  }

  function handleDeleteEdge() {
    const edge = selectedEdge.value
    const id = templateId.value
    if (!edge || !id) return
    ElMessageBox.confirm('确定删除该连接吗？', '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() =>
        deleteWorkflowEdgeApi(id, edge.source, edge.target).then(() => {
          edges.value = edges.value.filter((e) => e.id !== edge.id)
          selectedEdge.value = null
          ElMessage.success('已删除')
        })
      )
      .catch(() => {})
  }

  onMounted(() => loadData())
</script>

<style scoped lang="scss">
  .workflow-template-detail {
    display: flex;
    flex-direction: column;
    height: calc(100vh - 120px);
    padding: 16px;
  }

  .detail-header {
    display: flex;
    gap: 12px;
    align-items: center;
    margin-bottom: 12px;
  }

  .detail-title {
    flex: 1;
    margin: 0;
    font-size: 18px;
  }

  .detail-body {
    display: flex;
    flex: 1;
    gap: 16px;
    min-height: 0;
  }

  .flow-container {
    flex: 1;
    min-width: 0;
    overflow: hidden;
    border: 1px solid var(--el-border-color);
    border-radius: 8px;
  }

  .flow-container :deep(.vue-flow) {
    height: 100%;
    min-height: 400px;
  }

  .side-panel {
    flex-shrink: 0;
    width: 320px;
    padding: 12px;
    overflow-y: auto;
    background: var(--el-fill-color-lighter);
    border: 1px solid var(--el-border-color);
    border-radius: 8px;
  }

  .side-panel-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 12px;
    font-weight: 500;
  }

  .node-form .form-hint {
    margin-left: 8px;
    font-size: 12px;
    color: var(--el-text-color-secondary);
  }

  .node-results-section,
  .edge-section {
    padding-top: 12px;
    margin-top: 16px;
    border-top: 1px solid var(--el-border-color-lighter);
  }

  .section-title {
    margin-bottom: 8px;
    font-size: 13px;
    font-weight: 500;
  }

  .mt-2 {
    margin-top: 8px;
  }
</style>

<style>
  @import '@vue-flow/core/dist/style.css';
  @import '@vue-flow/core/dist/theme-default.css';
</style>
