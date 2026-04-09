<template>
  <div class="art-full-height">
    <ContactSearch
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
            <ElButton type="primary" @click="handleCreate" v-ripple>
              <ArtSvgIcon icon="ri:add-line" /> 新建联系人
            </ElButton>
            <ElDropdown trigger="click">
              <ElButton type="default" v-ripple>
                <ArtSvgIcon icon="ri:more-2-line" /> 更多
                <ElIcon class="el-icon--right"><ArrowDown /></ElIcon>
              </ElButton>
              <template #dropdown>
                <ElDropdownMenu>
                  <ElDropdownItem @click="handleBatchDelete">
                    <ArtSvgIcon class="el-icon--left" icon="ri:delete-bin-line" /> 批量删除
                  </ElDropdownItem>
                  <ElDropdownItem divided></ElDropdownItem>
                  <ElDropdownItem @click="handleExport">
                    <ArtSvgIcon class="el-icon--left" icon="ri:download-line" /> 导出
                  </ElDropdownItem>
                </ElDropdownMenu>
              </template>
            </ElDropdown>
          </ElSpace>
        </template>
      </ArtTableHeader>
      <ArtTable
        ref="proTable"
        :loading="loading"
        :data="data as ContactItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      />
    </ElCard>
    <ContactDialog
      v-model="dialogVisible"
      :contact="currentContact"
      :readonly="isViewMode"
      @created="handleContactCreated"
      @updated="handleContactUpdated"
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
  import ContactSearch from './modules/contact-search.vue'
  import ContactDialog from './modules/contact-dialog.vue'
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
    listPurContactApi,
    deletePurContactApi,
    batchActionPurContactApi
  } from '@/api/pur/contact'
  import { exportExcel } from '@/utils/tool/toExcel'

  defineOptions({ name: 'PurContact' })
  const router = useRouter()

  interface ContactItem {
    id?: string | number
    supplier_id?: string | number
    supplier_name?: string
    name?: string
    dept?: string
    phone?: string
    mobile?: string
    email?: string
    is_primary?: boolean
    remark?: string
    [key: string]: any
  }

  const searchForm = ref({ name_cont: undefined, supplier_id_eq: undefined })
  const proTable = ref()
  const showSearchBar = ref(true)
  const dialogVisible = ref(false)
  const currentContact = ref<ContactItem | undefined>(undefined)
  const isViewMode = ref(false)
  const selectedRows = ref<ContactItem[]>([])

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
      apiFn: listPurContactApi,
      apiParams: { page: 1, per_page: 20 },
      columnsFactory: () => [
        { type: 'selection' },
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'name',
          label: '联系人姓名',
          minWidth: 120,
          formatter: (row: unknown) => {
            const r = row as ContactItem
            return h(
              'span',
              { class: 'cursor-pointer hover:text-primary-500', onClick: () => handleView(r) },
              r.name || '-'
            )
          }
        },
        {
          prop: 'supplier_name',
          label: '供应商',
          minWidth: 140,
          formatter: (row: unknown) => (row as ContactItem).supplier_name || '-'
        },
        {
          prop: 'dept',
          label: '部门',
          minWidth: 100,
          formatter: (row: unknown) => (row as ContactItem).dept || '-'
        },
        {
          prop: 'phone',
          label: '电话',
          minWidth: 120,
          formatter: (row: unknown) => (row as ContactItem).phone || '-'
        },
        {
          prop: 'mobile',
          label: '手机',
          minWidth: 120,
          formatter: (row: unknown) => (row as ContactItem).mobile || '-'
        },
        {
          prop: 'is_primary',
          label: '主联系人',
          width: 90,
          formatter: (row: unknown) => ((row as ContactItem).is_primary ? '是' : '否')
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as ContactItem)
              }),
              h(ArtButtonMore, {
                list: [
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as ContactItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: ContactItem) => {
    if (item.key === 'view') handleView(row)
    else if (item.key === 'edit') handleEdit(row)
    else if (item.key === 'delete') deleteContact(row)
  }

  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }
  const handleCreate = () => {
    currentContact.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }
  const handleView = (row?: ContactItem) => {
    if (row?.id) router.push({ path: `/pur/contacts/${row.id}` })
  }
  const handleEdit = (row?: ContactItem) => {
    currentContact.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteContact = (row: ContactItem) => {
    ElMessageBox.confirm(`确定删除联系人"${row.name || '未命名'}"吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() =>
        deletePurContactApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      )
      .catch(() => ElMessage.info('已取消删除'))
  }

  const handleContactCreated = () => refreshCreate()
  const handleContactUpdated = () => refreshUpdate()
  const handleSelectionChange = (selection: ContactItem[]) => {
    selectedRows.value = selection
  }

  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的联系人')
      return
    }
    ElMessageBox.confirm(`确认删除选中的 ${selectedRows.value.length} 个联系人吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(async () => {
        await batchActionPurContactApi({
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
    exportExcel(columns.value, _data, '供应商联系人数据')
    ElMessage.success('导出成功')
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';
</style>
