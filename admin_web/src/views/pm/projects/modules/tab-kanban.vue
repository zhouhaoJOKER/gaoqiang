<!-- 任务看板 -->
<template>
  <div class="kanban-container">
    <!-- 工具栏 -->
    <div class="kanban-toolbar">
      <div class="toolbar-left">
        <ElButton text class="toolbar-btn">
          <ArtSvgIcon icon="ri:layout-grid-line" class="mr-1" />
          看板
        </ElButton>
        <ElButton text class="toolbar-btn">
          <ArtSvgIcon icon="ri:settings-3-line" class="mr-1" />
          自定义分列
        </ElButton>
        <ElButton text class="toolbar-btn">
          <ArtSvgIcon icon="ri:node-tree" class="mr-1" />
          仅父任务
        </ElButton>
        <ElDropdown @command="handleSortChange">
          <ElButton text class="toolbar-btn">
            <span>按创建时间</span>
            <ArtSvgIcon icon="ri:arrow-down-s-line" class="ml-1" />
          </ElButton>
          <template #dropdown>
            <ElDropdownMenu>
              <ElDropdownItem command="created_at">按创建时间</ElDropdownItem>
              <ElDropdownItem command="updated_at">按更新时间</ElDropdownItem>
              <ElDropdownItem command="priority">按优先级</ElDropdownItem>
            </ElDropdownMenu>
          </template>
        </ElDropdown>
        <ElButton text class="toolbar-btn">
          <ArtSvgIcon icon="ri:filter-3-line" class="mr-1" />
          筛选
          <span class="ml-1">...</span>
        </ElButton>
      </div>
      <div class="toolbar-right">
        <ElInput
          v-model="searchKeyword"
          placeholder="搜索标题和 ID"
          clearable
          class="search-input"
          @input="handleSearch"
        >
          <template #prefix>
            <ArtSvgIcon icon="ri:search-line" />
          </template>
        </ElInput>
        <ElButton type="primary" @click="handleCreateTask">
          <ArtSvgIcon icon="ri:add-line" class="mr-1" />
          创建任务
        </ElButton>
      </div>
    </div>

    <!-- 看板列 -->
    <div class="kanban-board" ref="kanbanBoardRef" v-loading="loading" @scroll="handleBoardScroll">
      <div v-for="column in columns" :key="column.id" class="kanban-column">
        <!-- 列标题 -->
        <div class="column-header">
          <div class="column-title">
            <span class="title-text">{{ column.name }}</span>
            <span class="task-count">({{ getColumnTasks(column.id).length }})</span>
          </div>
          <ElDropdown @command="(cmd) => handleColumnAction(cmd, column.id)">
            <ElButton text class="column-menu-btn">
              <ArtSvgIcon icon="ri:more-line" />
            </ElButton>
            <template #dropdown>
              <ElDropdownMenu>
                <ElDropdownItem command="settings">修改别名</ElDropdownItem>
                <ElDropdownItem command="hide">隐藏列</ElDropdownItem>
              </ElDropdownMenu>
            </template>
          </ElDropdown>
        </div>

        <!-- 任务列表 -->
        <VueDraggable
          :model-value="getColumnTasks(column.id)"
          @update:model-value="(newTasks: TaskItem[]) => handleTaskOrderChange(column.id, newTasks)"
          @start="(evt) => handleDragStart(evt, column.id)"
          @end="(evt) => handleDragEnd(evt, column.id)"
          @add="(evt) => handleDragAdd(evt, column.id)"
          :animation="200"
          group="tasks"
          :item-key="(item: TaskItem) => item.id"
          :data-column-id="column.id"
          class="task-list"
        >
          <div
            v-for="task in getColumnTasks(column.id)"
            :key="task.id"
            :data-task-id="task.id"
            :data-column-id="column.id"
            class="task-card"
            :class="{ 'task-completed': isTaskDone(task) }"
            @click="handleTaskClick(task)"
          >
            <!-- 主内容区 -->
            <div class="task-card-body">
              <div class="task-content-set">
                <!-- 复选框和标题 -->
                <div class="task-content-wrapper">
                  <span class="check-box">
                    <ElCheckbox
                      :model-value="isTaskDone(task)"
                      @change="(val) => handleTaskComplete(task, val)"
                      @click.stop
                      class="task-checkbox"
                    />
                  </span>
                  <span class="task-content-text">{{ task.name || task.title }}</span>
                </div>

                <!-- 任务信息行 -->
                <div class="task-infos">
                  <!-- 类型标签 -->
                  <span v-if="task.category_name || task.type_name" class="icon-wrapper scenario">
                    <ArtSvgIcon icon="ri:check-line" class="scenario-icon" />
                    <span class="scenario-icon-name">{{
                      task.category_name || task.type_name
                    }}</span>
                  </span>

                  <!-- 实际工时 -->
                  <div
                    v-if="task.real_time || task.actual_hours"
                    class="card-crumb-customfield-like-row"
                  >
                    <ArtSvgIcon icon="ri:timer-line" class="custom-field-icon" />
                    <span class="card-crumb-custom-field-right"
                      >实际工时: {{ task.real_time || task.actual_hours }} 小时</span
                    >
                  </div>

                  <!-- 子任务数量 -->
                  <div
                    v-if="task.subtask_count || task.children_count"
                    class="card-crumb-customfield-like-row"
                  >
                    <ArtSvgIcon icon="ri:list-check-2" class="custom-field-icon" />
                    <span class="card-crumb-custom-field-right"
                      >{{ task.completed_subtasks || task.children_done_count || 0 }}/{{
                        task.subtask_count || task.children_count
                      }}</span
                    >
                  </div>

                  <!-- 状态标签 -->
                  <div v-if="task.status_name" class="card-crumb-customfield-like-row tag-row">
                    <ArtSvgIcon icon="ri:price-tag-3-line" class="tag-icon-small" />
                    <span class="tag tag-color-green">{{ task.status_name }}</span>
                  </div>
                </div>

                <!-- 优先级 -->
                <div v-if="task.priority_name" class="task-priority-row">
                  <div class="task-priority">
                    <ArtSvgIcon icon="ri:flag-line" class="priority-flag-icon" />
                    <span class="priority-text">{{ task.priority_name }}</span>
                  </div>
                </div>
              </div>
            </div>

            <!-- 执行人头像/更多操作 -->
            <div class="task-card-more" @click.stop>
              <ElDropdown @command="(cmd) => handleTaskAction(cmd, task)" trigger="click">
                <div class="executor-avatar-wrapper">
                  <!-- 默认显示头像 -->
                  <div class="executor-avatar-default">
                    <div
                      v-if="task.executor_avatar"
                      class="executor-avatar"
                      :style="{ backgroundImage: `url(${task.executor_avatar})` }"
                    ></div>
                    <div v-else class="executor-avatar executor-avatar-placeholder">
                      {{ getInitials(task.executor_name) }}
                    </div>
                  </div>
                  <!-- 悬停时显示 ... -->
                  <div class="executor-more-text">...</div>
                </div>
                <template #dropdown>
                  <ElDropdownMenu>
                    <ElDropdownItem command="edit">编辑</ElDropdownItem>
                    <ElDropdownItem command="delete">删除</ElDropdownItem>
                  </ElDropdownMenu>
                </template>
              </ElDropdown>
            </div>
          </div>
        </VueDraggable>

        <!-- 添加任务按钮（固定在底部） -->
        <div class="add-task-btn" @click="handleAddTask(column.id)">
          <ArtSvgIcon icon="ri:add-line" />
        </div>
      </div>

      <!-- 新建任务列表按钮 -->
      <div class="new-column-btn-container" ref="newColumnBtnRef">
        <ElButton text class="new-column-btn" @click="handleOpenNewColumnDialog">
          <ArtSvgIcon icon="ri:add-line" class="mr-1" />
          新建任务列表
        </ElButton>

        <!-- 隐藏的列 -->
        <div v-if="archivedColumns.length > 0" class="archived-columns">
          <div
            v-for="archivedColumn in archivedColumns"
            :key="archivedColumn.id"
            class="archived-column-item"
          >
            <span class="archived-column-name">{{ archivedColumn.name }}</span>
            <ElButton text size="small" @click="handleShowColumn(archivedColumn.id)">
              <ArtSvgIcon icon="ri:eye-line" />
              显示
            </ElButton>
          </div>
        </div>
      </div>
    </div>

    <!-- 底部滚动条 -->
    <div class="kanban-scrollbar-container">
      <div
        class="kanban-scrollbar-track"
        ref="scrollbarTrackRef"
        @mousedown="handleScrollbarMouseDown"
      >
        <div
          class="kanban-scrollbar-thumb"
          :style="{ left: scrollbarThumbLeft + 'px', width: scrollbarThumbWidth + 'px' }"
          ref="scrollbarThumbRef"
        ></div>
      </div>
    </div>

    <!-- 新建任务列表对话框 -->
    <ElDialog
      v-model="newColumnDialogVisible"
      title="新建任务列表"
      width="400px"
      :close-on-click-modal="false"
      :align-center="false"
      class="new-column-dialog"
      :style="dialogStyle"
    >
      <div class="new-column-form">
        <ElInput
          v-model="newColumnName"
          placeholder="列表名称"
          clearable
          autofocus
          @keyup.enter="handleCreateColumn"
        />
      </div>
      <template #footer>
        <div class="dialog-footer">
          <ElButton @click="handleCloseNewColumnDialog">取消</ElButton>
          <ElButton type="primary" :disabled="!newColumnName.trim()" @click="handleCreateColumn">
            创建
          </ElButton>
        </div>
      </template>
    </ElDialog>

    <!-- 修改列名对话框 -->
    <ElDialog
      v-model="renameDialogVisible"
      title="修改列名"
      width="400px"
      :close-on-click-modal="false"
    >
      <div class="new-column-form">
        <ElInput
          v-model="renameColumnName"
          placeholder="列表名称"
          clearable
          autofocus
          @keyup.enter="handleRenameColumn"
        />
      </div>
      <template #footer>
        <div class="dialog-footer">
          <ElButton @click="renameDialogVisible = false">取消</ElButton>
          <ElButton type="primary" :disabled="!renameColumnName.trim()" @click="handleRenameColumn">
            确定
          </ElButton>
        </div>
      </template>
    </ElDialog>

    <!-- 任务创建对话框 -->
    <TaskDialog
      v-model="taskDialogVisible"
      :project-id="taskDialogProjectId"
      :stage-id="currentStageId"
      @created="handleTaskCreated"
    />
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onMounted, nextTick, onUnmounted } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import {
    ElButton,
    ElInput,
    ElCheckbox,
    ElDropdown,
    ElDropdownMenu,
    ElDropdownItem,
    ElDialog,
    ElMessage,
    ElMessageBox
  } from 'element-plus'
  import { listPmTaskApi, updatePmTaskApi, deletePmTaskApi } from '@/api/pm/task'
  import { listPropertyApi } from '@/api/property'
  import { createPmStageApi, listPmStageApi, updatePmStageApi } from '@/api/pm/project'
  import TaskDialog from './task-dialog.vue'
  import { VueDraggable } from 'vue-draggable-plus'

  const route = useRoute()
  const router = useRouter()

  interface TaskItem {
    id?: string | number
    title?: string
    name?: string
    stage_id?: string | number
    status_id?: string | number
    status_name?: string
    category_id?: string | number
    category_name?: string
    type?: string
    type_name?: string
    priority_id?: string | number
    priority_name?: string
    is_completed?: boolean
    is_done?: boolean
    done_at?: string
    is_parent?: boolean
    parent_id?: string | number
    parent_name?: string
    planned_hours?: number
    actual_hours?: number
    real_time?: number
    subtask_count?: number
    completed_subtasks?: number
    children_count?: number
    children_done_count?: number
    assignee_id?: string | number
    assignee_name?: string
    assignee_avatar?: string
    executor_id?: string | number
    executor_name?: string
    executor_avatar?: string
    project_id?: string | number
    project_name?: string
    due_at?: string
    sort?: number
    start_at?: string
    code?: string
    [key: string]: any
  }

  // 判断任务是否已完成（兼容 is_done 和 is_completed）
  const isTaskDone = (task: TaskItem): boolean => {
    return task.is_done === true || task.is_completed === true
  }

  interface ColumnItem {
    id: string | number
    name: string
    status_id?: string | number
    order?: number
    is_archived?: boolean
  }

  // 项目ID
  const projectId = computed(() => {
    const id = route.params.id
    return Array.isArray(id) ? id[0] : id
  })

  // 任务对话框用的项目ID（类型转换）
  const taskDialogProjectId = computed<string | number>(() => {
    return projectId.value as string | number
  })

  // 加载状态
  const loading = ref(false)

  // 搜索关键词
  const searchKeyword = ref('')

  // 排序方式
  const sortBy = ref('created_at')

  // 任务列表
  const taskList = ref<TaskItem[]>([])

  // 默认列配置
  const defaultColumns = ref<ColumnItem[]>([
    { id: 'planned', name: '计划任务', status_id: undefined },
    { id: 'in_progress', name: '进行中', status_id: undefined },
    { id: 'testing', name: '开发完成待测试', status_id: undefined },
    { id: 'completed', name: '已完成', status_id: undefined }
  ])

  // 看板列（可以从配置或API获取）
  const columns = ref<ColumnItem[]>([])

  // 状态列表
  const statusList = ref<Array<{ id: number | string; name: string; color?: string }>>([])

  // 新建任务列表对话框
  const newColumnDialogVisible = ref(false)
  const newColumnName = ref('')
  const newColumnBtnRef = ref<HTMLElement | null>(null)
  const dialogStyle = ref<Record<string, string>>({})

  // 滚动条相关
  const kanbanBoardRef = ref<HTMLElement | null>(null)
  const scrollbarTrackRef = ref<HTMLElement | null>(null)
  const scrollbarThumbRef = ref<HTMLElement | null>(null)
  const scrollbarThumbLeft = ref(0)
  const scrollbarThumbWidth = ref(0)
  const isDragging = ref(false)
  const dragStartX = ref(0)
  const dragStartLeft = ref(0)

  // 获取列中的任务（已完成的排在最后）
  const getColumnTasks = (columnId: string | number): TaskItem[] => {
    const tasks = taskList.value.filter((task) => {
      // 根据列的 stage_id 匹配任务的 stage_id
      // 列的 id 就是 stage_id（从 API 获取的列数据）
      return task.stage_id === columnId
    })
    // 未完成的在前，已完成的在后
    return tasks.sort((a, b) => {
      const aDone = isTaskDone(a)
      const bDone = isTaskDone(b)
      if (aDone && !bDone) return 1
      if (!aDone && bDone) return -1
      return 0
    })
  }

  // 加载任务列表
  const loadTasks = async (): Promise<void> => {
    loading.value = true
    try {
      const res = await listPmTaskApi({
        'q[project_id_eq]': projectId.value,
        sort_by: sortBy.value
      })
      const data = (res as any).data || {}
      taskList.value = Array.isArray(data) ? data : data.list || data.data || data.records || []
    } catch (error) {
      console.error('加载任务列表失败:', error)
      taskList.value = []
    } finally {
      loading.value = false
      // 任务加载完成后更新滚动条
      await nextTick()
      updateScrollbar()
    }
  }

  // 加载状态列表
  const loadStatusList = async (): Promise<void> => {
    try {
      const res = await listPropertyApi({
        'q[sign_eq]': 'task_status'
      })
      const data = (res as any).data || []
      statusList.value = Array.isArray(data) ? data : []
    } catch (error) {
      console.error('加载状态列表失败:', error)
      statusList.value = []
    }
  }

  // 隐藏的列
  const archivedColumns = ref<ColumnItem[]>([])

  // 加载列配置（从API获取）
  const loadColumns = async (): Promise<void> => {
    try {
      const res = await listPmStageApi({
        project_id: projectId.value
      })
      const data = (res as any).data || []
      const stageList = Array.isArray(data) ? data : data.list || data.data || data.records || []

      if (stageList.length > 0) {
        const allColumns = stageList.map((stage: any) => ({
          id: stage.id,
          name: stage.name || stage.title,
          status_id: stage.status_id,
          order: stage.order || stage.sort || 0,
          is_archived: stage.is_archived || false
        }))
        // 分离显示列和隐藏列
        columns.value = allColumns.filter((col: ColumnItem) => !col.is_archived)
        archivedColumns.value = allColumns.filter((col: ColumnItem) => col.is_archived)
      } else {
        columns.value = [...defaultColumns.value]
        archivedColumns.value = []
      }
    } catch (error) {
      console.error('加载任务列失败:', error)
      columns.value = [...defaultColumns.value]
      archivedColumns.value = []
    }
  }

  // 搜索任务
  const handleSearch = (): void => {
    loadTasks()
  }

  // 排序改变
  const handleSortChange = (command: string): void => {
    sortBy.value = command
    loadTasks()
  }

  // 修改别名对话框
  const renameDialogVisible = ref(false)
  const renameColumnId = ref<string | number | null>(null)
  const renameColumnName = ref('')

  // 列操作
  const handleColumnAction = (command: string, columnId: string | number): void => {
    if (command === 'settings') {
      // 打开修改别名对话框
      const column = columns.value.find((c) => c.id === columnId)
      if (column) {
        renameColumnId.value = columnId
        renameColumnName.value = column.name
        renameDialogVisible.value = true
      }
    } else if (command === 'hide') {
      // 隐藏列
      handleHideColumn(columnId)
    }
  }

  // 隐藏列
  const handleHideColumn = async (columnId: string | number): Promise<void> => {
    try {
      await updatePmStageApi(String(columnId), { is_archived: true })
      ElMessage.success('列已隐藏')
      await loadColumns()
    } catch (error) {
      console.error('隐藏列失败:', error)
      ElMessage.error('隐藏列失败')
    }
  }

  // 显示列
  const handleShowColumn = async (columnId: string | number): Promise<void> => {
    try {
      await updatePmStageApi(String(columnId), { is_archived: false })
      ElMessage.success('列已显示')
      await loadColumns()
    } catch (error) {
      console.error('显示列失败:', error)
      ElMessage.error('显示列失败')
    }
  }

  // 确认修改别名
  const handleRenameColumn = async (): Promise<void> => {
    if (!renameColumnId.value || !renameColumnName.value.trim()) {
      ElMessage.warning('请输入列名')
      return
    }
    try {
      await updatePmStageApi(String(renameColumnId.value), { name: renameColumnName.value.trim() })
      ElMessage.success('修改成功')
      renameDialogVisible.value = false
      await loadColumns()
    } catch (error) {
      console.error('修改列名失败:', error)
      ElMessage.error('修改列名失败')
    }
  }

  // 任务点击
  const handleTaskClick = (task: TaskItem): void => {
    if (task.id) {
      // 跳转到任务详情页
      router.push(`/pm/tasks/${task.id}`)
    }
  }

  // 保存拖拽前的任务状态，用于检测跨列拖拽
  const dragStartState = ref<{
    columnId: string | number
    taskMap: Map<string | number, string | number> // taskId -> originalStageId
  } | null>(null)

  // 拖拽开始处理
  const handleDragStart = (evt: any, columnId: string | number): void => {
    // 保存拖拽前该列的所有任务及其原始 stage_id
    const tasks = getColumnTasks(columnId)
    const taskMap = new Map<string | number, string | number>()
    tasks.forEach((task) => {
      if (task.id && task.stage_id) {
        taskMap.set(task.id, task.stage_id)
      }
    })
    dragStartState.value = {
      columnId,
      taskMap
    }
  }

  // 保存目标列 ID（从 @add 事件获取）
  const targetColumnIdRef = ref<string | number | null>(null)

  // 拖拽添加到新列（跨列拖拽时触发）
  const handleDragAdd = (evt: any, targetColumnId: string | number): void => {
    // 这个事件在跨列拖拽时会被触发
    // 保存目标列 ID，供 handleDragEnd 使用
    targetColumnIdRef.value = targetColumnId
    console.log('拖拽添加到列:', targetColumnId, evt)
  }

  // 拖拽结束处理
  const handleDragEnd = async (evt: any, columnId: string | number): Promise<void> => {
    if (!dragStartState.value) {
      return
    }

    const { columnId: sourceColumnId, taskMap } = dragStartState.value

    // 优先使用 @add 事件保存的目标列 ID，如果没有则使用当前列 ID
    const targetColumnId = targetColumnIdRef.value !== null ? targetColumnIdRef.value : columnId
    targetColumnIdRef.value = null // 清除临时保存的值

    const targetTasks = getColumnTasks(targetColumnId)
    const isCrossColumn = String(sourceColumnId) !== String(targetColumnId)

    console.log('拖拽结束:', {
      sourceColumnId,
      targetColumnId,
      isCrossColumn,
      targetTasksCount: targetTasks.length,
      taskMapSize: taskMap.size
    })

    // 找出被移动的任务（原始 stage_id 与目标列不同的任务）
    const movedTaskIds = new Set<string | number>()
    if (isCrossColumn) {
      // 遍历所有目标列的任务，检查哪些是从源列移动过来的
      targetTasks.forEach((task) => {
        if (task.id && taskMap.has(task.id)) {
          const originalStageId = taskMap.get(task.id)
          // 如果任务的原始 stage_id 与目标列不同，说明是跨列拖拽
          if (originalStageId && String(originalStageId) !== String(targetColumnId)) {
            movedTaskIds.add(task.id)
            console.log('检测到跨列任务:', {
              taskId: task.id,
              originalStageId,
              targetColumnId,
              currentStageId: task.stage_id
            })
          }
        } else if (task.id && !taskMap.has(task.id)) {
          // 如果任务不在原始 map 中，可能是从其他列拖拽过来的（不是当前保存的源列）
          // 检查当前 stage_id 是否与目标列不同
          if (task.stage_id && String(task.stage_id) !== String(targetColumnId)) {
            movedTaskIds.add(task.id)
            console.log('检测到跨列任务（不在原始map中）:', {
              taskId: task.id,
              currentStageId: task.stage_id,
              targetColumnId
            })
          }
        }
      })
    }

    // 更新所有受影响任务的 sort 和 stage_id
    const updatePromises: Promise<any>[] = []

    // 更新目标列的任务
    targetTasks.forEach((task, index) => {
      if (!task.id) return

      const newSort = index + 1
      const updateParams: any = { sort: newSort }

      // 如果是跨列拖拽，检查是否需要更新 stage_id
      if (isCrossColumn) {
        // 如果任务在 movedTaskIds 中，或者任务的 stage_id 与目标列不同，都需要更新
        if (
          movedTaskIds.has(task.id) ||
          (task.stage_id && String(task.stage_id) !== String(targetColumnId))
        ) {
          updateParams.stage_id = targetColumnId
          // 确保本地数据也更新
          task.stage_id = targetColumnId
          console.log('准备更新任务 stage_id:', {
            taskId: task.id,
            newStageId: targetColumnId,
            updateParams,
            isInMovedSet: movedTaskIds.has(task.id),
            currentStageId: task.stage_id
          })
        }
      }

      // 如果 sort 改变或 stage_id 需要更新，则调用 API
      if (task.sort !== newSort || updateParams.stage_id) {
        console.log('调用 updatePmTaskApi:', {
          taskId: task.id,
          updateParams,
          hasStageId: !!updateParams.stage_id
        })
        updatePromises.push(
          updatePmTaskApi(String(task.id), updateParams)
            .then(() => {
              task.sort = newSort
              if (updateParams.stage_id) {
                task.stage_id = targetColumnId
                console.log('任务 stage_id 更新成功:', {
                  taskId: task.id,
                  stageId: targetColumnId
                })
              }
            })
            .catch((error) => {
              console.error(`更新任务 ${task.id} 失败:`, error, {
                updateParams
              })
              throw error
            })
        )
      }
    })

    // 如果跨列，更新源列的任务排序
    if (isCrossColumn) {
      const sourceColumnTasks = getColumnTasks(sourceColumnId)
      sourceColumnTasks.forEach((task, index) => {
        if (!task.id) return
        const newSort = index + 1
        if (task.sort !== newSort) {
          updatePromises.push(
            updatePmTaskApi(String(task.id), { sort: newSort })
              .then(() => {
                task.sort = newSort
              })
              .catch((error) => {
                console.error(`更新任务 ${task.id} 排序失败:`, error)
                throw error
              })
          )
        }
      })
    }

    // 清除拖拽状态
    dragStartState.value = null

    if (updatePromises.length > 0) {
      try {
        await Promise.all(updatePromises)
        ElMessage.success('任务顺序已更新')
      } catch (error) {
        console.error('更新任务顺序失败:', error)
        ElMessage.error('更新任务顺序失败')
        await loadTasks()
      }
    } else {
      console.log('没有需要更新的任务')
    }
  }

  // 任务顺序改变（拖拽后）
  const handleTaskOrderChange = async (
    columnId: string | number,
    newTasks: TaskItem[]
  ): Promise<void> => {
    // 更新任务列表：保持其他列的任务不变，更新当前列的任务
    const otherColumnTasks = taskList.value.filter((t) => String(t.stage_id) !== String(columnId))

    // 更新当前列任务的 stage_id（确保一致）
    newTasks.forEach((task) => {
      task.stage_id = columnId
    })

    // 合并：其他列的任务 + 当前列的新顺序任务
    taskList.value = [...otherColumnTasks, ...newTasks]
  }

  // 任务操作
  const handleTaskAction = async (command: string, task: TaskItem): Promise<void> => {
    if (command === 'edit') {
      console.log('编辑任务:', task)
      // TODO: 打开编辑任务弹窗
    } else if (command === 'delete') {
      if (!task.id) {
        ElMessage.warning('任务ID不存在')
        return
      }

      try {
        await ElMessageBox.confirm('确定要删除这个任务吗？', '确认删除', {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        })

        await deletePmTaskApi(Number(task.id))
        ElMessage.success('任务删除成功')
        // 重新加载任务列表
        await loadTasks()
      } catch (error: any) {
        // 用户取消删除
        if (error === 'cancel') {
          return
        }
        console.error('删除任务失败:', error)
        const errorMessage = error?.response?.data?.message || error?.message || '删除任务失败'
        ElMessage.error(errorMessage)
      }
    }
  }

  /**
   * 获取首字母
   */
  const getInitials = (text: string | undefined): string => {
    if (!text) return '?'
    const match = text.match(/[\u4e00-\u9fa5]/)
    if (match) {
      return match[0]
    }
    return text.charAt(0).toUpperCase()
  }

  // 任务完成状态改变
  const handleTaskComplete = async (
    task: TaskItem,
    completed: boolean | string | number
  ): Promise<void> => {
    const isDone = typeof completed === 'boolean' ? completed : Boolean(completed)
    try {
      // 更新任务完成状态
      const params: any = {
        is_done: isDone,
        done_at: isDone ? new Date().toISOString() : null
      }
      await updatePmTaskApi(String(task.id), params)
      // 更新本地状态
      task.is_done = isDone
      task.done_at = isDone ? new Date().toISOString() : undefined
      ElMessage.success(isDone ? '任务已完成' : '任务已取消完成')
    } catch (error) {
      console.error('更新任务状态失败:', error)
      ElMessage.error('更新任务状态失败')
    }
  }

  // 任务创建对话框
  const taskDialogVisible = ref(false)
  const currentStageId = ref<string | number | undefined>(undefined)

  // 创建任务（默认使用第一列的 id）
  const handleCreateTask = (): void => {
    currentStageId.value = columns.value.length > 0 ? columns.value[0].id : undefined
    taskDialogVisible.value = true
  }

  // 添加任务到指定列
  const handleAddTask = (columnId: string | number): void => {
    currentStageId.value = columnId
    taskDialogVisible.value = true
  }

  // 任务创建成功回调
  const handleTaskCreated = (): void => {
    loadTasks()
  }

  // 打开新建任务列表对话框
  const handleOpenNewColumnDialog = async (): Promise<void> => {
    newColumnName.value = ''

    // 计算弹窗位置，让它靠近新建按钮
    await nextTick()
    if (newColumnBtnRef.value) {
      const rect = newColumnBtnRef.value.getBoundingClientRect()
      const dialogWidth = 400 // 弹窗宽度
      const dialogHeight = 240 // 估算的弹窗高度（包含标题、输入框、按钮）
      const offset = 10 // 距离按钮的偏移量

      // 计算位置：在按钮右侧显示
      let left = rect.right + offset
      let top = rect.top

      // 如果右侧空间不足，显示在按钮左侧
      if (left + dialogWidth > window.innerWidth) {
        left = rect.left - dialogWidth - offset
      }

      // 如果下方空间不足，调整垂直位置
      if (top + dialogHeight > window.innerHeight) {
        top = Math.max(20, window.innerHeight - dialogHeight - 20)
      }

      // 确保弹窗不会超出屏幕左侧
      if (left < 20) {
        left = 20
      }

      dialogStyle.value = {
        position: 'fixed',
        left: `${left}px`,
        top: `${top}px`,
        margin: '0',
        transform: 'none'
      }
    }

    newColumnDialogVisible.value = true
  }

  // 关闭新建任务列表对话框
  const handleCloseNewColumnDialog = (): void => {
    newColumnDialogVisible.value = false
    newColumnName.value = ''
  }

  // 创建新任务列表
  const handleCreateColumn = async (): Promise<void> => {
    if (!newColumnName.value.trim()) {
      ElMessage.warning('请输入列表名称')
      return
    }

    // 检查是否已存在同名列表
    const existingColumn = columns.value.find((col) => col.name === newColumnName.value.trim())
    if (existingColumn) {
      ElMessage.warning('列表名称已存在')
      return
    }

    try {
      // 调用API创建任务列
      const res = await createPmStageApi({
        project_id: projectId.value,
        name: newColumnName.value.trim(),
        order: columns.value.length
      })

      // 处理API返回的数据
      const stageData = (res as any).data || {}
      const newColumn: ColumnItem = {
        id: stageData.id,
        name: stageData.name || newColumnName.value.trim(),
        status_id: stageData.status_id,
        order: stageData.order || columns.value.length
      }

      // 添加到列列表
      columns.value.push(newColumn)

      ElMessage.success('任务列表创建成功')
      handleCloseNewColumnDialog()
    } catch (error: any) {
      console.error('创建任务列表失败:', error)
      const errorMessage = error?.response?.data?.message || error?.message || '创建任务列表失败'
      ElMessage.error(errorMessage)
    }
  }

  // 更新滚动条
  const updateScrollbar = (): void => {
    if (!kanbanBoardRef.value || !scrollbarTrackRef.value) return

    const board = kanbanBoardRef.value
    const track = scrollbarTrackRef.value

    const scrollWidth = board.scrollWidth
    const clientWidth = board.clientWidth
    const scrollLeft = board.scrollLeft
    const trackWidth = track.clientWidth

    if (scrollWidth <= clientWidth) {
      // 内容不需要滚动，隐藏滚动条滑块
      scrollbarThumbWidth.value = 0
      scrollbarThumbLeft.value = 0
      return
    }

    // 计算滚动条滑块宽度
    scrollbarThumbWidth.value = (clientWidth / scrollWidth) * trackWidth

    // 确保滚动条滑块有最小宽度
    const minThumbWidth = 20
    if (scrollbarThumbWidth.value < minThumbWidth) {
      scrollbarThumbWidth.value = minThumbWidth
    }

    // 计算滚动条滑块位置
    const maxLeft = trackWidth - scrollbarThumbWidth.value
    scrollbarThumbLeft.value = Math.max(
      0,
      Math.min((scrollLeft / (scrollWidth - clientWidth)) * maxLeft, maxLeft)
    )
  }

  // 处理看板滚动
  const handleBoardScroll = (): void => {
    if (!isDragging.value) {
      updateScrollbar()
    }
  }

  // 处理滚动条鼠标按下
  const handleScrollbarMouseDown = (e: MouseEvent): void => {
    if (!scrollbarTrackRef.value || !kanbanBoardRef.value) return

    const track = scrollbarTrackRef.value
    const trackRect = track.getBoundingClientRect()
    const clickX = e.clientX - trackRect.left

    // 如果点击在滑块上，开始拖拽
    if (
      clickX >= scrollbarThumbLeft.value &&
      clickX <= scrollbarThumbLeft.value + scrollbarThumbWidth.value
    ) {
      isDragging.value = true
      dragStartX.value = e.clientX
      dragStartLeft.value = scrollbarThumbLeft.value
      e.preventDefault()
    } else {
      // 如果点击在轨道上，直接跳转到对应位置
      const trackWidth = track.clientWidth
      const board = kanbanBoardRef.value
      const scrollWidth = board.scrollWidth
      const clientWidth = board.clientWidth

      const targetLeft = Math.max(
        0,
        Math.min(clickX - scrollbarThumbWidth.value / 2, trackWidth - scrollbarThumbWidth.value)
      )
      const scrollRatio = targetLeft / (trackWidth - scrollbarThumbWidth.value)
      board.scrollLeft = scrollRatio * (scrollWidth - clientWidth)
    }
  }

  // 处理鼠标移动
  const handleMouseMove = (e: MouseEvent): void => {
    if (!isDragging.value || !scrollbarTrackRef.value || !kanbanBoardRef.value) return

    const track = scrollbarTrackRef.value
    const board = kanbanBoardRef.value
    const trackWidth = track.clientWidth
    const scrollWidth = board.scrollWidth
    const clientWidth = board.clientWidth

    const deltaX = e.clientX - dragStartX.value
    const newLeft = Math.max(
      0,
      Math.min(dragStartLeft.value + deltaX, trackWidth - scrollbarThumbWidth.value)
    )

    scrollbarThumbLeft.value = newLeft

    // 同步滚动看板内容
    const scrollRatio = newLeft / (trackWidth - scrollbarThumbWidth.value)
    board.scrollLeft = scrollRatio * (scrollWidth - clientWidth)
  }

  // 处理鼠标释放
  const handleMouseUp = (): void => {
    isDragging.value = false
  }

  // 初始化
  onMounted(async () => {
    await Promise.all([loadStatusList(), loadColumns()])
    await loadTasks()

    // 初始化滚动条
    await nextTick()
    updateScrollbar()

    // 监听窗口大小变化
    window.addEventListener('resize', updateScrollbar)
    // 监听鼠标事件
    document.addEventListener('mousemove', handleMouseMove)
    document.addEventListener('mouseup', handleMouseUp)
  })

  onUnmounted(() => {
    window.removeEventListener('resize', updateScrollbar)
    document.removeEventListener('mousemove', handleMouseMove)
    document.removeEventListener('mouseup', handleMouseUp)
  })
</script>

<style scoped lang="scss">
  .kanban-container {
    display: flex;
    flex-direction: column;
    width: 100%;
    max-width: 100%;
    height: 100%;
    min-height: 0;
    overflow: hidden;
    background: #f5f7fa;
  }

  .kanban-toolbar {
    box-sizing: border-box;
    display: flex;
    flex-shrink: 0;
    align-items: center;
    justify-content: space-between;
    height: 56px;
    padding: 12px 16px;
    background: #fff;
    border-bottom: 1px solid var(--el-border-color-light);

    .toolbar-left {
      display: flex;
      gap: 8px;
      align-items: center;
    }

    .toolbar-right {
      display: flex;
      gap: 12px;
      align-items: center;
    }

    .toolbar-btn {
      display: flex;
      align-items: center;
      font-size: 14px;
      color: var(--el-text-color-regular);
    }

    .search-input {
      width: 200px;
    }
  }

  .kanban-board {
    position: relative;
    display: flex;
    flex: 1;
    gap: 16px;
    align-items: stretch;
    width: 100%;
    min-width: 0;
    height: 100%;
    min-height: 0;
    padding: 16px 0 16px 16px;
    overflow: auto hidden;

    /* 隐藏浏览器默认滚动条 */
    scrollbar-width: none; /* Firefox */
    -ms-overflow-style: none; /* IE and Edge */

    &::-webkit-scrollbar {
      display: none; /* Chrome, Safari, Opera */
    }
  }

  .kanban-column {
    position: relative;
    display: flex;
    flex-direction: column;
    flex-shrink: 0 !important;
    width: 300px !important;
    min-width: 300px !important;
    max-width: 300px !important;
    height: calc(100vh - 180px);
    min-height: 0;
    max-height: calc(100vh - 180px);
    overflow: hidden;
    background: #f5f7fa;
    border-radius: 8px;
  }

  .column-header {
    display: flex;
    flex-shrink: 0;
    align-items: center;
    justify-content: space-between;
    padding: 12px 16px;
    background: #fff;
    border-bottom: 1px solid var(--el-border-color-lighter);
    border-radius: 8px 8px 0 0;
  }

  .column-title {
    display: flex;
    gap: 8px;
    align-items: center;
    font-size: 14px;
    font-weight: 500;
    color: var(--el-text-color-primary);

    .title-text {
      flex: 1;
    }

    .task-count {
      font-weight: normal;
      color: var(--el-text-color-regular);
    }
  }

  .column-menu-btn {
    padding: 4px;
  }

  .task-list {
    display: flex;
    flex: 1;
    flex-direction: column;
    gap: 8px;
    min-height: 0;
    padding: 12px;
    overflow: hidden auto;
    background-color: var(--status-color-kanban-bg, var(--CDS_gray_pale, rgb(38 38 38 / 3%)));

    /* 自定义滚动条样式 */
    &::-webkit-scrollbar {
      width: 6px;
    }

    &::-webkit-scrollbar-track {
      background: transparent;
    }

    &::-webkit-scrollbar-thumb {
      background: rgb(0 0 0 / 20%);
      border-radius: 3px;

      &:hover {
        background: rgb(0 0 0 / 30%);
      }
    }
  }

  .task-card {
    position: relative;
    padding: 12px;
    padding-left: 12px;
    margin-bottom: 8px;
    cursor: pointer;
    background: #fff;
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 8px;
    box-shadow: 0 1px 3px rgb(0 0 0 / 5%);
    transition: all 0.2s;

    &:hover {
      box-shadow: 0 2px 8px rgb(0 0 0 / 10%);
      transform: translateY(-1px);

      .task-card-more {
        opacity: 1;

        .executor-avatar-default {
          display: none;
        }

        .executor-more-text {
          display: block;
        }
      }
    }

    // 已完成任务样式
    &.task-completed {
      .task-content-text {
        /* text-decoration: line-through; */
        color: var(--el-text-color-placeholder);
      }

      .task-infos,
      .task-priority-row {
        opacity: 0.6;
      }

      .executor-avatar-placeholder {
        opacity: 0.6;
      }
    }
  }

  .task-card-body {
    position: relative;
  }

  .task-content-set {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .task-content-wrapper {
    display: flex;
    gap: 8px;
    align-items: center;
  }

  .check-box {
    flex-shrink: 0;
  }

  .task-checkbox {
    margin: 0;
  }

  .task-content-text {
    flex: 1;
    font-size: 14px;
    line-height: 1.5;
    color: var(--el-text-color-primary);
    word-break: break-word;
  }

  .task-parent {
    margin-bottom: 8px;
    font-size: 12px;
    line-height: 1.5;
    color: var(--el-text-color-placeholder);
  }

  .task-infos {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
    align-items: center;
    font-size: 12px;
  }

  .icon-wrapper {
    display: inline-flex;
    gap: 4px;
    align-items: center;
    padding: 4px 8px;
    font-size: 12px;
    border-radius: 4px;

    &.scenario {
      color: #1976d2;
      background: #e3f2fd;
    }

    .scenario-icon {
      width: 12px;
      height: 12px;
      font-size: 12px;
    }

    .scenario-icon-name {
      line-height: 1.5;
    }
  }

  .card-crumb-customfield-like-row {
    display: inline-flex;
    gap: 4px;
    align-items: center;
    font-size: 12px;
    color: var(--el-text-color-regular);

    .custom-field-icon {
      width: 14px;
      height: 14px;
      font-size: 14px;
    }

    .card-crumb-custom-field-right {
      line-height: 1.5;
    }

    &.tag-row {
      gap: 4px;
    }

    .tag-icon-small {
      width: 12px;
      height: 12px;
      font-size: 12px;
    }
  }

  .tag {
    display: inline-block;
    padding: 2px 8px;
    font-size: 12px;
    line-height: 1.5;
    border-radius: 12px;

    &.tag-color-green {
      color: #4caf50;
      background: #e8f5e9;
    }

    &.tag-color-red {
      color: #f44336;
      background: #ffebee;
    }
  }

  .task-priority-row {
    margin-top: 4px;
  }

  .task-priority {
    display: inline-flex;
    gap: 4px;
    align-items: center;
    font-size: 12px;
    color: var(--el-text-color-regular);

    .priority-flag-icon {
      width: 14px;
      height: 14px;
      font-size: 14px;
      color: #9ca3af;
    }

    .priority-text {
      line-height: 1.5;
    }
  }

  .task-due-date {
    display: flex;
    gap: 4px;
    align-items: center;
    width: fit-content;
    padding: 4px 10px;
    font-size: 12px;
    color: var(--el-color-danger);
    background: var(--el-color-danger-light-9);
    border-radius: 12px;

    .date-icon {
      font-size: 12px;
    }

    .date-text {
      line-height: 1.5;
    }
  }

  .task-progress {
    display: flex;
    gap: 4px;
    align-items: center;
    font-size: 12px;
    color: var(--el-text-color-regular);

    .progress-icon {
      font-size: 14px;
    }
  }

  .task-attachments {
    display: flex;
    align-items: center;
    color: var(--el-text-color-regular);

    .attachment-icon {
      font-size: 16px;
    }
  }

  .task-links {
    display: flex;
    gap: 4px;
    align-items: center;
    font-size: 12px;
    color: var(--el-color-primary);

    .link-icon {
      font-size: 14px;
    }

    .link-text {
      text-decoration: none;
      cursor: pointer;

      &:hover {
        text-decoration: underline;
      }
    }
  }

  .task-card-more {
    position: absolute;
    top: 8px;
    right: 8px;
    z-index: 10;
    cursor: pointer;

    .executor-avatar-wrapper {
      position: relative;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .executor-avatar-default {
      display: block;
    }

    .executor-more-text {
      display: none;
      font-size: 18px;
      line-height: 1;
      color: var(--el-text-color-regular);
      user-select: none;
    }

    .executor-avatar {
      flex-shrink: 0;
      width: 24px;
      height: 24px;
      background-repeat: no-repeat;
      background-position: center;
      background-size: cover;
      border: 1px solid var(--el-border-color-lighter);
      border-radius: 50%;
    }

    .executor-avatar-placeholder {
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 12px;
      font-weight: 500;
      color: white;
      background-color: var(--el-color-primary);
    }
  }

  .task-badges {
    display: flex;
    gap: 4px;
    align-items: center;
  }

  .task-badge {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 24px;
    height: 24px;
    font-size: 10px;
    font-weight: 500;
    color: white;
    border-radius: 50%;

    &.badge-primary {
      background: var(--el-color-primary);
    }

    &.badge-success {
      background: var(--el-color-success);
    }

    &.badge-warning {
      background: var(--el-color-warning);
    }

    &.badge-danger {
      background: var(--el-color-danger);
    }

    &.badge-info {
      background: var(--el-color-info);
    }
  }

  .add-task-btn {
    display: flex;
    flex-shrink: 0;
    align-items: center;
    justify-content: center;
    width: calc(100%);
    padding: 2px 0;
    font-size: 16px;
    font-weight: normal;
    color: var(--el-text-color-primary);
    cursor: pointer;
    background: #fff;
    border: 1px dashed #d1d5db;
    border-radius: 8px;
    transition: all 0.2s;

    :deep(svg) {
      width: 20px;
      height: 20px;
      color: #000;
      stroke-width: 2.5;
    }

    &:hover {
      background: #d1d5db;
      border-color: #9ca3af;
    }

    &:active {
      background: #9ca3af;
    }
  }

  .new-column-btn-container {
    display: flex;
    flex-direction: column;
    flex-shrink: 0 !important;
    gap: 8px;
    align-items: flex-start;
    width: 300px !important;
    min-width: 300px !important;
    max-width: 300px !important;
  }

  .new-column-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 100%;
    padding: 12px 16px;
    font-size: 14px;
    color: var(--el-text-color-regular);
    transition: all 0.2s;

    &:hover {
      color: var(--el-color-primary);
    }
  }

  .archived-columns {
    display: flex;
    flex-direction: column;
    gap: 4px;
    width: 100%;
    padding: 0 8px;
  }

  .archived-column-item {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 8px 12px;
    background: #fff;
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 6px;

    &:hover {
      background: var(--el-fill-color-light);
    }
  }

  .archived-column-name {
    flex: 1;
    overflow: hidden;
    font-size: 13px;
    color: var(--el-text-color-regular);
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .kanban-scrollbar-container {
    flex-shrink: 0;
    height: 20px;
    padding: 8px 16px;
    background: #f5f7fa;
    border-top: 1px solid var(--el-border-color-lighter);
  }

  .kanban-scrollbar-track {
    position: relative;
    width: 100%;
    height: 4px;
    cursor: pointer;
    background: var(--el-border-color-lighter);
    border-radius: 2px;
  }

  .kanban-scrollbar-thumb {
    position: absolute;
    top: 0;
    height: 4px;
    cursor: grab;
    background: var(--el-text-color-placeholder);
    border-radius: 2px;
    transition: background 0.2s;

    &:hover {
      background: var(--el-text-color-regular);
    }

    &:active {
      cursor: grabbing;
      background: var(--el-color-primary);
    }
  }

  .new-column-form {
    padding: 20px 0;
  }

  .dialog-footer {
    display: flex;
    gap: 12px;
    justify-content: flex-end;
  }

  // 自定义弹窗位置样式
  :deep(.new-column-dialog) {
    &.el-dialog {
      position: fixed !important;
      margin: 0 !important;
      transform: none !important;
    }

    .el-dialog__header {
      padding: 20px 20px 10px;
    }

    .el-dialog__body {
      padding: 20px;
    }

    .el-dialog__footer {
      padding: 10px 20px 20px;
      border-top: none;

      .dialog-footer {
        .el-button {
          min-width: 80px;
        }
      }
    }
  }
</style>
