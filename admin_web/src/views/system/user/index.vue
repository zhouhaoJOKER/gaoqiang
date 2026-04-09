<!-- 用户管理页面 -->
<!-- art-full-height 自动计算出页面剩余高度 -->
<!-- art-table-card 一个符合系统样式的 class，同时自动撑满剩余高度 -->
<!-- 更多 useTable 使用示例请移步至 功能示例 下面的高级表格示例或者查看官方文档 -->
<!-- useTable 文档：https://www.artd.pro/docs/zh/guide/hooks/use-table.html -->
<template>
  <div class="user-page art-full-height">
    <!-- 搜索栏 -->
    <UserSearch v-model="searchForm" @search="handleSearch" @reset="resetSearchParams"></UserSearch>

    <ElCard class="art-table-card" shadow="never">
      <!-- 表格头部 -->
      <ArtTableHeader v-model:columns="columnChecks" :loading="loading" @refresh="refreshData">
        <template #left>
          <ElSpace wrap>
            <ElButton v-if="hasAuth('add')" type="primary" @click="showDialog('add')" v-ripple>
              <ArtSvgIcon icon="ri:add-line" />
              新增用户
            </ElButton>
            <ElDropdown
              trigger="click"
              v-if="
                hasAuth('batchAdd') ||
                hasAuth('batchEdit') ||
                hasAuth('batchDelete') ||
                hasAuth('batchDisable') ||
                hasAuth('batchEnable') ||
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
                  <ElDropdownItem v-if="hasAuth('batchAdd')" @click="handleBatchAdd"
                    ><ArtSvgIcon class="el-icon--left" icon="ri:add-circle-line" />
                    批量新增</ElDropdownItem
                  >
                  <ElDropdownItem v-if="hasAuth('batchEdit')" @click="handleBatchEdit"
                    ><ArtSvgIcon class="el-icon--left" icon="ri:edit-box-line" />
                    批量修改</ElDropdownItem
                  >
                  <ElDropdownItem v-if="hasAuth('batchDelete')" @click="handleBatchDelete"
                    ><ArtSvgIcon class="el-icon--left" icon="ri:delete-bin-line" />
                    批量删除</ElDropdownItem
                  >
                  <ElDropdownItem v-if="hasAuth('batchEdit')" @click="handleBatchDisable"
                    ><ArtSvgIcon class="el-icon--left" icon="ri:close-circle-line" />
                    批量禁用</ElDropdownItem
                  >
                  <ElDropdownItem v-if="hasAuth('batchEdit')" @click="handleBatchEnable"
                    ><ArtSvgIcon class="el-icon--left" icon="ri:checkbox-circle-line" />
                    批量启用</ElDropdownItem
                  >
                  <ElDropdownItem
                    v-if="hasAuth('import') || hasAuth('export')"
                    divided
                  ></ElDropdownItem>
                  <ElDropdownItem v-if="hasAuth('import')" @click="handleImport"
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
        :data="data as Record<string, any>[]"
        :columns="columns"
        :pagination="pagination"
        @selection-change="handleSelectionChange"
        @pagination:size-change="handleSizeChange"
        @pagination:current-change="handleCurrentChange"
      >
      </ArtTable>

      <!-- 用户弹窗 -->
      <UserDialog
        v-model:visible="dialogVisible"
        :type="dialogType"
        :user-data="currentUserData"
        @submit="handleDialogSubmit"
        @addData="handleAddData"
        @updateData="handleUpdateData"
      />

      <!-- 批量添加弹窗 -->
      <UserBatchAddDialog v-model="batchAddDialogVisible" @success="handleBatchAddSuccess" />

      <!-- 批量编辑弹窗 -->
      <UserBatchEditDialog
        v-model="batchEditDialogVisible"
        :selectedData="selectedRows"
        @success="handleBatchEditSuccess"
      />

      <!-- 导入弹窗 -->
      <UserImportDialog v-model="importDialogVisible" @success="handleImportSuccess" />
    </ElCard>
  </div>
</template>

<script setup lang="ts">
  defineOptions({ name: 'User' })
  import { ref, nextTick, h } from 'vue'
  import { useRouter } from 'vue-router'
  import { ElMessage, ElMessageBox, ElImage } from 'element-plus'
  import { listUserApi, deleteUserApi, batchActionUserApi } from '@/api/user'
  import { ArrowDown } from '@element-plus/icons-vue'
  import { ElTag } from 'element-plus'

  import ArtButtonTable from '@/components/core/forms/art-button-table/index.vue'
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import { ButtonMoreItem } from '@/components/core/forms/art-button-more/index.vue'
  // Import default avatar image
  // import defaultAvatar from '@/assets/img/user/avatar.webp'

  import { useTable } from '@/hooks/core/useTable'
  import { useAuth } from '@/hooks/core/useAuth'

  // 组件导入
  import UserSearch from './modules/user-search.vue'
  import UserDialog from './modules/user-dialog.vue'
  import UserBatchAddDialog from './modules/user-batch-add-dialog.vue'
  import UserBatchEditDialog from './modules/user-batch-edit-dialog.vue'
  import UserImportDialog from './modules/user-import-dialog.vue'

  import { DialogType } from '@/types/common'
  // import UserView from './modules/user-view.vue'
  import { exportExcel } from '@/utils'

  const router = useRouter()

  const { hasAuth } = useAuth()
  // 简单的用户类型定义
  type UserListItem = any

  // type UserListItem = Api.SystemManage.UserListItem

  // 弹窗相关
  const dialogType = ref<DialogType>('add')
  const dialogVisible = ref(false)
  const currentUserData = ref<Partial<UserListItem>>({})

  // 批量操作相关
  const batchAddDialogVisible = ref(false)
  const batchEditDialogVisible = ref(false)
  const importDialogVisible = ref(false)

  // 选中行
  const selectedRows = ref<UserListItem[]>([])
  const selectedIds = ref<number[]>([])

  // 表格实例ref
  const proTable = ref<any>(null)

  // 搜索表单
  const searchForm = ref({
    name: undefined,
    level: 'vip',
    date: undefined,
    daterange: undefined,
    status: undefined
  })

  // 用户状态配置
  const USER_STATUS_CONFIG = {
    false: { type: 'info' as const, text: '禁用' },
    true: { type: 'success' as const, text: '激活' },
    '2': { type: 'info' as const, text: '离线' },
    '3': { type: 'warning' as const, text: '异常' },
    '4': { type: 'danger' as const, text: '注销' }
  } as const

  /**
   * 获取用户状态配置
   */
  const getUserStatusConfig = (status: string) => {
    return (
      USER_STATUS_CONFIG[status as keyof typeof USER_STATUS_CONFIG] || {
        type: 'info' as const,
        text: '未知'
      }
    )
  }

  const {
    columns,
    columnChecks,
    data,
    loading,
    pagination, // 分页信息
    handleSizeChange, // 分页大小变化处理
    handleCurrentChange, // 当前页变化处理
    // 数据操作
    getData, // 获取数据
    // clearData, // 清空数据
    searchParams,
    resetSearchParams,
    // refreshSoft, // 轻量刷新：仅清空当前搜索条件的缓存，保持分页状态（适用于定时刷新）
    refreshCreate, // 新增后刷新：回到第一页并清空分页缓存（适用于新增数据后）
    refreshUpdate, // 更新后刷新：保持当前页，仅清空当前搜索缓存（适用于更新数据后）
    refreshRemove, // 删除后刷新：智能处理页码，避免空页面（适用于删除数据后）
    refreshData
  } = useTable({
    // 核心配置
    core: {
      apiFn: listUserApi,
      apiParams: {
        current: 1,
        size: 20,
        ...searchForm.value
      },
      // 排除 apiParams 中的属性
      excludeParams: ['daterange'],
      columnsFactory: () => [
        { type: 'selection' }, // 勾选列
        { type: 'index', width: 50, label: 'ID' }, // 序号
        {
          prop: 'avatar',
          label: '用户名',
          width: 280,
          // visible: false, // 默认是否显示列
          formatter: (row: any) => {
            return h('div', { class: 'user flex-c' }, [
              h(ElImage, {
                class: 'size-9.5 rounded-md',
                src: row.avatar?.url,
                previewSrcList: [row.avatar?.url],
                // 图片预览是否插入至 body 元素上，用于解决表格内部图片预览样式异常
                previewTeleported: true
              }),
              h('div', { class: 'ml-2' }, [
                h('p', { class: 'user-name' }, row.name),
                h('p', { class: 'email' }, row.email)
              ])
            ])
          }
        },
        {
          prop: 'sex',
          label: '性别',
          sortable: true,
          // checked: false, // 隐藏列
          formatter: (row: any) => row.sex
        },
        { prop: 'phone', label: '手机号', formatter: (row: any) => row.phone },
        {
          prop: 'approved',
          label: '状态',
          formatter: (row: any) => {
            const statusConfig = getUserStatusConfig(row.approved)
            return h(ElTag, { type: statusConfig.type }, () => statusConfig.text)
          }
        },
        {
          prop: 'department_id',
          label: '部门',
          sortable: true
        },
        {
          prop: 'role_id',
          label: '角色',
          sortable: true
        },
        {
          prop: 'created_time',
          label: '创建于',
          sortable: true
        },
        {
          prop: 'updated_time',
          label: '更新于',
          sortable: true
        },
        {
          prop: 'operation',
          label: '操作',
          width: 86,
          fixed: 'right',
          formatter: (row: unknown) => {
            const userRow = row as Record<string, any>
            const buttons = []
            // 编辑按钮
            if (hasAuth('edit')) {
              buttons.push(
                h(ArtButtonTable, {
                  type: 'edit',
                  onClick: () => {
                    showDialog('edit', userRow)
                  }
                })
              )
            }

            // 更多操作按钮
            const moreItems: ButtonMoreItem[] = []

            if (hasAuth('view')) {
              moreItems.push({
                key: 'view',
                label: '查看详情',
                icon: 'ri:eye-line'
              })
            }
            if (hasAuth('clone')) {
              moreItems.push({
                key: 'clone',
                label: '克隆用户',
                icon: 'ri:file-copy-line'
              })
            }
            if (hasAuth('delete')) {
              moreItems.push({
                key: 'delete',
                label: '删除用户',
                icon: 'ri:delete-bin-4-line',
                color: '#f56c6c'
              })
            }
            if (moreItems.length > 0) {
              buttons.push(
                h('div', [
                  h(ArtButtonMore, {
                    list: moreItems,
                    onClick: (item: ButtonMoreItem) => buttonMoreClick(item, userRow)
                  })
                ])
              )
            }
            return h('div', { style: 'display: flex;' }, buttons)
          }
        }
      ]
    },
    // 数据处理
    transform: {
      // 数据转换器 - 替换头像
      // dataTransformer: (records) => {
      //   // 类型守卫检查
      //   if (!Array.isArray(records)) {
      //     console.warn('数据转换器: 期望数组类型，实际收到:', typeof records)
      //     return []
      //   }
      //   // 使用本地头像替换接口返回的头像
      //   return records.map((item, index: number) => {
      //     return {
      //       ...item,
      //       avatar: ACCOUNT_TABLE_DATA[index % ACCOUNT_TABLE_DATA.length].avatar
      //     }
      //   })
      // }
    }
  })

  /**
   * 搜索处理
   * @param params 参数
   */
  const handleSearch = (params: Record<string, any>) => {
    console.log(params)
    // 搜索参数赋值
    Object.assign(searchParams, params)
    getData()
  }

  /**
   * 显示用户弹窗
   */
  const showDialog = (type: DialogType, row?: UserListItem): void => {
    console.log('打开弹窗:', { type, row })
    dialogType.value = type
    currentUserData.value = row || {}
    nextTick(() => {
      dialogVisible.value = true
    })
  }

  /**
   * 显示批量添加弹窗
   */
  const handleBatchAdd = () => {
    batchAddDialogVisible.value = true
  }

  /**
   * 处理批量编辑
   */
  const handleBatchEdit = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要编辑的用户')
      return
    }
    batchEditDialogVisible.value = true
  }
  /**
   * 处理批量删除
   */
  const handleBatchDelete = () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要删除的用户')
      return
    }

    // 提取选中的ID
    selectedIds.value = selectedRows.value.map((row: any) => row.id)
    ElMessageBox.alert(`确认删除选中的 ${selectedRows.value.length} 个用户吗？`, 'Title', {
      // if you want to disable its autofocus
      // autofocus: false,
      confirmButtonText: '确认删除',
      callback: async (action: string) => {
        if (action === 'confirm') {
          const deleteData = {
            actions: 'delete',
            ids: selectedIds.value
          }
          // 调用批量删除API
          const res = await batchActionUserApi(deleteData)
          console.log('批量删除提交数据:', deleteData)
          console.log('批量删除API响应:', res)

          ElMessage.success('批量删除成功')
          refreshRemove()
        }
      }
    })
  }
  /**
   * 页面跳转
   * @param {string} path - 目标路径
   */
  const goPage = (path: string): void => {
    router.push(path)
  }

  /**
   * 显示用户详情
   */
  const viewUser = (row?: UserListItem): void => {
    console.log('打开弹窗:', { row })
    goPage('/system/user-view?id=' + row.id)
  }

  /**
   * 删除用户
   */
  const deleteUser = (row: UserListItem): void => {
    console.log('删除用户:', row)
    ElMessageBox.confirm(`确定要删除用户 ${row.name} 吗？`, '删除用户', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'error'
    }).then(() => {
      // 调用删除接口
      deleteUserApi(row.id).then(() => {
        // 删除成功后刷新数据
        refreshRemove()
        ElMessage.success('删除成功')
      })
    })
  }

  /**
   * 更多操作按钮点击处理
   */
  const buttonMoreClick = (item: ButtonMoreItem, row: Record<string, any>) => {
    switch (item.key) {
      case 'view':
        viewUser(row)
        break
      case 'clone':
        handleCloneUser(row)
        break
      case 'delete':
        deleteUser(row)
        break
    }
  }

  /**
   * 克隆用户
   */
  const handleCloneUser = (row: Record<string, any>) => {
    console.log('克隆用户:', row)
    ElMessage.info('克隆用户功能待实现')
  }

  /**
   * 处理弹窗提交事件
   */
  const handleDialogSubmit = async () => {
    try {
      dialogVisible.value = false
      currentUserData.value = {}
    } catch (error) {
      console.error('提交失败:', error)
    }
  }
  /**
   * 处理添加用户数据
   */
  const handleAddData = () => {
    // 调用refreshCreate函数刷新数据，回到第一页并清空分页缓存
    refreshCreate()
  }

  /**
   * 处理更新用户数据
   */
  const handleUpdateData = () => {
    // 调用refreshUpdate函数刷新数据，保持当前页
    refreshUpdate()
  }

  /**
   * 处理表格行选择变化
   */
  const handleSelectionChange = (selection: UserListItem[]): void => {
    selectedRows.value = selection
    console.log('选中行数据:', selectedRows.value)
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
   * 处理批量禁用
   */
  const handleBatchDisable = async () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要禁用的用户')
      return
    }

    // 提取选中的ID
    selectedIds.value = selectedRows.value.map((row: any) => row.id)

    await handleBatchApi({
      fields: ['status'],
      values: {
        status: false
      }
    })
  }

  /**
   * 处理批量启用
   */
  const handleBatchEnable = async () => {
    if (selectedRows.value.length === 0) {
      ElMessage.warning('请先选择要启用的用户')
      return
    }

    // 提取选中的ID
    selectedIds.value = selectedRows.value.map((row: any) => row.id)

    await handleBatchApi({
      fields: ['status'],
      values: {
        status: true
      }
    })
  }

  /**
   * 批量操作API调用
   */
  const handleBatchApi = async (params: any) => {
    // 调用批量修改API
    params.fields = params.fields || ['status']
    params.values = params.values || {
      status: false
    }
    const batchData = {
      actions: 'update',
      fields: params.fields,
      values: params.values,
      ids: selectedIds.value
    }

    // 调用批量修改API
    const res = await batchActionUserApi(batchData)
    console.log('批量操作提交数据:', batchData)
    console.log('批量操作API响应:', res)

    ElMessage.success('批量操作成功')
    refreshUpdate()
  }

  /**
   * 处理导入
   */
  const handleImport = () => {
    importDialogVisible.value = true
  }

  /**
   * 导出excel
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
      const fileName = '用户数据'
      exportExcel(columns.value, _data, fileName)
      ElMessage.success('导出成功')
      // 清空选中数据
      elTableInstance.clearSelection()
    } catch (error) {
      console.error('导出失败:', error)
      ElMessage.error('导出失败，请重试')
    }
  }
</script>
