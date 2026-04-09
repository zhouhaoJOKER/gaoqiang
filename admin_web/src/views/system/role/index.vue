<!-- 角色管理页面 -->
<template>
  <div class="art-full-height">
    <RoleSearch
      v-show="showSearchBar"
      v-model="searchForm"
      @search="handleSearch"
      @reset="resetSearchParams"
    ></RoleSearch>

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
            <ElButton v-if="hasAuth('add')" type="primary" @click="showDialog('add')" v-ripple>
              <ArtSvgIcon icon="ri:add-line" />
              新增角色
            </ElButton>
            <ElDropdown
              trigger="click"
              v-if="
                hasAuth('batchAdd') ||
                hasAuth('batchEdit') ||
                hasAuth('batchDelete') ||
                hasAuth('import') ||
                hasAuth('export')
              "
            >
              <ElButton type="default" v-ripple>
                <ArtSvgIcon icon="ri:more-2-line" />
                更多 <ElIcon class="el-icon--right"><ArrowDown /></ElIcon>
              </ElButton>
              <template #dropdown>
                <ElDropdownMenu>
                  <ElDropdownItem v-if="hasAuth('batchAdd')" @click="showBatchAddDialog"
                    ><ArtSvgIcon class="el-icon--left" icon="ri:add-circle-line" />
                    批量添加</ElDropdownItem
                  >
                  <ElDropdownItem v-if="hasAuth('batchEdit')" @click="showBatchEditDialog"
                    ><ArtSvgIcon class="el-icon--left" icon="ri:edit-box-line" />
                    批量编辑</ElDropdownItem
                  >
                  <ElDropdownItem v-if="hasAuth('batchDelete')" @click="handleBatchDelete"
                    ><ArtSvgIcon class="el-icon--left" icon="ri:delete-bin-line" />
                    批量删除</ElDropdownItem
                  >
                  <ElDropdownItem
                    v-if="hasAuth('import') || hasAuth('export')"
                    divided
                  ></ElDropdownItem>
                  <ElDropdownItem v-if="hasAuth('import')" @click="showImportDialog"
                    ><ArtSvgIcon class="el-icon--left" icon="ri:upload-line" /> 导入</ElDropdownItem
                  >
                  <ElDropdownItem v-if="hasAuth('export')" @click="handleExport"
                    ><ArtSvgIcon class="el-icon--left" icon="ri:download-line" />
                    导出</ElDropdownItem
                  >
                </ElDropdownMenu>
              </template>
            </ElDropdown>
          </ElSpace>
        </template>
      </ArtTableHeader>

      <!-- 表格 -->
      <ArtTable
        ref="proTable"
        :loading="loading"
        :data="data as RoleListItem[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      >
      </ArtTable>
    </ElCard>

    <!-- 角色编辑弹窗 -->
    <RoleEditDialog
      v-model="dialogVisible"
      :dialog-type="dialogType"
      :role-data="currentRoleData"
      @addData="handleAddData"
      @updateData="handleUpdateData"
      @success="refreshData"
    />

    <!-- 菜单权限弹窗 -->
    <RolePermissionDialog
      v-model="permissionDialog"
      :role-data="currentRoleData"
      @success="refreshData"
    />

    <!-- 批量添加弹窗 -->
    <RoleBatchAddDialog v-model="batchAddDialogVisible" @success="handleBatchAddSuccess" />

    <!-- 批量编辑弹窗 -->
    <RoleBatchEditDialog
      v-model="batchEditDialogVisible"
      :selectedRows="selectedRows"
      @success="handleBatchEditSuccess"
    />

    <!-- 导入弹窗 -->
    <RoleImportDialog v-model="importDialogVisible" @success="handleImportSuccess" />
  </div>
</template>

<script setup lang="ts">
  import { ref, h } from 'vue'
  defineOptions({ name: 'Role' })
  import { ButtonMoreItem } from '@/components/core/forms/art-button-more/index.vue'
  import { useTable } from '@/hooks/core/useTable'
  import { useAuth } from '@/hooks/core/useAuth'
  // import { fetchGetRoleList } from '@/api/system-manage'
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import ArtButtonTable from '@/components/core/forms/art-button-table/index.vue'
  import RoleSearch from './modules/role-search.vue'
  import RoleEditDialog from './modules/role-edit-dialog.vue'
  import RolePermissionDialog from './modules/role-permission-dialog.vue'
  import { ElTag, ElMessageBox } from 'element-plus'
  import { ElMessage } from 'element-plus'
  import { listRoleApi, deleteRoleApi, batchActionRoleApi } from '@/api/role'
  import { exportExcel } from '@/utils/tool/toExcel'
  import { ArrowDown } from '@element-plus/icons-vue'

  import RoleBatchAddDialog from './modules/role-batch-add-dialog.vue'
  import RoleBatchEditDialog from './modules/role-batch-edit-dialog.vue'
  import RoleImportDialog from './modules/role-import-dialog.vue'

  type RoleListItem = Api.SystemManage.RoleListItem

  // 搜索表单
  const searchForm = ref({
    roleName: undefined,
    roleCode: undefined,
    description: undefined,
    enabled: undefined,
    daterange: undefined
  })

  const proTable = ref()
  const showSearchBar = ref(true)

  const { hasAuth } = useAuth()

  const dialogVisible = ref(false)
  const permissionDialog = ref(false)
  const currentRoleData = ref<RoleListItem | undefined>(undefined)

  // 批量操作相关
  const batchAddDialogVisible = ref(false)
  const batchEditDialogVisible = ref(false)
  const importDialogVisible = ref(false)
  const selectedRows = ref<RoleListItem[]>([])

  const {
    columns,
    columnChecks,
    data,
    loading,
    pagination,
    getData,
    searchParams,
    refreshCreate, // 新增后刷新：回到第一页并清空分页缓存（适用于新增数据后）
    refreshUpdate, // 更新后刷新：保持当前页，仅清空当前搜索缓存（适用于更新数据后）
    refreshRemove, // 删除后刷新：智能处理页码，避免空页面（适用于删除数据后）
    resetSearchParams,
    handleSizeChange,
    handleCurrentChange,
    refreshData
  } = useTable({
    // 核心配置
    // 核心配置
    core: {
      apiFn: listRoleApi,
      apiParams: {
        current: 1,
        size: 20
      },
      // 排除 apiParams 中的属性
      excludeParams: ['daterange'],
      columnsFactory: () => [
        { type: 'selection' }, // 勾选列
        { type: 'index', width: 65, label: '序号' }, // 序号
        {
          prop: 'code',
          label: '角色编码',
          minWidth: 65
        },
        {
          prop: 'name',
          label: '角色名称',
          minWidth: 100,
          formatter: (row: unknown) => {
            const roleRow = row as RoleListItem & { sign?: string }
            return h('div', { class: 'flex items-center gap-2' }, [
              // 角色标识 - 标签显示
              h(ElTag, { type: 'warning', size: 'small' }, () => formatSign(roleRow.sign || '')),
              // 角色名称 - 普通文字
              h('span', null, roleRow.name || '')
            ])
          }
        },
        {
          prop: 'describe',
          label: '角色描述',
          minWidth: 180,
          showOverflowTooltip: true
        },
        {
          prop: 'is_open',
          label: '角色状态',
          width: 90,
          formatter: (row: unknown) => {
            const roleRow = row as RoleListItem
            const statusConfig = roleRow.is_open
              ? { type: 'success', text: '启用' }
              : { type: 'warning', text: '禁用' }
            return h(
              ElTag,
              { type: statusConfig.type as 'success' | 'warning' },
              () => statusConfig.text
            )
          }
        },
        {
          prop: 'user_id',
          label: '创建人',
          width: 100,
          sortable: true
        },
        {
          prop: 'created_time',
          label: '创建于',
          width: 152,
          sortable: true
        },
        {
          prop: 'updated_time',
          label: '更新于',
          width: 152,
          sortable: true
        },
        {
          prop: 'operation',
          label: '操作',
          width: 86,
          fixed: 'right',
          formatter: (row: unknown) =>
            h('div', { style: 'display: flex' }, [
              h(ArtButtonTable, {
                type: 'role',
                onClick: () => buttonMoreClick({ key: 'permission' }, row as RoleListItem)
              }),
              h(ArtButtonMore, {
                list: [
                  {
                    key: 'edit',
                    label: '编辑角色',
                    icon: 'ri:edit-2-line'
                  },
                  {
                    key: 'delete',
                    label: '删除角色',
                    icon: 'ri:delete-bin-4-line',
                    color: '#f56c6c'
                  }
                ],
                onClick: (item: ButtonMoreItem) => buttonMoreClick(item, row as RoleListItem)
              })
            ])
        }
      ]
    }
  })

  const dialogType = ref<'add' | 'edit'>('add')

  const showDialog = (type: 'add' | 'edit', row?: RoleListItem) => {
    dialogVisible.value = true
    dialogType.value = type
    currentRoleData.value = row
  }

  const handleAddData = () => {
    console.log('新增角色handleAddData')
    refreshCreate()
  }

  const handleUpdateData = () => {
    console.log('更新角色handleUpdateData')
    refreshUpdate()
  }

  const formatSign = (sign: string) => {
    switch (sign) {
      case 'user':
        return '个人'
      case 'department':
        return '部门'
      case 'company':
        return '公司'
      case 'admin':
        return '全部'
      default:
        return sign
    }
  }

  /**
   * 导出excel
   * @param params 导出选中的记录
   */
  const handleExport = () => {
    let _data: any = []

    // 通过 ref 获取 ElTable 实例
    const elTableInstance = proTable.value?.elTableRef

    if (elTableInstance) {
      // 使用 ElTable 实例的 getSelectionRows 方法获取选中的行
      const selectedRows = elTableInstance.getSelectionRows()
      if (selectedRows && selectedRows.length > 0) {
        _data = selectedRows
      } else if (data.value && data.value.length > 0) {
        // 如果没有选中的行，则导出所有数据
        _data = data.value
      } else {
        ElMessage.warning('暂无数据可导出')
        return
      }
    } else {
      ElMessage.warning('表格实例未获取到')
      return
    }

    // 确保columns.value存在
    if (!columns.value || !columns.value.length) {
      ElMessage.warning('缺少表格列配置')
      return
    }

    try {
      // 使用表格标题或默认名称作为文件名
      const fileName = '角色数据'
      exportExcel(columns.value, _data, fileName)
      ElMessage.success('导出成功')
      // 清空选中数据
      elTableInstance.clearSelection()
    } catch (error) {
      console.error('导出失败:', error)
      ElMessage.error('导出失败，请重试')
    }
  }

  /**
   * 搜索处理
   * @param params 搜索参数
   */
  const handleSearch = (params: Record<string, any>) => {
    // 处理日期区间参数，把 daterange 转换为 startTime 和 endTime
    const { daterange, ...filtersParams } = params
    const [startTime, endTime] = Array.isArray(daterange) ? daterange : [null, null]

    // 搜索参数赋值
    Object.assign(searchParams, { ...filtersParams, startTime, endTime })
    getData()
  }

  const buttonMoreClick = (item: any, row: RoleListItem) => {
    switch (item.key) {
      case 'permission':
        showPermissionDialog(row)
        break
      case 'edit':
        showDialog('edit', row)
        break
      case 'delete':
        deleteRole(row)
        break
    }
  }

  const showPermissionDialog = (row?: RoleListItem) => {
    permissionDialog.value = true
    currentRoleData.value = row
  }

  const deleteRole = (row: RoleListItem) => {
    ElMessageBox.confirm(`确定删除角色"${row.name || '未命名'}"吗？此操作不可恢复！`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() => {
        // 调用删除接口
        deleteRoleApi(String(row.id)).then(() => {
          ElMessage.success('删除成功')
          refreshRemove()
        })
      })
      .catch(() => {
        ElMessage.info('已取消删除')
      })
  }

  /**
   * 显示批量添加弹窗
   */
  const showBatchAddDialog = () => {
    batchAddDialogVisible.value = true
  }

  /**
   * 显示批量编辑弹窗
   */
  const showBatchEditDialog = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要编辑的角色')
      return
    }
    batchEditDialogVisible.value = true
  }

  /**
   * 显示导入弹窗
   */
  const showImportDialog = () => {
    importDialogVisible.value = true
  }

  /**
   * 处理批量添加成功
   */
  const handleBatchAddSuccess = () => {
    refreshCreate()
  }

  /**
   * 处理批量编辑成功
   */
  const handleBatchEditSuccess = () => {
    refreshUpdate()
    selectedRows.value = []
  }

  /**
   * 处理导入成功
   */
  const handleImportSuccess = () => {
    refreshCreate()
  }

  /**
   * 处理表格行选择变化
   */
  const handleSelectionChange = (selection: RoleListItem[]) => {
    selectedRows.value = selection
  }

  /**
   * 处理批量删除
   */
  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的角色')
      return
    }

    ElMessageBox.confirm(
      `确认删除选中的 ${selectedRows.value.length} 个角色吗？此操作不可恢复！`,
      '删除确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
      .then(async () => {
        // 提取选中的ID
        const selectedIds = selectedRows.value.map((row) => row.id)
        // 调用批量删除API
        await batchActionRoleApi({
          actions: 'delete',
          ids: selectedIds
        })
        ElMessage.success('批量删除成功')
        refreshRemove()
        selectedRows.value = []
      })
      .catch(() => {
        ElMessage.info('已取消删除')
      })
  }
</script>
