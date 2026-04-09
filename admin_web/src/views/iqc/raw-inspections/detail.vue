<template>
  <div class="crm-detail-container">
    <div class="detail-header-bar">
      <div class="header-left">
        <ElButton text class="back-btn" @click="handleGoBack"
          ><ArtSvgIcon icon="ri:arrow-left-line"
        /></ElButton>
        <span class="header-name">{{ detailData.code || detailData.name || '原料检验详情' }}</span>
      </div>
      <div class="header-right">
        <ElButton text class="header-action-btn" @click="handleRefresh"
          ><ArtSvgIcon icon="ri:refresh-line" class="mr-1" />刷新</ElButton
        >
        <ElButton type="primary" @click="handleEdit">编辑原料检验</ElButton>
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
                      ><span class="info-label">检验编号</span
                      ><span class="info-value">{{ detailData.code || '-' }}</span></div
                    >
                    <div class="info-row"
                      ><span class="info-label">原料名称</span
                      ><span class="info-value">{{ detailData.name || '-' }}</span></div
                    >
                    <div class="info-row"
                      ><span class="info-label">关联合同</span
                      ><span class="info-value">
                        <template v-if="detailData.contract_id">
                          <span
                            class="cursor-pointer hover:text-primary-500"
                            @click="handleGoContract"
                            >{{ detailData.contract_code || detailData.contract_id }}</span
                          >
                        </template>
                        <template v-else>-</template>
                      </span></div
                    >
                    <div class="info-row"
                      ><span class="info-label">供应商</span
                      ><span class="info-value">{{ detailData.supplier_name || '-' }}</span></div
                    >
                    <div class="info-row"
                      ><span class="info-label">原料批号</span
                      ><span class="info-value">{{ detailData.batch_number || '-' }}</span></div
                    >
                    <div class="info-row"
                      ><span class="info-label">检验数量</span
                      ><span class="info-value">{{ detailData.inspection_qty || '-' }}</span></div
                    >
                    <div class="info-row"
                      ><span class="info-label">请检日期</span
                      ><span class="info-value">{{
                        detailData.request_inspection_date || '-'
                      }}</span></div
                    >
                    <div class="info-row"
                      ><span class="info-label">检验日期</span
                      ><span class="info-value">{{ detailData.inspection_date || '-' }}</span></div
                    >
                    <div class="info-row"
                      ><span class="info-label">检验依据</span
                      ><span class="info-value">{{ detailData.inspection_basis || '-' }}</span></div
                    >
                    <div class="info-row"
                      ><span class="info-label">结论</span
                      ><span
                        class="info-value"
                        :class="{
                          'text-green-600': detailData.conclusion === '合格',
                          'text-red-600': detailData.conclusion === '不合格'
                        }"
                        >{{ detailData.conclusion || '-' }}</span
                      ></div
                    >
                    <div class="info-row"
                      ><span class="info-label">是否开具不合格评审单</span
                      ><span class="info-value">{{ detailData.issue_ncr ? '是' : '否' }}</span></div
                    >
                    <div class="info-row info-row-full"
                      ><span class="info-label">备注</span
                      ><span class="info-value">{{ detailData.notes || '-' }}</span></div
                    >
                  </div>
                </div>
                <ElDivider direction="vertical" class="info-divider" />
                <div class="info-block">
                  <div class="info-block-title">标样与指标</div>
                  <div class="info-rows">
                    <div class="info-row"
                      ><span class="info-label">标样 m₀</span
                      ><span class="info-value">{{ detailData.std_sample_m ?? '-' }}</span></div
                    >
                    <div class="info-row"
                      ><span class="info-label">标样 X₀</span
                      ><span class="info-value">{{ detailData.std_sample_x ?? '-' }}</span></div
                    >
                    <div class="info-row"
                      ><span class="info-label">标样 A₀(r₀)-1</span
                      ><span class="info-value">{{ detailData.std_sample_a_r_1 ?? '-' }}</span></div
                    >
                    <div class="info-row"
                      ><span class="info-label">标样 A₀(r₀)-2</span
                      ><span class="info-value">{{ detailData.std_sample_a_r_2 ?? '-' }}</span></div
                    >
                    <div class="info-row"
                      ><span class="info-label">PH值（%）</span
                      ><span class="info-value">{{ detailData.ph_value || '-' }}</span></div
                    >
                    <div class="info-row"
                      ><span class="info-label">水分（%）</span
                      ><span class="info-value">{{ detailData.moisture_percent || '-' }}</span></div
                    >
                    <div class="info-row"
                      ><span class="info-label">其它</span
                      ><span class="info-value">{{ detailData.other_indicators || '-' }}</span></div
                    >
                  </div>
                </div>
                <ElDivider direction="vertical" class="info-divider" />
                <div class="info-block">
                  <div class="info-block-title">负责人信息</div>
                  <div class="info-rows">
                    <div class="info-row"
                      ><span class="info-label">检验</span
                      ><span class="info-value">{{ detailData.inspector_name || '-' }}</span></div
                    >
                    <div class="info-row"
                      ><span class="info-label">复核</span
                      ><span class="info-value">{{ detailData.reviewer_name || '-' }}</span></div
                    >
                    <div class="info-row"
                      ><span class="info-label">创建人</span
                      ><span class="info-value">{{ detailData.user_name || '-' }}</span></div
                    >
                    <div class="info-row"
                      ><span class="info-label">创建时间</span
                      ><span class="info-value">{{
                        detailData.created_at || detailData.created_time || '-'
                      }}</span></div
                    >
                  </div>
                </div>
              </div>
            </ElCard>
          </div>
          <div v-show="activeTab === 'lines'" class="tab-pane">
            <div class="tab-pane-toolbar">
              <ElButton type="primary" @click="handleEdit"
                ><ArtSvgIcon icon="ri:edit-line" class="mr-1" />编辑原料检验</ElButton
              >
            </div>
            <TabRawInspectionLines :raw-id="detailId" @edit="handleEdit" />
          </div>
          <div v-show="activeTab === 'contract'" class="tab-pane">
            <ElCard v-if="detailData.contract_id" shadow="never" class="info-card-single">
              <div class="info-card-body">
                <div class="info-block">
                  <div class="info-block-title">关联合同</div>
                  <div class="info-rows">
                    <div class="info-row"
                      ><span class="info-label">合同编号</span
                      ><span class="info-value">
                        <span
                          class="cursor-pointer hover:text-primary-500"
                          @click="handleGoContract"
                          >{{ detailData.contract_code || detailData.contract_id }}</span
                        >
                      </span></div
                    >
                  </div>
                </div>
              </div>
            </ElCard>
            <div v-else class="empty-tip">未关联合同</div>
          </div>
        </div>
      </div>
    </div>
    <RawInspectionDialog
      v-model="editDialogVisible"
      :raw="detailData"
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
  import RawInspectionDialog from './modules/raw-inspection-dialog.vue'
  import TabRawInspectionLines from './modules/tab-raw-inspection-lines.vue'
  import { viewIqcRawApi } from '@/api/iqc/raw'
  import { ElButton, ElCard, ElDivider } from 'element-plus'

  defineOptions({ name: 'IqcRawInspectionDetail' })
  const route = useRoute()
  const router = useRouter()
  const editDialogVisible = ref(false)
  const activeTab = ref('basic')
  const tabs = [
    { key: 'basic', label: '基本信息' },
    { key: 'lines', label: '有效成分读数表' },
    { key: 'contract', label: '关联合同' }
  ]
  const detailId = computed((): string | number | undefined => {
    const id = route.params.id || route.query.id
    const single = Array.isArray(id) ? id[0] : id
    return single != null ? (single as string | number) : undefined
  })
  const detailData = ref<Record<string, any>>({})
  const loadDetail = async () => {
    if (!detailId.value) {
      ElMessage.warning('ID不存在')
      return
    }
    try {
      const res = await viewIqcRawApi({ id: detailId.value })
      detailData.value = (res as any).data || {}
    } catch {
      ElMessage.error('加载详情失败')
    }
  }
  const handleGoBack = () => router.back()
  const handleRefresh = () => loadDetail()
  const handleEdit = () => {
    editDialogVisible.value = true
  }
  const handleUpdated = (p: any) => {
    Object.assign(detailData.value, p)
    editDialogVisible.value = false
  }
  const handleGoContract = () => {
    if (detailData.value?.contract_id) {
      router.push({ path: `/fm/contracts/${detailData.value.contract_id}` })
    }
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

  .empty-tip {
    padding: 24px;
    color: var(--el-text-color-secondary);
    text-align: center;
  }
</style>
