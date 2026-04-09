<template>
  <div class="art-full-height">
    <ElCard class="art-table-card" shadow="never">
      <ArtTableHeader :loading="loading" v-model:columns="columnChecks" @refresh="onToolbarRefresh">
        <template #left>
          <div class="pre-order-toolbar">
            <ElRadioGroup
              :model-value="filterStatus"
              size="small"
              class="status-filter"
              @update:model-value="onStatusScopeChange"
            >
              <ElRadioButton value="pending">待处理</ElRadioButton>
              <ElRadioButton value="all">全部</ElRadioButton>
            </ElRadioGroup>
            <ElInput
              v-model="keywordInput"
              class="search-input"
              clearable
              placeholder="搜索客户名称、客户编号"
              @clear="onSearch"
              @keyup.enter="onSearch"
            >
              <template #prefix>
                <ArtSvgIcon icon="ri:search-line" class="text-g-400" />
              </template>
            </ElInput>
            <ElButton type="primary" @click="onSearch">搜索</ElButton>
            <ElButton type="default" @click="onToolbarRefresh" v-ripple>
              <ArtSvgIcon icon="ri:refresh-line" /> 刷新
            </ElButton>
          </div>
        </template>
      </ArtTableHeader>

      <ArtTable
        :loading="loading"
        :data="data as PreOrderItem[]"
        :columns="columns"
        :pagination="pagination"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      />
    </ElCard>

    <ElDialog v-model="viewVisible" title="预购单详情" width="860px">
      <div class="mb-2 text-sm text-gray-600"
        >客户：{{ viewRow?.customer_name || '-' }} / 编号：{{ viewRow?.customer_code || '-' }}</div
      >
      <div class="mb-3 text-sm text-gray-500"
        >规格要求：{{ viewRow?.spec_requirements || '-' }}</div
      >
      <ElTable :data="viewLines" border stripe>
        <ElTableColumn type="index" label="#" width="50" />
        <ElTableColumn prop="product_name" label="产品名称" min-width="160" />
        <ElTableColumn prop="model" label="型号" width="110" />
        <ElTableColumn prop="color" label="颜色" width="100" />
        <ElTableColumn prop="weight" label="克重" width="110" />
        <ElTableColumn prop="quantity" label="数量" width="90" />
        <ElTableColumn prop="unit" label="单位" width="90" />
      </ElTable>
      <template #footer>
        <ElButton @click="viewVisible = false">关闭</ElButton>
      </template>
    </ElDialog>
  </div>
</template>

<script setup lang="ts">
  import { computed, h, ref } from 'vue'
  import { useRouter } from 'vue-router'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { useTable } from '@/hooks/core/useTable'
  import ArtButtonTable from '@/components/core/forms/art-button-table/index.vue'
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import { listCrmPreOrderApi, viewCrmPreOrderApi, updateCrmPreOrderApi } from '@/api/crm/pre-order'
  import { ElButton, ElCard, ElInput, ElMessage, ElRadioButton, ElRadioGroup } from 'element-plus'

  defineOptions({ name: 'CrmPreOrders' })

  interface PreOrderItem {
    id: number | string
    customer_name?: string
    customer_code?: string
    status?: string
    created_at?: string
    crm_order_id?: number | string
    crm_order_code?: string
    processor_name?: string
    [key: string]: any
  }

  const router = useRouter()
  const viewVisible = ref(false)
  const viewRow = ref<any>(null)
  const viewLines = ref<any[]>([])

  /** 与接口同步：默认仅待处理；全部时不传 pending 过滤 */
  const keywordInput = ref('')

  const {
    columns,
    columnChecks,
    data,
    loading,
    pagination,
    searchParams,
    refreshData,
    refreshCreate,
    handleSizeChange,
    handleCurrentChange
  } = useTable({
    core: {
      apiFn: listCrmPreOrderApi,
      apiParams: {
        page: 1,
        per_page: 20,
        status_scope: 'pending',
        keyword: ''
      } as Record<string, unknown>,
      columnsFactory: () => [
        { type: 'index', width: 65, label: '序号' },
        { prop: 'id', label: '预购单ID', minWidth: 90 },
        { prop: 'customer_name', label: '客户', minWidth: 120 },
        { prop: 'customer_code', label: '客户编号', minWidth: 120 },
        {
          prop: 'status',
          label: '状态',
          width: 100,
          formatter: (row: unknown) => {
            const status = (row as PreOrderItem).status || '-'
            const c =
              status === 'converted' ? 'success' : status === 'processing' ? 'warning' : 'info'
            return h('span', { class: `el-tag el-tag--${c} el-tag--light` }, status)
          }
        },
        {
          prop: 'crm_order_code',
          label: '已转订单',
          minWidth: 120,
          formatter: (row: unknown) => (row as PreOrderItem).crm_order_code || '-'
        },
        { prop: 'processor_name', label: '处理人', minWidth: 100 },
        {
          prop: 'created_at',
          label: '提交时间',
          minWidth: 160,
          formatter: (row: unknown) => {
            const v = (row as PreOrderItem).created_at
            if (!v) return '-'
            return String(v).replace('T', ' ').slice(0, 19)
          }
        },
        {
          prop: 'operation',
          label: '操作',
          width: 140,
          fixed: 'right',
          formatter: (row: unknown) =>
            h('div', { style: 'display:flex' }, [
              h(ArtButtonTable, {
                type: 'view',
                onClick: () => handleView(row as PreOrderItem)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'convert', label: '转订单', icon: 'ri:file-transfer-line' },
                  { key: 'processing', label: '标记处理中', icon: 'ri:time-line' },
                  { key: 'closed', label: '标记已关闭', icon: 'ri:close-circle-line' },
                  { key: 'orders', label: '订单列表', icon: 'ri:article-line' }
                ],
                onClick: (item: any) => handleMore(item.key, row as PreOrderItem)
              })
            ])
        }
      ]
    }
  })

  const filterStatus = computed(() => {
    const v = (searchParams as Record<string, unknown>).status_scope
    return v === 'all' ? 'all' : 'pending'
  })

  function syncQueryToSearchParams() {
    const sp = searchParams as Record<string, unknown>
    sp.keyword = keywordInput.value.trim()
  }

  function onStatusScopeChange(val: string | number | boolean | undefined) {
    const scope = String(val ?? '')
    const sp = searchParams as Record<string, unknown>
    sp.status_scope = scope === 'all' ? 'all' : 'pending'
    syncQueryToSearchParams()
    refreshCreate()
  }

  function onSearch() {
    syncQueryToSearchParams()
    refreshCreate()
  }

  function onToolbarRefresh() {
    syncQueryToSearchParams()
    refreshData()
  }

  async function handleView(row: PreOrderItem) {
    const res = await viewCrmPreOrderApi({ id: row.id })
    viewRow.value = (res as any).data || row
    viewLines.value = Array.isArray(viewRow.value?.line_items) ? viewRow.value.line_items : []
    viewVisible.value = true
  }

  async function handleMore(key: string, row: PreOrderItem) {
    if (key === 'convert') {
      router.push({
        path: '/crm/orders/new',
        query: { pre_order_id: String(row.id), customer_name: row.customer_name || '' }
      })
      return
    }
    if (key === 'processing') {
      await updateCrmPreOrderApi(row.id, { status: 'processing' })
      ElMessage.success('已标记处理中')
      onToolbarRefresh()
      return
    }
    if (key === 'closed') {
      await updateCrmPreOrderApi(row.id, { status: 'closed' })
      ElMessage.success('已标记已关闭')
      onToolbarRefresh()
      return
    }
    if (key === 'orders') {
      router.push({ path: '/crm/orders' })
    }
  }
</script>

<style scoped>
  .pre-order-toolbar {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    align-items: center;
  }

  .status-filter {
    flex-shrink: 0;
  }

  .search-input {
    width: 260px;
    max-width: 100%;
  }
</style>
