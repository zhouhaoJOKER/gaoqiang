<!-- 项目集列表页面 -->
<template>
  <div class="portfolio-page art-full-height">
    <!-- 顶部：星标项目集 -->
    <div class="mb-6">
      <div class="flex items-center justify-between mb-3">
        <div class="text-base font-medium text-g-900">星标项目集</div>
      </div>

      <div
        v-if="starredPortfolios.length"
        class="grid grid-cols-1 gap-4 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4"
      >
        <ElCard
          v-for="item in starredPortfolios"
          :key="item.id"
          class="relative overflow-hidden cursor-pointer transition-all duration-150 hover:shadow-md"
          shadow="never"
          @click="handlePortfolioClick(item)"
        >
          <div class="flex items-center">
            <div
              class="flex items-center justify-center w-20 h-16 mr-4 rounded-lg bg-g-100 text-primary-500"
            >
              <ArtSvgIcon icon="ri:folder-3-line" class="text-2xl" />
            </div>
            <div class="flex-1 min-w-0">
              <div class="flex items-center">
                <span class="text-sm font-medium text-g-900 truncate">{{ item.name }}</span>
                <ArtSvgIcon
                  v-if="item.is_star"
                  icon="ri:star-fill"
                  class="ml-2 text-base text-yellow-400"
                />
              </div>
              <div class="mt-1 text-xs text-g-500 truncate">
                共 {{ item.project_count || 0 }} 个项目
              </div>
              <div class="mt-1 text-xs text-g-400 truncate">
                {{ item.group_name || '默认分组' }}
              </div>
            </div>
          </div>
        </ElCard>
      </div>

      <div v-else class="flex items-center justify-center h-32 text-sm text-g-400">
        暂无星标项目集
      </div>
    </div>

    <!-- 中部：工具栏 / 搜索 -->
    <div class="flex items-center justify-between mb-3">
      <div class="flex items-center gap-3">
        <span class="text-base font-medium text-g-900">我参与的</span>
        <ElDropdown>
          <span class="flex items-center text-sm text-g-500 cursor-pointer">
            全部
            <ArtSvgIcon icon="ri:arrow-down-s-line" class="ml-0.5 text-xs" />
          </span>
          <template #dropdown>
            <ElDropdownMenu>
              <ElDropdownItem>全部</ElDropdownItem>
              <ElDropdownItem>我负责的</ElDropdownItem>
              <ElDropdownItem>我参与的</ElDropdownItem>
            </ElDropdownMenu>
          </template>
        </ElDropdown>
      </div>

      <div class="flex items-center gap-2">
        <ElButton text>
          <ArtSvgIcon icon="ri:layout-row-line" class="mr-1" />
          分组
        </ElButton>
        <ElButton text>
          <ArtSvgIcon icon="ri:filter-3-line" class="mr-1" />
          筛选
        </ElButton>
        <ElButton text>
          <ArtSvgIcon icon="ri:download-2-line" class="mr-1" />
          导出
        </ElButton>
        <ElButton type="primary" @click="handleCreate">
          <ArtSvgIcon icon="ri:add-line" class="mr-1" />
          新建项目集
        </ElButton>
      </div>
    </div>

    <!-- 搜索栏 -->
    <ArtSearchBar
      v-model="formFilters"
      :items="formItems"
      :showExpand="false"
      class="mb-3"
      @reset="handleReset"
      @search="handleSearch"
    />

    <!-- 表格 -->
    <ElCard class="art-table-card" shadow="never">
      <ArtTableHeader
        :showZebra="false"
        :loading="loading"
        v-model:columns="columnChecks"
        @refresh="handleRefresh"
      />

      <ArtTable
        rowKey="id"
        :loading="loading"
        :columns="columns"
        :data="filteredTableData"
        :stripe="false"
      />
    </ElCard>

    <!-- 项目集弹窗 -->
    <PortfolioDialog
      v-model:visible="dialogVisible"
      :editData="editData"
      @submit="handleSubmit"
      @submit-and-add="handleSubmitAndAdd"
    />

    <!-- 状态管理弹窗 -->
    <PortfolioStatusDialog
      v-model="statusDialogVisible"
      sign="portfolio_status"
      :selectable="true"
      selection-mode="single"
      :selected-value="selectedStatusId"
      @update:selected-value="handleSelectedStatusChange"
      @confirm="handleStatusConfirm"
    />
  </div>
</template>

<script setup lang="ts">
  import { h } from 'vue'
  import { useRouter } from 'vue-router'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { useTableColumns } from '@/hooks/core/useTableColumns'
  import { ElMessage, ElTooltip } from 'element-plus'
  import {
    listPmPortfolioApi,
    createPmPortfolioApi,
    updatePmPortfolioApi
  } from '@/api/pm/portfolio'
  import { listPropertyApi } from '@/api/property'
  import PortfolioDialog from './modules/portfolio-dialog.vue'
  import PortfolioStatusDialog from '@/components/PortfolioStatusDialog.vue'

  defineOptions({ name: 'PmPortfolios' })

  const router = useRouter()

  interface PortfolioItem {
    id?: string | number
    name?: string
    status_id?: string | number
    status?: string // 状态文本（用于显示）
    start_date?: string
    end_date?: string
    manager_id?: string | number
    manager_name?: string
    description?: string
    is_star?: boolean
    user_id?: (string | number)[]
    group_name?: string // 分组（如果有）
    project_count?: number // 项目数量（如果有）
    [key: string]: any
  }

  const loading = ref(false)

  // 弹窗相关
  const dialogVisible = ref(false)
  const editData = ref<any>(null)
  const statusDialogVisible = ref(false)
  const selectedStatusId = ref<string | number | undefined>(undefined)

  // 状态列表
  const statusList = ref<Array<{ id: number | string; name: string; [key: string]: any }>>([])

  // 状态选项映射（从接口数据动态生成）
  const statusMap = computed<Record<number, string>>(() => {
    const map: Record<number, string> = {}
    statusList.value.forEach((status) => {
      if (status.id !== undefined && status.id !== null) {
        map[Number(status.id)] = status.name
      }
    })
    return map
  })

  // 搜索相关
  const initialSearchState = {
    name: '',
    status_id: ''
  }

  const formFilters = reactive({ ...initialSearchState })
  const appliedFilters = reactive({ ...initialSearchState })

  const formItems = computed(() => [
    {
      label: '名称',
      key: 'name',
      type: 'input',
      props: { clearable: true, placeholder: '请输入项目集名称' }
    },
    {
      label: '状态',
      key: 'status_id',
      type: 'select',
      props: {
        clearable: true,
        options: statusList.value.map((status) => ({
          label: status.name,
          value: status.id
        }))
      }
    }
  ])

  // 数据
  const tableData = ref<PortfolioItem[]>([])

  /**
   * 加载状态列表
   */
  const loadStatusList = async (): Promise<void> => {
    try {
      const res = await listPropertyApi({
        sign: 'portfolio_status'
      })
      const data = (res as any).data || []
      // 按 sort 字段排序，如果没有 sort 则按 id 排序
      statusList.value = data.sort((a: any, b: any) => {
        const sortA = a.sort ?? a.id ?? 0
        const sortB = b.sort ?? b.id ?? 0
        return Number(sortA) - Number(sortB)
      })
    } catch (error) {
      console.error('加载状态列表失败:', error)
      statusList.value = []
    }
  }

  onMounted(() => {
    loadStatusList()
    getPortfolioList()
  })

  /**
   * 获取项目集列表
   */
  const getPortfolioList = async (): Promise<void> => {
    loading.value = true
    try {
      const res = await listPmPortfolioApi({ ...appliedFilters })
      tableData.value = (res as any).data || []
    } catch (error) {
      console.error('获取项目集列表失败:', error)
      tableData.value = []
      ElMessage.error('获取项目集列表失败')
    } finally {
      loading.value = false
    }
  }

  /**
   * 星标项目集
   */
  const starredPortfolios = computed(() => tableData.value.filter((item) => item.is_star))

  /**
   * 切换星标状态
   */
  const toggleStar = async (row: PortfolioItem, event: Event): Promise<void> => {
    event.stopPropagation() // 阻止事件冒泡

    if (!row.id) {
      ElMessage.warning('项目集ID不存在')
      return
    }

    const newStarStatus = !row.is_star

    try {
      // 乐观更新：先更新UI
      row.is_star = newStarStatus

      // 调用API更新
      await updatePmPortfolioApi(String(row.id), {
        is_star: newStarStatus
      })

      ElMessage.success(newStarStatus ? '已添加星标' : '已取消星标')
    } catch (error) {
      // 失败时回滚
      row.is_star = !newStarStatus
      console.error('更新星标状态失败:', error)
      ElMessage.error('更新星标状态失败')
    }
  }

  /**
   * 表格列配置
   */
  const { columnChecks, columns } = useTableColumns(() => [
    {
      prop: 'name',
      label: '名称',
      minWidth: 200,
      formatter: (row: PortfolioItem) => {
        return h('div', { class: 'flex items-center gap-2' }, [
          h(
            'span',
            {
              class: 'cursor-pointer hover:text-primary-500 transition-colors',
              onClick: () => handlePortfolioClick(row)
            },
            row.name || ''
          ),
          h(
            ElTooltip,
            {
              content: row.is_star ? '取消星标' : '添加星标',
              placement: 'top'
            },
            {
              default: () =>
                h(
                  'span',
                  {
                    class: 'star-icon-wrapper inline-flex items-center',
                    onClick: (e: Event) => toggleStar(row, e)
                  },
                  [
                    h(ArtSvgIcon, {
                      icon: row.is_star ? 'ri:star-fill' : 'ri:star-line',
                      class: row.is_star
                        ? 'text-base text-yellow-400 cursor-pointer hover:opacity-80 transition-opacity'
                        : 'text-base text-g-400 cursor-pointer hover:text-yellow-400 transition-colors'
                    })
                  ]
                )
            }
          )
        ])
      }
    },
    {
      prop: 'group_name',
      label: '分组',
      minWidth: 120,
      formatter: (row: PortfolioItem) => row.group_name || '原分组'
    },
    {
      prop: 'status_id',
      label: '状态',
      minWidth: 120,
      formatter: (row: PortfolioItem) => {
        const statusText = row.status
          ? row.status
          : row.status_id !== undefined && row.status_id !== null
            ? statusMap.value[row.status_id as number] || '待设置'
            : '待设置'

        return h(
          'span',
          {
            class:
              'cursor-pointer text-primary-500 hover:text-primary-600 hover:underline transition-colors',
            onClick: (e: Event) => {
              e.stopPropagation()
              handleOpenStatusDialog()
            }
          },
          statusText
        )
      }
    },
    {
      prop: 'manager_name',
      label: '项目集负责人',
      minWidth: 150,
      formatter: (row: PortfolioItem) => row.manager_name || '待设置'
    },
    {
      prop: 'start_date',
      label: '开始时间',
      minWidth: 160,
      formatter: (row: PortfolioItem) => {
        if (!row.start_date) return '待设置'
        // 格式化日期显示
        const date = new Date(row.start_date)
        if (isNaN(date.getTime())) return row.start_date
        return date
          .toLocaleDateString('zh-CN', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit'
          })
          .replace(/\//g, '-')
      }
    },
    {
      prop: 'end_date',
      label: '截止时间',
      minWidth: 160,
      formatter: (row: PortfolioItem) => {
        if (!row.end_date) return '待设置'
        // 格式化日期显示
        const date = new Date(row.end_date)
        if (isNaN(date.getTime())) return row.end_date
        return date
          .toLocaleDateString('zh-CN', {
            year: 'numeric',
            month: '2-digit',
            day: '2-digit'
          })
          .replace(/\//g, '-')
      }
    }
  ])

  /**
   * 过滤后的表格数据（简单按名称 / 状态过滤）
   */
  const filteredTableData = computed(() => {
    const name = (appliedFilters.name || '').toLowerCase().trim()
    const statusId = appliedFilters.status_id

    return tableData.value.filter((item) => {
      const n = (item.name || '').toLowerCase()
      const nameMatch = !name || n.includes(name)

      // 状态匹配：如果选择了状态ID，则匹配 status_id
      let statusMatch = true
      if (statusId !== '' && statusId !== null && statusId !== undefined) {
        statusMatch = item.status_id === statusId
      }

      return nameMatch && statusMatch
    })
  })

  /**
   * 搜索与重置
   */
  const handleReset = (): void => {
    Object.assign(formFilters, { ...initialSearchState })
    Object.assign(appliedFilters, { ...initialSearchState })
    getPortfolioList()
  }

  const handleSearch = (): void => {
    Object.assign(appliedFilters, { ...formFilters })
    getPortfolioList()
  }

  const handleRefresh = (): void => {
    getPortfolioList()
  }

  /**
   * 新建项目集
   */
  const handleCreate = () => {
    editData.value = null
    dialogVisible.value = true
  }

  /**
   * 提交项目集表单
   */
  const handleSubmit = async (formData: any): Promise<void> => {
    try {
      if (formData.id) {
        // 编辑
        await updatePmPortfolioApi(String(formData.id), formData)
        ElMessage.success('更新成功')
      } else {
        // 新建
        await createPmPortfolioApi(formData)
        ElMessage.success('创建成功')
      }
      getPortfolioList()
    } catch (error) {
      console.error('提交项目集失败:', error)
      ElMessage.error('操作失败')
    }
  }

  /**
   * 完成并添加项目
   */
  const handleSubmitAndAdd = async (formData: any): Promise<void> => {
    try {
      if (formData.id) {
        await updatePmPortfolioApi(String(formData.id), formData)
        ElMessage.success('更新成功')
      } else {
        const res = await createPmPortfolioApi(formData)
        ElMessage.success('创建成功')
        // 这里可以根据返回的项目集ID跳转到添加项目页面
        // 或者打开添加项目的弹窗
        const portfolioId = (res as any).data?.id
        if (portfolioId) {
          ElMessage.info('可以在这里跳转到添加项目页面，项目集ID: ' + portfolioId)
        }
      }
      getPortfolioList()
    } catch (error) {
      console.error('提交项目集失败:', error)
      ElMessage.error('操作失败')
    }
  }

  /**
   * 处理选中状态变化
   */
  const handleSelectedStatusChange = (
    value: string | number | (string | number)[] | undefined
  ): void => {
    if (Array.isArray(value)) {
      selectedStatusId.value = value.length > 0 ? value[0] : undefined
    } else {
      selectedStatusId.value = value
    }
  }

  /**
   * 打开状态管理弹窗
   */
  const handleOpenStatusDialog = (): void => {
    statusDialogVisible.value = true
  }

  /**
   * 状态管理弹窗确认回调
   */
  const handleStatusConfirm = (statusList: any[]): void => {
    // 单选模式下，statusList 只包含一个选中的状态项
    if (statusList.length > 0) {
      const selectedStatus = statusList[0]
      selectedStatusId.value = selectedStatus.id
      // 可以在这里更新状态映射或刷新列表
      getPortfolioList()
    }
  }

  /**
   * 点击项目集跳转到详情页
   */
  const handlePortfolioClick = (item: PortfolioItem): void => {
    if (item.id) {
      router.push({
        name: 'PortfolioDetail',
        params: { id: item.id }
      })
    }
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';

  .portfolio-page {
    @apply p-4;
  }
</style>
