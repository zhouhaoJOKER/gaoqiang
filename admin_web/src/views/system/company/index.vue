<!-- 公司管理页面 -->
<template>
  <div class="company-page art-full-height">
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
            <b>公司管理</b>
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
                  />
                </div>
                <div v-else class="py-4 text-center text-gray-400"> 暂无公司数据 </div>
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
              <ElButton v-auth="'add'" @click="handleAddCompany" v-ripple> 添加公司 </ElButton>
              <ElButton @click="toggleExpand" v-ripple>
                {{ isExpanded ? '收起' : '展开' }}
              </ElButton>
            </template>
          </ArtTableHeader>

          <ArtTable
            ref="tableRef"
            rowKey="id"
            :loading="loading"
            :columns="columns"
            :data="filteredTableData"
            :stripe="false"
            :tree-props="{ children: 'children', hasChildren: 'hasChildren' }"
            :default-expand-all="false"
          />

          <!-- 公司弹窗 -->
          <CompanyDialog
            v-model:visible="dialogVisible"
            :editData="editData"
            @submit="handleSubmit"
          />
        </ElCard>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import type { ButtonMoreItem } from '@/components/core/forms/art-button-more/index.vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { useTableColumns } from '@/hooks/core/useTableColumns'
  import CompanyDialog from './modules/company-dialog.vue'
  import { ElMessageBox, ElMessage, ElScrollbar } from 'element-plus'

  import {
    listCompanyApi,
    createCompanyApi,
    updateCompanyApi,
    deleteCompanyApi
  } from '@/api/company'

  defineOptions({ name: 'Companies' })
  // 状态管理
  const loading = ref(false)
  const isExpanded = ref(false)
  const tableRef = ref()

  // 树相关
  const isTreeCollapsed = ref(false)
  const treeLoading = ref(false)
  const treeData = ref<any[]>([])
  const treeProps = {
    label: 'name',
    children: 'children'
  }

  // 弹窗相关
  const dialogVisible = ref(false)
  const editData = ref<any>(null)
  // 搜索相关
  const initialSearchState = {
    name: '',
    abbr: ''
  }

  const formFilters = reactive({ ...initialSearchState })
  const appliedFilters = reactive({ ...initialSearchState })

  const formItems = computed(() => [
    {
      label: '公司名称',
      key: 'name',
      type: 'input',
      props: { clearable: true }
    },
    {
      label: '公司简称',
      key: 'abbr',
      type: 'input',
      props: { clearable: true }
    }
  ])

  onMounted(() => {
    getCompanyList()
  })

  /**
   * 构建树形结构
   */
  const buildTree = (items: any[]): any[] => {
    const map: any = {}
    const tree: any[] = []

    // 构建ID映射
    items.forEach((item) => {
      map[item.id] = { ...item, children: [] }
    })

    // 构建树形结构
    items.forEach((item) => {
      if (item.parent_id) {
        if (map[item.parent_id]) {
          map[item.parent_id].children.push(map[item.id])
        }
      } else {
        tree.push(map[item.id])
      }
    })

    // 为每个节点添加 isLeaf 属性
    const addIsLeafProperty = (nodes: any[]) => {
      nodes.forEach((node) => {
        node.isLeaf = node.children.length === 0
        if (node.children.length > 0) {
          addIsLeafProperty(node.children)
        }
      })
    }

    addIsLeafProperty(tree)

    return tree
  }

  /**
   * 获取公司列表数据
   */
  const getCompanyList = async (): Promise<void> => {
    loading.value = true
    treeLoading.value = true

    try {
      // 调用listCompanyApi接口获取公司数据
      const response = await listCompanyApi({ ...appliedFilters })
      // 使用records字段获取数据
      const data = (response as any).data || []
      tableData.value = data
      treeData.value = buildTree(data)
    } catch (error: any) {
      console.error('获取公司列表失败:', error)
      ElMessage.error('获取公司列表失败')
      tableData.value = []
      treeData.value = []
    } finally {
      loading.value = false
      treeLoading.value = false
    }
  }

  /**
   * 切换树折叠/展开状态
   */
  const toggleTreeCollapse = () => {
    isTreeCollapsed.value = !isTreeCollapsed.value
  }

  // 表格列配置
  const { columnChecks, columns } = useTableColumns(() => [
    // {
    //   prop: 'logo',
    //   label: '公司logo',
    //   minWidth: 80,
    //   formatter: (row: any) => {
    //     if (row.logo) {
    //       return h('img', {
    //         src: row.logo,
    //         class: 'w-8 h-8 rounded',
    //         alt: row.name
    //       })
    //     }
    //     return ''
    //   }
    // },
    {
      prop: 'credit_code',
      label: '编号',
      maxWidth: 80,
      formatter: (row: any) => row.credit_code || ''
    },
    {
      prop: 'name',
      label: '公司名称',
      minWidth: 150,
      formatter: (row: any) => row.name || ''
    },
    {
      prop: 'abbr',
      label: '公司简称',
      minWidth: 100,
      formatter: (row: any) => row.abbr || ''
    },
    {
      prop: 'parent_id',
      label: '上级公司',
      minWidth: 120,
      formatter: (row: any) => {
        if (row.parent_id) {
          const parentCompany = tableData.value.find((item: any) => item.id === row.parent_id)
          return parentCompany?.name || ''
        }
        return '无'
      }
    },
    {
      prop: 'user_id',
      label: '负责人',
      minWidth: 100,
      formatter: (row: any) => row.user_name || ''
    },
    {
      prop: 'operation',
      label: '操作',
      width: 120,
      fixed: 'right',
      formatter: (row: any) => {
        const moreItems: ButtonMoreItem[] = [
          { key: 'edit', label: '编辑', icon: 'ri:edit-line' },
          { key: 'delete', label: '删除', icon: 'ri:delete-bin-line', color: '#f56c6c' }
        ]

        const handleMoreClick = (item: ButtonMoreItem) => {
          if (item.key === 'edit') handleEditCompany(row)
          if (item.key === 'delete') handleDeleteCompany(Number(row.id || 0))
        }

        return h('div', { style: 'display: flex; gap: 4px;' }, [
          h(ArtButtonMore, {
            list: moreItems,
            onClick: handleMoreClick
          })
        ])
      }
    }
  ])

  // 数据相关
  const tableData = ref<any[]>([])

  /**
   * 重置搜索条件
   */
  const handleReset = (): void => {
    Object.assign(formFilters, { ...initialSearchState })
    Object.assign(appliedFilters, { ...initialSearchState })
    getCompanyList()
  }

  /**
   * 执行搜索
   */
  const handleSearch = (): void => {
    Object.assign(appliedFilters, { ...formFilters })
    getCompanyList()
  }

  /**
   * 刷新公司列表
   */
  const handleRefresh = (): void => {
    getCompanyList()
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
   * 处理公司项，移除权限列表转换为子节点的逻辑
   * @param items 公司项数组
   * @returns 处理后的公司项数组
   */
  const convertCompanyList = (items: any[]): any[] => {
    return items.map((item) => {
      const clonedItem = deepClone(item)

      if (clonedItem.children?.length) {
        clonedItem.children = convertCompanyList(clonedItem.children)
      }

      return clonedItem
    })
  }

  /**
   * 搜索公司
   * @param items 公司项数组
   * @returns 搜索结果数组
   */
  const searchCompany = (items: any[]): any[] => {
    const results: any[] = []

    for (const item of items) {
      const searchName = appliedFilters.name?.toLowerCase().trim() || ''
      const searchAbbr = appliedFilters.abbr?.toLowerCase().trim() || ''
      const companyName = (item.name || '').toLowerCase()
      const companyAbbr = (item.abbr || '').toLowerCase()
      const nameMatch = !searchName || companyName.includes(searchName)
      const abbrMatch = !searchAbbr || companyAbbr.includes(searchAbbr)

      if (item.children?.length) {
        const matchedChildren = searchCompany(item.children)
        if (matchedChildren.length > 0) {
          const clonedItem = deepClone(item)
          clonedItem.children = matchedChildren
          results.push(clonedItem)
          continue
        }
      }

      if (nameMatch && abbrMatch) {
        results.push(deepClone(item))
      }
    }

    return results
  }

  // 过滤后的表格数据
  const filteredTableData = computed(() => {
    const searchedData = searchCompany(tableData.value)
    return convertCompanyList(searchedData)
  })

  /**
   * 添加公司
   */
  const handleAddCompany = () => {
    editData.value = {}
    dialogVisible.value = true
  }

  /**
   * 编辑公司
   * @param row 公司行数据
   */
  const handleEditCompany = (row: any) => {
    editData.value = row
    dialogVisible.value = true
  }

  /**
   * 提交表单数据
   * @param formData 表单数据
   */
  const handleSubmit = (formData: Record<string, any>) => {
    if (formData.id != 0) {
      // 编辑公司
      updateCompanyApi(editData.value?.id as string, formData).then(() => {
        ElMessage.success('更新成功')
        getCompanyList()
      })
    } else {
      // 新增公司
      createCompanyApi(formData).then(() => {
        ElMessage.success('新增成功')
        getCompanyList()
      })
    }
  }

  const handleDeleteCompany = async (id: number) => {
    try {
      await ElMessageBox.confirm('确定要删除该公司吗？删除后无法恢复', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })
      ElMessage.success('删除成功')

      deleteCompanyApi(id).then(() => {
        getCompanyList()
      })
    } catch (error) {
      if (error !== 'cancel') {
        ElMessage.error('删除失败')
      }
    }
  }

  /**
   * 切换展开/收起所有公司
   */
  const toggleExpand = (): void => {
    isExpanded.value = !isExpanded.value
    nextTick(() => {
      if (tableRef.value?.elTableRef && filteredTableData.value) {
        const processRows = (rows: any[]) => {
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
