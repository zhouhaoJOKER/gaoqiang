<template>
  <div class="tab-carton-purchases">
    <div class="tab-toolbar">
      <ElButton type="primary" @click="handleAdd">
        <ArtSvgIcon icon="ri:add-line" class="mr-1" />新增包装箱采购
      </ElButton>
    </div>
    <div v-loading="loading" class="purchase-list">
      <template v-if="contractList.length === 0 && !loading">
        <ElEmpty description="暂无包装箱采购合同" />
      </template>
      <div v-for="pc in contractList" :key="pc.id" class="purchase-block">
        <div class="purchase-block-header">
          <span class="contract-code">合同编号：{{ pc.code || '-' }}</span>
          <span class="supplier-name" v-if="pc.supplier_name">供方：{{ pc.supplier_name }}</span>
          <span class="sign-date" v-if="pc.signing_date">签订日期：{{ pc.signing_date }}</span>
        </div>
        <ElTable :data="getLines(pc.id)" border stripe class="product-table">
          <ElTableColumn type="index" width="55" label="序号" />
          <ElTableColumn prop="product_name" label="品名" min-width="200" show-overflow-tooltip />
          <ElTableColumn prop="length" label="长" width="90" align="right">
            <template #default="{ row }">
              {{ formatNum(row.length) }}
            </template>
          </ElTableColumn>
          <ElTableColumn prop="width" label="宽" width="90" align="right">
            <template #default="{ row }">
              {{ formatNum(row.width) }}
            </template>
          </ElTableColumn>
          <ElTableColumn prop="height" label="高" width="90" align="right">
            <template #default="{ row }">
              {{ formatNum(row.height) }}
            </template>
          </ElTableColumn>
          <ElTableColumn prop="qty" label="数量" width="100" align="right">
            <template #default="{ row }">
              {{ formatNum(row.qty) }}
            </template>
          </ElTableColumn>
          <ElTableColumn prop="price" label="单价(RMB)" width="110" align="right">
            <template #default="{ row }">
              {{ formatNum(row.price) }}
            </template>
          </ElTableColumn>
          <ElTableColumn prop="amount" label="总金额(RMB)" width="120" align="right">
            <template #default="{ row }">
              {{ formatNum(row.amount) }}
            </template>
          </ElTableColumn>
          <ElTableColumn prop="remark" label="备注" min-width="160" show-overflow-tooltip />
        </ElTable>
        <div class="purchase-block-summary">
          <span class="summary-label">合计：</span>
          <span class="summary-amount">RMB {{ formatNum(getContractTotal(pc.id)) }}</span>
          <span v-if="getTotalChinese(pc.id)" class="summary-chinese"
            >（{{ getTotalChinese(pc.id) }}）</span
          >
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, watch } from 'vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { ElButton, ElTable, ElTableColumn, ElEmpty } from 'element-plus'
  import { listPurContractApi, listPurCollectionApi } from '@/api/pur/contract'

  const props = defineProps<{ contractId?: string | number }>()
  const emit = defineEmits<{ (e: 'add'): void }>()

  const loading = ref(false)
  const contractList = ref<any[]>([])
  const collectionsByContract = ref<Record<string, any[]>>({})

  const formatNum = (v: any) => {
    if (v == null || v === '') return '-'
    const n = Number(v)
    return Number.isNaN(n)
      ? '-'
      : n.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }

  const getLines = (contractId: string | number) => {
    return collectionsByContract.value[String(contractId)] || []
  }

  const getContractTotal = (contractId: string | number) => {
    const lines = getLines(contractId)
    const total = lines.reduce((sum, row) => sum + (Number(row.amount) || 0), 0)
    return total
  }

  const getTotalChinese = (contractId: string | number) => {
    const total = getContractTotal(contractId)
    if (total === 0) return ''
    return toChineseAmount(total)
  }

  function toChineseAmount(n: number) {
    const digits = ['零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖']
    const units = ['', '拾', '佰', '仟']
    const bigUnits = ['', '万', '亿']
    if (n === 0) return '零元整'
    const intPart = Math.floor(n)
    const decPart = Math.round((n - intPart) * 100)
    let s = String(intPart)
    let result = ''
    const len = s.length
    for (let i = 0; i < len; i++) {
      const d = Number(s[i])
      const u = units[(len - 1 - i) % 4]
      const bu = len - 1 - i >= 4 ? bigUnits[Math.floor((len - 1 - i) / 4)] : ''
      if (d !== 0) {
        result += digits[d] + u
      } else if (result && result[result.length - 1] !== '零') {
        result += '零'
      }
      if (u === '' && bu) result += bu
    }
    result = result.replace(/零+$/, '') || '零'
    result += '元'
    if (decPart === 0) result += '整'
    else {
      result += digits[Math.floor(decPart / 10)] + (decPart >= 10 ? '角' : '')
      if (decPart % 10) result += digits[decPart % 10] + '分'
    }
    return result
  }

  const fetchList = async (contractId: string | number) => {
    if (!contractId) return
    loading.value = true
    try {
      const res = await listPurContractApi({
        'q[contract_id_eq]': contractId,
        'q[sign_eq]': 'carton',
        per_page: 100
      })
      const data = (res as any).data || []
      const arr = Array.isArray(data) ? data : data.list || data.data || []
      contractList.value = arr.filter((c: any) => c && c.id != null)
      const next: Record<string, any[]> = {}
      for (const pc of contractList.value) {
        try {
          const colRes = await listPurCollectionApi({
            'q[purchase_contract_id_eq]': pc.id,
            per_page: 500
          })
          const colData = (colRes as any).data || []
          const colArr = Array.isArray(colData) ? colData : colData.list || colData.data || []
          next[String(pc.id)] = colArr.filter((r: any) => r != null)
        } catch {
          next[String(pc.id)] = []
        }
      }
      collectionsByContract.value = next
    } catch {
      contractList.value = []
      collectionsByContract.value = {}
    } finally {
      loading.value = false
    }
  }

  const handleAdd = () => emit('add')

  watch(
    () => props.contractId,
    (id) => {
      if (id) fetchList(id)
    },
    { immediate: true }
  )
</script>

<style scoped>
  .tab-carton-purchases .tab-toolbar {
    margin-bottom: 16px;
  }

  .purchase-list {
    min-height: 120px;
  }

  .purchase-block {
    padding: 16px;
    margin-bottom: 24px;
    background: var(--el-bg-color);
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 8px;
  }

  .purchase-block-header {
    margin-bottom: 12px;
    font-size: 14px;
    color: var(--el-text-color-regular);
  }

  .purchase-block-header .contract-code {
    margin-right: 16px;
    font-weight: 500;
  }

  .purchase-block-header .supplier-name,
  .purchase-block-header .sign-date {
    margin-right: 16px;
  }

  .product-table {
    margin-bottom: 12px;
  }

  .purchase-block-summary {
    font-size: 14px;
    font-weight: 500;
    color: var(--el-text-color-primary);
  }

  .purchase-block-summary .summary-label {
    margin-right: 8px;
  }

  .purchase-block-summary .summary-amount {
    margin-right: 8px;
  }

  .purchase-block-summary .summary-chinese {
    font-size: 13px;
    font-weight: 400;
    color: var(--el-text-color-regular);
  }
</style>
