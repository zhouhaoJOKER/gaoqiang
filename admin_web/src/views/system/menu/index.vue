<!-- 菜单管理页面 -->
<template>
  <div class="menu-page art-full-height">
    <!-- 搜索栏 -->
    <ArtSearchBar
      v-model="formFilters"
      :items="formItems"
      :showExpand="false"
      @reset="handleReset"
      @search="handleSearch"
    />

    <ElCard class="art-table-card" shadow="never">
      <!-- 表格头部 -->
      <ArtTableHeader
        :showZebra="false"
        :loading="loading"
        v-model:columns="columnChecks"
        @refresh="handleRefresh"
      >
        <template #left>
          <ElButton v-auth="'add'" @click="handleAddMenu" v-ripple> 添加菜单 </ElButton>
          <ElButton @click="toggleExpand" v-ripple>
            {{ isExpanded ? '收起' : '展开' }}
          </ElButton>
        </template>
      </ArtTableHeader>

      <ArtTable
        ref="tableRef"
        rowKey="path"
        :loading="loading"
        :columns="columns"
        :data="filteredTableData"
        :stripe="false"
        :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
        :default-expand-all="false"
      />

      <!-- 菜单弹窗 -->
      <MenuDialog
        v-model:visible="dialogVisible"
        :type="dialogType"
        :editData="editData"
        :lockType="lockMenuType"
        @submit="handleSubmit"
      />
    </ElCard>
  </div>
</template>

<script setup lang="ts">
  import { formatMenuTitle } from '@/utils/router'
  import ArtButtonTable from '@/components/core/forms/art-button-table/index.vue'
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import type { ButtonMoreItem } from '@/components/core/forms/art-button-more/index.vue'
  import { useTableColumns } from '@/hooks/core/useTableColumns'
  import type { AppRouteRecord } from '@/types/router'
  import MenuDialog from './modules/menu-dialog.vue'
  // import { fetchGetMenuList } from '@/api/system-manage'
  import { ElTag, ElMessageBox, ElMessage } from 'element-plus'

  import { listMenuApi, createMenuApi, updateMenuApi, deleteMenuApi } from '@/api/menu'

  defineOptions({ name: 'Menus' })

  // 状态管理
  const loading = ref(false)
  const isExpanded = ref(false)
  const tableRef = ref()

  // 弹窗相关
  const dialogVisible = ref(false)
  const dialogType = ref<'menu' | 'button'>('menu')
  const editData = ref<AppRouteRecord | any>(null)
  const lockMenuType = ref(false)

  // 搜索相关
  const initialSearchState = {
    name: '',
    route: ''
  }

  const formFilters = reactive({ ...initialSearchState })
  const appliedFilters = reactive({ ...initialSearchState })

  const formItems = computed(() => [
    {
      label: '菜单名称',
      key: 'name',
      type: 'input',
      props: { clearable: true }
    },
    {
      label: '路由地址',
      key: 'route',
      type: 'input',
      props: { clearable: true }
    }
  ])

  onMounted(() => {
    getMenuList()
  })

  /**
   * 获取菜单列表数据
   */
  const getMenuList = async (): Promise<void> => {
    loading.value = true

    try {
      // 调用listMenuApi接口获取菜单数据
      const response = await listMenuApi({ ...appliedFilters })
      // 使用records字段获取数据
      tableData.value = (response as any).data || []
    } catch (error: any) {
      console.error('获取菜单列表失败:', error)
      ElMessage.error('获取菜单列表失败')
      tableData.value = []
    } finally {
      loading.value = false
    }
  }

  /**
   * 获取菜单类型标签颜色
   * @param row 菜单行数据
   * @returns 标签颜色类型
   */
  const getMenuTypeTag = (
    row: AppRouteRecord
  ): 'primary' | 'success' | 'warning' | 'info' | 'danger' => {
    if (row.meta?.isAuthButton) return 'danger'
    if (row.children?.length) return 'info'
    if (row.meta?.link && row.meta?.isIframe) return 'success'
    if (row.path) return 'primary'
    if (row.meta?.link) return 'warning'
    return 'info'
  }

  /**
   * 获取菜单状态标签颜色
   * @param status 菜单状态
   * @returns 标签颜色类型
   */
  const getMenuStatusTag = (status: boolean): 'success' | 'danger' => {
    return status === true ? 'success' : 'danger'
  }

  /**
   * 获取菜单状态文本
   * @param status 菜单状态
   * @returns 菜单状态文本
   */
  const getMenuStatusText = (status: any): string => {
    return status === true ? '启用' : '停用'
  }

  /**
   * 获取菜单类型文本
   * @param row 菜单行数据
   * @returns 菜单类型文本
   */
  const getMenuTypeText = (row: AppRouteRecord): string => {
    if (row.meta?.isAuthButton) return '按钮'
    if (row.authList?.length || row.meta?.authList?.length) return '菜单'
    if (row.children?.length) return '目录'
    if (row.meta?.link && row.meta?.isIframe) return '内嵌'
    if (row.path) return '菜单'
    if (row.meta?.link) return '外链'
    return '未知'
  }

  // 表格列配置
  const { columnChecks, columns } = useTableColumns(() => [
    {
      prop: 'meta.title',
      label: '菜单名称',
      minWidth: 120,
      formatter: (row: AppRouteRecord) => formatMenuTitle(row.meta?.title)
    },
    {
      prop: 'type',
      label: '菜单类型',
      formatter: (row: AppRouteRecord) => {
        return h(ElTag, { type: getMenuTypeTag(row) }, () => getMenuTypeText(row))
      }
    },
    {
      prop: 'path',
      label: '路由',
      formatter: (row: AppRouteRecord) => {
        if (row.meta?.isAuthButton) return ''
        return row.meta?.link || row.path || ''
      }
    },
    {
      prop: 'authList',
      label: '权限标识',
      formatter: (row: AppRouteRecord) => {
        if (row.meta?.authList?.length === 0) return ''
        return `${row.meta?.authList?.length} 个权限标识`
      }
    },
    {
      prop: 'date',
      label: '编辑时间',
      formatter: (row: AppRouteRecord) => formatMenuTitle(row?.updated_time || '')
    },
    {
      prop: 'status',
      label: '状态',
      formatter: (row: any) => {
        return h(ElTag, { type: getMenuStatusTag(row.meta?.isEnable) }, () =>
          getMenuStatusText(row.meta?.isEnable)
        )
      }
    },
    {
      prop: 'operation',
      label: '操作',
      width: 120,
      fixed: 'right',
      formatter: (row: AppRouteRecord) => {
        // 目录类型菜单
        const moreItems: ButtonMoreItem[] = [
          { key: 'edit', label: '编辑', icon: 'ri:edit-line' },
          { key: 'add', label: '新增子菜单', icon: 'ri:add-line' },
          { key: 'clone', label: '克隆', icon: 'ri:file-copy-line' },
          { key: 'delete', label: '删除', icon: 'ri:delete-bin-line', color: '#f56c6c' }
        ]

        const handleMoreClick = (item: ButtonMoreItem) => {
          if (item.key === 'edit') handleEditMenu(row)
          if (item.key === 'add') handleAddMenu(row.id)
          if (item.key === 'clone') handleCloneMenu(row)
          if (item.key === 'delete') handleDeleteMenu(Number(row.id || 0))
        }

        return h('div', { style: 'display: flex; gap: 4px;' }, [
          h(ArtButtonTable, {
            type: 'role',
            onClick: () => handleAddAuth(row),
            title: '配置权限'
          }),
          h(ArtButtonTable, {
            type: 'edit',
            onClick: () => handleEditMenu(row),
            title: '编辑'
          }),
          h(ArtButtonMore, {
            list: moreItems,
            onClick: handleMoreClick
          })
        ])
      }
    }
  ])

  // 数据相关
  const tableData = ref<AppRouteRecord[]>([])

  /**
   * 重置搜索条件
   */
  const handleReset = (): void => {
    Object.assign(formFilters, { ...initialSearchState })
    Object.assign(appliedFilters, { ...initialSearchState })
    getMenuList()
  }

  /**
   * 执行搜索
   */
  const handleSearch = (): void => {
    Object.assign(appliedFilters, { ...formFilters })
    getMenuList()
  }

  /**
   * 刷新菜单列表
   */
  const handleRefresh = (): void => {
    getMenuList()
  }

  /**
   * 深度克隆对象
   * @param obj 要克隆的对象
   * @returns 克隆后的对象
   */
  const deepClone = <T,>(obj: T): T => {
    if (obj === null || typeof obj !== 'object') return obj
    if (obj instanceof Date) return new Date(obj) as T
    if (Array.isArray(obj)) return obj.map((item) => deepClone(item)) as T

    const cloned = {} as T
    for (const key in obj) {
      if (Object.prototype.hasOwnProperty.call(obj, key)) {
        cloned[key] = deepClone(obj[key])
      }
    }
    return cloned
  }

  /**
   * 处理菜单项，移除权限列表转换为子节点的逻辑
   * @param items 菜单项数组
   * @returns 处理后的菜单项数组
   */
  const convertAuthListToChildren = (items: AppRouteRecord[]): AppRouteRecord[] => {
    return items.map((item) => {
      const clonedItem = deepClone(item)

      if (clonedItem.children?.length) {
        clonedItem.children = convertAuthListToChildren(clonedItem.children)
      }

      // 移除将权限列表转换为子节点的逻辑，不再在表格中显示权限项

      return clonedItem
    })
  }

  /**
   * 搜索菜单
   * @param items 菜单项数组
   * @returns 搜索结果数组
   */
  const searchMenu = (items: AppRouteRecord[]): AppRouteRecord[] => {
    const results: AppRouteRecord[] = []

    for (const item of items) {
      const searchName = appliedFilters.name?.toLowerCase().trim() || ''
      const searchRoute = appliedFilters.route?.toLowerCase().trim() || ''
      const menuTitle = formatMenuTitle(item.meta?.title || '').toLowerCase()
      const menuPath = (item.path || '').toLowerCase()
      const nameMatch = !searchName || menuTitle.includes(searchName)
      const routeMatch = !searchRoute || menuPath.includes(searchRoute)

      if (item.children?.length) {
        const matchedChildren = searchMenu(item.children)
        if (matchedChildren.length > 0) {
          const clonedItem = deepClone(item)
          clonedItem.children = matchedChildren
          results.push(clonedItem)
          continue
        }
      }

      if (nameMatch && routeMatch) {
        results.push(deepClone(item))
      }
    }

    return results
  }

  // 过滤后的表格数据
  const filteredTableData = computed(() => {
    const searchedData = searchMenu(tableData.value)
    return convertAuthListToChildren(searchedData)
  })

  /**
   * 添加菜单
   */
  const handleAddMenu = (id: any) => {
    dialogType.value = 'menu'
    editData.value = {
      parent_id: id
    }
    lockMenuType.value = true
    dialogVisible.value = true
  }

  /**
   * 添加权限按钮
   */
  const handleAddAuth = (row: AppRouteRecord) => {
    dialogType.value = 'button'
    editData.value = {
      parent_id: row.id,
      currentAuthList: row.meta?.authList || []
    }
    lockMenuType.value = false
    dialogVisible.value = true
  }

  /**
   * 编辑菜单
   * @param row 菜单行数据
   */
  const handleEditMenu = (row: AppRouteRecord) => {
    dialogType.value = 'menu'
    editData.value = row
    lockMenuType.value = true
    dialogVisible.value = true
  }

  /**
   * 提交表单数据
   * @param formData 表单数据
   */
  const handleSubmit = (formData: Record<string, any>) => {
    if (dialogType.value === 'menu') {
      // 编辑菜单字段映射调整
      formData.show_text_badge = formData.showTextBadge
      formData.active_path = formData.activePath
      formData.is_enable = formData.isEnable
      formData.keep_alive = formData.keepAlive
      formData.is_hide = formData.isHide
      formData.show_badge = formData.showBadge
      formData.is_iframe = formData.isIframe
      formData.fixed_tab = formData.fixedTab
      formData.is_hide_tab = formData.isHideTab
      formData.is_full_page = formData.isFullPage
      console.log(formData)
      // 处理菜单提交逻辑
      if (formData.id != 0) {
        // 编辑菜单api
        updateMenuApi(editData.value?.id as string, formData).then(() => {
          ElMessage.success('更新成功')
          getMenuList()
        })
      } else {
        // 新增菜单
        formData.menu_type = 'menu'
        createMenuApi(formData).then(() => {
          ElMessage.success('新增成功')
          getMenuList()
        })
      }
    } else if (dialogType.value === 'button') {
      // 处理权限提交逻辑
      formData.menu_type = 'btn'

      // 确保权限数据被正确关联到菜单
      if (formData.permissions && Array.isArray(formData.permissions)) {
        // 过滤掉空权限项
        const validPermissions = formData.permissions.filter((item) => item.title || item.name)
        if (validPermissions.length > 0) {
          // 将权限列表保存到菜单数据中
          formData.auth_list = validPermissions.map((perm) => ({
            title: perm.title,
            authMark: perm.name
          }))
        }
      }

      if (formData.id != 0) {
        // 编辑权限
        updateMenuApi(editData.value?.id as string, formData).then(() => {
          ElMessage.success('更新成功')
          getMenuList()
        })
      } else {
        // 配置权限
        createMenuApi(formData).then(() => {
          ElMessage.success('新增成功')
          getMenuList()
        })
      }
    }

    // 这里可以调用API保存数据
    getMenuList()
  }

  const handleDeleteMenu = async (id: number) => {
    try {
      await ElMessageBox.confirm('确定要删除该菜单吗？删除后无法恢复', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })
      ElMessage.success('删除成功')

      deleteMenuApi(id).then(() => {
        getMenuList()
      })
    } catch (error) {
      if (error !== 'cancel') {
        ElMessage.error('删除失败')
      }
    }
  }

  /**
   * 克隆菜单
   * @param row 要克隆的菜单行数据
   */
  const handleCloneMenu = (row: AppRouteRecord) => {
    // 深度克隆菜单数据
    const clonedRow = deepClone(row)

    // 根据菜单类型设置不同的克隆逻辑
    if (row.meta?.isAuthButton) {
      // 克隆按钮权限
      dialogType.value = 'button'

      // 修改克隆数据，添加_clone后缀
      const originalTitle = row.meta?.title || ''
      const originalAuthMark = row.meta?.authMark || ''

      clonedRow.meta = {
        ...clonedRow.meta,
        title: `${originalTitle}_clone`,
        authMark: `${originalAuthMark}_clone`,
        id: 0, // 重置ID为新增状态
        sort: row.meta?.sort || 1
      }

      editData.value = {
        id: 0,
        parent_id: clonedRow.meta?.parent_id,
        title: clonedRow.meta?.title,
        sort: clonedRow.meta?.sort,
        name: clonedRow.meta?.authMark
      }
    } else {
      // 克隆普通菜单
      dialogType.value = 'menu'

      // 修改克隆数据，添加_clone后缀
      const originalTitle = row.meta?.title || ''
      const originalPath = row.path || ''
      const originalName = row.name || ''

      // 重置ID为新增状态
      clonedRow.id = 0
      clonedRow.meta = {
        ...clonedRow.meta,
        id: 0,
        title: `${originalTitle}_clone`,
        sort: row.meta?.sort || 1
      }

      if (originalPath) {
        clonedRow.path = `${originalPath}_clone`
      }

      if (originalName) {
        clonedRow.name = `${String(originalName)}_clone`
      }

      editData.value = clonedRow
    }

    lockMenuType.value = dialogType.value === 'menu'
    dialogVisible.value = true
  }

  /**
   * 切换展开/收起所有菜单
   */
  const toggleExpand = (): void => {
    isExpanded.value = !isExpanded.value
    nextTick(() => {
      if (tableRef.value?.elTableRef && filteredTableData.value) {
        const processRows = (rows: AppRouteRecord[]) => {
          rows.forEach((row) => {
            if (row.children?.length) {
              tableRef.value.elTableRef.toggleRowExpansion(row, isExpanded.value)
              processRows(row.children)
            }
          })
        }
        processRows(filteredTableData.value)
      }
    })
  }
</script>
