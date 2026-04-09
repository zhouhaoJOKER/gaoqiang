<template>
  <div class="internal-tracking-page art-full-height">
    <div class="it-search" v-show="showSearchBar">
      <ElInput
        v-model="searchForm.order_code"
        class="it-search-field"
        clearable
        placeholder="订单编号"
        @keyup.enter="handleSearch"
      />
      <ElInput
        v-model="searchForm.contract_code"
        class="it-search-field"
        clearable
        placeholder="合同编号"
        @keyup.enter="handleSearch"
      />
      <ElInput
        v-model="searchForm.client_name"
        class="it-search-field it-search-field--wide"
        clearable
        placeholder="客户名称"
        @keyup.enter="handleSearch"
      />
      <ElButton type="primary" @click="handleSearch">搜索</ElButton>
      <ElButton @click="handleReset">重置</ElButton>
    </div>

    <ElCard
      class="art-table-card"
      shadow="never"
      :style="{ 'margin-top': showSearchBar ? '12px' : '0' }"
    >
      <ArtTableHeader
        v-model:columns="columnChecks"
        v-model:showSearchBar="showSearchBar"
        :loading="loading"
        @refresh="load"
      >
        <template #left>
          <span class="page-title">订单行</span>
        </template>
      </ArtTableHeader>

      <ArtTable
        :fit="false"
        :loading="loading"
        :data="rows"
        :columns="visibleColumns"
        :pagination="pagination"
        @pagination:size-change="onSizeChange"
        @pagination:current-change="onCurrentChange"
      />
    </ElCard>
  </div>
</template>

<script setup lang="ts">
  import { computed, h, onMounted, reactive, ref } from 'vue'
  import { useRouter } from 'vue-router'
  import ArtTable from '@/components/core/tables/art-table/index.vue'
  import type { ColumnOption } from '@/types/component'
  import { ElButton, ElCard, ElDatePicker, ElInput, ElMessage, ElTag } from 'element-plus'
  import ArtTableHeader from '@/components/core/tables/art-table-header/index.vue'
  import { listCrmInternalTrackingApi, updateCrmOrderLineDataApi } from '@/api/crm/order'
  import { HttpError } from '@/utils/http/error'
  import { crmOrderStatusTagAttrs } from '@/views/crm/crm-order-status'

  defineOptions({ name: 'CrmOrderLines' })

  const router = useRouter()
  const loading = ref(false)
  const rows = ref<any[]>([])
  const showSearchBar = ref(true)

  const pagination = reactive({
    current: 1,
    size: 20,
    total: 0
  })

  const searchForm = reactive({
    order_code: '',
    contract_code: '',
    client_name: ''
  })

  function fmtDate(v?: string | null) {
    if (v == null || v === '') return '—'
    const s = String(v)
    return s.length >= 10 ? s.slice(0, 10) : s
  }

  function fmtQty(v?: number | string | null) {
    if (v === null || v === undefined || v === '') return '—'
    const n = Number(v)
    if (Number.isNaN(n)) return String(v)
    return String(n)
  }

  function buildParams(): Record<string, string | number> {
    const params: Record<string, string | number> = {
      page: pagination.current,
      per_page: pagination.size
    }
    if (searchForm.order_code?.trim()) params['q[order_code_cont]'] = searchForm.order_code.trim()
    if (searchForm.contract_code?.trim()) {
      params['q[order_contract_code_cont]'] = searchForm.contract_code.trim()
    }
    if (searchForm.client_name?.trim()) {
      params['q[order_client_name_cont]'] = searchForm.client_name.trim()
    }
    return params
  }

  function normalizeDecimal(v: unknown): number | null {
    if (v === '' || v === null || v === undefined) return null
    const n = Number(v)
    return Number.isNaN(n) ? null : n
  }

  const DECIMAL_KEYS = [
    'delivery_qty',
    'loss_qty',
    'semi_inventory',
    'semi_completed',
    'semi_reserve',
    'original_inventory',
    'outsourcing_qty',
    'unfinished_qty',
    'finished_total'
  ] as const

  const TEXT_KEYS = [
    'production_machine',
    'injection_prod_code',
    'gasket_machine',
    'gasket_prod_code'
  ] as const

  const DATE_KEYS = [
    'line_delivery_date',
    'injection_prod_date',
    'gasket_prod_date',
    'closing_date'
  ] as const

  function committedEquals(key: string, committed: unknown, payloadVal: unknown): boolean {
    if (DECIMAL_KEYS.includes(key as (typeof DECIMAL_KEYS)[number])) {
      return normalizeDecimal(committed) === (payloadVal as number | null)
    }
    if (DATE_KEYS.includes(key as (typeof DATE_KEYS)[number])) {
      const a = committed === '' || committed == null ? null : String(committed)
      const b = payloadVal === '' || payloadVal == null ? null : String(payloadVal)
      return a === b
    }
    if (TEXT_KEYS.includes(key as (typeof TEXT_KEYS)[number])) {
      const a = committed == null || committed === '' ? null : String(committed)
      const b = payloadVal == null || payloadVal === '' ? null : String(payloadVal)
      return a === b
    }
    return committed === payloadVal
  }

  async function patch(row: any, key: string, raw: unknown) {
    let payloadVal: unknown = raw
    if (DECIMAL_KEYS.includes(key as (typeof DECIMAL_KEYS)[number])) {
      payloadVal = normalizeDecimal(raw)
    } else if (TEXT_KEYS.includes(key as (typeof TEXT_KEYS)[number])) {
      payloadVal = raw === '' || raw == null ? null : String(raw)
    } else if (DATE_KEYS.includes(key as (typeof DATE_KEYS)[number])) {
      payloadVal = raw === '' || raw == null ? null : raw
    }

    const prevCommitted = row._crmCommitted?.[key]
    if (committedEquals(key, prevCommitted, payloadVal)) return

    try {
      await updateCrmOrderLineDataApi(row.id, { [key]: payloadVal })
      row[key] = payloadVal
      if (!row._crmCommitted) row._crmCommitted = {}
      if (DECIMAL_KEYS.includes(key as (typeof DECIMAL_KEYS)[number])) {
        row._crmCommitted[key] = payloadVal
      } else if (TEXT_KEYS.includes(key as (typeof TEXT_KEYS)[number])) {
        row._crmCommitted[key] = payloadVal == null || payloadVal === '' ? null : String(payloadVal)
      } else if (DATE_KEYS.includes(key as (typeof DATE_KEYS)[number])) {
        row._crmCommitted[key] = payloadVal == null || payloadVal === '' ? null : String(payloadVal)
      } else {
        row._crmCommitted[key] = payloadVal
      }
      ElMessage.success({ message: '已保存', duration: 1500 })
    } catch (e) {
      const msg = e instanceof HttpError ? e.message : '保存失败'
      ElMessage.error(msg)
      load()
    }
  }

  /** 与后端已持久化值对比，避免 blur 时 row 已被 input 改成字符串导致误判「未变更」 */
  function snapshotCommittedFields(row: Record<string, unknown>) {
    const m: Record<string, unknown> = {}
    for (const key of DECIMAL_KEYS) {
      m[key] = normalizeDecimal(row[key])
    }
    for (const key of TEXT_KEYS) {
      const v = row[key]
      m[key] = v == null || v === '' ? null : String(v)
    }
    for (const key of DATE_KEYS) {
      const v = row[key]
      m[key] = v == null || v === '' ? null : String(v)
    }
    row._crmCommitted = m
  }

  async function load() {
    loading.value = true
    try {
      const res = (await listCrmInternalTrackingApi(buildParams())) as any
      const list = res.data || []
      list.forEach((r: Record<string, unknown>) => snapshotCommittedFields(r))
      rows.value = list
      pagination.total = Number(res.total) || 0
    } finally {
      loading.value = false
    }
  }

  function handleSearch() {
    pagination.current = 1
    load()
  }

  function handleReset() {
    searchForm.order_code = ''
    searchForm.contract_code = ''
    searchForm.client_name = ''
    pagination.current = 1
    load()
  }

  function onSizeChange(val: number) {
    pagination.current = 1
    pagination.size = val
    load()
  }

  function onCurrentChange(val: number) {
    pagination.current = val
    load()
  }

  function goInternalTrackingDetail(lineId: number | string | null | undefined) {
    if (lineId == null || String(lineId) === '') return
    // 详情页改为 order-lines 语义
    router.push({ path: `/crm/order-lines/${lineId}` })
  }

  function fmtTagAttrs(color?: string | null) {
    return crmOrderStatusTagAttrs(color)
  }

  const columnsAll = computed<ColumnOption<any>[]>(() => [
    {
      prop: 'receive_date',
      label: '接单日期',
      minWidth: 130,
      formatter: (row) =>
        h('div', { class: 'it-receive-cell' }, [
          h(
            'button',
            {
              type: 'button',
              class: 'file-link it-link',
              onClick: () => goInternalTrackingDetail(row.id)
            },
            fmtDate(row.receive_date)
          ),
          row.order_status_name
            ? h(
                ElTag,
                { ...fmtTagAttrs(row.order_status_color), size: 'small', class: 'it-status-tag' },
                () => row.order_status_name
              )
            : h('span', { class: 'it-dash' }, '—')
        ])
    },
    {
      prop: 'client_name',
      label: '客户名称',
      minWidth: 150,
      formatter: (row) => row.client_name || '—'
    },
    {
      prop: 'contract_code',
      label: '合同号',
      minWidth: 140,
      formatter: (row) => row.contract_code || '—'
    },
    {
      prop: 'product_name',
      label: '产品名称',
      minWidth: 160,
      formatter: (row) => row.product_name || '—'
    },
    { prop: 'remark', label: '铝箔/要求', minWidth: 180, formatter: (row) => row.remark || '—' },
    {
      prop: 'stock_status',
      label: '铝箔结存情况',
      minWidth: 160,
      formatter: (row) => row.stock_status || '—'
    },
    { prop: 'color', label: '颜色', minWidth: 110, formatter: (row) => row.color || '—' },
    { prop: 'model', label: '配瓶型/盖型', minWidth: 160, formatter: (row) => row.model || '—' },
    { prop: 'weight', label: '克重', minWidth: 90, formatter: (row) => row.weight || '—' },
    {
      prop: 'color_master_status',
      label: '色母情况',
      minWidth: 120,
      formatter: (row) => row.color_master_status || '—'
    },
    { prop: 'qty', label: '订单量', minWidth: 84, formatter: (row) => fmtQty(row.qty) },
    {
      prop: 'delivery_qty',
      label: '交货情况',
      width: 132,
      minWidth: 124,
      formatter: (row) =>
        h('div', { class: 'it-edit-cell it-edit-cell--delivery it-edit-zone' }, [
          h('input', {
            key: `dq-${row.id}`,
            value: row.delivery_qty ?? '',
            type: 'text',
            inputmode: 'decimal',
            class: 'it-excel-input it-excel-input--num it-excel-input--zone',
            placeholder: '填写数量',
            onInput: (e: Event) => (row.delivery_qty = (e.target as HTMLInputElement).value),
            onBlur: (e: Event) => patch(row, 'delivery_qty', (e.target as HTMLInputElement).value),
            onKeydown: (e: KeyboardEvent) => {
              if (e.key === 'Enter') (e.target as HTMLInputElement).blur()
            }
          })
        ])
    },
    {
      prop: 'loss_qty',
      label: '配损量',
      width: 132,
      minWidth: 124,
      formatter: (row) =>
        h('div', { class: 'it-edit-cell it-edit-zone' }, [
          h('input', {
            value: row.loss_qty ?? '',
            type: 'text',
            inputmode: 'decimal',
            class: 'it-excel-input it-excel-input--num it-excel-input--zone',
            onInput: (e: Event) => (row.loss_qty = (e.target as HTMLInputElement).value),
            onBlur: (e: Event) => patch(row, 'loss_qty', (e.target as HTMLInputElement).value),
            onKeydown: (e: KeyboardEvent) => {
              if (e.key === 'Enter') (e.target as HTMLInputElement).blur()
            }
          })
        ])
    },
    {
      prop: 'line_delivery_date',
      label: '交期',
      width: 132,
      minWidth: 124,
      formatter: (row) =>
        h('div', { class: 'it-edit-cell it-edit-cell--date it-edit-zone' }, [
          h(ElDatePicker, {
            modelValue: row.line_delivery_date,
            'onUpdate:modelValue': (v: unknown) => (row.line_delivery_date = v),
            type: 'date',
            valueFormat: 'YYYY-MM-DD',
            size: 'small',
            class: 'it-dp',
            clearable: true,
            teleported: true,
            popperClass: 'crm-it-date-popper',
            onChange: (v: unknown) => patch(row, 'line_delivery_date', v)
          })
        ])
    },
    {
      prop: 'production_machine',
      label: '生产机台',
      width: 128,
      minWidth: 120,
      formatter: (row) =>
        h('div', { class: 'it-edit-cell it-edit-zone' }, [
          h('input', {
            value: row.production_machine ?? '',
            type: 'text',
            class: 'it-excel-input it-excel-input--zone',
            onInput: (e: Event) => (row.production_machine = (e.target as HTMLInputElement).value),
            onBlur: (e: Event) =>
              patch(row, 'production_machine', (e.target as HTMLInputElement).value)
          })
        ])
    },
    {
      prop: 'injection_prod_code',
      label: '注塑生产编号',
      width: 148,
      minWidth: 136,
      formatter: (row) =>
        h('div', { class: 'it-edit-cell it-edit-zone' }, [
          h('input', {
            value: row.injection_prod_code ?? '',
            type: 'text',
            class: 'it-excel-input it-excel-input--zone',
            onInput: (e: Event) => (row.injection_prod_code = (e.target as HTMLInputElement).value),
            onBlur: (e: Event) =>
              patch(row, 'injection_prod_code', (e.target as HTMLInputElement).value)
          })
        ])
    },
    {
      prop: 'injection_prod_date',
      label: '注塑生产日期',
      width: 132,
      minWidth: 124,
      formatter: (row) =>
        h('div', { class: 'it-edit-cell it-edit-cell--date it-edit-zone' }, [
          h(ElDatePicker, {
            modelValue: row.injection_prod_date,
            'onUpdate:modelValue': (v: unknown) => (row.injection_prod_date = v),
            type: 'date',
            valueFormat: 'YYYY-MM-DD',
            size: 'small',
            class: 'it-dp',
            clearable: true,
            teleported: true,
            popperClass: 'crm-it-date-popper',
            onChange: (v: unknown) => patch(row, 'injection_prod_date', v)
          })
        ])
    },
    {
      prop: 'gasket_machine',
      label: '垫盖机台',
      width: 128,
      minWidth: 120,
      formatter: (row) =>
        h('div', { class: 'it-edit-cell it-edit-zone' }, [
          h('input', {
            value: row.gasket_machine ?? '',
            type: 'text',
            class: 'it-excel-input it-excel-input--zone',
            onInput: (e: Event) => (row.gasket_machine = (e.target as HTMLInputElement).value),
            onBlur: (e: Event) => patch(row, 'gasket_machine', (e.target as HTMLInputElement).value)
          })
        ])
    },
    {
      prop: 'gasket_prod_code',
      label: '垫盖生产编号',
      width: 148,
      minWidth: 136,
      formatter: (row) =>
        h('div', { class: 'it-edit-cell it-edit-zone' }, [
          h('input', {
            value: row.gasket_prod_code ?? '',
            type: 'text',
            class: 'it-excel-input it-excel-input--zone',
            onInput: (e: Event) => (row.gasket_prod_code = (e.target as HTMLInputElement).value),
            onBlur: (e: Event) =>
              patch(row, 'gasket_prod_code', (e.target as HTMLInputElement).value)
          })
        ])
    },
    {
      prop: 'gasket_prod_date',
      label: '垫盖生产日期',
      width: 132,
      minWidth: 124,
      formatter: (row) =>
        h('div', { class: 'it-edit-cell it-edit-cell--date it-edit-zone' }, [
          h(ElDatePicker, {
            modelValue: row.gasket_prod_date,
            'onUpdate:modelValue': (v: unknown) => (row.gasket_prod_date = v),
            type: 'date',
            valueFormat: 'YYYY-MM-DD',
            size: 'small',
            class: 'it-dp',
            clearable: true,
            teleported: true,
            popperClass: 'crm-it-date-popper',
            onChange: (v: unknown) => patch(row, 'gasket_prod_date', v)
          })
        ])
    },
    {
      prop: 'closing_date',
      label: '结单日期',
      width: 132,
      minWidth: 124,
      formatter: (row) =>
        h('div', { class: 'it-edit-cell it-edit-cell--date it-edit-zone' }, [
          h(ElDatePicker, {
            modelValue: row.closing_date,
            'onUpdate:modelValue': (v: unknown) => (row.closing_date = v),
            type: 'date',
            valueFormat: 'YYYY-MM-DD',
            size: 'small',
            class: 'it-dp',
            clearable: true,
            teleported: true,
            popperClass: 'crm-it-date-popper',
            onChange: (v: unknown) => patch(row, 'closing_date', v)
          })
        ])
    },
    ...(
      [
        ['semi_inventory', '半成品库存量'],
        ['semi_completed', '半成品已完成量'],
        ['semi_reserve', '半成品生产备库存量'],
        ['original_inventory', '原库存量'],
        ['outsourcing_qty', '外加工量'],
        ['unfinished_qty', '订单生产未完成量'],
        ['finished_total', '成品已完成量合计']
      ] as Array<[string, string]>
    ).map(([k, label]) => ({
      prop: k,
      label,
      width: 118,
      minWidth: 108,
      formatter: (row: any) =>
        h('div', { class: 'it-edit-cell it-edit-zone' }, [
          h('input', {
            value: row[k] ?? '',
            type: 'text',
            inputmode: 'decimal',
            class: 'it-excel-input it-excel-input--num it-excel-input--zone',
            onInput: (e: Event) => (row[k] = (e.target as HTMLInputElement).value),
            onBlur: (e: Event) => patch(row, k, (e.target as HTMLInputElement).value),
            onKeydown: (e: KeyboardEvent) => {
              if (e.key === 'Enter') (e.target as HTMLInputElement).blur()
            }
          })
        ])
    }))
  ])

  const columnChecks = ref<ColumnOption<any>[]>(columnsAll.value.map((c) => ({ ...c })))
  const visibleColumns = computed(() => columnChecks.value.filter((c) => c.visible !== false))

  onMounted(() => {
    load()
  })
</script>

<style scoped>
  .internal-tracking-page {
    display: flex;
    flex-direction: column;
    min-width: 0;
    min-height: 0;
  }

  /* 全屏时与 .el-card__body 组成 flex 链，保证宽表可横向滚动 */
  .internal-tracking-page :deep(.art-table-card) {
    min-width: 0;
  }

  .internal-tracking-page :deep(.art-table-card .el-card__body) {
    display: flex;
    flex-direction: column;
    min-width: 0;
    min-height: 0;
  }

  .internal-tracking-page :deep(.art-table-card .el-card__body .art-table) {
    flex: 1;
    min-width: 0;
    min-height: 0;
  }

  .page-title {
    font-size: 15px;
    font-weight: 600;
    color: var(--el-text-color-primary);
  }

  .it-search {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    align-items: center;
    margin-bottom: 12px;
  }

  .it-search-field {
    width: 160px;
  }

  .it-search-field--wide {
    width: 200px;
  }

  /* 旧 it-matrix（手写 table）已移除：现使用 ArtTable/ElTable */

  .th-base {
    font-weight: 600;
    color: #212121;
    background: #e0e0e0;
  }

  .th-h-red {
    color: #c62828;
  }

  .th-h-green {
    color: #2e7d32;
  }

  .th-h-orange {
    color: #ef6c00;
  }

  .th-h-purple {
    color: #6a1b9a;
  }

  .th-contract {
    min-width: 120px;
  }

  .th-thumb,
  .td-thumb {
    box-sizing: border-box;
    width: 80px;
    min-width: 80px;
    max-width: 80px;
  }

  .th-date,
  .td-date {
    box-sizing: border-box;
    width: 118px;
    min-width: 118px;
    max-width: 118px;
    padding: 2px 4px !important;
    overflow: hidden;
    white-space: nowrap;
  }

  .td-base {
    background: #fff;
  }

  .td-left {
    text-align: left !important;
  }

  .td-contract {
    line-height: 1.35;
    white-space: pre-wrap;
  }

  .td-num {
    white-space: nowrap;
  }

  .it-thumb-wrap {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    min-height: 52px;
  }

  .it-thumb-img {
    display: block;
    width: auto;
    max-width: 72px;
    height: auto;
    max-height: 56px;
    object-fit: contain;
  }

  .it-thumb-ph {
    color: #9e9e9e;
  }

  .it-row--alt .td-base {
    background: #f1f8e9;
  }

  .td-cell-green {
    font-weight: 500;
    color: #1b5e20;
  }

  .td-cell-red {
    font-weight: 500;
    color: #b71c1c;
  }

  .td-cell-purple {
    font-weight: 500;
    color: #4a148c;
  }

  .td-empty {
    padding: 24px !important;
    color: #757575;
    background: #fafafa;
  }

  /* 与 ElDatePicker（.it-dp .el-input__wrapper）同高、同色、同 hover/focus */

  /* 交货区使用 .it-excel-input--zone，尺寸由 .it-edit-zone 与日期列对齐，勿写死 108px */
  .it-excel-input:not(.it-excel-input--zone) {
    box-sizing: border-box;
    width: 108px;
    min-width: 0;
    max-width: 108px;
    height: 24px;
    padding: 1px 2px;
    margin: 0;
    font-family: inherit;
    font-size: 12px;
    line-height: 24px;
    color: var(--el-text-color-primary, #303133);
    vertical-align: middle;
    background: var(--el-fill-color-blank, #fefefe);
    border: 1px solid var(--el-border-color, #dcdfe6);
    border-radius: 4px;
    box-shadow: none;
  }

  /* 日期面板已 teleport，单元格可裁切溢出，避免输入框撑破 td */
  :deep(.el-table .cell) {
    overflow: hidden;
  }

  :deep(.el-table td.el-table__cell) {
    overflow: hidden;
  }

  .it-edit-cell {
    display: block;
    width: 100%;
    min-width: 0;
    max-width: 100%;
    overflow: hidden;
  }

  .it-edit-cell--date {
    min-width: 0;
  }

  /* 交货情况及之后：与右侧 ElDatePicker（size=small）同宽、同高、同圆角与描边 */
  :deep(.it-edit-zone) {
    box-sizing: border-box;
    width: 100%;
    min-width: 0;
    max-width: 100%;

    /* 与 Element Plus small 输入框高度对齐（日期列同款） */
    --it-zone-ctrl-h: var(--el-input-height, 32px);
  }

  :deep(.it-edit-zone .it-dp.el-date-editor.el-input) {
    width: 100% !important;
    height: var(--it-zone-ctrl-h) !important;
    min-height: var(--it-zone-ctrl-h) !important;
  }

  :deep(.it-edit-zone .it-excel-input--zone),
  :deep(.it-edit-zone .it-excel-input.it-excel-input--zone) {
    box-sizing: border-box;
    width: 100% !important;
    min-width: 0;
    max-width: 100% !important;
    height: var(--it-zone-ctrl-h) !important;
    min-height: var(--it-zone-ctrl-h) !important;
    padding: 0 11px !important;
    margin: 0;
    font-family: inherit;
    font-size: var(--el-font-size-base);
    line-height: var(--it-zone-ctrl-h) !important;
    color: #303133 !important;
    vertical-align: middle;
    background-color: #fff !important;
    border: none !important;
    border-radius: var(--el-border-radius-base) !important;
    outline: none !important;
    box-shadow: 0 0 0 1px var(--el-border-color, #dcdfe6) inset !important;
  }

  :deep(.it-edit-zone .it-excel-input--zone:hover) {
    box-shadow: 0 0 0 1px var(--el-color-primary) inset !important;
  }

  :deep(.it-edit-zone .it-excel-input--zone:focus) {
    color: #303133 !important;
    background-color: #fff !important;
    box-shadow: 0 0 0 1px var(--el-color-primary) inset !important;
  }

  :deep(.it-edit-zone .it-excel-input--zone::placeholder) {
    color: #888 !important;
  }

  /* 日期列：与上方原生 input 同一高度、同一水平 padding，视觉一致 */
  :deep(.it-edit-zone .it-dp .el-input__wrapper) {
    box-sizing: border-box;
    height: var(--it-zone-ctrl-h) !important;
    min-height: var(--it-zone-ctrl-h) !important;
    padding: 0 11px !important;
    background-color: #fff !important;
    border: none !important;
    border-radius: var(--el-border-radius-base) !important;
    box-shadow: 0 0 0 1px var(--el-border-color, #dcdfe6) inset !important;
  }

  :deep(.it-edit-zone .it-dp .el-input__wrapper:hover),
  :deep(.it-edit-zone .it-dp .el-input__wrapper.is-focus) {
    background-color: #fff !important;
    box-shadow: 0 0 0 1px var(--el-color-primary) inset !important;
  }

  :deep(.it-edit-zone .it-dp input),
  :deep(.it-edit-zone .it-dp .el-input__inner) {
    height: auto !important;
    min-height: 0 !important;
    line-height: 1.25 !important;
    color: #303133 !important;
    -webkit-text-fill-color: #303133;
  }

  :deep(.it-edit-zone .it-dp .el-input__prefix),
  :deep(.it-edit-zone .it-dp .el-input__suffix) {
    color: var(--el-text-color-secondary);
  }

  /* 略增内边距，避免窄列里输入框被裁切难点中 */
  :deep(.el-table .cell:has(.it-edit-zone)) {
    padding-top: 4px;
    padding-bottom: 4px;
  }

  .it-excel-input:not(.it-excel-input--zone):hover {
    border-color: var(--el-color-primary);
    box-shadow: 0 0 0 1px var(--el-color-primary) inset;
  }

  .it-excel-input:not(.it-excel-input--zone):focus {
    background: var(--el-fill-color-blank, #fff);
    border-color: var(--el-color-primary);
    outline: none;
    box-shadow: 0 0 0 1px var(--el-color-primary) inset;
  }

  .it-excel-input--num {
    font-variant-numeric: tabular-nums;
    text-align: right;
  }

  .it-edit-cell--delivery {
    min-width: 0;
    padding: 2px 0;
  }

  .it-excel-input:not(.it-excel-input--zone)::placeholder {
    color: var(--el-text-color-placeholder);
  }

  .it-excel-input--date {
    width: 108px;
    min-width: 0;
    max-width: 108px;
    padding: 1px 2px;
    font-variant-numeric: tabular-nums;
  }

  .it-dp {
    width: 100%;
  }

  :deep(.it-dp) {
    width: 100% !important;
    max-width: 100% !important;
  }

  :deep(.it-dp .el-input__wrapper),
  :deep(.it-dp .el-date-editor) {
    box-sizing: border-box;
    width: 100% !important;
    min-width: 0 !important;
    max-width: 100% !important;
  }

  :deep(.it-dp .el-input__wrapper) {
    min-height: 24px;
    padding: 0 6px;
    background: var(--el-fill-color-blank, #fff);
    border: 1px solid var(--el-border-color, #dcdfe6);
    border-radius: 4px;
    box-shadow: none;
  }

  .td-date :deep(.el-input__wrapper) {
    box-sizing: border-box;
    width: 100% !important;
    min-width: 0 !important;
    max-width: 100% !important;
    height: 24px;
    padding: 0 6px;
    background: var(--el-fill-color-blank, #fff);
    border: 1px solid var(--el-border-color, #dcdfe6);
    border-radius: 4px;
    box-shadow: none;
  }

  .td-date :deep(.el-date-editor) {
    box-sizing: border-box;
    width: 100% !important;
    min-width: 0 !important;
    max-width: 100% !important;
  }

  .td-date :deep(.el-input__wrapper:hover),
  .td-date :deep(.el-input__wrapper.is-focus) {
    background: rgb(255 255 255 / 85%);
    border-color: #a0a0a0;
  }

  .td-date :deep(.el-input__wrapper.is-focus) {
    background: #fff;
    border-color: #217346;
    box-shadow: inset 0 0 0 1px #217346;
  }

  .td-date :deep(input) {
    box-sizing: border-box;
    width: 100% !important;
    min-width: 0 !important;
    padding: 0;
    font-size: 12px;
    color: var(--el-text-color-primary, #303133);
    text-align: center;
  }

  :deep(.it-dp .el-input__inner),
  :deep(.it-dp input) {
    color: var(--el-text-color-primary, #303133);
  }

  .it-receive-cell {
    display: flex;
    flex-direction: column;
    gap: 6px;
    align-items: flex-start;
  }

  .it-link {
    padding: 0;
    margin: 0;
    font: inherit;
    color: var(--el-color-primary);
    text-decoration: none;
    cursor: pointer;
    background: none;
    border: none;
  }

  .it-link:hover {
    text-decoration: underline;
  }

  .it-status-tag {
    align-self: flex-start;
  }

  .it-dash {
    color: #9e9e9e;
  }

  :deep(.it-dp .el-input__wrapper:hover),
  :deep(.it-dp .el-input__wrapper.is-focus) {
    border-color: var(--el-color-primary);
    box-shadow: 0 0 0 1px var(--el-color-primary) inset;
  }
</style>

<!-- 日期选择面板挂到 body，需全局提高层级，避免被表格/抽屉遮挡 -->
<style>
  .crm-it-date-popper {
    z-index: 5000 !important;
  }
</style>
