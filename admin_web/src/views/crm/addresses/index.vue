<template>
  <div class="art-full-height">
    <AddressSearch
      v-show="showSearchBar"
      v-model="searchForm"
      @search="handleSearch"
      @reset="resetSearchParams"
      @add="handleCreate"
    />
    <ElCard
      class="art-table-card"
      shadow="never"
      :style="{ 'margin-top': showSearchBar ? '12px' : '0' }"
    >
      <ArtTableHeader
        v-model:columns="columnChecks"
        v-model:showSearchBar="showSearchBar"
        :loading="loading"
        @refresh="refreshData"
      >
        <template #left>
          <ElSpace wrap>
            <ElButton type="primary" @click="handleCreate" v-ripple
              ><ArtSvgIcon icon="ri:add-line" /> 新建收货地址</ElButton
            >
            <ElDropdown trigger="click">
              <ElButton type="default" v-ripple
                ><ArtSvgIcon icon="ri:more-2-line" /> 更多
                <ElIcon class="el-icon--right"><ArrowDown /></ElIcon
              ></ElButton>
              <template #dropdown>
                <ElDropdownMenu>
                  <ElDropdownItem @click="handleBatchDelete"
                    ><ArtSvgIcon class="el-icon--left" icon="ri:delete-bin-line" />
                    批量删除</ElDropdownItem
                  >
                  <ElDropdownItem divided></ElDropdownItem>
                  <ElDropdownItem @click="handleExport"
                    ><ArtSvgIcon class="el-icon--left" icon="ri:download-line" />
                    导出</ElDropdownItem
                  >
                </ElDropdownMenu>
              </template>
            </ElDropdown>
          </ElSpace>
        </template>
      </ArtTableHeader>
      <ArtTable
        ref="proTable"
        :loading="loading"
        :data="data as AddressItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      />
    </ElCard>
    <AddressDialog
      v-model="dialogVisible"
      :address="currentAddress"
      :readonly="isViewMode"
      @created="handleAddressCreated"
      @updated="handleAddressUpdated"
    />
  </div>
</template>

<script setup lang="ts">
  import { h, ref } from 'vue'
  import { useRouter } from 'vue-router'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { useTable } from '@/hooks/core/useTable'
  import ArtButtonTable from '@/components/core/forms/art-button-table/index.vue'
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import { ButtonMoreItem } from '@/components/core/forms/art-button-more/index.vue'
  import AddressSearch from './modules/address-search.vue'
  import AddressDialog from './modules/address-dialog.vue'
  import {
    ElButton,
    ElCard,
    ElMessage,
    ElMessageBox,
    ElSpace,
    ElDropdown,
    ElDropdownMenu,
    ElDropdownItem,
    ElIcon
  } from 'element-plus'
  import { ArrowDown } from '@element-plus/icons-vue'
  import {
    listCrmAddressApi,
    deleteCrmAddressApi,
    batchActionCrmAddressApi
  } from '@/api/crm/address'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'CrmAddress' })
  const router = useRouter()

  interface AddressItem {
    id?: string | number
    client_id?: string | number
    client_name?: string
    addr_kind?: string
    contact?: string
    phone?: string
    addr?: string
    is_default?: boolean
    remark?: string
    [key: string]: any
  }

  const searchForm = ref({ client_id_eq: undefined, addr_kind_eq: undefined })
  const proTable = ref()
  const showSearchBar = ref(true)
  const dialogVisible = ref(false)
  const currentAddress = ref<AddressItem | undefined>(undefined)
  const isViewMode = ref(false)
  const selectedRows = ref<AddressItem[]>([])

  const {
    columns,
    columnChecks,
    data,
    loading,
    pagination,
    getData,
    searchParams,
    refreshCreate,
    refreshUpdate,
    refreshRemove,
    resetSearchParams,
    handleSizeChange,
    handleCurrentChange,
    refreshData
  } = useTable({
    core: {
      apiFn: listCrmAddressApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'selection' },
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'client_name',
          label: '客户',
          minWidth: 120,
          formatter: (row: unknown) => (row as AddressItem).client_name || '-'
        },
        {
          prop: 'addr_kind',
          label: '地址类型',
          minWidth: 90,
          formatter: (row: unknown) => (row as AddressItem).addr_kind || '-'
        },
        {
          prop: 'contact',
          label: '收件人',
          minWidth: 100,
          formatter: (row: unknown) => (row as AddressItem).contact || '-'
        },
        {
          prop: 'phone',
          label: '电话',
          minWidth: 120,
          formatter: (row: unknown) => (row as AddressItem).phone || '-'
        },
        {
          prop: 'addr',
          label: '地址',
          minWidth: 200,
          formatter: (row: unknown) => (row as AddressItem).addr || '-'
        },
        {
          prop: 'is_default',
          label: '默认',
          width: 70,
          formatter: (row: unknown) => ((row as AddressItem).is_default ? '是' : '否')
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as AddressItem)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as AddressItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: AddressItem) => {
    if (item.key === 'view') handleView(row)
    else if (item.key === 'edit') handleEdit(row)
    else if (item.key === 'delete') deleteAddress(row)
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }
  const handleCreate = () => {
    currentAddress.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }
  const handleView = (row?: AddressItem) => {
    if (row?.id) router.push({ path: `/crm/addresses/${row.id}` })
  }
  const handleEdit = (row?: AddressItem) => {
    currentAddress.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteAddress = (row: AddressItem) => {
    ElMessageBox.confirm(`确定删除该收货地址吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() =>
        deleteCrmAddressApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      )
      .catch(() => ElMessage.info('已取消删除'))
  }

  const handleAddressCreated = () => refreshCreate()
  const handleAddressUpdated = () => refreshUpdate()
  const handleSelectionChange = (selection: AddressItem[]) => {
    selectedRows.value = selection
  }

  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的记录')
      return
    }
    ElMessageBox.confirm(`确认删除选中的 ${selectedRows.value.length} 条吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(async () => {
        await batchActionCrmAddressApi({
          actions: 'delete',
          ids: selectedRows.value.map((r) => r.id).filter(Boolean)
        })
        ElMessage.success('批量删除成功')
        refreshData()
        selectedRows.value = []
      })
      .catch(() => ElMessage.info('已取消删除'))
  }

  const handleExport = () => {
    const _data: any = data.value || []
    if (_data.length === 0) {
      ElMessage.warning('暂无数据可导出')
      return
    }
    exportExcel(columns.value, _data, '客户收货地址数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
