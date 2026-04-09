<template>
  <div class="crm-detail-container order-detail-page">
    <div class="detail-header-bar">
      <div class="header-left">
        <ElButton text class="back-btn" @click="goBack">
          <ArtSvgIcon icon="ri:arrow-left-line" />
        </ElButton>
        <span class="header-name">{{ detail.code || '订单详情' }}</span>
        <ElTag
          v-if="detail.status_name"
          v-bind="statusTagAttrs(detail.status_color)"
          size="small"
          class="header-status-tag"
        >
          {{ detail.status_name }}
        </ElTag>
      </div>
      <div class="header-right">
        <ElButton text class="header-action-btn" @click="loadDetail">
          <ArtSvgIcon icon="ri:refresh-line" class="mr-1" />刷新
        </ElButton>
        <ElButton type="primary" @click="goCreateFromPre">新建订单</ElButton>
      </div>
    </div>

    <div class="detail-content-wrapper">
      <div class="detail-panel">
        <div class="detail-main-grid">
          <div class="detail-main-left">
            <ElCard class="info-group-card info-group-card--unified" shadow="never">
              <template #header>
                <span class="group-card-title">订单信息</span>
              </template>
              <div class="unified-info-body">
                <ElDivider content-position="left">基本信息</ElDivider>
                <ElDescriptions
                  :column="2"
                  border
                  size="small"
                  label-width="140px"
                  class="group-desc group-desc--uniform"
                >
                  <ElDescriptionsItem label="订单编号">{{ detail.code || '—' }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="客户名称">
                    <RouterLink
                      v-if="detail.client_id"
                      class="file-link"
                      :to="{ path: '/crm/orders', query: { client_id: String(detail.client_id) } }"
                    >
                      {{ detail.client_name || '—' }}
                    </RouterLink>
                    <span v-else>{{ detail.client_name || '—' }}</span>
                  </ElDescriptionsItem>
                  <ElDescriptionsItem label="客户标识">
                    <div v-if="detail.client_logo_url" class="logo-cell">
                      <img class="client-logo" :src="mediaUrl(detail.client_logo_url)" alt="" />
                    </div>
                    <span v-else>—</span>
                  </ElDescriptionsItem>
                  <ElDescriptionsItem label="订单附件">
                    <a
                      v-if="detail.file_url"
                      class="file-link"
                      :href="mediaUrl(detail.file_url)"
                      target="_blank"
                      rel="noopener"
                      >查看附件</a
                    >
                    <span v-else>—</span>
                  </ElDescriptionsItem>
                  <ElDescriptionsItem label="接单日期">{{
                    fmtDate(detail.receive_date)
                  }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="合同编号">{{
                    detail.contract_code || '—'
                  }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="危包月份">{{
                    detail.hazard_pack_month || '—'
                  }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="客户交期">{{
                    fmtDate(detail.customer_delivery_date)
                  }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="跟进人">{{
                    detail.follower_name || '—'
                  }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="跟进时间">{{
                    fmtDateTime(detail.follow_at)
                  }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="订单状态">
                    <ElTag
                      v-if="detail.status_name"
                      v-bind="statusTagAttrs(detail.status_color)"
                      size="small"
                      class="desc-status-tag"
                    >
                      {{ detail.status_name }}
                    </ElTag>
                    <span v-else>—</span>
                  </ElDescriptionsItem>
                  <ElDescriptionsItem label="明细行数">{{
                    detail.line_count ?? '—'
                  }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="备注" :span="2">{{
                    detail.follow_progress || '—'
                  }}</ElDescriptionsItem>
                </ElDescriptions>

                <ElDivider content-position="left">款项信息</ElDivider>
                <ElDescriptions
                  :column="2"
                  border
                  size="small"
                  label-width="140px"
                  class="group-desc group-desc--uniform"
                >
                  <ElDescriptionsItem label="金额">{{
                    fmtMoney(detail.amount)
                  }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="开票金额">{{
                    fmtMoney(detail.invoice_amount)
                  }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="开票时间">{{
                    fmtDateTime(detail.invoice_at)
                  }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="付款金额">{{
                    fmtMoney(detail.payment_amount)
                  }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="付款时间" :span="2">{{
                    fmtDateTime(detail.payment_at)
                  }}</ElDescriptionsItem>
                </ElDescriptions>

                <ElDivider content-position="left">交付信息</ElDivider>
                <ElDescriptions
                  :column="2"
                  border
                  size="small"
                  label-width="140px"
                  class="group-desc group-desc--uniform"
                >
                  <ElDescriptionsItem label="客户交期">{{
                    fmtDate(detail.customer_delivery_date)
                  }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="已发货数量">{{
                    fmtQty(detail.delivered_qty)
                  }}</ElDescriptionsItem>
                </ElDescriptions>

                <ElDivider content-position="left">记录信息</ElDivider>
                <ElDescriptions
                  :column="2"
                  border
                  size="small"
                  label-width="140px"
                  class="group-desc group-desc--uniform"
                >
                  <ElDescriptionsItem label="创建人">{{
                    detail.user_name || '—'
                  }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="更新人">{{
                    detail.updater_name || '—'
                  }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="创建时间">{{
                    fmtDateTime(detail.created_at)
                  }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="更新时间">{{
                    fmtDateTime(detail.updated_at)
                  }}</ElDescriptionsItem>
                </ElDescriptions>

                <ElDivider content-position="left">订单明细</ElDivider>
                <div class="matrix-wrap detail-matrix detail-matrix--in-card">
                  <table
                    v-if="lines.length"
                    class="crm-orders-matrix"
                    border="0"
                    cellspacing="0"
                    cellpadding="0"
                  >
                    <thead>
                      <tr>
                        <th class="th-base">#</th>
                        <th class="th-base">产品名称</th>
                        <th class="th-base">型号</th>
                        <th class="th-base">颜色</th>
                        <th class="th-base">克重</th>
                        <th class="th-base">数量</th>
                        <th class="th-base">单位</th>
                        <th class="th-base">单价</th>
                        <th class="th-base">金额</th>
                        <th class="th-base">库存状态</th>
                        <th class="th-base">色母状况</th>
                        <th class="th-base">发货单未回</th>
                        <th class="th-base">发货单已回</th>
                        <th class="th-base">规格要求</th>
                        <th class="th-base">备注</th>
                      </tr>
                    </thead>
                    <tbody>
                      <tr v-for="(line, idx) in lines" :key="line.id || idx">
                        <td class="td-line">{{ idx + 1 }}</td>
                        <td class="td-line">{{ line.product_name || '—' }}</td>
                        <td class="td-line">{{ line.model || '—' }}</td>
                        <td class="td-line">{{ line.color || '—' }}</td>
                        <td class="td-line">{{ line.weight || '—' }}</td>
                        <td class="td-line">{{ line.qty ?? '—' }}</td>
                        <td class="td-line">{{ line.unit || '—' }}</td>
                        <td class="td-line td-num">{{ fmtMoney(line.unit_price) }}</td>
                        <td class="td-line td-num">{{ fmtMoney(lineAmount(line)) }}</td>
                        <td class="td-line">{{ line.stock_status || '—' }}</td>
                        <td class="td-line">{{ line.color_master_status || '—' }}</td>
                        <td class="td-line">{{ line.ship_doc_unreturned || '—' }}</td>
                        <td class="td-line">{{ line.ship_doc_returned || '—' }}</td>
                        <td class="td-line td-require">{{ line.spec_requirements || '—' }}</td>
                        <td class="td-line td-require">{{ line.remark || '—' }}</td>
                      </tr>
                    </tbody>
                  </table>
                  <ElEmpty v-else description="暂无明细" class="empty-lines" />
                </div>
              </div>
            </ElCard>
          </div>

          <!-- 右侧：订单附件 + 跟进 -->
          <aside class="detail-main-aside">
            <ElCard class="info-group-card order-attach-card" shadow="never">
              <template #header>
                <span class="group-card-title">订单附件</span>
              </template>
              <div class="order-attach-body">
                <div v-if="detail.file_url" class="order-attach-row">
                  <a
                    class="file-link"
                    :href="mediaUrl(detail.file_url)"
                    target="_blank"
                    rel="noopener"
                    >查看当前附件</a
                  >
                </div>
                <div v-else class="order-attach-placeholder">暂无附件</div>
                <ElUpload
                  :show-file-list="false"
                  :disabled="orderFileUploading || !detailId"
                  :http-request="handleOrderFileUpload"
                  accept=".pdf,.doc,.docx,.xls,.xlsx,.png,.jpg,.jpeg,.gif,.webp,.zip,.rar"
                >
                  <ElButton
                    type="primary"
                    plain
                    size="small"
                    :loading="orderFileUploading"
                    :disabled="!detailId"
                  >
                    <ArtSvgIcon icon="ri:upload-2-line" class="mr-1" />
                    {{ detail.file_url ? '替换附件' : '上传附件' }}
                  </ElButton>
                </ElUpload>
                <p class="order-attach-hint">上传后写入订单 file 关联，并更新更新人</p>
              </div>
            </ElCard>

            <ElCard class="info-group-card follow-card follow-card--aside" shadow="never">
              <template #header>
                <div class="follow-card-header">
                  <span class="group-card-title">订单跟进</span>
                  <span class="follow-card-hint">进展记入跟进记录表；变更状态将同步订单</span>
                </div>
              </template>

              <div class="follow-form-block follow-form-block--aside">
                <div class="follow-form-row">
                  <label class="follow-label">订单状态</label>
                  <div class="follow-field">
                    <PropertySelectWithAdd
                      v-model="followStatusId"
                      sign="crm_order_status"
                      placeholder="与订单状态一致，可在此更新"
                      :refresh-trigger="propertyRefreshKey"
                    />
                  </div>
                </div>
                <div class="follow-form-row follow-form-row--textarea">
                  <label class="follow-label">跟进内容</label>
                  <div class="follow-field">
                    <ElInput
                      v-model="followContent"
                      type="textarea"
                      :rows="6"
                      maxlength="2000"
                      show-word-limit
                      placeholder="记录沟通进展、客户反馈、内部协调等（必填）"
                    />
                  </div>
                </div>
                <div class="follow-form-actions follow-form-actions--aside">
                  <ElButton
                    type="primary"
                    :loading="followSubmitting"
                    :disabled="!followContent.trim()"
                    @click="submitFollow"
                  >
                    提交跟进
                  </ElButton>
                  <ElButton text @click="resetFollowForm">重置</ElButton>
                </div>
              </div>
            </ElCard>
          </aside>
        </div>

        <!-- 跟进记录 / 操作日志 -->
        <div class="detail-follow-wrap">
          <ElTabs v-model="followRecordTab" class="detail-follow-tabs">
            <ElTabPane label="跟进记录" name="follow">
              <div v-loading="activitiesLoading" class="activity-table-wrap">
                <ElTable
                  v-if="displayedActivities.length"
                  :data="displayedActivities"
                  stripe
                  border
                  size="small"
                  class="activity-record-table"
                  max-height="420"
                >
                  <ElTableColumn prop="created_at" label="时间" width="168">
                    <template #default="{ row }">{{ fmtDateTime(row.created_at) }}</template>
                  </ElTableColumn>
                  <ElTableColumn
                    prop="user_name"
                    label="操作人"
                    width="100"
                    show-overflow-tooltip
                  />
                  <ElTableColumn label="状态" width="120">
                    <template #default="{ row }">
                      <ElTag
                        v-if="row.status_id && row.status_name"
                        v-bind="statusTagAttrs(row.color)"
                        size="small"
                      >
                        {{ row.status_name }}
                      </ElTag>
                      <span v-else class="cell-dash">—</span>
                    </template>
                  </ElTableColumn>
                  <ElTableColumn
                    prop="content"
                    label="跟进内容"
                    min-width="220"
                    show-overflow-tooltip
                  />
                </ElTable>
                <ElEmpty v-else description="暂无跟进记录" class="empty-lines" />
              </div>
            </ElTabPane>
            <ElTabPane label="操作日志" name="logs" lazy>
              <LogTable
                v-if="detailId"
                category="10"
                :record-id="detailId"
                record-type="Crm::Order"
                embedded
              />
            </ElTabPane>
          </ElTabs>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { computed, ref, watch } from 'vue'
  import { RouterLink, useRoute, useRouter } from 'vue-router'
  import {
    ElButton,
    ElCard,
    ElDivider,
    ElDescriptions,
    ElDescriptionsItem,
    ElEmpty,
    ElInput,
    ElMessage,
    ElTabPane,
    ElTable,
    ElTableColumn,
    ElTabs,
    ElTag,
    ElUpload
  } from 'element-plus'
  import type { UploadRequestOptions } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'
  import LogTable from '@/views/system/log/modules/LogTable.vue'
  import { uploadCrmOrderFileApi, viewCrmOrderApi } from '@/api/crm/order'
  import { createActivityApi, listActivityApi } from '@/api/activity'
  import { crmOrderStatusTagAttrs } from '@/views/crm/crm-order-status'

  defineOptions({ name: 'CrmOrderDetail' })

  const CRM_ORDER_RECORD_TYPE = 'Crm::Order'

  const route = useRoute()
  const router = useRouter()
  const detail = ref<Record<string, any>>({})

  const followContent = ref('')
  const followStatusId = ref<number | string | null>(null)
  const followSubmitting = ref(false)
  const activities = ref<
    Array<{
      id: number
      content: string
      user_name?: string
      created_at?: string
      status_id?: number | null
      status_name?: string
      color?: string
    }>
  >([])
  const activitiesLoading = ref(false)
  const activityFilterTab = ref<'all' | 'with_status'>('all')
  const propertyRefreshKey = ref(0)
  const followRecordTab = ref<'follow' | 'logs'>('follow')
  const orderFileUploading = ref(false)

  const lines = computed(() =>
    Array.isArray(detail.value?.line_items) ? detail.value.line_items : []
  )

  const displayedActivities = computed(() => {
    const list = activities.value
    if (activityFilterTab.value === 'with_status') {
      return list.filter((a) => a.status_id != null)
    }
    return list
  })

  const detailId = computed(() => {
    const id = route.params.id
    return Array.isArray(id) ? id[0] : id
  })

  function mediaUrl(url: string) {
    if (!url) return ''
    if (/^https?:\/\//i.test(url)) return url
    return url.startsWith('/') ? url : `/${url}`
  }

  function fmtDate(v?: string | null) {
    if (v == null || v === '') return '—'
    const s = String(v)
    return s.length >= 10 ? s.slice(0, 10) : s
  }

  function fmtDateTime(v?: string | null) {
    if (v == null || v === '') return '—'
    const s = String(v).replace('T', ' ')
    return s.length >= 19 ? s.slice(0, 19) : s
  }

  function fmtMoney(v: unknown) {
    if (v === null || v === undefined || v === '') return '—'
    return String(v)
  }

  function fmtQty(v: unknown) {
    if (v === null || v === undefined || v === '') return '—'
    return String(v)
  }

  function lineAmount(line: Record<string, any>) {
    const explicit = line?.line_amount
    if (explicit !== null && explicit !== undefined && explicit !== '') return explicit
    const qty = Number(line?.qty)
    const price = Number(line?.unit_price)
    if (Number.isNaN(qty) || Number.isNaN(price)) return null
    return qty * price
  }

  function statusTagAttrs(color?: string | null) {
    return crmOrderStatusTagAttrs(color)
  }

  async function handleOrderFileUpload(options: UploadRequestOptions) {
    const file = options.file as File
    if (!detailId.value || !file) return
    orderFileUploading.value = true
    try {
      await uploadCrmOrderFileApi(detailId.value, file)
      ElMessage.success('附件已更新')
      await loadDetail()
      propertyRefreshKey.value += 1
    } catch {
      ElMessage.error('上传失败')
    } finally {
      orderFileUploading.value = false
    }
  }

  function syncFollowStatusFromDetail() {
    const sid = detail.value?.status_id
    followStatusId.value =
      sid === undefined || sid === null || sid === '' ? null : (sid as number | string)
  }

  async function loadDetail() {
    if (!detailId.value) {
      ElMessage.warning('缺少订单 ID')
      return
    }
    try {
      const res = (await viewCrmOrderApi({ id: detailId.value })) as any
      detail.value = res.data || {}
      syncFollowStatusFromDetail()
    } catch {
      ElMessage.error('加载订单失败')
    }
  }

  async function loadActivities() {
    if (!detailId.value) return
    activitiesLoading.value = true
    try {
      const res = (await listActivityApi({
        list: 1,
        'q[record_type_eq]': CRM_ORDER_RECORD_TYPE,
        'q[record_id_eq]': detailId.value
      })) as any
      const raw = res?.data
      const arr = Array.isArray(raw) ? raw : []
      activities.value = arr.map((item: Record<string, any>) => ({
        id: item.id,
        content: item.content || '',
        user_name: item.user_name,
        created_at: item.created_at,
        status_id: item.status_id,
        status_name: item.status_name,
        color: item.color
      }))
    } catch {
      activities.value = []
    } finally {
      activitiesLoading.value = false
    }
  }

  function resetFollowForm() {
    followContent.value = ''
    syncFollowStatusFromDetail()
  }

  async function submitFollow() {
    const text = followContent.value.trim()
    if (!text) {
      ElMessage.warning('请填写跟进内容')
      return
    }
    if (!detailId.value) return
    followSubmitting.value = true
    try {
      const payload: Record<string, unknown> = {
        record_type: CRM_ORDER_RECORD_TYPE,
        record_id: detailId.value,
        content: text
      }
      if (followStatusId.value !== null && followStatusId.value !== '') {
        payload.status_id = followStatusId.value
      }
      await createActivityApi(payload)
      ElMessage.success('跟进已保存')
      followContent.value = ''
      await loadDetail()
      propertyRefreshKey.value += 1
      await loadActivities()
    } catch {
      ElMessage.error('提交失败')
    } finally {
      followSubmitting.value = false
    }
  }

  watch(
    detailId,
    async () => {
      if (!detailId.value) return
      await loadDetail()
      await loadActivities()
    },
    { immediate: true }
  )

  function goBack() {
    router.push({ path: '/crm/orders' })
  }

  function goCreateFromPre() {
    router.push({ path: '/crm/orders/new' })
  }
</script>

<style scoped lang="scss">
  @use '@/views/crm/detail-common.scss' as *;

  .order-detail-page .detail-panel {
    max-width: none;
  }

  .detail-main-grid {
    display: grid;
    grid-template-columns: minmax(0, 1fr) 340px;
    gap: 16px;
    align-items: start;
  }

  @media (width <= 1100px) {
    .detail-main-grid {
      grid-template-columns: 1fr;
    }

    .detail-main-aside {
      position: static;
    }
  }

  .detail-main-aside {
    position: sticky;
    top: 12px;
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .order-attach-card {
    .order-attach-body {
      display: flex;
      flex-direction: column;
      gap: 10px;
    }

    .order-attach-placeholder {
      font-size: 13px;
      color: var(--el-text-color-secondary);
    }

    .order-attach-hint {
      margin: 0;
      font-size: 12px;
      line-height: 1.4;
      color: var(--el-text-color-secondary);
    }
  }

  .detail-follow-wrap {
    padding-top: 16px;
    margin-top: 20px;
    border-top: 1px solid var(--el-border-color-lighter);
  }

  .detail-follow-tabs {
    :deep(.el-tabs__header) {
      margin-bottom: 12px;
    }
  }

  .activity-table-toolbar {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    align-items: center;
  }

  .activity-table-wrap {
    min-height: 120px;
  }

  .cell-dash {
    color: var(--el-text-color-placeholder);
  }

  .unified-info-body {
    display: flex;
    flex-direction: column;
    gap: 0;

    :deep(.el-divider) {
      margin: 20px 0 14px;

      &:first-child {
        margin-top: 0;
      }
    }

    :deep(.el-divider__text) {
      font-size: 14px;
      font-weight: 600;
      color: var(--el-text-color-primary);
    }

    .group-desc {
      margin-bottom: 0;
    }

    .detail-matrix--in-card {
      margin-top: 0;
    }
  }

  /* 各区块 Descriptions 标签列宽一致（与 label-width 对齐） */
  .group-desc--uniform {
    width: 100%;

    :deep(.el-descriptions__label) {
      box-sizing: border-box;
      width: 140px !important;
      min-width: 140px;
      max-width: 140px;
    }

    :deep(.el-descriptions__content) {
      min-width: 0;
    }
  }

  .info-group-card--unified {
    :deep(.el-card__body) {
      padding-top: 12px;
    }
  }

  .info-group-card {
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 8px;
  }

  .group-card-title {
    font-size: 15px;
    font-weight: 600;
    color: var(--el-text-color-primary);
  }

  .group-desc :deep(.el-descriptions__body) {
    background: transparent;
  }

  .logo-cell {
    display: flex;
    align-items: center;
  }

  .client-logo {
    max-width: 120px;
    max-height: 48px;
    object-fit: contain;
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 4px;
  }

  .file-link {
    color: var(--el-color-primary);
  }

  .header-status-tag {
    flex-shrink: 0;
    font-weight: 500;
  }

  .desc-status-tag {
    font-weight: 500;
  }

  .matrix-wrap {
    overflow-x: auto;
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 8px;
  }

  .empty-lines {
    padding: 32px;
  }

  .crm-orders-matrix {
    width: 100%;
    min-width: 860px;
    font-size: 13px;
    border-collapse: collapse;
  }

  .crm-orders-matrix th,
  .crm-orders-matrix td {
    padding: 8px 6px;
    text-align: center;
    vertical-align: middle;
    border: 1px solid #bdbdbd;
  }

  .th-base {
    font-weight: 600;
    background: #e8e8e8;
  }

  .td-line {
    background: #fafafa;
  }

  .td-require {
    max-width: 220px;
    text-align: left !important;
  }

  .follow-card {
    .follow-card-header {
      display: flex;
      flex-direction: column;
      gap: 6px;
      align-items: flex-start;
    }

    .follow-card-hint {
      font-size: 12px;
      font-weight: 400;
      line-height: 1.4;
      color: var(--el-text-color-secondary);
    }

    .follow-form-block {
      &--aside {
        padding-bottom: 0;
      }
    }

    .follow-form-row {
      display: flex;
      gap: 12px;
      align-items: flex-start;
      margin-bottom: 14px;

      &--textarea {
        align-items: stretch;
      }
    }

    .follow-label {
      flex: 0 0 72px;
      padding-top: 6px;
      font-size: 13px;
      color: var(--el-text-color-regular);
    }

    .follow-field {
      flex: 1;
      min-width: 0;
    }

    .follow-form-actions {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      align-items: center;
      padding-left: 84px;

      &--aside {
        padding-left: 84px;
        margin-top: 4px;
      }
    }
  }
</style>
