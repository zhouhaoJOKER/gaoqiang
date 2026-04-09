<!-- 产品组合列表页面 -->
<template>
  <div class="art-full-height">
    <ComboSearch
      v-show="showSearchBar"
      v-model="searchForm"
      @search="handleSearch"
      @reset="resetSearchParams"
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
              <ArtSvgIcon icon="ri:add-line" />
              新建组合
            </ElButton>
          </ElSpace>
        </template>
      </ArtTableHeader>

      <!-- 表格 -->
      <ArtTable
        ref="proTable"
        :loading="loading"
        :data="data as ComboItem[]"
        :columns="columns"
        :pagination="pagination"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      >
      </ArtTable>
    </ElCard>

    <!-- 创建/编辑组合对话框 -->
    <ComboDialog
      v-model="dialogVisible"
      :combo="currentCombo"
      :readonly="isViewMode"
      @created="handleComboCreated"
      @updated="handleComboUpdated"
    />
  </div>
</template>

<script setup lang="ts">
  import { h, ref } from 'vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { useTable } from '@/hooks/core/useTable'
  import ArtButtonTable from '@/components/core/forms/art-button-table/index.vue'
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import { ButtonMoreItem } from '@/components/core/forms/art-button-more/index.vue'
  import ComboSearch from './modules/combo-search.vue'
  import ComboDialog from '../products/modules/combo-dialog.vue'
  import { ElButton, ElCard, ElMessage, ElMessageBox, ElSpace } from 'element-plus'
  import { listMatProductComboApi, deleteMatProductComboApi } from '@/api/mat/product'

  defineOptions({ name: 'MatProductCombo' })

  interface ComboItem {
    id?: string | number
    name?: string
    company_id?: string | number
    company_name?: string
    price?: number | string
    discount?: number | string
    description?: string
    options?: Array<{
      product_id?: string | number
      name?: string
      price?: number
      extra_price?: number
    }>
    [key: string]: any
  }

  // 搜索表单
  const searchForm = ref({
    name_cont: undefined
  })

  const proTable = ref()
  const showSearchBar = ref(true)

  const dialogVisible = ref(false)
  const currentCombo = ref<ComboItem | undefined>(undefined)
  const isViewMode = ref(false)

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
      apiFn: listMatProductComboApi,
      apiParams: {
        page: 1,
        per_page: 20
      },
      columnsFactory: () => [
        { type: 'index', width: 65, label: '序号' },
        {
          prop: 'name',
          label: '组合名称',
          minWidth: 150,
          formatter: (row: unknown) => {
            const comboRow = row as ComboItem
            return h(
              'span',
              {
                class: 'cursor-pointer hover:text-primary-500 transition-colors',
                onClick: () => handleView(comboRow)
              },
              comboRow.name || ''
            )
          }
        },
        {
          prop: 'company_name',
          label: '公司',
          minWidth: 120,
          formatter: (row: unknown) => {
            const comboRow = row as ComboItem
            return comboRow.company_name || '未设置'
          }
        },
        {
          prop: 'price',
          label: '价格',
          minWidth: 100,
          formatter: (row: unknown) => {
            const comboRow = row as ComboItem
            return formatCurrency(comboRow.price)
          }
        },
        {
          prop: 'discount',
          label: '折扣',
          minWidth: 80,
          formatter: (row: unknown) => {
            const comboRow = row as ComboItem
            const discount = Number(comboRow.discount) || 0
            return discount > 0 ? `${discount}%` : '-'
          }
        },
        {
          prop: 'options',
          label: '产品数量',
          minWidth: 100,
          formatter: (row: unknown) => {
            const comboRow = row as ComboItem
            const count = Array.isArray(comboRow.options) ? comboRow.options.length : 0
            return count > 0 ? `${count} 个产品` : '0 个产品'
          }
        },
        {
          prop: 'description',
          label: '描述',
          minWidth: 200,
          showOverflowTooltip: true,
          formatter: (row: unknown) => {
            const comboRow = row as ComboItem
            return comboRow.description || '-'
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
                onClick: () => buttonMoreClick({ key: 'view' }, row as ComboItem)
              }),
              h(ArtButtonMore, {
                list: [
                  {
                    key: 'edit',
                    label: '编辑组合',
                    icon: 'ri:edit-2-line'
                  },
                  {
                    key: 'delete',
                    label: '删除组合',
                    icon: 'ri:delete-bin-4-line',
                    color: '#f56c6c'
                  }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as ComboItem)
              })
            ])
        }
      ]
    }
  })

  const buttonMoreClick = (item: any, row: ComboItem) => {
    switch (item.key) {
      case 'view':
        handleView(row)
        break
      case 'edit':
        handleEdit(row)
        break
      case 'delete':
        deleteCombo(row)
        break
    }
  }

  const handleCreate = (): void => {
    currentCombo.value = undefined
    isViewMode.value = false
    dialogVisible.value = true
  }

  const handleView = (row?: ComboItem): void => {
    currentCombo.value = row
    isViewMode.value = true
    dialogVisible.value = true
  }

  const handleEdit = (row?: ComboItem): void => {
    currentCombo.value = row
    isViewMode.value = false
    dialogVisible.value = true
  }

  const deleteCombo = (row: ComboItem) => {
    ElMessageBox.confirm(`确定删除组合"${row.name || '未命名'}"吗？此操作不可恢复！`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() => {
        deleteMatProductComboApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      })
      .catch(() => {
        ElMessage.info('已取消删除')
      })
  }

  const handleComboCreated = (combo: any): void => {
    if (combo && combo.id) {
      refreshCreate()
    }
  }

  const handleComboUpdated = (combo: any): void => {
    if (combo && combo.id) {
      refreshUpdate()
    }
  }

  const formatCurrency = (value: number | string | undefined): string => {
    const num = Number(value)
    if (Number.isNaN(num)) return '￥0.00'
    return `￥${num.toFixed(2)}`
  }

  /**
   * 搜索处理
   * @param params 搜索参数
   */
  const handleSearch = (params: Record<string, any>) => {
    Object.assign(searchParams, params)
    getData()
  }
</script>
