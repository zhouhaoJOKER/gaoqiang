<!-- 左树右表示例页面 -->
<template>
  <div class="art-full-height">
    <div class="box-border flex gap-0 h-full max-md:block max-md:gap-0 max-md:h-auto">
      <!-- 左侧树容器 -->
      <div
        class="tree-container flex-shrink-0 h-full relative transition-all duration-150 max-md:hidden"
        :class="isTreeCollapsed ? 'w-10' : 'w-58'"
      >
        <ElCard
          class="tree-card art-card-xs flex flex-col h-full mt-0 transition-all duration-150"
          shadow="never"
          :style="isTreeCollapsed ? 'opacity: 0; pointer-events: none;' : ''"
        >
          <template #header>
            <b>部门管理</b>
          </template>
          <!-- 修复ElScrollbar布局问题 -->
          <ElScrollbar>
            <div class="p-2">
              <!-- 简化的树展示 -->
              <div v-if="treeLoading" class="py-4 text-center text-gray-500"> 加载中... </div>
              <div v-else>
                <!-- 直接展示数据，不使用复杂的树组件 -->
                <div v-if="treeData.length > 0">
                  <ElTree
                    :data="treeData"
                    node-key="id"
                    :props="treeProps"
                    default-expand-level="2"
                    highlight-current
                    @node-click="handleNodeClick"
                    @expand-or-collapse-tree="expandOrCollapseTree"
                    @node-contextmenu="
                      (event, data) => {
                        event.preventDefault()
                        handleContextMenu(event, data)
                      }
                    "
                  />
                </div>
                <div v-else class="py-4 text-center text-gray-400"> 暂无部门数据 </div>
              </div>
            </div>
          </ElScrollbar>
        </ElCard>
        <!-- 树折叠/展开按钮 -->
        <div
          class="tree-collapse-btn-container absolute right-0 top-1/2 -translate-y-1/2 transform transition-all duration-300 z-10"
        >
          <div
            class="tree-collapse-btn items-center justify-center"
            @click.stop="toggleTreeCollapse"
          >
            <ArtSvgIcon
              :icon="isTreeCollapsed ? 'ri:arrow-right-s-line' : 'ri:arrow-left-s-line'"
              class="w-4 h-4 text-gray-500"
            />
          </div>
        </div>
      </div>

      <div class="flex flex-col flex-grow min-w-0 ml-4 transition-all duration-300">
        <DepartmentSearch
          v-model="defaultFilter"
          @search="handleSearch"
          @reset="resetSearchParams"
        ></DepartmentSearch>

        <ElCard class="flex flex-col flex-1 min-h-0 art-table-card" shadow="never">
          <ArtTableHeader v-model:columns="columnChecks" :loading="loading" @refresh="refreshData">
            <template #left>
              <ElSpace wrap>
                <ElButton
                  v-if="hasAuth('add')"
                  type="primary"
                  @click="handleAddDepartment()"
                  v-ripple
                >
                  <ArtSvgIcon icon="ri:add-line" />
                  新增部门
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
                    更多 <ElIcon class="el-icon--right"><ArrowDown /></ElIcon>
                  </ElButton>
                  <template #dropdown>
                    <ElDropdownMenu>
                      <ElDropdownItem v-if="hasAuth('batchAdd')" @click="handleBatchAdd"
                        >批量新增</ElDropdownItem
                      >
                      <ElDropdownItem v-if="hasAuth('batchEdit')" @click="handleBatchEdit"
                        >批量修改</ElDropdownItem
                      >
                      <ElDropdownItem v-if="hasAuth('batchDelete')" @click="handleBatchDelete"
                        >批量删除</ElDropdownItem
                      >
                      <ElDropdownItem v-if="hasAuth('batchEdit')" @click="handleBatchDisable"
                        >批量禁用</ElDropdownItem
                      >
                      <ElDropdownItem v-if="hasAuth('batchEdit')" @click="handleBatchEnable"
                        >批量启用</ElDropdownItem
                      >
                      <ElDropdownItem
                        v-if="hasAuth('import') || hasAuth('export')"
                        divided
                      ></ElDropdownItem>
                      <ElDropdownItem v-if="hasAuth('import')" @click="handleImport"
                        >导入</ElDropdownItem
                      >
                      <ElDropdownItem v-if="hasAuth('export')" @click="handleExport"
                        >导出</ElDropdownItem
                      >
                    </ElDropdownMenu>
                  </template>
                </ElDropdown>
              </ElSpace>
            </template>
          </ArtTableHeader>

          <ArtTable
            ref="proTable"
            rowKey="id"
            :loading="loading"
            :data="data as Record<string, any>[]"
            :columns="columns"
            :pagination="pagination"
            @pagination:size-change="handleSizeChange"
            @pagination:current-change="handleCurrentChange"
            @sort-change="handleSortChange"
          >
          </ArtTable>
        </ElCard>
      </div>
    </div>
    <!-- 右键菜单组件 -->
    <ArtMenuRight ref="menuRef" :menu-items="menuItems" @select="handleMenuClick" />
    <!-- 部门编辑弹窗 -->
    <DepartmentDialog
      v-model="dialogVisible"
      :dialog-type="dialogType"
      :department-data="currentDepartmentData"
      @success="handleDialogSuccess"
    />

    <!-- 部门批量修改弹窗 -->
    <DepartmentBatchEditDialog
      v-model="batchEditDialogVisible"
      :selected-ids="selectedDepartmentIds"
      @success="handleBatchEditSuccess"
    />

    <!-- 部门批量新增弹窗 -->
    <DepartmentBatchAddDialog v-model="batchAddDialogVisible" @success="handleBatchAddSuccess" />

    <!-- 部门导入弹窗 -->
    <DepartmentImportDialog v-model="importDialogVisible" @success="handleImportSuccess" />
  </div>
</template>

<script setup lang="ts">
  defineOptions({ name: 'DepartmentTree' })

  import { ref, computed, onMounted, h } from 'vue'
  import { useRouter } from 'vue-router'
  import { ElMessage, ElMessageBox, ElIcon, ElTag } from 'element-plus'
  import { ArrowDown } from '@element-plus/icons-vue'
  import ArtMenuRight from '@/components/core/others/art-menu-right/index.vue'
  import ArtButtonTable from '@/components/core/forms/art-button-table/index.vue'
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import type { ButtonMoreItem } from '@/components/core/forms/art-button-more/index.vue'
  import type { MenuItemType } from '@/components/core/others/art-menu-right/index.vue'
  import { useTable } from '@/hooks/core/useTable'
  import { useAuth } from '@/hooks/core/useAuth'
  import {
    listDepartmentTreeApi,
    listDepartmentApi,
    deleteDepartmentApi,
    batchActionDepartmentApi
  } from '@/api/department'
  import DepartmentSearch from './modules/department-search.vue'
  import DepartmentDialog from './modules/department-dialog.vue'
  import DepartmentBatchEditDialog from './modules/department-batch-edit-dialog.vue'
  import DepartmentBatchAddDialog from './modules/department-batch-add-dialog.vue'
  import DepartmentImportDialog from './modules/department-import-dialog.vue'
  import { exportExcel } from '@/utils'

  // 创建router实例
  const router = useRouter()

  // 树节点接口定义
  interface Tree {
    id: number | string
    name: string
    children?: Tree[]
    [key: string]: any
  }

  // 左侧树
  const hideLeftTree = ref(false)
  const expandOrCollapseTree = (data: boolean) => {
    hideLeftTree.value = data
  }

  const { hasAuth } = useAuth()
  const treeLoading = ref(false)
  // 左侧树折叠状态
  const isTreeCollapsed = ref(false)
  // 切换树折叠/展开状态
  const toggleTreeCollapse = () => {
    isTreeCollapsed.value = !isTreeCollapsed.value
  }

  // 树形数据 - 数据从 listDepartmentTreeApi 获取
  const treeData = ref<Record<string, any>[]>([])

  // 树形配置 - 匹配API返回的数据结构
  const treeProps = {
    // 子节点字段名 - 确保与API返回的子节点字段匹配
    children: 'children',
    // 标签字段名 - 确保与API返回的名称字段匹配
    label: 'name'
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
  // 获取部门树数据
  const getTreeData = async () => {
    treeLoading.value = true
    try {
      // 调用部门树API获取数据 - 传递空对象参数以匹配函数签名
      const res = await listDepartmentTreeApi({})
      // 处理API响应，支持多种可能的数据结构
      let departmentData: Record<string, any>[] = []
      if (res?.data) {
        // 如果data是数组，直接使用
        if (Array.isArray(res.data)) {
          departmentData = res.data as Record<string, any>[]
        }
        // 如果data是对象，检查是否有departments或items字段
        else if (typeof res.data === 'object') {
          // 尝试多种可能的数据字段
          departmentData = (res.data.departments ||
            res.data.items ||
            res.data.list ||
            []) as Record<string, any>[]
          // 也可能data本身就是一个节点对象
          if (!Array.isArray(departmentData)) {
            // 检查是否是根节点对象
            if (res.data.id || res.data.children) {
              departmentData = [res.data as Record<string, any>]
            }
          }
        }
      }
      treeData.value = departmentData
    } catch (error) {
      console.error('获取部门树数据失败:', error)
      treeData.value = []
    } finally {
      treeLoading.value = false
    }
  }

  // 删除重复的handleNodeClick函数定义

  // 右键菜单相关
  const menuRef = ref<InstanceType<typeof ArtMenuRight> | null>(null)
  const selectedNode = ref<any>(null)
  const proTable = ref()

  // 部门对话框相关
  const dialogVisible = ref(false)
  const dialogType = ref<'add' | 'edit' | 'clone' | 'view'>('add')
  const currentDepartmentData = ref<any>(undefined)

  // 批量修改对话框相关
  const batchEditDialogVisible = ref(false)
  const selectedDepartmentIds = ref<number[]>([])

  // 批量新增对话框相关
  const batchAddDialogVisible = ref(false)

  // 导入对话框相关
  const importDialogVisible = ref(false)

  // 右键菜单配置 - 根据权限动态生成菜单项
  const menuItems = computed<MenuItemType[]>(() => {
    const items: MenuItemType[] = []
    // 根据权限动态添加菜单项
    if (hasAuth('clone')) {
      items.push({ key: 'clone', label: '克隆部门', icon: 'ri:file-copy-line' })
    }
    if (hasAuth('add')) {
      items.push({ key: 'add', label: '添加子部门', icon: 'ri:add-line' })
    }
    if (hasAuth('delete')) {
      items.push({ key: 'delete', label: '删除部门', icon: 'ri:delete-bin-line' })
    }
    if (hasAuth('edit')) {
      items.push({ key: 'edit', label: '编辑部门', icon: 'ri:pencil-line' })
    }
    if (hasAuth('view')) {
      items.push({ key: 'view', label: '查看详情', icon: 'ri:eye-line' })
    }
    // 刷新功能通常不需要权限控制
    items.push({ key: 'refresh', label: '刷新', icon: 'ri:refresh-line' })
    return items
  })

  // 处理右键点击事件
  const handleContextMenu = (event: MouseEvent, data: any) => {
    // 阻止默认右键菜单
    event.preventDefault()
    // 设置选中节点
    selectedNode.value = data
    // 调用菜单组件的show方法
    if (menuRef.value) {
      menuRef.value.show(event)
    }
  }

  // 处理菜单点击
  const handleMenuClick = (item: MenuItemType) => {
    if (!selectedNode.value) return
    // 根据菜单key执行不同操作
    switch (item.key) {
      case 'view':
        if (hasAuth('view')) {
          handleViewDepartment()
        }
        break
      case 'edit':
        if (hasAuth('edit')) {
          handleEditDepartment()
        }
        break
      case 'clone':
        if (hasAuth('clone')) {
          handleCloneDepartment()
        }
        break
      case 'add':
        if (hasAuth('add')) {
          handleAddDepartment()
        }
        break
      case 'delete':
        if (hasAuth('delete')) {
          handleDeleteDepartment()
        }
        break
      case 'refresh':
        getTreeData()
        break
    }
  }

  // 查看部门详情
  const handleViewDepartment = () => {
    if (!selectedNode.value) return
    dialogType.value = 'view'
    currentDepartmentData.value = selectedNode.value
    dialogVisible.value = true
  }

  // 编辑部门
  const handleEditDepartment = () => {
    if (!selectedNode.value) return
    dialogType.value = 'edit'
    currentDepartmentData.value = selectedNode.value
    dialogVisible.value = true
  }

  // 克隆部门
  const handleCloneDepartment = () => {
    if (!selectedNode.value) return
    dialogType.value = 'clone'
    currentDepartmentData.value = { ...selectedNode.value }
    currentDepartmentData.value.name = `${selectedNode.value.name}副本`
    currentDepartmentData.value.parent_id = Number(selectedNode.value.parent_id)
    currentDepartmentData.value.code = `${selectedNode.value.code}-1`
    currentDepartmentData.value.remark = `来自于【${selectedNode.value.name}】副本`
    currentDepartmentData.value.created_at = ''
    currentDepartmentData.value.updated_at = ''
    currentDepartmentData.value.id = 0
    console.log(currentDepartmentData.value)
    console.log(selectedNode.value)
    dialogVisible.value = true
  }

  // 添加子部门
  const handleAddDepartment = () => {
    // if (!selectedNode.value) return
    dialogType.value = 'add'
    console.log('添加子部门:', selectedNode.value)
    if (selectedNode.value) {
      currentDepartmentData.value = {
        parent_id: selectedNode.value.id,
        name: `${selectedNode.value.name}子部门`,
        code: `${selectedNode.value.code}-1`
      }
    } else {
      currentDepartmentData.value = {}
    }
    console.log('添加子部门:', currentDepartmentData.value)
    dialogVisible.value = true
  }

  // 删除部门
  const handleDeleteDepartment = async () => {
    if (!selectedNode.value) return
    try {
      await ElMessageBox.confirm('确定要删除该部门吗？删除后将无法恢复。', '警告', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })

      const res = await deleteDepartmentApi(selectedNode.value.id)
      if (res && res.code === 200) {
        ElMessage.success('删除部门成功')
        getTreeData() // 刷新树数据
      }
    } catch (error) {
      if (error === 'cancel') {
        return // 用户取消操作
      }
      console.error('删除部门失败:', error)
      ElMessage.error('删除部门失败')
    }
  }

  // 处理对话框成功事件
  const handleDialogSuccess = () => {
    // ElMessage.success(dialogType.value === 'add' ? '添加部门成功' : '编辑部门成功')
    getTreeData() // 刷新树数据
  }

  // 初始加载树数据
  onMounted(() => {
    getTreeData()
  })

  // 表单搜索初始值
  const defaultFilter = ref({
    name: undefined
  })

  // 选中的部门ID，用于筛选子部门
  const selectedDepartmentId = ref<number | string>(0)

  const {
    data,
    columns,
    columnChecks,
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
    core: {
      apiFn: listDepartmentApi,
      apiParams: {
        current: 1,
        size: 20
      },
      columnsFactory: () => [
        { type: 'selection' }, // 勾选列
        { type: 'index', width: 65, label: '序号' }, // 序号
        { prop: 'id', width: 65, sortable: true, label: 'ID' }, // 部门ID
        {
          prop: 'name',
          label: '部门名称',
          sortable: true,
          formatter: (row: unknown) => {
            const departmentRow = row as Record<string, any>
            return h(
              'div',
              {
                style: 'cursor: pointer; color: var(--el-color-primary);',
                onClick: () => {
                  selectedNode.value = departmentRow
                  handleMenuClick({ key: 'view', label: '查看详情', icon: 'ri:eye-line' })
                }
              },
              departmentRow.name
            )
          }
        },
        {
          prop: 'manager_id',
          label: '负责人'
        },
        {
          prop: 'code',
          label: '部门编码'
        },
        {
          prop: 'sort',
          label: '排序'
        },
        {
          prop: 'status',
          label: '部门状态',
          width: 90,
          formatter: (row: unknown) => {
            const departmentRow = row as Record<string, any>
            const statusConfig = departmentRow.status
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
          prop: 'remark',
          label: '备注',
          showOverflowTooltip: true
        },
        {
          prop: 'created_time',
          sortable: true,
          sortField: 'created_at',
          label: '创建时间'
        },
        {
          prop: 'updated_time',
          sortable: true,
          sortField: 'updated_at',
          label: '更新时间'
        },
        {
          prop: 'operation',
          label: '操作',
          width: 75,
          fixed: 'right',
          formatter: (row: unknown) => {
            const departmentRow = row as Record<string, any>
            const buttons = []

            // 编辑按钮
            if (hasAuth('edit')) {
              buttons.push(
                h(ArtButtonTable, {
                  type: 'edit',
                  onClick: () => {
                    selectedNode.value = departmentRow
                    handleMenuClick({ key: 'edit', label: '编辑部门', icon: 'ri:pencil-line' })
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
                label: '克隆部门',
                icon: 'ri:file-copy-line'
              })
            }
            if (hasAuth('add')) {
              moreItems.push({
                key: 'add',
                label: '添加子部门',
                icon: 'ri:add-line'
              })
            }
            if (hasAuth('delete')) {
              moreItems.push({
                key: 'delete',
                label: '删除部门',
                icon: 'ri:delete-bin-4-line',
                color: '#f56c6c'
              })
            }
            if (moreItems.length > 0) {
              buttons.push(
                h('div', [
                  h(ArtButtonMore, {
                    list: moreItems,
                    onClick: (item: ButtonMoreItem) => buttonMoreClick(item, departmentRow)
                  })
                ])
              )
            }
            return h('div', { style: 'display: flex; gap: 4px;' }, buttons)
          }
        }
      ]
    }
  })

  // 路由跳转查看部门详情
  const viewDepartment = (row: Record<string, any>) => {
    // 使用router实例进行路由跳转
    router.push(`/system/department/view/${row.id}`)
  }

  // 批量操作方法
  const handleBatchEdit = () => {
    // 获取选中的行
    const elTableInstance = proTable.value?.elTableRef
    if (!elTableInstance) {
      ElMessage.warning('表格实例未获取到')
      return
    }

    const selectedRows = elTableInstance.getSelectionRows()
    if (!selectedRows || selectedRows.length === 0) {
      ElMessage.warning('请至少选择一个部门')
      return
    }

    // 提取选中的ID
    selectedDepartmentIds.value = selectedRows.map((row: any) => row.id)
    batchEditDialogVisible.value = true
  }

  const handleBatchAdd = () => {
    batchAddDialogVisible.value = true
  }

  const handleBatchDelete = () => {
    // 获取选中的行
    const elTableInstance = proTable.value?.elTableRef
    if (!elTableInstance) {
      ElMessage.warning('表格实例未获取到')
      return
    }

    const selectedRows = elTableInstance.getSelectionRows()
    if (!selectedRows || selectedRows.length === 0) {
      ElMessage.warning('请至少选择一个部门')
      return
    }

    // 提取选中的ID
    selectedDepartmentIds.value = selectedRows.map((row: any) => row.id)
    ElMessageBox.alert(`确认删除选中的 ${selectedRows.length} 个部门吗？`, 'Title', {
      // if you want to disable its autofocus
      // autofocus: false,
      confirmButtonText: '确认删除',
      callback: async (action: string) => {
        if (action === 'confirm') {
          const deleteData = {
            actions: 'delete',
            ids: selectedDepartmentIds.value
          }
          // 调用批量修改API
          const res = await batchActionDepartmentApi(deleteData)
          console.log('批量修改提交数据:', deleteData)
          console.log('批量修改API响应:', res)

          ElMessage.success('批量删除成功')
          refreshRemove()
        }
      }
    })
  }

  const handleBatchDisable = async () => {
    // 获取选中的行
    const elTableInstance = proTable.value?.elTableRef
    if (!elTableInstance) {
      ElMessage.warning('表格实例未获取到')
      return
    }

    const selectedRows = elTableInstance.getSelectionRows()
    if (!selectedRows || selectedRows.length === 0) {
      ElMessage.warning('请至少选择一个部门')
      return
    }

    // 提取选中的ID
    selectedDepartmentIds.value = selectedRows.map((row: any) => row.id)
    await handleBatchApi({
      fields: ['status'],
      values: {
        status: 0
      }
    })
  }

  const handleBatchEnable = async () => {
    // 获取选中的行
    const elTableInstance = proTable.value?.elTableRef
    if (!elTableInstance) {
      ElMessage.warning('表格实例未获取到')
      return
    }

    const selectedRows = elTableInstance.getSelectionRows()
    if (!selectedRows || selectedRows.length === 0) {
      ElMessage.warning('请至少选择一个部门')
      return
    }

    // 提取选中的ID
    selectedDepartmentIds.value = selectedRows.map((row: any) => row.id)
    // ElMessage.info('批量启用功能暂未实现')
    await handleBatchApi({
      fields: ['status'],
      values: {
        status: true
      }
    })
  }

  const handleBatchApi = async (params: any) => {
    // 调用批量修改API
    params.fields = params.fields || ['status']
    params.values = params.values || {
      status: false
    }
    const deleteData = {
      actions: 'update',
      fields: params.fields,
      values: params.values,
      ids: selectedDepartmentIds.value
    }
    // 调用批量修改API
    const res = await batchActionDepartmentApi(deleteData)
    console.log('批量修改提交数据:', deleteData)
    console.log('批量修改API响应:', res)

    ElMessage.success('批量操作成功')
    refreshUpdate()
  }

  const handleImport = () => {
    importDialogVisible.value = true
  }

  // 批量修改成功处理
  const handleBatchEditSuccess = () => {
    // ElMessage.success('批量修改成功')
    // 刷新数据
    refreshUpdate()
  }

  // 批量新增成功处理
  const handleBatchAddSuccess = () => {
    // ElMessage.success('批量新增成功')
    // 刷新数据
    refreshCreate()
  }

  // 导入成功处理
  const handleImportSuccess = () => {
    // ElMessage.success('导入成功')
    // 刷新数据
    refreshCreate()
  }

  // 处理树节点点击事件
  const handleNodeClick = (data: Tree) => {
    console.log(data)
    selectedDepartmentId.value = data.id
    // 刷新表格数据时显式传递更新后的父部门ID
    refreshData({
      'q[parent_id_eq]': selectedDepartmentId.value
    })
  }

  /**
   * 处理排序变化事件
   * @param prop 当前点击的字段
   * @param order 排序方向
   * @param sortField 要排序的字段，不填写则默认使用当前点击的字段
   */
  const handleSortChange = (prop: string, order: 'asc' | 'desc' | null, sortField?: string) => {
    console.log('handleSortChange', prop, order, sortField)
    // 排序逻辑：点击任意排序列时请求API并传递排序参数
    if (prop) {
      // 确定最终要排序的字段：如果传入了sortField则使用，否则使用当前点击的字段
      const finalSortField = sortField || prop

      // 当前排序状态
      const currentSortField = searchParams['q[s]']?.split(' ')[0] || ''
      const currentSortOrder = searchParams['q[s]']?.split(' ')[1] || ''

      // 切换排序顺序：首次点击或当前为asc时设置为desc，当前为desc时设置为asc
      if (currentSortField !== finalSortField || currentSortOrder !== 'desc') {
        // 首次点击或当前为asc，设置为desc
        searchParams['q[s]'] = `${finalSortField} desc`
      } else {
        // 当前为desc，设置为asc
        searchParams['q[s]'] = `${finalSortField} asc`
      }

      // 调用getData()刷新数据
      getData()
    }
  }

  // 处理更多按钮点击事件
  const buttonMoreClick = (item: ButtonMoreItem, row: Record<string, any>) => {
    selectedNode.value = row
    switch (item.key) {
      case 'view':
        viewDepartment(row)
        break
      case 'clone':
        handleCloneDepartment()
        break
      case 'add':
        handleAddDepartment()
        break
      case 'delete':
        handleDeleteDepartment()
        break
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
      const fileName = '部门数据'
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

<style scoped>
  .tree-card :deep(.el-card__body) {
    flex: 1;
    min-height: 0;
    padding: 10px 2px 10px 10px;
  }

  .min-h-full {
    display: flex;
    flex-wrap: nowrap;
    width: inherit;
    height: 100%;

    .no-check-node {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 100%;
      height: 100%;
      margin-left: 12px;
      background: #fff;
    }
  }

  .tree-collapse-btn {
    height: 30px;
    cursor: pointer;
    background-color: #f3f3f3;
    border: 1px solid #dcdfe6;
    border-radius: 2px;
  }
</style>
