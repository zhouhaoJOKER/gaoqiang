<!-- 项目列表页面 -->
<template>
  <div class="project-page art-full-height">
    <!-- 顶部：星标项目 -->
    <div class="mb-6">
      <div class="flex items-center justify-between mb-3">
        <div class="text-base font-medium text-g-900">星标项目</div>
      </div>

      <ElRow v-if="starredProjects.length" :gutter="20">
        <ElCol
          v-for="item in starredProjects"
          :key="item.id"
          :xs="24"
          :sm="12"
          :md="6"
          class="mb-2"
        >
          <div class="relative project-card-wrapper">
            <ArtImageCard
              :imageUrl="getImageUrl(item.logo) || ''"
              :title="item.name || ''"
              :category="item.portfolio_name || ''"
              :date="getTruncatedDescription(item.description)"
              @click="handleProjectClick(item)"
            />
            <!-- 操作菜单 -->
            <div class="absolute top-2 right-2 z-10">
              <ElDropdown @command="(cmd) => handleCommand(cmd, item)" trigger="click">
                <ElButton text class="p-1 bg-white/80 hover:bg-white shadow-sm">
                  <ArtSvgIcon icon="ri:more-2-line" class="text-base text-g-500" />
                </ElButton>
                <template #dropdown>
                  <ElDropdownMenu>
                    <ElDropdownItem command="star">
                      <ArtSvgIcon
                        :icon="item.is_star ? 'ri:star-fill' : 'ri:star-line'"
                        class="mr-1"
                      />
                      {{ item.is_star ? '取消星标' : '添加星标' }}
                    </ElDropdownItem>
                    <ElDropdownItem command="edit">
                      <ArtSvgIcon icon="ri:edit-line" class="mr-1" />
                      编辑
                    </ElDropdownItem>
                    <ElDropdownItem command="delete" divided>
                      <ArtSvgIcon icon="ri:delete-bin-line" class="mr-1" />
                      删除
                    </ElDropdownItem>
                  </ElDropdownMenu>
                </template>
              </ElDropdown>
            </div>
          </div>
        </ElCol>
      </ElRow>

      <div v-else class="flex items-center justify-center h-32 text-sm text-g-400">
        暂无星标项目
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
          新建项目
        </ElButton>
      </div>
    </div>

    <!-- 搜索栏 -->
    <ArtSearchBar
      v-model="formFilters"
      :items="formItems"
      :showExpand="false"
      class="mb-1"
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

    <!-- 模板选择对话框 -->
    <TemplateSelectDialog
      :visible="templateSelectDialogVisible"
      @update:visible="templateSelectDialogVisible = $event"
      @select="handleTemplateSelect"
      @skip="handleSkipTemplate"
    />

    <!-- 项目创建对话框 -->
    <ProjectDialog
      v-model:visible="projectDialogVisible"
      :editData="editData"
      :templateData="selectedTemplateData"
      @submit="handleSubmit"
    />
  </div>
</template>

<script setup lang="ts">
  import { h } from 'vue'
  import { useRouter } from 'vue-router'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import ArtImageCard from '@/components/core/cards/art-image-card/index.vue'
  import { useTableColumns } from '@/hooks/core/useTableColumns'
  import {
    ElMessage,
    ElMessageBox,
    ElTooltip,
    ElCard,
    ElRow,
    ElCol,
    ElDropdown,
    ElDropdownMenu,
    ElDropdownItem,
    ElButton
  } from 'element-plus'
  import {
    listPmProjectApi,
    updatePmProjectApi,
    createPmProjectApi,
    deletePmProjectApi
  } from '@/api/pm/project'
  import { listPropertyApi } from '@/api/property'
  import TemplateSelectDialog from './modules/template-select-dialog.vue'
  import ProjectDialog from './modules/project-dialog.vue'

  defineOptions({ name: 'PmProjects' })

  const router = useRouter()

  interface ProjectItem {
    id?: string | number
    name?: string
    status_id?: string | number
    status?: string // 状态文本（用于显示）
    start_date?: string
    end_date?: string
    manager_id?: string | number
    manager_name?: string
    description?: string
    logo?: string
    is_star?: boolean
    portfolio_id?: string | number
    portfolio_name?: string
    task_count?: number // 任务数量（如果有）
    [key: string]: any
  }

  const loading = ref(false)

  // 弹窗相关
  const templateSelectDialogVisible = ref(false)
  const projectDialogVisible = ref(false)
  const editData = ref<any>(null)
  const selectedTemplateData = ref<any>(null)

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
      props: { clearable: true, placeholder: '请输入项目名称' }
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
  const tableData = ref<ProjectItem[]>([])

  /**
   * 加载状态列表
   */
  const loadStatusList = async (): Promise<void> => {
    try {
      const res = await listPropertyApi({
        'q[sign_eq]': 'project_status'
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
    getProjectList()
  })

  /**
   * 获取项目列表
   */
  const getProjectList = async (): Promise<void> => {
    loading.value = true
    try {
      const res = await listPmProjectApi({ ...appliedFilters })
      tableData.value = (res as any).data || []
    } catch (error) {
      console.error('获取项目列表失败:', error)
      tableData.value = []
      ElMessage.error('获取项目列表失败')
    } finally {
      loading.value = false
    }
  }

  /**
   * 获取图片 URL
   */
  const getImageUrl = (logo: string | undefined): string => {
    if (!logo) return ''
    // 如果已经是完整 URL，直接返回
    if (logo.startsWith('http://') || logo.startsWith('https://')) {
      return logo
    }
    // 如果是相对路径，直接返回（由代理处理）
    return logo.startsWith('/') ? logo : `/${logo}`
  }

  /**
   * 截断描述文本，最多显示一行
   */
  const getTruncatedDescription = (description: string | undefined): string | undefined => {
    if (!description) return undefined
    // 如果描述超过一定长度，截断并添加省略号
    // 根据卡片宽度，大约可以显示 30-40 个字符
    const maxLength = 40
    if (description.length > maxLength) {
      return description.substring(0, maxLength) + '...'
    }
    return description
  }

  /**
   * 星标项目
   */
  const starredProjects = computed(() => tableData.value.filter((item) => item.is_star))

  /**
   * 切换星标状态
   */
  const toggleStar = async (row: ProjectItem, event: Event): Promise<void> => {
    event.stopPropagation() // 阻止事件冒泡

    if (!row.id) {
      ElMessage.warning('项目ID不存在')
      return
    }

    const newStarStatus = !row.is_star

    try {
      // 乐观更新：先更新UI
      row.is_star = newStarStatus

      // 调用API更新
      await updatePmProjectApi(String(row.id), {
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
      formatter: (row: ProjectItem) => {
        return h('div', { class: 'flex items-center gap-2' }, [
          h(
            'span',
            {
              class: 'cursor-pointer hover:text-primary-500 transition-colors',
              onClick: () => handleProjectClick(row)
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
      prop: 'portfolio_name',
      label: '项目集',
      minWidth: 120,
      formatter: (row: ProjectItem) => row.portfolio_name || '未分组'
    },
    {
      prop: 'status_id',
      label: '状态',
      minWidth: 120,
      formatter: (row: ProjectItem) => {
        const statusText = row.status
          ? row.status
          : row.status_id !== undefined && row.status_id !== null
            ? statusMap.value[row.status_id as number] || '待设置'
            : '待设置'

        return h('span', { class: 'text-g-600' }, statusText)
      }
    },
    {
      prop: 'manager_name',
      label: '项目负责人',
      minWidth: 150,
      formatter: (row: ProjectItem) => row.manager_name || '待设置'
    },
    {
      prop: 'start_date',
      label: '开始时间',
      minWidth: 160,
      formatter: (row: ProjectItem) => {
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
      formatter: (row: ProjectItem) => {
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
    getProjectList()
  }

  const handleSearch = (): void => {
    Object.assign(appliedFilters, { ...formFilters })
    getProjectList()
  }

  const handleRefresh = (): void => {
    getProjectList()
  }

  /**
   * 新建项目
   */
  const handleCreate = (): void => {
    editData.value = null
    selectedTemplateData.value = null
    templateSelectDialogVisible.value = true
  }

  /**
   * 处理模板选择
   */
  const handleTemplateSelect = (template: any): void => {
    selectedTemplateData.value = template
    projectDialogVisible.value = true
  }

  /**
   * 跳过模板选择
   */
  const handleSkipTemplate = (): void => {
    selectedTemplateData.value = null
    projectDialogVisible.value = true
  }

  /**
   * 提交项目表单
   */
  const handleSubmit = async (formData: any): Promise<void> => {
    try {
      if (formData.id) {
        // 编辑
        await updatePmProjectApi(String(formData.id), formData)
        ElMessage.success('更新成功')
      } else {
        // 新建
        await createPmProjectApi(formData)
        ElMessage.success('创建成功')
      }
      projectDialogVisible.value = false
      getProjectList()
    } catch (error) {
      console.error('提交项目失败:', error)
      ElMessage.error('操作失败')
    }
  }

  /**
   * 处理下拉菜单命令
   */
  const handleCommand = (command: string, item: ProjectItem): void => {
    if (command === 'star') {
      toggleStar(item, new Event('click'))
    } else if (command === 'edit') {
      handleEdit(item)
    } else if (command === 'delete') {
      handleDelete(item)
    }
  }

  /**
   * 编辑项目
   */
  const handleEdit = (item: ProjectItem): void => {
    editData.value = item
    projectDialogVisible.value = true
  }

  /**
   * 删除项目
   */
  const handleDelete = (item: ProjectItem): void => {
    if (!item.id) {
      ElMessage.warning('项目ID不存在')
      return
    }

    ElMessageBox.confirm(
      `确定要删除项目"${item.name || '未命名'}"吗？此操作不可恢复！`,
      '删除确认',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      }
    )
      .then(async () => {
        try {
          await deletePmProjectApi(item.id as number)
          ElMessage.success('删除成功')
          await getProjectList()
        } catch (error) {
          console.error('删除项目失败:', error)
          ElMessage.error('删除失败')
        }
      })
      .catch(() => {
        ElMessage.info('已取消删除')
      })
  }

  /**
   * 点击项目跳转到详情页
   */
  const handleProjectClick = (item: ProjectItem): void => {
    if (item.id) {
      router.push({
        name: 'ProjectDetail',
        params: { id: item.id }
      })
    }
  }
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';

  .project-page {
    @apply p-4;

    display: flex;
    flex-direction: column;
  }

  .project-card-wrapper {
    position: relative;
  }

  /* 调整星标项目卡片高度 */
  .project-card-wrapper :deep(.art-card) [class*='aspect-'] {
    aspect-ratio: 16 / 7;
  }

  .project-card-wrapper:hover .project-actions {
    opacity: 1;
  }

  /* 表格卡片高度 */
  .art-table-card {
    display: flex;
    flex: 1;
    flex-direction: column;
    min-height: 400px;
  }

  .art-table-card :deep(.el-card__body) {
    display: flex;
    flex: 1;
    flex-direction: column;
    overflow: hidden;
  }

  .art-table-card :deep(.art-table) {
    flex: 1;
    overflow: auto;
  }
</style>
