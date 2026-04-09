<template>
  <div class="crm-detail-container">
    <div class="detail-header-bar">
      <div class="header-left">
        <ElButton text class="back-btn" @click="handleGoBack"
          ><ArtSvgIcon icon="ri:arrow-left-line"
        /></ElButton>
        <span class="header-name">{{
          detailData.code || detailData.name || '配方交接单详情'
        }}</span>
      </div>
      <div class="header-right">
        <ElButton text class="header-action-btn" @click="handleRefresh"
          ><ArtSvgIcon icon="ri:refresh-line" class="mr-1" />刷新</ElButton
        >
        <ElButton type="primary" @click="handleEdit">编辑配方交接单</ElButton>
      </div>
    </div>
    <div class="detail-content-wrapper">
      <div class="detail-panel">
        <div class="tab-bar">
          <div
            v-for="tab in tabs"
            :key="tab.key"
            class="tab-item"
            :class="{ active: activeTab === tab.key }"
            @click="activeTab = tab.key"
          >
            {{ tab.label }}
          </div>
        </div>
        <div class="tab-content">
          <div v-show="activeTab === 'basic'" class="tab-pane">
            <ElCard shadow="never" class="info-card-single">
              <div class="info-card-body">
                <div class="info-block">
                  <div class="info-block-title">基本信息</div>
                  <div class="info-rows">
                    <div class="info-row"
                      ><span class="info-label">产品名称</span
                      ><span class="info-value">{{ detailData.name || '-' }}</span></div
                    >
                    <div class="info-row"
                      ><span class="info-label">配方单号</span
                      ><span class="info-value">{{ detailData.code || '-' }}</span></div
                    >
                    <div class="info-row"
                      ><span class="info-label">交接日期</span
                      ><span class="info-value">{{ detailData.handover_date || '-' }}</span></div
                    >
                    <div class="info-row info-row-full"
                      ><span class="info-label">订购公司</span
                      ><span class="info-value">{{
                        detailData.ordering_companies_text || '-'
                      }}</span></div
                    >
                    <div class="info-row"
                      ><span class="info-label">订货数量</span
                      ><span class="info-value"
                        >{{ detailData.order_qty ?? '-'
                        }}{{
                          detailData.order_qty_unit ? ` ${detailData.order_qty_unit}` : ''
                        }}</span
                      ></div
                    >
                    <div class="info-row"
                      ><span class="info-label">指标要求</span
                      ><span class="info-value">{{
                        detailData.handover_order_doc_no || '请参阅交接单!'
                      }}</span></div
                    >
                    <div class="info-row"
                      ><span class="info-label">制单人</span
                      ><span class="info-value">{{ detailData.prepared_name || '-' }}</span></div
                    >
                    <div class="info-row"
                      ><span class="info-label">接收人</span
                      ><span class="info-value">{{ detailData.received_name || '-' }}</span></div
                    >
                    <div class="info-row info-row-full"
                      ><span class="info-label">通用备注</span
                      ><span class="info-value">{{ detailData.general_notes || '-' }}</span></div
                    >
                  </div>
                </div>
              </div>
            </ElCard>
          </div>
          <div v-show="activeTab === 'lines'" class="tab-pane">
            <div class="tab-pane-toolbar">
              <ElButton type="primary" @click="handleEdit"
                ><ArtSvgIcon icon="ri:edit-line" class="mr-1" />编辑配方交接单</ElButton
              >
            </div>
            <ElTable v-loading="linesLoading" :data="linesList" border stripe>
              <ElTableColumn type="index" width="55" label="序号" />
              <ElTableColumn
                prop="name"
                label="原、辅料品名"
                min-width="180"
                show-overflow-tooltip
              />
              <ElTableColumn
                prop="feeding_rate"
                label="投料比例, g/L"
                min-width="140"
                show-overflow-tooltip
              >
                <template #default="{ row }">
                  {{ row.feeding_rate != null && row.feeding_rate !== '' ? row.feeding_rate : '-' }}
                </template>
              </ElTableColumn>
              <ElTableColumn prop="remark" label="备注" min-width="140" show-overflow-tooltip />
            </ElTable>
          </div>
          <div v-show="activeTab === 'contracts'" class="tab-pane">
            <TabRecipeHandoverContracts :handover-id="detailId" />
          </div>
        </div>
      </div>
    </div>
    <RecipeHandoverDialog
      v-model="editDialogVisible"
      :handover="detailData"
      :readonly="false"
      @updated="handleUpdated"
    />
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onMounted } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import { ElMessage } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import RecipeHandoverDialog from './modules/recipe-handover-dialog.vue'
  import TabRecipeHandoverContracts from './modules/tab-recipe-handover-contracts.vue'
  import { viewRecipeHandoverApi, listRecipeHandoverLineApi } from '@/api/rms/recipe-handover'
  import { ElButton, ElCard, ElTable, ElTableColumn } from 'element-plus'

  defineOptions({ name: 'RmsRecipeHandoverDetail' })
  const route = useRoute()
  const router = useRouter()
  const editDialogVisible = ref(false)
  const activeTab = ref('basic')
  const tabs = [
    { key: 'basic', label: '基本信息' },
    { key: 'lines', label: '原辅料明细' },
    { key: 'contracts', label: '关联合同' }
  ]
  const detailId = computed((): string | number | undefined => {
    const id = route.params.id || route.query.id
    const single = Array.isArray(id) ? id[0] : id
    return single != null ? (single as string | number) : undefined
  })
  const detailData = ref<Record<string, any>>({})
  const linesList = ref<any[]>([])
  const linesLoading = ref(false)
  const loadLines = async (handoverId: string | number) => {
    if (!handoverId) return
    linesLoading.value = true
    try {
      const res = await listRecipeHandoverLineApi({
        'q[handover_id_eq]': handoverId,
        per_page: 500
      })
      const linesData = (res as any).data || []
      const arr = Array.isArray(linesData) ? linesData : linesData.list || linesData.data || []
      linesList.value = arr.map((line: any) => ({
        ...line,
        name: line.name || line.product_name || '-'
      }))
    } catch {
      linesList.value = []
    } finally {
      linesLoading.value = false
    }
  }
  const loadDetail = async () => {
    if (!detailId.value) {
      ElMessage.warning('ID不存在')
      return
    }
    try {
      const res = await viewRecipeHandoverApi({ id: detailId.value })
      detailData.value = (res as any).data || {}
      await loadLines(detailId.value)
    } catch {
      ElMessage.error('加载详情失败')
    }
  }
  const handleGoBack = () => router.back()
  const handleRefresh = () => loadDetail()
  const handleEdit = () => {
    editDialogVisible.value = true
  }
  const handleUpdated = async (p: any) => {
    Object.assign(detailData.value, p)
    editDialogVisible.value = false
    if (detailId.value) await loadLines(detailId.value)
  }
  onMounted(() => loadDetail())
</script>

<style scoped lang="scss">
  @use '../../crm/detail-common.scss' as *;

  .tab-pane {
    padding-top: 16px;
  }

  .tab-pane-toolbar {
    margin-bottom: 16px;
  }
</style>
