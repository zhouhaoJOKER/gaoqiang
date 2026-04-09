<template>
  <div class="art-full-height">
    <template v-if="!sign">
      <ElCard class="art-table-card" shadow="never">
        <ElEmpty
          description="请通过链接指定采购类型（sign），例如：pur/contracts?sign=raw_material"
        >
          <template #extra>
            <ElSpace>
              <ElButton type="primary" @click="goSign('raw_material')">原料采购合同</ElButton>
              <ElButton type="primary" @click="goSign('carton')">包装箱采购合同</ElButton>
              <ElButton type="primary" @click="goSign('bottle')">包装瓶采购合同</ElButton>
            </ElSpace>
          </template>
        </ElEmpty>
      </ElCard>
    </template>

    <ElCard v-else class="art-table-card" shadow="never">
      <ArtTableHeader
        v-model:columns="columnChecks"
        v-model:showSearchBar="showSearchBar"
        :loading="loading"
        @refresh="refreshData"
      >
        <template #left>
          <span class="page-title">{{ pageTitle }}</span>
        </template>
      </ArtTableHeader>
      <ArtTable
        ref="proTable"
        :loading="loading"
        :data="data as PurContractItem[]"
        :columns="columns"
        :pagination="pagination"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      />
    </ElCard>
  </div>
</template>

<script setup lang="ts">
  import { h, ref, computed, watch } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import { useTable } from '@/hooks/core/useTable'
  import ArtButtonTable from '@/components/core/forms/art-button-table/index.vue'
  import { listPurContractApi } from '@/api/pur/contract'
  import { ElButton, ElCard, ElEmpty, ElSpace, ElTooltip } from 'element-plus'

  defineOptions({ name: 'PurContracts' })

  const route = useRoute()
  const router = useRouter()

  const SIGN_MAP: Record<string, string> = {
    raw_material: '原料采购合同',
    carton: '包装箱采购合同',
    bottle: '包装瓶采购合同'
  }

  const sign = computed((): string => {
    const s = route.query.sign
    if (typeof s === 'string') return s
    if (Array.isArray(s) && s[0] != null) return s[0]
    return ''
  })

  const pageTitle = computed(() => (sign.value ? SIGN_MAP[sign.value] : '') || '采购合同')

  const goSign = (s: string) => {
    router.replace({ path: '/pur/contracts', query: { sign: s } })
  }

  interface PurContractItem {
    id?: string | number
    code?: string
    contract_id?: string | number
    supplier_name?: string
    client_name?: string
    signing_date?: string
    deliver_at?: string
    total_amount?: number | string
    total_amount_chinese?: string
    sign?: string
    [key: string]: any
  }

  const formatAmount = (v: any) => {
    if (v == null || v === '') return '-'
    const n = Number(v)
    return Number.isNaN(n)
      ? '-'
      : n.toLocaleString('zh-CN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })
  }

  const toChineseAmount = (n: number): string => {
    if (n === 0) return '零元整'
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

  const proTable = ref()
  const showSearchBar = ref(false)

  const {
    columns,
    columnChecks,
    data,
    loading,
    pagination,
    getData,
    searchParams,
    handleSizeChange,
    handleCurrentChange,
    refreshData
  } = useTable({
    core: {
      apiFn: listPurContractApi,
      apiParams: { page: 1, per_page: 20 },
      immediate: false,
      paginationKey: { current: 'page', size: 'per_page' },
      columnsFactory: () => [
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'code',
          label: '合同编号',
          minWidth: 140,
          formatter: (row: unknown) => {
            const r = row as PurContractItem
            return h(
              'span',
              { class: 'cursor-pointer hover:text-primary-500', onClick: () => handleView(r) },
              r.code || '-'
            )
          }
        },
        {
          prop: 'supplier_name',
          label: '供方',
          minWidth: 140,
          formatter: (row: unknown) => (row as PurContractItem).supplier_name || '-'
        },
        {
          prop: 'client_name',
          label: '需求',
          minWidth: 140,
          formatter: (row: unknown) => (row as PurContractItem).client_name || '-'
        },
        {
          prop: 'deliver_at',
          label: '预计交货时间',
          minWidth: 120,
          formatter: (row: unknown) => (row as PurContractItem).deliver_at || '-'
        },
        {
          prop: 'signing_date',
          label: '签订日期',
          minWidth: 120,
          formatter: (row: unknown) => (row as PurContractItem).signing_date || '-'
        },
        {
          prop: 'total_amount',
          label: '金额',
          minWidth: 120,
          align: 'right',
          formatter: (row: unknown) => {
            const r = row as PurContractItem
            const amount = r.total_amount
            const num = amount != null && amount !== '' ? Number(amount) : NaN
            const display = Number.isNaN(num) ? '-' : formatAmount(amount)
            const chinese =
              r.total_amount_chinese || (Number.isNaN(num) ? '' : toChineseAmount(num))
            if (!chinese) return h('span', {}, display)
            return h(
              ElTooltip,
              { content: chinese, placement: 'top' },
              { default: () => h('span', { class: 'cursor-default' }, display) }
            )
          }
        },
        {
          prop: 'operation',
          label: '操作',
          width: 86,
          fixed: 'right',
          formatter: (row: unknown) =>
            h('div', { style: 'display: flex' }, [
              h(ArtButtonTable, {
                type: 'view',
                onClick: () => handleView(row as PurContractItem)
              })
            ])
        }
      ]
    }
  })

  const handleView = (row: PurContractItem) => {
    const id = row?.id
    if (id) {
      router.push({ path: `/pur/contracts/${id}` })
    }
  }

  watch(
    sign,
    (newSign) => {
      if (newSign) {
        ;(searchParams as Record<string, unknown>)['q[sign_eq]'] = newSign
        ;(searchParams as Record<string, unknown>).page = 1
        getData()
      }
    },
    { immediate: true }
  )
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';

  .page-title {
    font-size: 16px;
    font-weight: 500;
  }
</style>
