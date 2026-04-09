<template>
  <div class="crm-detail-container">
    <div class="detail-header-bar">
      <div class="header-left">
        <ElButton text class="back-btn" @click="handleGoBack"
          ><ArtSvgIcon icon="ri:arrow-left-line"
        /></ElButton>
        <span class="header-name">{{ detailData.title || '开票信息详情' }}</span>
      </div>
      <div class="header-right">
        <ElButton text class="header-action-btn" @click="handleRefresh"
          ><ArtSvgIcon icon="ri:refresh-line" class="mr-1" />刷新</ElButton
        >
        <ElButton type="primary" @click="handleEdit">编辑</ElButton>
      </div>
    </div>
    <div class="detail-content-wrapper">
      <div class="detail-panel">
        <ElCard shadow="never" class="info-card-single">
          <div class="info-card-body">
            <div class="info-block">
              <div class="info-block-title">基本信息</div>
              <div class="info-rows">
                <div class="info-row"
                  ><span class="info-label">关联类型</span
                  ><span class="info-value">{{
                    detailData.billable_type === 'Crm::Client' ? '客户' : '供应商'
                  }}</span></div
                >
                <div class="info-row"
                  ><span class="info-label">开票抬头</span
                  ><span class="info-value">{{ detailData.title || '-' }}</span></div
                >
                <div class="info-row"
                  ><span class="info-label">税号</span
                  ><span class="info-value">{{ detailData.tax_no || '-' }}</span></div
                >
                <div class="info-row"
                  ><span class="info-label">发票类型</span
                  ><span class="info-value">{{ detailData.invoice_type_name || '-' }}</span></div
                >
                <div class="info-row"
                  ><span class="info-label">是否默认</span
                  ><span class="info-value">{{ detailData.is_default ? '是' : '否' }}</span></div
                >
                <div class="info-row info-row-full"
                  ><span class="info-label">注册/开票地址</span
                  ><span class="info-value">{{ detailData.address || '-' }}</span></div
                >
                <div class="info-row"
                  ><span class="info-label">注册/开票电话</span
                  ><span class="info-value">{{ detailData.phone || '-' }}</span></div
                >
                <div class="info-row"
                  ><span class="info-label">开户银行</span
                  ><span class="info-value">{{ detailData.bank_name || '-' }}</span></div
                >
                <div class="info-row"
                  ><span class="info-label">银行账号</span
                  ><span class="info-value">{{ detailData.bank_account || '-' }}</span></div
                >
                <div class="info-row info-row-full"
                  ><span class="info-label">备注</span
                  ><span class="info-value">{{ detailData.remark || '-' }}</span></div
                >
              </div>
            </div>
            <ElDivider direction="vertical" class="info-divider" />
            <div class="info-block">
              <div class="info-block-title">负责人信息</div>
              <div class="info-rows">
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
                <div class="info-row"
                  ><span class="info-label">更新人</span
                  ><span class="info-value">{{ detailData.updater_name || '-' }}</span></div
                >
                <div class="info-row"
                  ><span class="info-label">更新时间</span
                  ><span class="info-value">{{
                    detailData.updated_at || detailData.updated_time || '-'
                  }}</span></div
                >
              </div>
            </div>
          </div>
        </ElCard>
      </div>
    </div>
    <InvoiceDialog
      v-model="editDialogVisible"
      :invoice="detailData"
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
  import InvoiceDialog from './modules/invoice-dialog.vue'
  import { viewCrmInvoiceApi } from '@/api/crm/invoice'
  import { ElButton, ElCard, ElDivider } from 'element-plus'

  defineOptions({ name: 'CrmInvoiceDetail' })
  const route = useRoute()
  const router = useRouter()
  const editDialogVisible = ref(false)
  const detailId = computed(() => {
    const id = route.params.id || route.query.id
    return Array.isArray(id) ? id[0] : id
  })
  const detailData = ref<Record<string, any>>({})
  const loadDetail = async () => {
    if (!detailId.value) {
      ElMessage.warning('ID不存在')
      return
    }
    try {
      const res = await viewCrmInvoiceApi({ id: detailId.value })
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
  onMounted(() => loadDetail())
</script>

<style scoped lang="scss">
  @use '../detail-common.scss' as *;
</style>
