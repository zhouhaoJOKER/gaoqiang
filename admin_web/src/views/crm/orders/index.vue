<template>
  <div class="crm-orders-page art-full-height">
    <div class="crm-orders-search-toolbar" v-show="showSearchBar">
      <div class="crm-orders-search">
        <ElInput
          v-model="searchForm.code"
          class="search-field"
          clearable
          placeholder="订单编号"
          @clear="handleSearch"
          @keyup.enter="handleSearch"
        >
          <template #prefix>
            <ArtSvgIcon icon="ri:hashtag" class="search-field-icon" />
          </template>
        </ElInput>
        <ElSelect
          v-model="searchForm.client_id"
          class="search-field-client"
          placeholder="客户"
          filterable
          remote
          reserve-keyword
          clearable
          :remote-method="searchClients"
          :loading="clientSearchLoading"
          @change="handleSearch"
          @clear="handleSearch"
        >
          <ElOption
            v-for="c in clientOptions"
            :key="c.id"
            :label="clientOptionLabel(c)"
            :value="c.id"
          />
        </ElSelect>
        <ElInput
          v-model="searchForm.contract_code"
          class="search-field"
          clearable
          placeholder="合同编号"
          @clear="handleSearch"
          @keyup.enter="handleSearch"
        >
          <template #prefix>
            <ArtSvgIcon icon="ri:file-text-line" class="search-field-icon" />
          </template>
        </ElInput>
        <PropertySelectWithAdd
          v-model="searchForm.status_id"
          sign="crm_order_status"
          placeholder="订单状态"
          class="search-field-status"
          @change="handleSearch"
        />
        <ElDatePicker
          v-model="searchForm.customerDeliveryRange"
          type="daterange"
          range-separator="至"
          start-placeholder="客户交期起"
          end-placeholder="客户交期止"
          value-format="YYYY-MM-DD"
          class="search-field-delivery"
          clearable
        />
        <ElButton type="primary" @click="handleSearch">搜索</ElButton>
        <ElButton @click="handleResetSearch">重置</ElButton>
      </div>

      <div class="crm-orders-search-quick">
        <span class="quick-label">接单日期</span>
        <ElRadioGroup v-model="receiveQuick" size="small" @change="onReceiveQuickChange">
          <ElRadioButton value="all">不限</ElRadioButton>
          <ElRadioButton value="today">今天</ElRadioButton>
          <ElRadioButton value="week">本周</ElRadioButton>
          <ElRadioButton value="month">本月</ElRadioButton>
        </ElRadioGroup>
      </div>
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
          <ElButton type="primary" @click="goCreate" v-ripple>
            <ArtSvgIcon icon="ri:add-line" /> 新建订单
          </ElButton>
          <ElButton
            type="default"
            :disabled="selectedOrderCount === 0"
            @click="handleExportSelected"
            v-ripple
          >
            <ArtSvgIcon icon="ri:download-line" /> 导出
          </ElButton>
        </template>
      </ArtTableHeader>

      <ArtTable
        :fit="false"
        :loading="loading"
        :data="tableRows"
        :columns="visibleColumns"
        :pagination="pagination"
        :row-style="rowStyle"
        :span-method="spanMethod"
        @pagination:size-change="onSizeChange"
        @pagination:current-change="onCurrentChange"
      >
        <template #receive_date-header>
          <div class="th-sort-inner">
            <span>接单日期</span>
            <ElTooltip content="按接单日期排序" placement="top">
              <ElButton
                size="small"
                :type="sortActiveType('receive_date')"
                link
                class="th-sort-btn"
                @click.stop="toggleSort('receive_date')"
              >
                <ArtSvgIcon :icon="sortIcon('receive_date')" />
              </ElButton>
            </ElTooltip>
          </div>
        </template>

        <template #customer_delivery_date-header>
          <div class="th-sort-inner">
            <span>客户交期</span>
            <ElTooltip content="按客户交期排序" placement="top">
              <ElButton
                size="small"
                :type="sortActiveType('customer_delivery_date')"
                link
                class="th-sort-btn"
                @click.stop="toggleSort('customer_delivery_date')"
              >
                <ArtSvgIcon :icon="sortIcon('customer_delivery_date')" />
              </ElButton>
            </ElTooltip>
          </div>
        </template>
      </ArtTable>
    </ElCard>
  </div>
</template>

<script setup lang="ts">
  import { computed, h, onMounted, reactive, ref } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import ArtTableHeader from '@/components/core/tables/art-table-header/index.vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import {
    ElButton,
    ElCard,
    ElCheckbox,
    ElDatePicker,
    ElInput,
    ElOption,
    ElRadioButton,
    ElRadioGroup,
    ElSelect,
    ElTag,
    ElTooltip,
    ElMessage
  } from 'element-plus'
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'
  import { listCrmClientApi, viewCrmClientApi } from '@/api/crm/client'
  import { listCrmOrderApi } from '@/api/crm/order'
  import { receiveRangeByQuick } from '@/views/crm/crm-date-range'
  import { crmOrderRowBgByStatus, crmOrderStatusTagAttrs } from '@/views/crm/crm-order-status'
  import type { ColumnOption } from '@/types/component'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'CrmOrders' })

  const router = useRouter()
  const route = useRoute()

  interface OrderLineItem {
    id?: number
    file_url?: string
    product_name?: string
    model?: string
    color?: string
    weight?: string
    qty?: number | string
    unit?: string
    stock_status?: string
    color_master_status?: string
    spec_requirements?: string
    remark?: string
    product_image_url?: string
    unit_price?: number | string | null
    line_amount?: number | string | null
    ship_doc_unreturned?: string | null
    ship_doc_returned?: string | null
  }

  interface OrderRow {
    id: number
    client_id?: number | string | null
    code?: string
    spec_requirements?: string | null
    hazard_pack_month?: string | null
    status_name?: string
    status_color?: string
    receive_date?: string
    contract_code?: string
    customer_delivery_date?: string
    follow_at?: string | null
    delivered_qty?: number | string | null
    invoice_at?: string | null
    client_name?: string
    client_logo_url?: string | null
    follower_name?: string | null
    line_items?: OrderLineItem[]
  }

  interface TableRow {
    key: string
    order: OrderRow
    line: OrderLineItem | null
    status_color?: string | null

    // 订单头（每个 order_line 都复制一份，避免 rowspan 错位）
    receive_date?: string | null
    client_id?: number | string | null
    client_name?: string | null
    client_logo_url?: string | null
    contract_code?: string | null
    hazard_pack_month?: string | null
    customer_delivery_date?: string | null
    follow_at?: string | null
    delivered_qty?: number | string | null
    invoice_at?: string | null
    follower_name?: string | null
    status_name?: string | null

    // 明细行
    product_name?: string | null
    model?: string | null
    stock_status?: string | null
    color?: string | null
    spec_requirements?: string | null
    remark?: string | null
    weight?: string | null
    color_master_status?: string | null
    line_thumb_url?: string
    qty?: number | string | null
    unit?: string | null
    unit_price?: number | string | null
    line_amount?: number | string | null
    undelivered_qty?: number
    ship_doc_unreturned?: string | null
    ship_doc_returned?: string | null
  }

  const loading = ref(false)
  const orders = ref<OrderRow[]>([])

  const pagination = reactive({
    current: 1,
    size: 20,
    total: 0
  })

  const searchForm = reactive({
    code: '',
    client_id: null as number | string | null,
    contract_code: '',
    status_id: null as number | string | null,
    customerDeliveryRange: null as [string, string] | null
  })

  const receiveQuick = ref<'all' | 'today' | 'week' | 'month'>('all')

  type SortField = 'receive_date' | 'status_id' | 'customer_delivery_date'
  const sortKey = ref<SortField | null>(null)
  const sortDir = ref<'asc' | 'desc'>('desc')

  const clientOptions = ref<Array<{ id: number | string; name?: string; code?: string }>>([])
  const clientSearchLoading = ref(false)

  const showSearchBar = ref(true)
  const selectedOrderIds = ref<Set<number>>(new Set())
  const selectedOrderCount = computed(() => selectedOrderIds.value.size)

  const tableRows = computed<TableRow[]>(() => {
    const out: TableRow[] = []
    for (const order of orders.value) {
      const lines = order.line_items?.length
        ? order.line_items
        : ([null] as Array<OrderLineItem | null>)
      const undeliveredQty = orderUndelivered(order)
      for (const line of lines) {
        const thumb = lineThumb(line)
        out.push({
          key: `${order.id}-${line?.id ?? 'x'}`,
          order,
          line: line || null,
          status_color: order.status_color,

          // 订单头
          receive_date: order.receive_date ?? null,
          client_id: order.client_id ?? null,
          client_name: order.client_name ?? null,
          client_logo_url: order.client_logo_url ?? null,
          contract_code: order.contract_code ?? null,
          hazard_pack_month: order.hazard_pack_month ?? null,
          customer_delivery_date: order.customer_delivery_date ?? null,
          follow_at: order.follow_at ?? null,
          delivered_qty: order.delivered_qty ?? null,
          invoice_at: order.invoice_at ?? null,
          follower_name: order.follower_name ?? null,
          status_name: order.status_name ?? null,

          // 明细行
          product_name: line?.product_name ?? null,
          model: line?.model ?? null,
          stock_status: line?.stock_status ?? null,
          color: line?.color ?? null,
          // “要求”优先显示订单头字段（crm_orders.spec_requirements）
          spec_requirements: order.spec_requirements ?? (line as any)?.spec_requirements ?? null,
          remark: line?.remark ?? null,
          weight: line?.weight ?? null,
          color_master_status: line?.color_master_status ?? null,
          line_thumb_url: thumb || '',
          qty: line?.qty ?? null,
          unit: line?.unit ?? null,
          unit_price: line?.unit_price ?? null,
          line_amount: lineAmount(line),
          undelivered_qty: undeliveredQty,
          ship_doc_unreturned: line?.ship_doc_unreturned ?? null,
          ship_doc_returned: line?.ship_doc_returned ?? null
        })
      }
    }
    return out
  })

  const columnsAll = computed<ColumnOption<TableRow>[]>(() => [
    {
      prop: 'order_select',
      label: '',
      width: 48,
      fixed: 'left',
      formatter: (row) =>
        h(ElCheckbox, {
          modelValue: selectedOrderIds.value.has(row.order.id),
          'onUpdate:modelValue': (val: unknown) => setOrderSelected(row.order.id, !!val)
        })
    },
    {
      prop: 'receive_date',
      label: '接单日期',
      minWidth: 120,
      useHeaderSlot: true,
      formatter: (row) =>
        h('div', { class: 'receive-cell is-link' }, [
          h(
            'button',
            {
              type: 'button',
              class: 'file-link table-link receive-link',
              onClick: () => goDetail(row.order.id)
            },
            fmtDate(row.receive_date)
          ),
          h(
            ElTag,
            {
              ...crmOrderStatusTagAttrs(row.status_color),
              size: 'small'
            },
            () => row.status_name || '—'
          )
        ])
    },
    {
      prop: 'client_name',
      label: '客户',
      minWidth: 160,
      formatter: (row) =>
        h('div', { class: 'client-cell' }, [
          row.client_id != null
            ? h(
                'button',
                {
                  type: 'button',
                  class: 'client-name file-link table-link',
                  onClick: () => filterByClient(row.order)
                },
                row.client_name || '—'
              )
            : h('span', { class: 'client-name' }, row.client_name || '—'),
          row.client_logo_url
            ? h('img', { class: 'client-logo', src: mediaUrl(row.client_logo_url), alt: '' })
            : null
        ])
    },
    {
      prop: 'contract_code',
      label: '合同编号',
      minWidth: 140,
      formatter: (row) => row.contract_code || '—'
    },
    {
      prop: 'product_name',
      label: '产品名称',
      minWidth: 140,
      formatter: (row) => row.product_name || '—'
    },
    { prop: 'model', label: '型号', minWidth: 120, formatter: (row) => row.model || '—' },
    {
      prop: 'stock_status',
      label: '铝箔垫情况',
      minWidth: 120,
      formatter: (row) => row.stock_status || '—'
    },
    { prop: 'color', label: '颜色', minWidth: 120, formatter: (row) => row.color || '—' },
    {
      prop: 'spec_requirements',
      label: '要求',
      minWidth: 160,
      formatter: (row) => row.spec_requirements || '—'
    },
    { prop: 'weight', label: '克重', minWidth: 90, formatter: (row) => row.weight || '—' },
    {
      prop: 'color_master_status',
      label: '色母情况',
      minWidth: 120,
      formatter: (row) => row.color_master_status || '—'
    },
    {
      prop: 'line_thumb_url',
      label: '产品图文',
      minWidth: 110,
      formatter: (row) =>
        row.line_thumb_url
          ? h('img', { class: 'product-thumb', src: mediaUrl(row.line_thumb_url), alt: '' })
          : h('span', { class: 'thumb-ph' }, '—')
    },
    { prop: 'qty', label: '订单量', minWidth: 110, formatter: (row) => fmtQty(row.qty) },
    { prop: 'unit', label: '单位', minWidth: 90, formatter: (row) => row.unit || '—' },
    {
      prop: 'hazard_pack_month',
      label: '危包月份',
      minWidth: 110,
      formatter: (row) => row.hazard_pack_month || '—'
    },
    {
      prop: 'customer_delivery_date',
      label: '客户交期',
      minWidth: 120,
      useHeaderSlot: true,
      formatter: (row) => fmtDate(row.customer_delivery_date)
    },
    {
      prop: 'follow_at',
      label: '跟进日期',
      minWidth: 120,
      formatter: (row) => fmtDate(row.follow_at)
    },
    {
      prop: 'unit_price',
      label: '单价',
      minWidth: 110,
      formatter: (row) => fmtMoney(row.unit_price)
    },
    {
      prop: 'line_amount',
      label: '金额',
      minWidth: 120,
      formatter: (row) => fmtMoney(row.line_amount)
    },
    {
      prop: 'delivered_qty',
      label: '交货情况已发',
      minWidth: 110,
      formatter: (row) => fmtQty(row.delivered_qty)
    },
    {
      prop: 'undelivered_qty',
      label: '未发量',
      minWidth: 110,
      formatter: (row) => fmtQty(row.undelivered_qty)
    },
    {
      prop: 'invoice_at',
      label: '开票日期',
      minWidth: 120,
      formatter: (row) => fmtDate(row.invoice_at)
    },
    {
      prop: 'ship_doc_unreturned',
      label: '发货单未回',
      minWidth: 130,
      formatter: (row) => row.ship_doc_unreturned || '—'
    },
    {
      prop: 'ship_doc_returned',
      label: '发货单已回',
      minWidth: 130,
      formatter: (row) => row.ship_doc_returned || '—'
    },
    {
      prop: 'follower_name',
      label: '跟单员',
      minWidth: 100,
      formatter: (row) => row.follower_name || '—'
    },
    { prop: 'remark', label: '备注', minWidth: 160, formatter: (row) => row.remark || '—' }
  ])

  const columnChecks = ref<ColumnOption<TableRow>[]>(columnsAll.value.map((c) => ({ ...c })))

  const visibleColumns = computed(() => {
    return columnChecks.value.filter((c) => c.visible !== false)
  })

  type MergeProp =
    | 'order_select'
    | 'receive_date'
    | 'client_name'
    | 'contract_code'
    | 'spec_requirements'
    | 'hazard_pack_month'
    | 'invoice_at'

  const mergeProps = new Set<MergeProp>([
    'order_select',
    'receive_date',
    'client_name',
    'contract_code',
    'spec_requirements',
    'hazard_pack_month',
    'invoice_at'
  ])

  const orderRowSpanMeta = computed(() => {
    const startMap = new Map<number, number>()
    const countMap = new Map<number, number>()
    tableRows.value.forEach((r, idx) => {
      const oid = r.order.id
      if (!startMap.has(oid)) startMap.set(oid, idx)
      countMap.set(oid, (countMap.get(oid) || 0) + 1)
    })
    return { startMap, countMap }
  })

  function spanMethod(data: {
    row: Record<string, any>
    column: { property?: string }
    rowIndex: number
    columnIndex: number
  }) {
    const prop = (data.column?.property || '') as MergeProp
    if (!mergeProps.has(prop)) return { rowspan: 1, colspan: 1 }

    const r = data.row as TableRow
    const oid = r.order.id
    const start = orderRowSpanMeta.value.startMap.get(oid)
    const count = orderRowSpanMeta.value.countMap.get(oid) || 1

    if (start === data.rowIndex) return { rowspan: count, colspan: 1 }
    return { rowspan: 0, colspan: 0 }
  }

  function rowStyle({ row }: { row: Record<string, any> }) {
    const r = row as TableRow
    return { backgroundColor: crmOrderRowBgByStatus(r.status_color) }
  }

  function setOrderSelected(orderId: number, val: boolean) {
    const next = new Set(selectedOrderIds.value)
    if (val) next.add(orderId)
    else next.delete(orderId)
    selectedOrderIds.value = next
  }

  function handleExportSelected() {
    if (selectedOrderIds.value.size === 0) {
      ElMessage.warning('请先勾选要导出的记录')
      return
    }
    const cols = visibleColumns.value.filter((c) => c.prop !== 'order_select')
    const _data = tableRows.value
      .filter((r) => selectedOrderIds.value.has(r.order.id))
      .map((r) => ({
        ...r,
        receive_date: fmtDate(r.receive_date),
        customer_delivery_date: fmtDate(r.customer_delivery_date),
        follow_at: fmtDate(r.follow_at),
        invoice_at: fmtDate(r.invoice_at)
      }))
    exportExcel(cols, _data, '订单列表导出')
  }

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

  function lineThumb(line: OrderLineItem | null) {
    if (!line) return ''
    return line.file_url || line.product_image_url || ''
  }

  function fmtQty(v?: number | string | null) {
    if (v === null || v === undefined || v === '') return '—'
    const n = Number(v)
    if (Number.isNaN(n)) return String(v)
    return String(n)
  }

  function fmtMoney(v?: number | string | null) {
    if (v === null || v === undefined || v === '') return '—'
    const n = Number(v)
    if (Number.isNaN(n)) return String(v)
    return n.toFixed(2)
  }

  function lineAmount(line: OrderLineItem | null) {
    if (!line) return null
    const explicit = (line as any).line_amount
    if (explicit !== null && explicit !== undefined && explicit !== '') return explicit
    const qty = Number(line.qty)
    const price = Number((line as any).unit_price)
    if (Number.isNaN(qty) || Number.isNaN(price)) return null
    return qty * price
  }

  function orderTotalQty(order: OrderRow) {
    const lines = order.line_items || []
    return lines.reduce((sum, l: any) => sum + (Number(l?.qty) || 0), 0)
  }

  function orderUndelivered(order: OrderRow) {
    const total = orderTotalQty(order)
    const delivered = Number((order as any).delivered_qty) || 0
    const v = total - delivered
    return v < 0 ? 0 : v
  }

  function clientOptionLabel(c: { code?: string; name?: string }) {
    const code = (c.code || '').trim()
    const name = (c.name || '').trim()
    if (code && name) return `[${code}] ${name}`
    return name || code || '—'
  }

  async function searchClients(query: string) {
    clientSearchLoading.value = true
    try {
      const res = await listCrmClientApi({
        'q[name_or_code_cont]': query || '',
        per_page: 50
      })
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      clientOptions.value = arr.filter((c: any) => c && c.id != null)
    } finally {
      clientSearchLoading.value = false
    }
  }

  function buildListParams(): Record<string, string | number> {
    const params: Record<string, string | number> = {
      page: pagination.current,
      per_page: pagination.size
    }
    const q = searchForm
    if (q.code?.trim()) params['q[code_cont]'] = q.code.trim()
    if (q.client_id !== null && q.client_id !== undefined && q.client_id !== '') {
      params['q[client_id_eq]'] = q.client_id as number | string
    }
    if (q.contract_code?.trim()) params['q[contract_code_cont]'] = q.contract_code.trim()
    if (q.status_id !== null && q.status_id !== undefined && q.status_id !== '') {
      params['q[status_id_eq]'] = q.status_id as number | string
    }
    if (q.customerDeliveryRange?.length === 2) {
      params['q[customer_delivery_date_gteq]'] = q.customerDeliveryRange[0]
      params['q[customer_delivery_date_lteq]'] = q.customerDeliveryRange[1]
    }
    if (receiveQuick.value !== 'all') {
      const { gte, lte } = receiveRangeByQuick(receiveQuick.value)
      params['q[receive_date_gteq]'] = gte
      params['q[receive_date_lteq]'] = lte
    }
    if (sortKey.value) {
      params['q[s]'] = `${sortKey.value} ${sortDir.value}`
    }
    return params
  }

  function sortIcon(field: SortField) {
    if (sortKey.value !== field) return 'ri:arrow-up-down-line'
    return sortDir.value === 'asc' ? 'ri:arrow-up-s-line' : 'ri:arrow-down-s-line'
  }

  function sortActiveType(field: SortField): 'primary' | 'default' {
    return sortKey.value === field ? 'primary' : 'default'
  }

  function toggleSort(field: SortField) {
    if (sortKey.value === field) {
      sortDir.value = sortDir.value === 'asc' ? 'desc' : 'asc'
    } else {
      sortKey.value = field
      sortDir.value = 'desc'
    }
    pagination.current = 1
    load()
  }

  async function load() {
    loading.value = true
    try {
      const res = (await listCrmOrderApi(buildListParams())) as any
      orders.value = res.data || []
      pagination.total = Number(res.total) || 0
    } finally {
      loading.value = false
    }
  }

  function ensureClientOptionForFilter(order: OrderRow) {
    const id = order.client_id
    if (id == null || id === '') return
    const exists = clientOptions.value.some((c) => String(c.id) === String(id))
    if (!exists) {
      clientOptions.value = [{ id, name: order.client_name || undefined }, ...clientOptions.value]
    }
  }

  async function ensureClientOptionById(id: number | string) {
    const exists = clientOptions.value.some((c) => String(c.id) === String(id))
    if (exists) return
    try {
      const res = (await viewCrmClientApi({ id })) as any
      const c = res?.data
      if (c?.id != null) {
        clientOptions.value = [{ id: c.id, name: c.name, code: c.code }, ...clientOptions.value]
      } else {
        clientOptions.value = [{ id, name: undefined }, ...clientOptions.value]
      }
    } catch {
      clientOptions.value = [{ id, name: undefined }, ...clientOptions.value]
    }
  }

  function filterByClient(order: OrderRow) {
    if (order.client_id == null || order.client_id === '') return
    ensureClientOptionForFilter(order)
    searchForm.client_id = order.client_id
    pagination.current = 1
    router.replace({ path: '/crm/orders', query: { client_id: String(order.client_id) } })
    load()
  }

  function handleSearch() {
    pagination.current = 1
    load()
  }

  function onReceiveQuickChange() {
    handleSearch()
  }

  function handleResetSearch() {
    searchForm.code = ''
    searchForm.client_id = null
    searchForm.contract_code = ''
    searchForm.status_id = null
    searchForm.customerDeliveryRange = null
    receiveQuick.value = 'all'
    sortKey.value = null
    sortDir.value = 'desc'
    clientOptions.value = []
    pagination.current = 1
    router.replace({ path: '/crm/orders', query: {} })
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

  function goCreate() {
    router.push({ path: '/crm/orders/new' })
  }

  function goDetail(id: number) {
    router.push({ path: `/crm/orders/${id}` })
  }

  onMounted(async () => {
    const cid = route.query.client_id
    const cidValue = Array.isArray(cid) ? cid[0] : cid
    if (cidValue != null && String(cidValue) !== '') {
      const id = /^\d+$/.test(String(cidValue)) ? Number(cidValue) : String(cidValue)
      searchForm.client_id = id
      await ensureClientOptionById(id)
      pagination.current = 1
    }
    await load()
  })
</script>

<style scoped>
  .crm-orders-page {
    display: flex;
    flex-direction: column;
    min-width: 0;
    min-height: 0;
  }

  /* 表格全屏时：与 order-lines 一致，保证宽表可横向滚动 */
  .crm-orders-page :deep(.art-table-card) {
    min-width: 0;
  }

  .crm-orders-page :deep(.art-table-card .el-card__body) {
    display: flex;
    flex-direction: column;
    min-width: 0;
    min-height: 0;
  }

  .crm-orders-page :deep(.art-table-card .el-card__body .art-table) {
    flex: 1;
    min-width: 0;
    min-height: 0;
  }

  .crm-orders-search-toolbar {
    display: flex;
    flex-wrap: wrap;
    gap: 12px;
    align-items: center;
    padding: 12px 14px;
    margin-top: 8px;
    margin-bottom: 10px;
    background: var(--el-fill-color-lighter);
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 8px;
  }

  .crm-orders-search {
    display: flex;
    flex: 1 1 auto;
    flex-wrap: wrap;
    gap: 10px;
    align-items: center;
    min-width: 0;
  }

  .crm-orders-search-quick {
    display: flex;
    flex: 0 0 auto;
    flex-wrap: wrap;
    gap: 8px;
    align-items: center;
    padding-left: 12px;
    margin-left: auto;
    border-left: 1px solid var(--el-border-color-lighter);
  }

  .quick-label {
    font-size: 13px;
    color: var(--el-text-color-secondary);
    white-space: nowrap;
  }

  .search-field-delivery {
    width: 240px;
  }

  .th-sort-head {
    padding-right: 6px;
    padding-left: 6px;
    vertical-align: middle;
  }

  .th-sort-inner {
    display: inline-flex;
    gap: 2px;
    align-items: center;
    justify-content: center;
    white-space: nowrap;
  }

  .th-sort-inner .th-sort-btn {
    flex-shrink: 0;
    min-height: auto;
    padding: 2px 4px;
    margin-left: 2px;
  }

  .th-sort-inner .th-sort-btn :deep(.art-svg-icon) {
    font-size: 16px;
  }

  .search-field {
    width: 160px;
  }

  .search-field--wide {
    width: 200px;
  }

  .search-field-client {
    width: 220px;
  }

  .search-field-status {
    width: 200px;
  }

  .search-field-icon {
    font-size: 16px;
    color: var(--el-text-color-placeholder);
  }

  .matrix-wrap {
    margin-top: 0;
    overflow-x: auto;
    border: 1px solid #bdbdbd;
    border-radius: 4px;
  }

  .order-row > td {
    background-color: var(--order-row-bg, #e8f5e9) !important;
  }

  .code-link {
    font-weight: 600;
    color: var(--el-color-primary);
    text-decoration: none;
  }

  .code-link:hover {
    text-decoration: underline;
  }

  .td-code {
    min-width: 120px;
  }

  .crm-orders-matrix {
    width: 100%;
    min-width: 1480px;
    font-size: 13px;
    table-layout: fixed;
    border-collapse: collapse;
  }

  .crm-orders-matrix th,
  .crm-orders-matrix td {
    padding: 8px 6px;
    text-align: center;
    word-break: break-word;
    vertical-align: middle;
    border: 1px solid #bdbdbd;
  }

  .th-base {
    font-weight: 600;
    color: #212121;
    background: #e0e0e0;
  }

  .th-require {
    width: 22%;
    min-width: 200px;
  }

  .th-status {
    width: 100px;
    min-width: 96px;
  }

  .th-delivery {
    width: 110px;
    font-weight: 600;
    color: #1565c0;
    background: #b3d7f2;
  }

  .td-merge {
    font-weight: 500;
    background: #e8f5e9;
  }

  .td-line {
    background: #e8f5e9;
  }

  .td-require {
    line-height: 1.45;
    text-align: left !important;
  }

  .td-delivery {
    font-weight: 500;
    background: #e8f5e9;
  }

  .td-empty {
    padding: 24px !important;
    color: #757575;
    background: #fafafa;
  }

  .cell-purple {
    font-weight: 500;
    color: #7b1fa2;
  }

  .td-thumb {
    width: 72px;
  }

  .product-thumb {
    max-width: 56px;
    max-height: 56px;
    vertical-align: middle;
    object-fit: contain;
    border: 1px solid #c8e6c9;
    border-radius: 4px;
  }

  .thumb-ph {
    color: #9e9e9e;
  }

  .td-num {
    white-space: nowrap;
  }

  .client-cell {
    display: flex;
    flex-direction: column;
    gap: 6px;
    align-items: center;
    padding: 4px 0;
  }

  .client-name {
    line-height: 1.3;
  }

  .table-link {
    padding: 0;
    margin: 0;
    font: inherit;
    color: var(--theme-color);
    text-align: center;
    text-decoration: none;
    cursor: pointer;
    background: none;
    border: none;
  }

  .table-link:hover {
    text-decoration: underline;
    cursor: pointer;
  }

  /* 与详情页 `file-link` 一致：可点击字段使用主题色 */
  .file-link {
    color: var(--theme-color);
  }

  .receive-cell {
    display: flex;
    flex-direction: column;
    gap: 4px;
    align-items: center;
    padding: 2px 0;
  }

  .receive-sub {
    font-size: 12px;
    line-height: 1.2;
    color: var(--el-text-color-secondary);
    white-space: nowrap;
  }

  .td-status {
    vertical-align: middle;
  }

  .order-status-tag {
    max-width: 100%;
    font-weight: 500;
  }

  .status-empty {
    color: #9e9e9e;
  }

  .client-logo {
    max-width: 72px;
    max-height: 40px;
    object-fit: contain;
    background: #fff;
    border: 1px solid #e0e0e0;
    border-radius: 2px;
  }

  .th-month {
    width: 90px;
    min-width: 90px;
  }

  .td-month {
    white-space: nowrap;
  }

  .th-money {
    width: 90px;
    min-width: 90px;
  }

  .th-ship {
    width: 80px;
    min-width: 80px;
  }

  .th-invoice {
    width: 96px;
    min-width: 96px;
  }

  .th-shipdoc {
    width: 110px;
    min-width: 110px;
  }

  .td-shipdoc {
    white-space: nowrap;
  }

  .th-follower {
    width: 80px;
    min-width: 80px;
  }

  .th-remark {
    width: 180px;
    min-width: 160px;
  }

  .td-remark {
    line-height: 1.35;
    text-align: left !important;
  }
</style>
