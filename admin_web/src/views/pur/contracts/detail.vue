<template>
  <div class="pur-contract-detail-container">
    <div class="detail-header-bar">
      <div class="header-left">
        <ElButton text class="back-btn" @click="handleGoBack">
          <ArtSvgIcon icon="ri:arrow-left-line" />
        </ElButton>
        <span class="header-name">{{ detailData.code || '采购合同详情' }}</span>
      </div>
      <div class="header-right">
        <ElButton text class="header-action-btn" @click="handleRefresh">
          <ArtSvgIcon icon="ri:refresh-line" class="mr-1" />刷新
        </ElButton>
        <ElButton type="primary" @click="handleGoToFmContract" v-if="detailData.contract_id">
          关联销售合同
        </ElButton>
      </div>
    </div>
    <div class="detail-content-wrapper">
      <div class="detail-panel">
        <!-- 基本信息：按创建时字段展示 -->
        <ElCard shadow="never" class="info-card-single">
          <div class="info-block-title">基本信息</div>
          <div class="info-rows">
            <div class="info-row">
              <span class="info-label">合同编号</span>
              <span class="info-value">{{ detailData.code || '-' }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">供方</span>
              <span class="info-value">{{ detailData.supplier_name || '-' }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">需方</span>
              <span class="info-value">{{ detailData.client_name || '-' }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">签订日期</span>
              <span class="info-value">{{ detailData.signing_date || '-' }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">预计交货时间</span>
              <span class="info-value">{{ detailData.deliver_at || '-' }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">交货地点</span>
              <span class="info-value">{{ detailData.deliver_addr || '-' }}</span>
            </div>
            <div class="info-row">
              <span class="info-label">签订地点</span>
              <span class="info-value">{{ detailData.signing_location || '-' }}</span>
            </div>
            <div class="info-row info-row-full" v-if="detailData.remark">
              <span class="info-label">备注</span>
              <span class="info-value">{{ detailData.remark }}</span>
            </div>
          </div>
        </ElCard>

        <!-- 产品明细：按 sign 展示不同列 -->
        <div class="section-title">产品明细</div>
        <ElTable v-loading="loadingLines" :data="lines" border stripe class="product-table">
          <ElTableColumn type="index" width="55" label="序号" />
          <!-- raw_material -->
          <template v-if="detailData.sign === 'raw_material'">
            <ElTableColumn
              prop="product_name"
              label="产品名称"
              min-width="160"
              show-overflow-tooltip
            />
            <ElTableColumn prop="unit" label="单位" width="80" />
            <ElTableColumn prop="qty" label="数量(KG)" width="110" align="right">
              <template #default="{ row }">{{ formatNum(row.qty) }}</template>
            </ElTableColumn>
            <ElTableColumn prop="price" label="单价(RMB)" width="110" align="right">
              <template #default="{ row }">{{ formatNum(row.price) }}</template>
            </ElTableColumn>
            <ElTableColumn prop="amount" label="总金额(RMB)" width="120" align="right">
              <template #default="{ row }">{{ formatNum(row.amount) }}</template>
            </ElTableColumn>
          </template>
          <!-- carton -->
          <template v-else-if="detailData.sign === 'carton'">
            <ElTableColumn prop="product_name" label="品名" min-width="200" show-overflow-tooltip />
            <ElTableColumn prop="length" label="长" width="90" align="right">
              <template #default="{ row }">{{ formatNum(row.length) }}</template>
            </ElTableColumn>
            <ElTableColumn prop="width" label="宽" width="90" align="right">
              <template #default="{ row }">{{ formatNum(row.width) }}</template>
            </ElTableColumn>
            <ElTableColumn prop="height" label="高" width="90" align="right">
              <template #default="{ row }">{{ formatNum(row.height) }}</template>
            </ElTableColumn>
            <ElTableColumn prop="qty" label="数量" width="100" align="right">
              <template #default="{ row }">{{ formatNum(row.qty) }}</template>
            </ElTableColumn>
            <ElTableColumn prop="price" label="单价(RMB)" width="110" align="right">
              <template #default="{ row }">{{ formatNum(row.price) }}</template>
            </ElTableColumn>
            <ElTableColumn prop="amount" label="总金额(RMB)" width="120" align="right">
              <template #default="{ row }">{{ formatNum(row.amount) }}</template>
            </ElTableColumn>
            <ElTableColumn prop="remark" label="备注" min-width="160" show-overflow-tooltip />
          </template>
          <!-- bottle -->
          <template v-else-if="detailData.sign === 'bottle'">
            <ElTableColumn
              prop="product_name"
              label="产品名称"
              min-width="160"
              show-overflow-tooltip
            />
            <ElTableColumn prop="unit" label="规格" width="100" show-overflow-tooltip />
            <ElTableColumn prop="qty" label="数量" width="100" align="right">
              <template #default="{ row }">{{ formatNum(row.qty) }}</template>
            </ElTableColumn>
            <ElTableColumn prop="price" label="单价(RMB)" width="110" align="right">
              <template #default="{ row }">{{ formatNum(row.price) }}</template>
            </ElTableColumn>
            <ElTableColumn prop="amount" label="总金额(RMB)" width="120" align="right">
              <template #default="{ row }">{{ formatNum(row.amount) }}</template>
            </ElTableColumn>
            <ElTableColumn
              prop="bottle_body_color"
              label="瓶身颜色"
              width="120"
              show-overflow-tooltip
            />
            <ElTableColumn prop="lid" label="盖子" min-width="140" show-overflow-tooltip />
            <ElTableColumn prop="remark" label="备注" min-width="140" show-overflow-tooltip />
          </template>
          <!-- 未知 sign 时通用列 -->
          <template v-else>
            <ElTableColumn
              prop="product_name"
              label="产品名称"
              min-width="160"
              show-overflow-tooltip
            />
            <ElTableColumn prop="unit" label="单位" width="80" />
            <ElTableColumn prop="qty" label="数量" width="100" align="right">
              <template #default="{ row }">{{ formatNum(row.qty) }}</template>
            </ElTableColumn>
            <ElTableColumn prop="price" label="单价(RMB)" width="110" align="right">
              <template #default="{ row }">{{ formatNum(row.price) }}</template>
            </ElTableColumn>
            <ElTableColumn prop="amount" label="总金额(RMB)" width="120" align="right">
              <template #default="{ row }">{{ formatNum(row.amount) }}</template>
            </ElTableColumn>
          </template>
        </ElTable>
        <div v-if="lines.length > 0" class="purchase-block-summary">
          <span class="summary-label">合计：</span>
          <span class="summary-amount">RMB {{ formatNum(totalAmount) }}</span>
          <span v-if="totalAmountChinese" class="summary-chinese"
            >（{{ totalAmountChinese }}）</span
          >
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onMounted } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import { ElMessage } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { ElButton, ElCard, ElTable, ElTableColumn } from 'element-plus'
  import { viewPurContractApi, listPurCollectionApi } from '@/api/pur/contract'

  defineOptions({ name: 'PurContractDetail' })

  const route = useRoute()
  const router = useRouter()
  const detailId = computed(() => {
    const id = route.params.id || route.query.id
    const single = Array.isArray(id) ? id[0] : id
    return single != null ? (single as string | number) : undefined
  })

  const detailData = ref<Record<string, any>>({})
  const lines = ref<any[]>([])
  const loadingLines = ref(false)

  const formatNum = (v: any) => {
    if (v == null || v === '') return '-'
    const n = Number(v)
    return Number.isNaN(n)
      ? '-'
      : n.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }

  const totalAmount = computed(() =>
    lines.value.reduce((sum, row) => sum + (Number(row.amount) || 0), 0)
  )

  function toChineseAmount(n: number): string {
    if (n === 0) return ''
    const digits = ['零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖']
    const units = ['', '拾', '佰', '仟']
    const bigUnits = ['', '万', '亿']
    const parts: string[] = []
    let intPart = Math.floor(n)
    let decPart = Math.round((n - intPart) * 100)
    if (intPart === 0) parts.push('零')
    else {
      let unitIndex = 0
      while (intPart > 0) {
        let segment = intPart % 10000
        let segStr = ''
        let place = 0
        while (segment > 0) {
          const d = segment % 10
          if (d !== 0) segStr = digits[d] + units[place] + segStr
          else if (segStr && !segStr.startsWith('零')) segStr = '零' + segStr
          segment = Math.floor(segment / 10)
          place++
        }
        if (segStr) parts.unshift(segStr + bigUnits[unitIndex])
        intPart = Math.floor(intPart / 10000)
        unitIndex++
      }
    }
    let result = parts.join('') + '元'
    if (decPart > 0) {
      const jiao = Math.floor(decPart / 10)
      const fen = decPart % 10
      result += (jiao ? digits[jiao] + '角' : '') + (fen ? digits[fen] + '分' : '整')
    } else result += '整'
    return result
  }

  const totalAmountChinese = computed(() => {
    const t = totalAmount.value
    return t > 0 ? toChineseAmount(t) : ''
  })

  const loadDetail = async () => {
    if (!detailId.value) {
      ElMessage.warning('ID不存在')
      return
    }
    try {
      const res = await viewPurContractApi({ id: detailId.value })
      detailData.value = (res as any).data || {}
    } catch {
      ElMessage.error('加载详情失败')
      return
    }
    loadLines()
  }

  const loadLines = async () => {
    if (!detailId.value) return
    loadingLines.value = true
    try {
      const res = await listPurCollectionApi({
        'q[purchase_contract_id_eq]': detailId.value,
        per_page: 500
      })
      const data = (res as any).data || []
      const arr = Array.isArray(data) ? data : data.list || data.data || []
      lines.value = arr.filter((r: any) => r != null)
    } catch {
      lines.value = []
    } finally {
      loadingLines.value = false
    }
  }

  const handleGoBack = () => router.back()
  const handleRefresh = () => loadDetail()
  const handleGoToFmContract = () => {
    const cid = detailData.value?.contract_id
    if (cid) {
      const sign = detailData.value?.sign || 'raw_material'
      router.push({ path: `/fm/contracts/${cid}`, query: { tab: sign } })
    }
  }

  onMounted(() => loadDetail())
</script>

<style scoped lang="scss">
  .pur-contract-detail-container {
    display: flex;
    flex-direction: column;
    width: 100%;
    min-height: 100vh;
    background: #fff;
  }

  .detail-header-bar {
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
    }

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

    .header-right {
      display: flex;
      gap: 8px;
      align-items: center;
    }

    .header-action-btn {
      color: var(--el-text-color-regular);

      &:hover {
        color: var(--el-color-primary);
      }
    }
  }

  .detail-content-wrapper {
    flex: 1;
    padding: 16px 20px;
    overflow-y: auto;
  }

  .detail-panel {
    max-width: 1200px;
    margin: 0 auto;
  }

  .info-card-single {
    margin-bottom: 24px;
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 10px;

    :deep(.el-card__body) {
      padding: 0;
    }
  }

  .info-block-title {
    padding: 12px 20px;
    font-size: 14px;
    font-weight: 600;
    color: var(--el-text-color-primary);
    background: var(--el-fill-color-light);
    border-bottom: 1px solid var(--el-border-color-lighter);
    border-radius: 10px 10px 0 0;
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
    font-size: 13px;
    color: var(--el-text-color-secondary);
  }

  .info-value {
    font-size: 14px;
    line-height: 1.5;
    color: var(--el-text-color-primary);
  }

  .section-title {
    margin-bottom: 12px;
    font-size: 14px;
    font-weight: 600;
    color: var(--el-text-color-primary);
  }

  .product-table {
    margin-bottom: 12px;
  }

  .purchase-block-summary {
    padding: 12px 20px;
    font-size: 14px;
    background: var(--el-fill-color-light);
    border-radius: 0 0 8px 8px;

    .summary-label {
      margin-right: 8px;
      color: var(--el-text-color-regular);
    }

    .summary-amount {
      font-weight: 600;
      color: var(--el-text-color-primary);
    }

    .summary-chinese {
      margin-left: 8px;
      font-size: 13px;
      color: var(--el-text-color-secondary);
    }
  }
</style>
