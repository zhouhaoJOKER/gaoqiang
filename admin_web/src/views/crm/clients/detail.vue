<!-- 客户详情页：顶部基本信息 + 负责人信息，下方 Tab 联系人/地址/开票信息 -->
<template>
  <div class="client-detail-container">
    <div class="client-header-bar">
      <div class="header-left">
        <ElButton text class="back-btn" @click="handleGoBack">
          <ArtSvgIcon icon="ri:arrow-left-line" />
        </ElButton>
        <span class="header-name">{{ clientData.name || '客户详情' }}</span>
      </div>
      <div class="header-right">
        <ElButton text class="header-action-btn" @click="handleRefresh">
          <ArtSvgIcon icon="ri:refresh-line" class="mr-1" />
          刷新
        </ElButton>
        <ElButton type="primary" @click="handleEditClient">编辑客户</ElButton>
      </div>
    </div>

    <div class="client-content-wrapper">
      <div class="client-detail-panel">
        <!-- 顶部信息区：一个 Card，中间分割线 -->
        <ElCard shadow="never" class="info-card-single">
          <div class="info-card-body">
            <div class="info-block">
              <div class="info-block-title">基本信息</div>
              <div class="info-rows">
                <div class="info-row">
                  <span class="info-label">客户名称</span>
                  <span class="info-value">{{ clientData.name || '-' }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">客户编号</span>
                  <span class="info-value">{{ clientData.code || '-' }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">简称</span>
                  <span class="info-value">{{ clientData.abbr || '-' }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">父级客户</span>
                  <span class="info-value">{{ clientData.parent_name || '-' }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">结算方式</span>
                  <span class="info-value">{{ clientData.settlement_name || '-' }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">默认发票类型</span>
                  <span class="info-value">{{ clientData.invoice_type_name || '-' }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">拼音/检索</span>
                  <span class="info-value">{{ clientData.py || '-' }}</span>
                </div>
                <div class="info-row info-row-full">
                  <span class="info-label">付款条款</span>
                  <span class="info-value">{{ clientData.payment_terms || '-' }}</span>
                </div>
                <div class="info-row info-row-full">
                  <span class="info-label">备注</span>
                  <span class="info-value">{{ clientData.remark || '-' }}</span>
                </div>
              </div>
            </div>
            <ElDivider direction="vertical" class="info-divider" />
            <div class="info-block">
              <div class="info-block-title">负责人信息</div>
              <div class="info-rows">
                <div class="info-row">
                  <span class="info-label">创建人</span>
                  <span class="info-value">{{ clientData.user_name || '-' }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">创建时间</span>
                  <span class="info-value">{{
                    clientData.created_at || clientData.created_time || '-'
                  }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">更新人</span>
                  <span class="info-value">{{ clientData.updater_name || '-' }}</span>
                </div>
                <div class="info-row">
                  <span class="info-label">更新时间</span>
                  <span class="info-value">{{
                    clientData.updated_at || clientData.updated_time || '-'
                  }}</span>
                </div>
              </div>
            </div>
          </div>
        </ElCard>

        <!-- 标签页：联系人信息、地址信息、开票信息 -->
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
            :client-id="clientId"
            :client-data="clientData"
            @refresh="loadClientDetail"
          />
          <TabAddresses
            v-else-if="activeTab === 'addresses'"
            :client-id="clientId"
            :client-data="clientData"
            @refresh="loadClientDetail"
          />
          <TabInvoices
            v-else-if="activeTab === 'invoices'"
            :client-id="clientId"
            :client-data="clientData"
            @refresh="loadClientDetail"
          />
        </div>
      </div>
    </div>

    <ClientDialog
      v-model="clientDialogVisible"
      :client="clientData"
      :readonly="false"
      @updated="handleClientUpdated"
    />
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onMounted } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import { ElMessage } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import ClientDialog from './modules/client-dialog.vue'
  import TabContacts from './modules/tab-contacts.vue'
  import TabAddresses from './modules/tab-addresses.vue'
  import TabInvoices from './modules/tab-invoices.vue'
  import { viewCrmClientApi } from '@/api/crm/client'
  import { ElButton, ElCard, ElDivider } from 'element-plus'

  defineOptions({ name: 'CrmClientDetail' })

  const tabs = [
    { key: 'contacts', label: '联系人信息' },
    { key: 'addresses', label: '地址信息' },
    { key: 'invoices', label: '开票信息' }
  ]

  const route = useRoute()
  const router = useRouter()
  const activeTab = ref('contacts')
  const clientDialogVisible = ref(false)

  const clientId = computed((): string | number | undefined => {
    const id = route.params.id || route.query.id
    const single = Array.isArray(id) ? id[0] : id
    return single != null ? (single as string | number) : undefined
  })

  const clientData = ref<Record<string, any>>({
    id: undefined,
    name: '',
    code: '',
    abbr: '',
    py: '',
    parent_id: undefined,
    parent_name: '',
    settlement_id: undefined,
    settlement_name: '',
    invoice_type_id: undefined,
    invoice_type_name: '',
    payment_terms: '',
    remark: '',
    user_id: undefined,
    user_name: '',
    updater_id: undefined,
    updater_name: '',
    created_at: '',
    updated_at: '',
    created_time: '',
    updated_time: ''
  })

  const loadClientDetail = async () => {
    if (!clientId.value) {
      ElMessage.warning('客户ID不存在')
      return
    }
    try {
      const res = await viewCrmClientApi({ id: clientId.value })
      const data = (res as any).data || {}
      clientData.value = { ...clientData.value, ...data }
    } catch (e) {
      console.error('加载客户详情失败:', e)
      ElMessage.error('加载客户详情失败')
    }
  }

  const handleGoBack = () => router.back()
  const handleRefresh = () => loadClientDetail()
  const handleEditClient = () => {
    clientDialogVisible.value = true
  }
  const handleClientUpdated = (payload: any) => {
    Object.assign(clientData.value, payload)
    clientDialogVisible.value = false
  }

  onMounted(() => loadClientDetail())
</script>

<style scoped lang="scss">
  .client-detail-container {
    display: flex;
    flex-direction: column;
    width: 100%;
    min-height: 100vh;
    background: #fff;
  }

  .client-header-bar {
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

  .client-content-wrapper {
    flex: 1;
    padding: 16px 20px;
    overflow-y: auto;
  }

  .client-detail-panel {
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
