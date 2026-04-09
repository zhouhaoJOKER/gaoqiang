<!-- 供应商详情页：顶部基本信息 + 负责人信息，下方 Tab 联系人 -->
<template>
  <div class="supplier-detail-container">
    <div class="supplier-header-bar">
      <div class="header-left">
        <ElButton text class="back-btn" @click="handleGoBack">
          <ArtSvgIcon icon="ri:arrow-left-line" />
        </ElButton>
        <span class="header-name">{{ supplierData.name || '供应商详情' }}</span>
      </div>
      <div class="header-right">
        <ElButton text class="header-action-btn" @click="handleRefresh">
          <ArtSvgIcon icon="ri:refresh-line" class="mr-1" />
          刷新
        </ElButton>
        <ElButton type="primary" @click="handleEditSupplier">编辑供应商</ElButton>
      </div>
    </div>

    <div class="supplier-content-wrapper">
      <div class="supplier-detail-panel">
        <!-- 顶部信息区 -->
        <ElCard shadow="never" class="info-card-single">
          <div class="info-card-body">
            <div class="info-block">
              <div class="info-block-title">基本信息</div>
              <div class="info-rows">
                <div class="info-row">
                  <span class="info-label">供应商名称</span>
                  <span class="info-value">{{ supplierData.name || '-' }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">供应商编号</span>
                  <span class="info-value">{{ supplierData.code || '-' }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">简称</span>
                  <span class="info-value">{{ supplierData.abbr || '-' }}</span>
                </div>
                <div class="info-row info-row-full">
                  <span class="info-label">资质说明</span>
                  <span class="info-value">{{ supplierData.qual_notes || '-' }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">拼音/检索</span>
                  <span class="info-value">{{ supplierData.py || '-' }}</span>
                </div>
                <div class="info-row info-row-full">
                  <span class="info-label">备注</span>
                  <span class="info-value">{{ supplierData.remark || '-' }}</span>
                </div>
              </div>
            </div>
            <ElDivider direction="vertical" class="info-divider" />
            <div class="info-block">
              <div class="info-block-title">负责人信息</div>
              <div class="info-rows">
                <div class="info-row">
                  <span class="info-label">创建人</span>
                  <span class="info-value">{{ supplierData.user_name || '-' }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">创建时间</span>
                  <span class="info-value">{{
                    supplierData.created_at || supplierData.created_time || '-'
                  }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">更新人</span>
                  <span class="info-value">{{ supplierData.updater_name || '-' }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">更新时间</span>
                  <span class="info-value">{{
                    supplierData.updated_at || supplierData.updated_time || '-'
                  }}</span>
                </div>
              </div>
            </div>
          </div>
        </ElCard>

        <!-- 标签页：联系人信息 -->
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
          <TabContacts
            v-if="activeTab === 'contacts'"
            :supplier-id="supplierId"
            :supplier-data="supplierData"
            @refresh="loadSupplierDetail"
          />
        </div>
      </div>
    </div>

    <SupplierDialog
      v-model="supplierDialogVisible"
      :supplier="supplierData"
      :readonly="false"
      @updated="handleSupplierUpdated"
    />
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onMounted } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import { ElMessage } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import SupplierDialog from './modules/supplier-dialog.vue'
  import TabContacts from './modules/tab-contacts.vue'
  import { viewPurSupplierApi } from '@/api/pur/supplier'
  import { ElButton, ElCard, ElDivider } from 'element-plus'

  defineOptions({ name: 'PurSupplierDetail' })

  const tabs = [{ key: 'contacts', label: '联系人信息' }]

  const route = useRoute()
  const router = useRouter()
  const activeTab = ref('contacts')
  const supplierDialogVisible = ref(false)

  const supplierId = computed((): string | number | undefined => {
    const id = route.params.id || route.query.id
    const single = Array.isArray(id) ? id[0] : id
    return single != null ? (single as string | number) : undefined
  })

  const supplierData = ref<Record<string, any>>({
    id: undefined,
    name: '',
    code: '',
    abbr: '',
    qual_notes: '',
    remark: '',
    py: '',
    user_id: undefined,
    user_name: '',
    updater_id: undefined,
    updater_name: '',
    created_at: '',
    updated_at: '',
    created_time: '',
    updated_time: ''
  })

  const loadSupplierDetail = async () => {
    if (!supplierId.value) {
      ElMessage.warning('供应商ID不存在')
      return
    }
    try {
      const res = await viewPurSupplierApi({ id: supplierId.value })
      const data = (res as any).data || {}
      supplierData.value = { ...supplierData.value, ...data }
    } catch (e) {
      console.error('加载供应商详情失败:', e)
      ElMessage.error('加载供应商详情失败')
    }
  }

  const handleGoBack = () => router.back()
  const handleRefresh = () => loadSupplierDetail()
  const handleEditSupplier = () => {
    supplierDialogVisible.value = true
  }
  const handleSupplierUpdated = (payload: any) => {
    Object.assign(supplierData.value, payload)
    supplierDialogVisible.value = false
  }

  onMounted(() => loadSupplierDetail())
</script>

<style scoped lang="scss">
  .supplier-detail-container {
    display: flex;
    flex-direction: column;
    width: 100%;
    min-height: 100vh;
    background: #fff;
  }

  .supplier-header-bar {
    display: flex;
    flex-shrink: 0;
    align-items: center;
    justify-content: space-between;
    padding: 12px 20px;
    border-bottom: 1px solid var(--el-border-color-lighter);

    .header-left {
      display: flex;
      gap: 12px;
      align-items: center;

      .back-btn {
        padding: 6px;
        font-size: 18px;
        color: var(--el-text-color-regular);

        &:hover {
          color: var(--el-color-primary);
        }
      }

      .header-name {
        font-size: 18px;
        font-weight: 600;
        color: var(--el-text-color-primary);
      }
    }

    .header-right {
      display: flex;
      gap: 8px;
      align-items: center;

      .header-action-btn {
        color: var(--el-text-color-regular);

        &:hover {
          color: var(--el-color-primary);
        }
      }
    }
  }

  .supplier-content-wrapper {
    flex: 1;
    padding: 16px 20px;
    overflow-y: auto;
  }

  .supplier-detail-panel {
    max-width: 1200px;
    margin: 0 auto;
  }

  .info-section,
  .info-card-single {
    margin-bottom: 24px;
  }

  .info-card-single {
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 10px;

    :deep(.el-card__body) {
      padding: 0;
    }
  }

  .info-card-body {
    display: flex;
    min-height: 1px;
  }

  .info-block {
    flex: 1;
    min-width: 0;
  }

  .info-divider {
    align-self: stretch;
    height: auto;
    margin: 0;
  }

  .info-block-title {
    padding: 12px 20px;
    font-size: 14px;
    font-weight: 600;
    color: var(--el-text-color-primary);
    background: var(--el-fill-color-light);
    border-bottom: 1px solid var(--el-border-color-lighter);
  }

  .info-card-single .info-block:first-child .info-block-title {
    border-radius: 10px 0 0;
  }

  .info-card-single .info-block:last-child .info-block-title {
    border-radius: 0;
  }

  .info-card-single .info-block + .info-divider + .info-block .info-block-title {
    border-left: 1px solid var(--el-border-color-lighter);
  }

  .info-rows {
    display: flex;
    flex-direction: column;
  }

  .info-row {
    display: grid;
    grid-template-columns: 100px 1fr;
    gap: 12px;
    align-items: baseline;
    min-height: 40px;
    padding: 8px 20px;
    border-bottom: 1px solid var(--el-border-color-extra-light);

    &:last-child {
      border-bottom: none;
    }

    &.info-row-full {
      align-items: flex-start;
      padding-top: 10px;

      .info-value {
        word-break: break-word;
        white-space: pre-wrap;
      }
    }
  }

  .info-label {
    flex-shrink: 0;
    font-size: 13px;
    color: var(--el-text-color-secondary);
  }

  .info-value {
    font-size: 14px;
    line-height: 1.5;
    color: var(--el-text-color-primary);
  }

  @media (width <= 768px) {
    .info-card-body {
      flex-direction: column;
    }

    .info-divider {
      width: auto;
      height: 1px;
    }

    .info-card-single .info-block + .info-divider + .info-block .info-block-title {
      border-left: none;
    }
  }

  .tab-bar {
    display: flex;
    gap: 4px;
    margin-bottom: 16px;
    border-bottom: 1px solid var(--el-border-color-lighter);

    .tab-item {
      padding: 10px 16px;
      margin-bottom: -1px;
      font-size: 14px;
      color: var(--el-text-color-regular);
      cursor: pointer;
      border-bottom: 2px solid transparent;
      transition: color 0.2s;

      &:hover {
        color: var(--el-color-primary);
      }

      &.active {
        font-weight: 500;
        color: var(--el-color-primary);
        border-bottom-color: var(--el-color-primary);
      }
    }
  }

  .tab-content {
    min-height: 200px;
  }
</style>
