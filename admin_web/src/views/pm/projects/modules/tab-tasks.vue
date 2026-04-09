<!-- 任务列表页签 -->
<template>
  <div class="tasks-container">
    <!-- 工具栏 -->
    <div class="tasks-toolbar">
      <div class="toolbar-left">
        <ElInput
          v-model="searchKeyword"
          placeholder="搜索任务..."
          prefix-icon="Search"
          clearable
          style="width: 450px"
          @input="handleSearch"
        />
        <ElSelect v-model="filterStatus" placeholder="状态" clearable @change="loadTasks">
          <ElOption
            v-for="status in statusList"
            :key="status.id"
            :label="status.name"
            :value="status.id"
          />
        </ElSelect>
        <ElSelect v-model="filterPriority" placeholder="优先级" clearable @change="loadTasks">
          <ElOption
            v-for="priority in priorityList"
            :key="priority.id"
            :label="priority.name"
            :value="priority.id"
          />
        </ElSelect>
        <ElSelect v-model="filterExecutor" placeholder="执行人" clearable @change="loadTasks">
          <ElOption
            v-for="member in memberList"
            :key="member.id"
            :label="member.name"
            :value="member.id"
          />
        </ElSelect>
      </div>
      <div class="toolbar-right">
        <ElButton type="primary" @click="handleCreateTask">
          <ArtSvgIcon icon="ri:add-line" class="mr-1" />
          新建任务
        </ElButton>
      </div>
    </div>

    <!-- 任务表格 -->
    <div class="tasks-table">
      <ElTable
        :data="taskList"
        style="width: 100%"
        v-loading="loading"
        row-key="id"
        @row-click="handleRowClick"
      >
        <ElTableColumn width="50">
          <template #default="{ row }">
            <ElCheckbox
              :model-value="row.is_done"
              @change="(val: any) => handleToggleComplete(row, Boolean(val))"
              @click.stop
            />
          </template>
        </ElTableColumn>
        <ElTableColumn prop="name" label="任务名称" min-width="300">
          <template #default="{ row }">
            <div class="task-name-cell" :class="{ completed: row.is_done }">
              <span class="task-name">{{ row.name }}</span>
              <ElTag v-if="row.is_done" type="success" size="small" class="ml-2"> 已完成 </ElTag>
            </div>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="category_name" label="类型" width="100">
          <template #default="{ row }">
            <ElTag v-if="row.category_name" size="small" type="info">
              {{ row.category_name }}
            </ElTag>
            <span v-else>-</span>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="status_name" label="状态" width="100">
          <template #default="{ row }">
            <ElTag
              v-if="row.status_name"
              :color="getStatusColor(row.status_color)"
              size="small"
              effect="dark"
            >
              {{ row.status_name }}
            </ElTag>
            <span v-else>-</span>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="priority_name" label="优先级" width="100">
          <template #default="{ row }">
            <span
              v-if="row.priority_name"
              class="priority-tag"
              :style="{ color: getPriorityColor(row.priority_name) }"
            >
              {{ row.priority_name }}
            </span>
            <span v-else>-</span>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="executor_name" label="执行人" width="120">
          <template #default="{ row }">
            <div v-if="row.executor_id" class="executor-cell">
              <div class="executor-avatar">
                {{ getInitials(row.executor_name) }}
              </div>
              <span>{{ row.executor_name }}</span>
            </div>
            <span v-else class="text-placeholder">未分配</span>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="due_at" label="截止日期" width="120">
          <template #default="{ row }">
            <span :class="{ overdue: isOverdue(row.due_at) && !row.is_done }">
              {{ formatDate(row.due_at) }}
            </span>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="plan_time" label="计划工时" width="100" align="right">
          <template #default="{ row }">
            {{ formatHours(row.plan_time) }}
          </template>
        </ElTableColumn>
        <ElTableColumn prop="real_time" label="实际工时" width="100" align="right">
          <template #default="{ row }">
            {{ formatHours(row.real_time) }}
          </template>
        </ElTableColumn>
        <ElTableColumn fixed="right" width="100">
          <template #default="{ row }">
            <ElDropdown @command="(cmd: string) => handleCommand(cmd, row)">
              <ElButton text size="small" @click.stop>
                <ArtSvgIcon icon="ri:more-line" />
              </ElButton>
              <template #dropdown>
                <ElDropdownMenu>
                  <ElDropdownItem command="edit">
                    <ArtSvgIcon icon="ri:edit-line" class="mr-2" />
                    编辑
                  </ElDropdownItem>
                  <ElDropdownItem command="delete" divided>
                    <ArtSvgIcon icon="ri:delete-bin-line" class="mr-2" />
                    删除
                  </ElDropdownItem>
                </ElDropdownMenu>
              </template>
            </ElDropdown>
          </template>
        </ElTableColumn>
      </ElTable>
    </div>

    <!-- 分页 -->
    <div class="pagination-wrapper">
      <ElPagination
        v-model:current-page="pagination.page"
        v-model:page-size="pagination.pageSize"
        :total="pagination.total"
        :page-sizes="[20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="loadTasks"
        @current-change="loadTasks"
      />
    </div>

    <!-- 新建任务弹窗 -->
    <TaskDialog
      v-model="taskDialogVisible"
      :project-id="projectData?.id"
      @success="handleTaskCreated"
    />
  </div>
</template>

<script setup lang="ts">
  import { ref, reactive, onMounted, inject, watch } from 'vue'
  import { useRouter } from 'vue-router'
  import { ElMessage, ElMessageBox } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import TaskDialog from './task-dialog.vue'
  import { listPmTaskApi, updatePmTaskApi, deletePmTaskApi } from '@/api/pm/project'
  import { listPropertyApi } from '@/api/property'

  interface TaskItem {
    id: string | number
    name: string
    is_done?: boolean
    done_at?: string
    category_id?: string | number
    category_name?: string
    status_id?: string | number
    status_name?: string
    status_color?: string
    priority_id?: string | number
    priority_name?: string
    executor_id?: string | number
    executor_name?: string
    due_at?: string
    plan_time?: number
    real_time?: number
    [key: string]: any
  }

  interface PropertyItem {
    id: string | number
    name: string
    color?: string
  }

  interface MemberItem {
    id: string | number
    name: string
  }

  // 注入项目数据
  const projectData = inject<any>('projectData')
  const router = useRouter()

  // 状态
  const loading = ref(false)
  const taskList = ref<TaskItem[]>([])
  const statusList = ref<PropertyItem[]>([])
  const priorityList = ref<PropertyItem[]>([])
  const memberList = ref<MemberItem[]>([])

  // 筛选条件
  const searchKeyword = ref('')
  const filterStatus = ref<string | number | null>(null)
  const filterPriority = ref<string | number | null>(null)
  const filterExecutor = ref<string | number | null>(null)

  // 分页
  const pagination = reactive({
    page: 1,
    pageSize: 20,
    total: 0
  })

  // 新建任务弹窗
  const taskDialogVisible = ref(false)

  // 搜索防抖
  let searchTimer: any = null

  /**
   * 加载任务列表
   */
  const loadTasks = async (): Promise<void> => {
    if (!projectData?.id) return
    loading.value = true
    try {
      const params: any = {
        'q[project_id_eq]': projectData.id,
        page: pagination.page,
        per_page: pagination.pageSize
      }

      if (searchKeyword.value) {
        params['q[name_or_py_cont]'] = searchKeyword.value
      }

      if (filterStatus.value) {
        params['q[status_id_eq]'] = filterStatus.value
      }

      if (filterPriority.value) {
        params['q[priority_id_eq]'] = filterPriority.value
      }

      if (filterExecutor.value) {
        params['q[executor_id_eq]'] = filterExecutor.value
      }

      const res = await listPmTaskApi(params)
      const data = (res as any).data || []
      taskList.value = Array.isArray(data) ? data : []
      pagination.total = (res as any).total || data.length

      // 提取成员列表
      const members = new Map()
      taskList.value.forEach((item) => {
        if (item.executor_id && item.executor_name) {
          members.set(item.executor_id, { id: item.executor_id, name: item.executor_name })
        }
      })
      memberList.value = Array.from(members.values())
    } catch (error) {
      console.error('加载任务失败:', error)
      ElMessage.error('加载任务失败')
    } finally {
      loading.value = false
    }
  }

  /**
   * 加载属性选项
   */
  const loadOptions = async (): Promise<void> => {
    try {
      // 加载状态列表
      const statusRes = await listPropertyApi({ 'q[sign_eq]': 'task_status' })
      statusList.value = (statusRes as any).data || []

      // 加载优先级列表
      const priorityRes = await listPropertyApi({ 'q[sign_eq]': 'task_priority' })
      priorityList.value = (priorityRes as any).data || []
    } catch (error) {
      console.error('加载选项失败:', error)
    }
  }

  /**
   * 搜索任务
   */
  const handleSearch = (): void => {
    if (searchTimer) clearTimeout(searchTimer)
    searchTimer = setTimeout(() => {
      pagination.page = 1
      loadTasks()
    }, 300)
  }

  /**
   * 行点击 - 查看详情
   */
  const handleRowClick = (row: TaskItem): void => {
    router.push({ name: 'TaskDetail', params: { id: row.id } })
  }

  /**
   * 创建任务
   */
  const handleCreateTask = (): void => {
    taskDialogVisible.value = true
  }

  /**
   * 任务创建成功
   */
  const handleTaskCreated = (): void => {
    loadTasks()
  }

  /**
   * 切换完成状态
   */
  const handleToggleComplete = async (row: TaskItem, done: boolean): Promise<void> => {
    try {
      await updatePmTaskApi(String(row.id), {
        is_done: done,
        done_at: done ? new Date().toISOString() : null
      })
      row.is_done = done
      ElMessage.success(done ? '已标记完成' : '已取消完成')
    } catch (error) {
      console.error('更新失败:', error)
      ElMessage.error('更新失败')
    }
  }

  /**
   * 操作命令
   */
  const handleCommand = async (command: string, row: TaskItem): Promise<void> => {
    switch (command) {
      case 'edit':
        router.push({ name: 'TaskDetail', params: { id: row.id } })
        break
      case 'delete':
        try {
          await ElMessageBox.confirm(`确定要删除任务"${row.name}"吗？`, '确认删除', {
            type: 'warning'
          })
          await deletePmTaskApi(Number(row.id))
          ElMessage.success('删除成功')
          await loadTasks()
        } catch (error: any) {
          if (error !== 'cancel') {
            ElMessage.error('删除失败')
          }
        }
        break
    }
  }

  /**
   * 获取状态颜色
   */
  const getStatusColor = (color?: string): string => {
    if (!color) return 'var(--el-color-info)'
    if (color.startsWith('#') || color.startsWith('rgb')) return color
    return `var(--el-color-${color})`
  }

  /**
   * 获取优先级颜色
   */
  const getPriorityColor = (name?: string): string => {
    if (!name) return 'var(--el-text-color-regular)'
    const lower = name.toLowerCase()
    if (lower.includes('高') || lower.includes('urgent') || lower.includes('high')) {
      return 'var(--el-color-danger)'
    }
    if (lower.includes('中') || lower.includes('medium')) {
      return 'var(--el-color-warning)'
    }
    if (lower.includes('低') || lower.includes('low')) {
      return 'var(--el-color-success)'
    }
    return 'var(--el-text-color-regular)'
  }

  /**
   * 格式化工时
   */
  const formatHours = (hours?: number): string => {
    if (hours === undefined || hours === null) return '-'
    return Number(hours).toFixed(1) + 'h'
  }

  /**
   * 格式化日期
   */
  const formatDate = (date?: string): string => {
    if (!date) return '-'
    const d = new Date(date)
    const month = d.getMonth() + 1
    const day = d.getDate()
    return `${month}月${day}日`
  }

  /**
   * 判断是否逾期
   */
  const isOverdue = (date?: string): boolean => {
    if (!date) return false
    return new Date(date) < new Date()
  }

  /**
   * 获取首字母
   */
  const getInitials = (name?: string): string => {
    if (!name) return '?'
    const match = name.match(/[\u4e00-\u9fa5]/)
    if (match) return match[0]
    return name.charAt(0).toUpperCase()
  }

  onMounted(() => {
    loadOptions()
    loadTasks()
  })

  // 监听项目数据变化，确保刷新时能加载数据
  watch(
    () => projectData?.id,
    (newId) => {
      if (newId) {
        loadTasks()
      }
    },
    { immediate: true }
  )
</script>

<style scoped lang="scss">
  @reference '@styles/core/tailwind.css';

  .tasks-container {
    display: flex;
    flex-direction: column;
    height: 100%;
    overflow: hidden;
    background: #fff;
    border-radius: 8px;
  }

  .tasks-toolbar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 16px 20px;
    border-bottom: 1px solid var(--el-border-color-lighter);
  }

  .toolbar-left {
    display: flex;
    gap: 12px;
    align-items: center;
  }

  .toolbar-right {
    display: flex;
    gap: 8px;
    align-items: center;
  }

  .tasks-table {
    flex: 1;
    overflow: auto;
  }

  .task-name-cell {
    display: flex;
    align-items: center;

    &.completed {
      .task-name {
        color: var(--el-text-color-placeholder);
        text-decoration: line-through;
      }
    }
  }

  .task-name {
    color: var(--el-text-color-primary);
  }

  .priority-tag {
    font-weight: 500;
  }

  .executor-cell {
    display: flex;
    gap: 8px;
    align-items: center;
  }

  .executor-avatar {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 24px;
    height: 24px;
    font-size: 11px;
    font-weight: 500;
    color: #fff;
    background: var(--el-color-primary);
    border-radius: 50%;
  }

  .text-placeholder {
    color: var(--el-text-color-placeholder);
  }

  .overdue {
    color: var(--el-color-danger);
  }

  .pagination-wrapper {
    display: flex;
    justify-content: flex-end;
    padding: 16px 20px;
    border-top: 1px solid var(--el-border-color-lighter);
  }

  :deep(.el-table__row) {
    cursor: pointer;

    &:hover {
      background-color: var(--el-fill-color-light);
    }
  }
</style>
