<template>
  <div class="crm-detail-container contract-detail-page">
    <div class="detail-header-bar no-print">
      <div class="header-left">
        <ElButton text class="back-btn" @click="handleGoBack">
          <ArtSvgIcon icon="ri:arrow-left-line" />
        </ElButton>
        <span class="header-name">{{ detailData.code || '合同详情' }}</span>
      </div>
      <div class="header-right">
        <ElButton text class="header-action-btn" @click="handleRefresh">
          <ArtSvgIcon icon="ri:refresh-line" class="mr-1" />刷新
        </ElButton>
        <ElButton type="primary" @click="handlePrintContract">
          <ArtSvgIcon icon="ri:printer-line" class="mr-1" />打印合同
        </ElButton>
        <ElButton type="primary" @click="handleEdit">编辑合同</ElButton>
      </div>
    </div>
    <div class="detail-content-wrapper">
      <div class="detail-panel">
        <!-- 左右两列：左侧合同详情，右侧流程 -->
        <div class="detail-two-col">
          <div class="detail-left">
            <div ref="contractPaperRef" class="contract-doc">
              <ContractDocContent :data="detailData" />
            </div>
          </div>
          <div class="detail-right no-print">
            <div class="workflow-panel">
              <div class="workflow-panel-title">
                <span>流程跟踪</span>
                <ElButton link type="primary" class="flow-chart-btn" @click="openFlowChartDialog">
                  <ArtSvgIcon icon="ri:node-tree" class="mr-1" />流程图
                </ElButton>
              </div>
              <TabWorkflow
                ref="tabWorkflowRef"
                :contract-id="detailId"
                @updated="onWorkflowUpdated"
              />
            </div>
          </div>
        </div>

        <!-- 下方：合同明细、交接单 -->
        <div class="detail-below no-print">
          <div class="tab-bar">
            <div
              v-for="tab in belowTabs"
              :key="tab.key"
              class="tab-item"
              :class="{ active: activeTab === tab.key }"
              @click="activeTab = tab.key"
            >
              {{ tab.label }}
            </div>
          </div>
          <div class="tab-content">
            <TabWorkflowLog
              v-if="activeTab === 'workflow_log'"
              :key="workflowLogKey"
              :contract-id="detailId"
            />
            <TabCollections
              v-else-if="activeTab === 'collections'"
              :key="collectionListKey"
              :contract-id="detailId"
              @edit="handleEdit"
            />
            <TabHandovers
              v-else-if="activeTab === 'handovers'"
              :contract-id="detailId"
              @add="handleAddHandover"
            />
            <TabRecipeHandovers
              v-else-if="activeTab === 'recipe_handovers'"
              :key="recipeHandoverListKey"
              :contract-id="detailId"
              @add="handleAddRecipeHandover"
            />
            <TabRawMaterialPurchases
              v-else-if="activeTab === 'raw_material'"
              :key="rawMaterialListKey"
              :contract-id="detailId"
              @add="handleAddRawMaterial"
            />
            <TabCartonPurchases
              v-else-if="activeTab === 'carton'"
              :key="cartonListKey"
              :contract-id="detailId"
              @add="handleAddCarton"
            />
            <TabBottlePurchases
              v-else-if="activeTab === 'bottle'"
              :key="bottleListKey"
              :contract-id="detailId"
              @add="handleAddBottle"
            />
            <TabRawInspections
              v-else-if="activeTab === 'raw_inspection'"
              :key="rawInspectionListKey"
              :contract-id="detailId"
            />
          </div>
        </div>
      </div>
    </div>
    <ContractDialog
      v-model="editDialogVisible"
      :contract="detailData"
      :readonly="false"
      @updated="handleUpdated"
    />
    <HandoverDialog
      v-model="handoverDialogVisible"
      :handover="undefined"
      :initial-contract-id="detailId"
      :readonly="false"
      @created="onHandoverCreated"
    />
    <RecipeHandoverDialog
      v-model="recipeHandoverDialogVisible"
      :handover="undefined"
      :initial-contract-id="detailId"
      :readonly="false"
      @created="onRecipeHandoverCreated"
    />
    <RawMaterialPurchaseDialog
      v-model="rawMaterialDialogVisible"
      :contract-id="detailId"
      @created="onRawMaterialCreated"
    />
    <CartonPurchaseDialog
      v-model="cartonDialogVisible"
      :contract-id="detailId"
      @created="onCartonCreated"
    />
    <BottlePurchaseDialog
      v-model="bottleDialogVisible"
      :contract-id="detailId"
      @created="onBottleCreated"
    />
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onMounted, watch } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import { ElMessage } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import ContractDialog from './modules/contract-dialog.vue'
  import HandoverDialog from '../../crm/handovers/modules/handover-dialog.vue'
  import RecipeHandoverDialog from '@/views/rms/recipe-handovers/modules/recipe-handover-dialog.vue'
  import ContractDocContent from './modules/contract-doc-content.vue'
  import TabCollections from './modules/tab-collections.vue'
  import TabHandovers from './modules/tab-handovers.vue'
  import TabRecipeHandovers from './modules/tab-recipe-handovers.vue'
  import TabRawMaterialPurchases from './modules/tab-raw-material-purchases.vue'
  import TabCartonPurchases from './modules/tab-carton-purchases.vue'
  import TabBottlePurchases from './modules/tab-bottle-purchases.vue'
  import TabRawInspections from './modules/tab-raw-inspections.vue'
  import RawMaterialPurchaseDialog from './modules/raw-material-purchase-dialog.vue'
  import CartonPurchaseDialog from './modules/carton-purchase-dialog.vue'
  import BottlePurchaseDialog from './modules/bottle-purchase-dialog.vue'
  import TabWorkflow from './modules/tab-workflow.vue'
  import TabWorkflowLog from './modules/tab-workflow-log.vue'
  import { viewCrmContractApi } from '@/api/crm/contract'
  import { ElButton } from 'element-plus'

  defineOptions({ name: 'CrmContractDetail' })
  const route = useRoute()
  const router = useRouter()
  const editDialogVisible = ref(false)
  const handoverDialogVisible = ref(false)
  const recipeHandoverDialogVisible = ref(false)
  const rawMaterialDialogVisible = ref(false)
  const cartonDialogVisible = ref(false)
  const bottleDialogVisible = ref(false)
  const collectionListKey = ref(0)
  const recipeHandoverListKey = ref(0)
  const rawMaterialListKey = ref(0)
  const cartonListKey = ref(0)
  const bottleListKey = ref(0)
  const rawInspectionListKey = ref(0)
  const workflowLogKey = ref(0)
  const activeTab = ref('workflow_log')
  const belowTabs = [
    { key: 'workflow_log', label: '流程日志' },
    { key: 'collections', label: '合同明细' },
    { key: 'handovers', label: '交接单' },
    { key: 'recipe_handovers', label: '配方交接单' },
    { key: 'raw_material', label: '原料采购' },
    { key: 'carton', label: '包装箱采购' },
    { key: 'bottle', label: '包装瓶采购' },
    { key: 'raw_inspection', label: '原料检验' }
  ]
  const tabKeys = belowTabs.map((t) => t.key)
  watch(
    () => route.query.tab,
    (tab) => {
      const t = typeof tab === 'string' ? tab : Array.isArray(tab) ? tab[0] : ''
      if (t && tabKeys.includes(t)) activeTab.value = t
    },
    { immediate: true }
  )
  const detailId = computed((): string | number | undefined => {
    const id = route.params.id || route.query.id
    const single = Array.isArray(id) ? id[0] : id
    return single != null ? (single as string | number) : undefined
  })
  const detailData = ref<Record<string, any>>({})
  const contractPaperRef = ref<HTMLElement>()
  const tabWorkflowRef = ref<{ openFlowChartDialog: () => void } | null>(null)

  function openFlowChartDialog() {
    tabWorkflowRef.value?.openFlowChartDialog()
  }

  const loadDetail = async () => {
    if (!detailId.value) {
      ElMessage.warning('ID不存在')
      return
    }
    try {
      const res = await viewCrmContractApi({ id: detailId.value })
      detailData.value = (res as any).data || {}
    } catch {
      ElMessage.error('加载详情失败')
    }
  }

  const handlePrintContract = () => {
    const el = contractPaperRef.value
    if (!el) return
    const code = detailData.value?.code || ''
    const printWin = window.open('', '_blank', 'width=900,height=1200')
    if (!printWin) return
    printWin.document.write(
      `<!DOCTYPE html><html><head><meta charset="utf-8"><title>订购合同 - ${code}</title>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { font-family: 'SimSun', '宋体', serif; font-size: 12pt; color: #000; padding: 15mm 20mm; }
  .paper-title { text-align: center; font-size: 22pt; font-weight: bold; letter-spacing: 8pt; margin-bottom: 16pt; }
  table { width: 100%; border-collapse: collapse; }
  .header-table { margin-bottom: 6pt; }
  .header-table td { padding: 2pt 0; font-size: 11pt; }
  .ht-label { width: 80pt; white-space: nowrap; }
  .ht-underline { border-bottom: 1px solid #000; }
  .party-table { margin-bottom: 6pt; }
  .party-table td { padding: 2pt 0; font-size: 11pt; }
  .pt-label { width: 72pt; letter-spacing: 2pt; white-space: nowrap; }
  .intro-text { font-size: 11pt; margin-bottom: 8pt; line-height: 1.8; }
  .contract-table { border: 1.5px solid #000; margin-bottom: 12pt; }
  .contract-table td { border: 1px solid #000; padding: 5pt 8pt; font-size: 11pt; line-height: 1.6; vertical-align: top; }
  .ct-label { width: 72pt; text-align: center; font-weight: bold; background: #f9f9f9; }
  .ct-label-inner { width: 72pt; text-align: center; font-weight: bold; background: #f9f9f9; }
  .ct-label-top { vertical-align: top; }
  .ct-multiline { white-space: pre-wrap; word-break: break-all; }
  .ct-remarks { min-height: 100pt; }
  .ct-sub { color: #333; }
  .sign-table { margin-top: 16pt; }
  .sign-table td { width: 50%; padding: 0 12pt; vertical-align: top; }
  .sign-label { font-size: 11pt; font-weight: bold; }
  .sign-space { height: 50pt; }
  .sign-date { font-size: 11pt; }
  @page { size: A4; margin: 15mm 20mm; }
</style></head><body>`
    )
    printWin.document.write(el.innerHTML)
    printWin.document.write('</body></html>')
    printWin.document.close()
    printWin.focus()
    setTimeout(() => {
      printWin.print()
    }, 400)
  }

  const handleGoBack = () => router.back()
  const handleRefresh = () => loadDetail()
  const handleEdit = () => {
    editDialogVisible.value = true
  }
  const handleUpdated = (p: any) => {
    Object.assign(detailData.value, p)
    editDialogVisible.value = false
    collectionListKey.value++
  }
  const onWorkflowUpdated = () => {
    workflowLogKey.value++
  }
  const handleAddHandover = () => {
    handoverDialogVisible.value = true
  }
  const onHandoverCreated = () => {
    handoverDialogVisible.value = false
    activeTab.value = 'handovers'
  }
  const handleAddRecipeHandover = () => {
    recipeHandoverDialogVisible.value = true
  }
  const onRecipeHandoverCreated = () => {
    recipeHandoverDialogVisible.value = false
    recipeHandoverListKey.value++
    activeTab.value = 'recipe_handovers'
  }
  const handleAddRawMaterial = () => {
    rawMaterialDialogVisible.value = true
  }
  const onRawMaterialCreated = () => {
    rawMaterialDialogVisible.value = false
    rawMaterialListKey.value++
    activeTab.value = 'raw_material'
  }
  const handleAddCarton = () => {
    cartonDialogVisible.value = true
  }
  const onCartonCreated = () => {
    cartonDialogVisible.value = false
    cartonListKey.value++
    activeTab.value = 'carton'
  }
  const handleAddBottle = () => {
    bottleDialogVisible.value = true
  }
  const onBottleCreated = () => {
    bottleDialogVisible.value = false
    bottleListKey.value++
    activeTab.value = 'bottle'
  }
  onMounted(() => loadDetail())
</script>

<style scoped lang="scss">
  @use '@/views/crm/detail-common.scss' as *;

  .contract-detail-page .detail-panel {
    display: flex;
    flex: 1;
    flex-direction: column;
    max-width: none;
    min-height: 0;
  }

  .contract-detail-page .detail-content-wrapper {
    display: flex;
    flex-direction: column;
    min-height: 0;
  }

  .detail-two-col {
    display: grid;
    flex: 1 1 0;
    grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
    gap: 20px;
    align-items: stretch;
    min-height: calc(100vh - 280px);
    margin-bottom: 16px;
  }

  .detail-left {
    display: flex;
    flex-direction: column;
    min-width: 0;
    min-height: 400px;
    overflow: auto;
    background: #fff;
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 8px;
    box-shadow: 0 1px 4px rgb(0 0 0 / 6%);
  }

  .contract-doc {
    flex: 1;
    min-height: 100%;
    padding: 14px 18px;
    font-family: SimSun, '宋体', serif;
  }

  .detail-right {
    display: flex;
    flex-direction: column;
    min-width: 0;
    min-height: 400px;
    overflow: hidden;
  }

  .workflow-panel {
    display: flex;
    flex: 1;
    flex-direction: column;
    min-height: 0;
    padding: 12px;
    overflow: hidden;
    background: var(--el-bg-color);
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 8px;
  }

  .workflow-panel-title {
    display: flex;
    flex-shrink: 0;
    gap: 8px;
    align-items: center;
    justify-content: space-between;
    padding-bottom: 8px;
    margin-bottom: 12px;
    font-size: 15px;
    font-weight: 600;
    color: var(--el-text-color-primary);
    border-bottom: 1px solid var(--el-border-color-lighter);
  }

  .workflow-panel-title .flow-chart-btn {
    padding: 4px 8px;
    font-weight: 500;
  }

  .detail-below {
    flex-shrink: 0;
    padding-top: 16px;
    padding-bottom: 20px;
    margin-top: 0;
    background: var(--el-bg-color);
    border-top: 1px solid var(--el-border-color-lighter);
  }

  .detail-below .tab-bar {
    display: flex;
    flex-wrap: nowrap;
    gap: 4px;
    margin-bottom: 12px;
    overflow-x: visible;
    border-bottom: 1px solid var(--el-border-color-lighter);
  }

  .detail-below .tab-bar .tab-item {
    flex-shrink: 0;
    padding: 10px 20px;
    margin-bottom: -1px;
    font-size: 14px;
    color: var(--el-text-color-regular);
    cursor: pointer;
    border-bottom: 2px solid transparent;
  }

  .detail-below .tab-bar .tab-item:hover {
    color: var(--el-color-primary);
  }

  .detail-below .tab-bar .tab-item.active {
    font-weight: 500;
    color: var(--el-color-primary);
    border-bottom-color: var(--el-color-primary);
  }

  .detail-below .tab-content {
    min-height: 200px;
  }

  /* 中屏及以下改为上下堆叠，保证合同与流程都可读 */
  @media (width <= 1024px) {
    .detail-two-col {
      grid-template-columns: 1fr;
      gap: 16px;
    }

    .detail-left {
      min-height: 50vh;
      max-height: 70vh;
    }

    .detail-right {
      min-height: 360px;
    }
  }

  /* 小屏：缩小内边距，流程区保持可用高度 */
  @media (width <= 768px) {
    .contract-detail-page .detail-content-wrapper {
      padding: 12px 14px;
    }

    .detail-two-col {
      gap: 12px;
      margin-bottom: 12px;
    }

    .contract-doc {
      padding: 12px 14px;
    }

    .workflow-panel {
      padding: 10px;
    }

    .detail-right {
      min-height: 320px;
    }
  }

  @media (width <= 480px) {
    .contract-detail-page .detail-content-wrapper {
      padding: 10px 12px;
    }
  }

  @media print {
    .no-print {
      display: none !important;
    }

    .detail-content-wrapper {
      padding: 0;
    }

    .detail-two-col {
      grid-template-columns: 1fr;
      gap: 0;
      margin-bottom: 0;
    }

    .detail-left {
      border: none;
      box-shadow: none;
    }

    .contract-doc {
      max-width: 100%;
      padding: 12pt 15pt;
    }
  }
</style>
