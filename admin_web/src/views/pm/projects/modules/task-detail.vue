<!-- 任务详情页面 -->
<template>
  <div class="task-detail-container">
    <!-- 顶部栏 -->
    <div class="task-header-bar">
      <div class="header-left">
        <ElButton text class="back-btn" @click="handleGoBack">
          <ArtSvgIcon icon="ri:arrow-left-line" />
        </ElButton>
        <span class="header-title">
          <ElPopover
            v-model:visible="categoryPopoverVisible"
            placement="bottom-start"
            :width="200"
            trigger="click"
          >
            <template #reference>
              <div class="header-category" v-if="taskData.category_name">
                <ArtSvgIcon :icon="getCategoryIcon(taskData.category_name)" class="category-icon" />
                <span>{{ taskData.category_name }}</span>
              </div>
              <div v-else class="header-category-placeholder">
                <ArtSvgIcon icon="ri:apps-line" class="category-icon" />
                <span>选择类型</span>
              </div>
            </template>
            <div class="category-popover">
              <div
                v-for="category in categoryList"
                :key="category.id"
                class="category-option"
                @click="handleSelectCategory(category)"
              >
                <ArtSvgIcon
                  v-if="taskData.category_id === category.id"
                  icon="ri:check-line"
                  class="check-icon"
                />
                <span v-else class="check-placeholder"></span>
                <ArtSvgIcon :icon="getCategoryIcon(category.name)" class="category-icon" />
                <span>{{ category.name }}</span>
              </div>
              <div class="category-config-btn" @click="handleOpenCategoryConfig">
                <ArtSvgIcon icon="ri:settings-3-line" class="config-icon" />
                配置类型
              </div>
            </div>
          </ElPopover>
        </span>

        <!-- 面包屑导航（子任务时显示） -->
        <div v-if="taskData.parent_name" class="task-breadcrumb-bar">
          <div class="breadcrumb-path">
            <span class="parent-name">{{ taskData.parent_name }}</span>
            <ArtSvgIcon icon="ri:arrow-right-s-line" class="breadcrumb-separator" />
            <span class="current-name">{{ taskData.name }}</span>
          </div>
        </div>
      </div>
      <div class="header-right">
        <ElButton text class="header-action-btn">
          <ArtSvgIcon icon="ri:share-line" />
        </ElButton>
        <ElButton text class="header-action-btn">
          <ArtSvgIcon icon="ri:links-line" />
        </ElButton>
        <ElButton text class="header-action-btn">
          <ArtSvgIcon icon="ri:thumb-up-line" />
        </ElButton>
        <ElDropdown @command="handleHeaderAction">
          <ElButton text class="header-action-btn">
            <ArtSvgIcon icon="ri:more-line" />
          </ElButton>
          <template #dropdown>
            <ElDropdownMenu>
              <ElDropdownItem command="edit">编辑</ElDropdownItem>
              <ElDropdownItem command="delete">删除</ElDropdownItem>
            </ElDropdownMenu>
          </template>
        </ElDropdown>
      </div>
    </div>

    <!-- 主要内容区域 -->
    <div class="task-content-wrapper">
      <!-- 左侧面板 - 任务详情 -->
      <div class="task-detail-panel">
        <!-- 任务标题 -->
        <div class="task-title-section">
          <ElInput
            v-model="taskData.name"
            type="textarea"
            :rows="2"
            placeholder="任务标题"
            class="task-title-input"
            @blur="handleTitleUpdate"
          />
        </div>

        <!-- 状态 -->
        <div class="detail-section">
          <div class="section-label">
            <ArtSvgIcon icon="ri:checkbox-circle-line" class="section-icon" />
            状态
          </div>
          <div class="section-content">
            <ElCheckbox v-model="taskData.is_completed" @change="handleStatusChange">
              {{ taskData.is_completed ? '已完成' : '未完成' }}
            </ElCheckbox>
          </div>
        </div>

        <!-- 执行者 -->
        <div class="detail-section">
          <div class="section-label">
            <ArtSvgIcon icon="ri:user-3-line" class="section-icon" />
            执行者
          </div>
          <div class="section-content">
            <div class="clickable-field" @click="handleSelectExecutor">
              <span v-if="taskData.executor_name">{{ taskData.executor_name }}</span>
              <span v-else class="placeholder-text">待认领</span>
            </div>
          </div>
        </div>

        <!-- 时间 -->
        <div class="detail-section">
          <div class="section-label">
            <ArtSvgIcon icon="ri:time-line" class="section-icon" />
            时间
          </div>
          <div class="section-content time-content">
            <ElDatePicker
              v-model="taskData.start_at"
              type="datetime"
              placeholder="设置开始时间"
              format="YYYY-MM-DD HH:mm"
              value-format="YYYY-MM-DD HH:mm:ss"
              class="time-picker"
              @change="handleTimeUpdate"
            />
            -
            <ElDatePicker
              v-model="taskData.due_at"
              type="datetime"
              placeholder="设置截止时间"
              format="YYYY-MM-DD HH:mm"
              value-format="YYYY-MM-DD HH:mm:ss"
              class="time-picker"
              @change="handleTimeUpdate"
            />
          </div>
        </div>

        <!-- 项目 -->
        <div class="detail-section">
          <div class="section-label">
            <ArtSvgIcon icon="ri:building-line" class="section-icon" />
            项目
          </div>
          <div class="section-content">
            <div class="clickable-field">
              <ArtSvgIcon icon="ri:building-line" class="field-icon" />
              <span>{{ taskData.project_name || '待添加' }}</span> /
              <span>{{ taskData.stage_name || '待添加' }}</span>
            </div>
          </div>
        </div>

        <!-- 备注 -->
        <div class="detail-section">
          <div class="section-label">
            <ArtSvgIcon icon="ri:file-text-line" class="section-icon" />
            备注
          </div>
          <div class="section-content">
            <div
              v-if="!descriptionEditorVisible"
              class="clickable-field"
              @click="handleOpenDescriptionEditor"
            >
              <span
                v-if="taskData.description"
                class="description-preview"
                v-html="getDescriptionPreview()"
              ></span>
              <span v-else class="placeholder-text">待添加</span>
            </div>
            <div v-else class="description-editor-wrapper">
              <ArtWangEditor
                v-model="descriptionEditorContent"
                :height="'180px'"
                :min-height="'150px'"
                :placeholder="'请输入备注内容...'"
                class="description-editor"
              />
              <div class="description-actions">
                <ElButton text @click="handleCancelDescriptionEdit">取消</ElButton>
                <ElButton type="primary" @click="handleSaveDescription">保存</ElButton>
              </div>
            </div>
          </div>
        </div>

        <!-- 优先级 -->
        <div class="detail-section">
          <div class="section-label">
            <ArtSvgIcon icon="ri:flag-line" class="section-icon" />
            优先级
          </div>
          <div class="section-content">
            <ElPopover
              v-model:visible="priorityPopoverVisible"
              placement="bottom-start"
              :width="200"
              trigger="click"
            >
              <template #reference>
                <div class="clickable-field priority-tag-wrapper">
                  <span
                    v-if="taskData.priority_name"
                    class="priority-tag"
                    :style="
                      getPriorityStyle({
                        name: taskData.priority_name,
                        color: taskData.priority_color
                      })
                    "
                  >
                    {{ taskData.priority_name }}
                  </span>
                  <span v-else class="placeholder-text">较低</span>
                </div>
              </template>
              <div class="priority-popover">
                <div
                  v-for="priority in priorityList"
                  :key="priority.id"
                  class="priority-option"
                  @click="handleSelectPriority(priority)"
                >
                  <ArtSvgIcon
                    v-if="taskData.priority_id === priority.id"
                    icon="ri:check-line"
                    class="check-icon"
                  />
                  <span v-else class="check-placeholder"></span>
                  <span class="priority-tag" :style="getPriorityStyle(priority)">
                    {{ priority.name }}
                  </span>
                </div>
                <div class="priority-config-btn" @click="handleOpenPriorityConfig">
                  <ArtSvgIcon icon="ri:settings-3-line" class="config-icon" />
                  配置优先级
                </div>
              </div>
            </ElPopover>
          </div>
        </div>

        <!-- 标签 -->
        <div class="detail-section">
          <div class="section-label">
            <ArtSvgIcon icon="ri:price-tag-3-line" class="section-icon" />
            标签
          </div>
          <div class="section-content">
            <ElPopover
              v-model:visible="tagPopoverVisible"
              placement="bottom-start"
              :width="240"
              trigger="click"
            >
              <template #reference>
                <div class="clickable-field tags-wrapper">
                  <span v-if="taskLabels.length > 0" class="tags-display">
                    <span
                      v-for="tag in taskLabels"
                      :key="tag.id"
                      class="tag-item"
                      :style="getTagStyle(tag)"
                    >
                      {{ tag.name }}
                    </span>
                  </span>
                  <span v-else class="placeholder-text">添加标签</span>
                </div>
              </template>
              <div class="tag-popover">
                <div
                  v-for="tag in tagList"
                  :key="tag.id"
                  class="tag-option"
                  @click="handleToggleTag(tag)"
                >
                  <ElCheckbox
                    :model-value="isTagSelected(tag.id)"
                    @click.stop
                    @change="handleToggleTag(tag)"
                  />
                  <span class="tag-item" :style="getTagStyle(tag)">
                    {{ tag.name }}
                  </span>
                </div>
                <div class="tag-config-btn" @click="handleOpenTagConfig">
                  <ArtSvgIcon icon="ri:settings-3-line" class="config-icon" />
                  配置标签
                </div>
              </div>
            </ElPopover>
          </div>
        </div>

        <!-- 添加字段 -->
        <div class="detail-section">
          <div class="section-content">
            <div class="add-field-btn" @click="handleAddField">
              <ArtSvgIcon icon="ri:add-line" class="add-icon" />
              <span>添加字段</span>
            </div>
          </div>
        </div>

        <!-- 工时 -->
        <div class="work-hours-card">
          <div class="work-hours-header">
            <span class="work-hours-title">工时</span>
          </div>

          <!-- 计划工时行 -->
          <div class="work-hours-row">
            <div class="work-hours-left">
              <ArtSvgIcon icon="ri:timer-line" class="hours-icon" />
              <span class="hours-label">计划工时</span>
            </div>
            <div class="work-hours-center clickable" @click="handleShowPlanHoursHistory">
              <span v-if="taskData.plan_time" class="hours-value">
                {{ formatHours(taskData.plan_time) }} 小时
              </span>
              <span v-else class="hours-empty">--</span>
            </div>
            <div class="work-hours-right">
              <ElButton text @click="handleAddPlanHours">
                <ArtSvgIcon icon="ri:add-line" class="mr-1" />
                计划工时
              </ElButton>
            </div>
          </div>

          <!-- 实际工时行 -->
          <div class="work-hours-row">
            <div class="work-hours-left">
              <ArtSvgIcon icon="ri:time-line" class="hours-icon" />
              <span class="hours-label">实际工时</span>
            </div>
            <div class="work-hours-center clickable" @click="handleShowActualHoursHistory">
              <span v-if="taskData.real_time" class="hours-value">
                {{ formatHours(taskData.real_time) }} 小时
              </span>
              <span v-else class="hours-empty">--</span>
            </div>
            <div class="work-hours-right">
              <ElButton text @click="handleAddActualHours">
                <ArtSvgIcon icon="ri:add-line" class="mr-1" />
                实际工时
              </ElButton>
            </div>
          </div>

          <!-- 工时记录列表 -->
          <div v-if="actualHoursRecords.length > 0" class="work-hours-records">
            <div
              v-for="(record, index) in actualHoursRecords"
              :key="index"
              class="hours-record-item"
            >
              <ElAvatar :size="32" class="record-avatar">
                {{ getInitials(record.user) }}
              </ElAvatar>
              <div class="record-content">
                <div class="record-info">
                  {{ record.user }} {{ record.date }}实际工时为 {{ record.hours }} 小时
                </div>
                <div v-if="record.tags && record.tags.length > 0" class="record-tags">
                  <span v-for="tag in record.tags" :key="tag" class="record-tag">
                    {{ tag }}
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 子任务 -->
        <div class="detail-section subtask-section">
          <div class="subtask-header">
            <span class="subtask-title">子任务</span>
            <span class="subtask-count">{{ completedSubtasksCount }}/{{ subtasks.length }}</span>
            <div class="subtask-header-actions">
              <ElButton text size="small" @click="handleAddSubtask">
                <ArtSvgIcon icon="ri:add-line" />
              </ElButton>
            </div>
          </div>
        </div>
        <div class="detail-section subtask-section">
          <!-- 子任务列表 -->
          <div class="subtask-list">
            <div
              v-for="subtask in subtasks"
              :key="subtask.id"
              class="subtask-item"
              @click="handleSubtaskClick(subtask)"
            >
              <ElCheckbox
                :model-value="subtask.is_done"
                @change="(val: any) => handleSubtaskComplete(subtask, Boolean(val))"
                @click.stop
              />
              <span class="subtask-name" :class="{ completed: subtask.is_done }">
                {{ subtask.name }}
              </span>
              <div class="subtask-meta">
                <span
                  v-if="subtask.due_at"
                  class="subtask-due"
                  :class="{ overdue: isOverdue(subtask.due_at) }"
                >
                  {{ formatSubtaskDue(subtask.due_at) }}
                </span>
                <span v-if="subtask.priority_name" class="subtask-priority">
                  <ArtSvgIcon
                    icon="ri:flag-fill"
                    :style="{ color: getPriorityColor(subtask.priority_name) }"
                  />
                </span>
                <ElAvatar v-if="subtask.executor_name" :size="24" class="subtask-executor">
                  {{ getInitials(subtask.executor_name) }}
                </ElAvatar>
              </div>
              <ElButton text size="small" class="subtask-expand-btn" @click.stop>
                <ArtSvgIcon icon="ri:arrow-down-s-line" />
              </ElButton>
            </div>

            <!-- 新增子任务表单 -->
            <div v-if="showSubtaskForm" class="subtask-form">
              <ElCheckbox disabled />
              <ElInput
                v-model="subtaskForm.name"
                placeholder="输入任务内容..."
                class="subtask-input"
                @keyup.enter="handleSaveSubtask"
              />
              <ElButton text size="small" class="subtask-expand-icon">
                <ArtSvgIcon icon="ri:arrow-right-up-line" />
              </ElButton>
              <ElDatePicker
                v-model="subtaskForm.due_at"
                type="datetime"
                placeholder="截止日期"
                format="MM-DD HH:mm"
                value-format="YYYY-MM-DD HH:mm:ss"
                class="subtask-date-picker"
              >
                <template #prefix>
                  <ArtSvgIcon icon="ri:calendar-line" />
                </template>
              </ElDatePicker>
              <ElPopover
                v-model:visible="subtaskCategoryPopoverVisible"
                placement="bottom"
                :width="160"
                trigger="click"
              >
                <template #reference>
                  <ElButton text size="small" class="subtask-category-btn">
                    <ArtSvgIcon :icon="getCategoryIcon(subtaskForm.category_name)" />
                  </ElButton>
                </template>
                <div class="subtask-category-options">
                  <div
                    v-for="cat in categoryList"
                    :key="cat.id"
                    class="category-option"
                    :class="{ active: subtaskForm.category_id === cat.id }"
                    @click="handleSelectSubtaskCategory(cat)"
                  >
                    <ArtSvgIcon :icon="getCategoryIcon(cat.name)" class="category-icon" />
                    <span>{{ cat.name }}</span>
                  </div>
                </div>
              </ElPopover>
              <div class="subtask-executor-select" @click="handleSelectSubtaskExecutor">
                <ElAvatar v-if="subtaskForm.executor_name" :size="24">
                  {{ getInitials(subtaskForm.executor_name) }}
                </ElAvatar>
                <ElAvatar v-else :size="24" class="executor-placeholder">
                  <ArtSvgIcon icon="ri:user-line" />
                </ElAvatar>
              </div>
            </div>

            <!-- 子任务表单操作按钮 -->
            <div v-if="showSubtaskForm" class="subtask-form-actions">
              <ElButton text @click="handleCancelSubtask">取消</ElButton>
              <ElButton
                type="primary"
                :disabled="!subtaskForm.name"
                :loading="subtaskSaving"
                @click="handleSaveSubtask"
              >
                保存
              </ElButton>
            </div>

            <!-- 添加子任务按钮 -->
            <div v-if="!showSubtaskForm" class="add-subtask-btn" @click="handleAddSubtask">
              <ArtSvgIcon icon="ri:add-line" class="add-icon" />
              <span>添加子任务</span>
            </div>
          </div>
        </div>

        <!-- 任务进展 -->
        <div class="detail-section">
          <div class="section-label">
            <ArtSvgIcon icon="ri:line-chart-line" class="section-icon" />
            任务进展
          </div>
          <div class="section-content">
            <div class="task-progress-content">
              <!-- 这里可以添加任务进展的内容 -->
            </div>
          </div>
        </div>
      </div>

      <!-- 右侧面板 - 活动日志和评论 -->
      <div class="task-activity-panel">
        <!-- 参与者 -->
        <div class="participants-section">
          <span class="participants-label">参与者 {{ participants.length }}</span>
          <div class="participants-list">
            <ElAvatar
              v-for="participant in participants"
              :key="participant.id"
              :size="32"
              class="participant-avatar"
            >
              {{ getInitials(participant.name) }}
            </ElAvatar>
            <ElAvatar :size="32" class="add-participant-avatar" @click="handleAddParticipant">
              <ArtSvgIcon icon="ri:add-line" />
            </ElAvatar>
          </div>
        </div>

        <!-- 标签页 -->
        <div class="tabs-section">
          <ElTabs v-model="activeTab" class="activity-tabs">
            <ElTabPane label="所有动态" name="all" />
            <ElTabPane label="仅评论" name="comments" />
            <ElTabPane label="仅附件" name="attachments" />
          </ElTabs>
          <div class="tabs-actions">
            <ElButton text class="tab-action-btn">
              <ArtSvgIcon icon="ri:search-line" />
            </ElButton>
            <ElButton text class="tab-action-btn">
              <ArtSvgIcon icon="ri:filter-3-line" />
            </ElButton>
          </div>
        </div>

        <!-- 活动列表 -->
        <div class="activity-list">
          <div v-for="(activity, index) in filteredActivities" :key="index" class="activity-item">
            <div class="activity-avatar">
              {{ getInitials(activity.user) }}
            </div>
            <div class="activity-body">
              <div class="activity-header">
                <div class="activity-title">
                  <span class="activity-user">{{ activity.user }}</span>
                  <span class="activity-action">{{ activity.action }}</span>
                </div>
                <div class="activity-time">{{ formatActivityTime(activity.time) }}</div>
              </div>
              <div
                v-if="activity.detail"
                class="activity-detail"
                v-html="sanitizeActivityDetail(activity.detail)"
              ></div>
            </div>
          </div>
        </div>

        <!-- 评论输入框 -->
        <div class="comment-section">
          <div class="comment-input">
            <div class="comment-editor-wrapper">
              <ArtWangEditor
                v-model="commentText"
                :height="'80px'"
                placeholder="请输入评论..."
                :toolbar-keys="[
                  'emotion',
                  'bold',
                  'italic',
                  '|',
                  'bulletedList',
                  'numberedList',
                  '|',
                  'undo',
                  'redo'
                ]"
                class="comment-editor"
              />
            </div>
            <div class="comment-actions">
              <div class="comment-tools">
                <ElButton text class="comment-tool-btn">
                  <ArtSvgIcon icon="ri:attachment-line" />
                </ElButton>
              </div>
              <ElButton type="primary" size="small" class="reply-btn" @click="handleSendComment"
                >回复</ElButton
              >
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 用户选择对话框 -->
    <UserSelectDialog
      v-model="executorSelectDialogVisible"
      :multiple="false"
      @select="handleExecutorSelect"
    />

    <!-- 参与者选择对话框 -->
    <UserSelectDialog
      v-model="participantSelectDialogVisible"
      :multiple="true"
      @select-multiple="handleParticipantSelect"
    />

    <!-- 优先级配置对话框 -->
    <PropertyConfigDialog
      v-model="priorityConfigDialogVisible"
      sign="task_priority"
      @updated="handlePriorityConfigUpdated"
    />

    <!-- 标签配置对话框 -->
    <PropertyConfigDialog
      v-model="tagConfigDialogVisible"
      sign="task_tag"
      @updated="handleTagConfigUpdated"
    />

    <!-- 任务类型配置对话框 -->
    <PropertyConfigDialog
      v-model="categoryConfigDialogVisible"
      sign="task_category"
      @updated="handleCategoryConfigUpdated"
    />

    <!-- 工时录入对话框 -->
    <WorkHoursDialog
      v-model="workHoursDialogVisible"
      :kind="workHoursKind"
      :task-id="taskId"
      :project-id="taskData.project_id"
      :task-start-at="taskData.start_at"
      :task-due-at="taskData.due_at"
      :default-executor-id="taskData.executor_id"
      :default-executor-name="taskData.executor_name"
      @success="handleWorkHoursSuccess"
    />

    <!-- 工时历史对话框 -->
    <WorkHoursHistoryDialog
      v-model="workHoursHistoryDialogVisible"
      :task-id="taskId"
      :kind="workHoursHistoryKind"
      @updated="handleWorkHoursHistoryUpdated"
    />

    <!-- 子任务执行人选择对话框 -->
    <UserSelectDialog
      v-model="subtaskExecutorDialogVisible"
      :multiple="false"
      @select="handleSubtaskExecutorSelect"
    />
  </div>
</template>

<script setup lang="ts">
  import { ref, reactive, computed, onMounted, watch } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import { ElMessage } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import ArtWangEditor from '@/components/core/forms/art-wang-editor/index.vue'
  import UserSelectDialog from '@/components/UserSelectDialog.vue'
  import {
    ElButton,
    ElInput,
    ElCheckbox,
    ElDatePicker,
    ElTabs,
    ElTabPane,
    ElDropdown,
    ElDropdownMenu,
    ElDropdownItem,
    ElAvatar,
    ElPopover
  } from 'element-plus'
  import { viewPmTaskApi, updatePmTaskApi } from '@/api/pm/task'
  import { listPmTaskApi, createPmTaskApi } from '@/api/pm/project'
  import { listPropertyApi } from '@/api/property'
  import WorkHoursDialog from '@/components/WorkHoursDialog.vue'
  import WorkHoursHistoryDialog from '@/components/WorkHoursHistoryDialog.vue'
  import { createActivityApi, listActivityApi } from '@/api/activity'
  import PropertyConfigDialog from '@/components/PropertyConfigDialog.vue'

  interface Props {
    taskId?: string | number
  }

  const props = withDefaults(defineProps<Props>(), {
    taskId: undefined
  })

  const route = useRoute()
  const router = useRouter()

  // 返回上一页
  const handleGoBack = (): void => {
    router.back()
  }

  // 从路由参数获取任务ID
  const taskId = computed(() => {
    if (props.taskId) return props.taskId
    const id = route.params.id || route.query.id
    return Array.isArray(id) ? id[0] : id
  })

  // 任务数据接口
  interface TaskData {
    id?: string | number
    name: string
    description: string
    is_completed: boolean
    executor_id?: string | number
    executor_name: string
    start_at?: string
    due_at?: string
    project_id?: string | number
    project_name: string
    stage_id?: string | number
    stage_name: string
    category_id?: string | number
    category_name: string
    status_id?: string | number
    status_name: string
    parent_id?: string | number
    parent_name: string
    priority_id?: string | number
    priority_name: string
    priority_color?: string
    sort: number
    labels: any[]
    custom_fields: any[]
    actual_hours: number
    [key: string]: any
  }

  // 任务数据
  const taskData = reactive<TaskData>({
    id: undefined,
    name: '',
    description: '',
    is_completed: false,
    executor_id: undefined,
    executor_name: '',
    start_at: undefined,
    due_at: undefined,
    project_id: undefined,
    project_name: '',
    stage_id: undefined,
    stage_name: '',
    category_id: undefined,
    category_name: '',
    status_id: undefined,
    status_name: '',
    parent_id: undefined,
    parent_name: '',
    priority_id: undefined,
    priority_name: '',
    sort: 0,
    is_star: false,
    is_public: false,
    is_done: false,
    done_at: undefined,
    user_id: undefined,
    user_name: '',
    updater_id: undefined,
    updater_name: '',
    plan_time: undefined,
    real_time: undefined,
    labels: [],
    custom_fields: undefined,
    actual_hours: 0
  } as unknown as TaskData)

  // 标签列表
  const tagList = ref<Array<{ id: string | number; name: string; color?: string }>>([])
  const taskLabels = computed(() => {
    if (!taskData.labels) return []
    try {
      if (typeof taskData.labels === 'string') {
        return JSON.parse(taskData.labels)
      }
      return Array.isArray(taskData.labels) ? taskData.labels : []
    } catch {
      return []
    }
  })

  // 实际工时记录
  const actualHoursRecords = ref<
    Array<{ user: string; date: string; hours: number; tags?: string[] }>
  >([])

  // 参与者
  const participants = ref<Array<{ id: string | number; name: string }>>([])

  // 活动列表
  const activities = ref<
    Array<{
      user: string
      action: string
      detail?: string
      time: string
      type: 'all' | 'comments' | 'attachments'
    }>
  >([])

  // 当前标签页
  const activeTab = ref('all')

  // 过滤后的活动列表
  const filteredActivities = computed(() => {
    if (activeTab.value === 'all') {
      return activities.value
    }
    return activities.value.filter((a) => a.type === activeTab.value)
  })

  // 评论文本
  const commentText = ref('')

  // 对话框显示状态
  const executorSelectDialogVisible = ref(false)
  const participantSelectDialogVisible = ref(false)
  const descriptionEditorVisible = ref(false)
  const descriptionEditorContent = ref('')

  // 加载任务详情
  const loadTaskDetail = async (): Promise<void> => {
    if (!taskId.value) {
      ElMessage.warning('任务ID不存在')
      return
    }

    try {
      const res = await viewPmTaskApi({ id: taskId.value }, { showErrorMessage: false })
      const data = (res as any).data || {}

      // 填充任务数据
      Object.assign(taskData, {
        id: data.id,
        project_id: data.project_id,
        project_name: data.project_name || '',
        stage_id: data.stage_id,
        stage_name: data.stage_name || '',
        category_id: data.category_id,
        category_name: data.category_name || '',
        status_id: data.status_id,
        status_name: data.status_name || '',
        parent_id: data.parent_id,
        parent_name: data.parent_name || '',
        name: data.name || '',
        py: data.py,
        priority_id: data.priority_id,
        priority_name: data.priority_name || '',
        priority_color: data.priority_color,
        sort: data.sort,
        labels: data.labels || [],
        custom_fields: data.custom_fields || [],
        due_at: data.due_at,
        done_at: data.done_at,
        is_star: data.is_star,
        is_public: data.is_public,
        is_done: data.is_done,
        executor_id: data.executor_id,
        executor_name: data.executor_name || '',
        start_at: data.start_at,
        description: data.description || '',
        plan_time: data.plan_time || 0,
        real_time: data.real_time || 0
      })

      // 加载活动记录
      await loadActivities()
    } catch (error) {
      console.error('加载任务详情失败:', error)
      ElMessage.error('加载任务详情失败')
    }
  }

  // 优先级列表
  const priorityList = ref<any[]>([])

  // 加载选项数据
  const loadOptions = async (): Promise<void> => {
    try {
      const [tagRes, priorityRes, categoryRes] = await Promise.all([
        listPropertyApi({ 'q[sign_eq]': 'task_tag' }, { showErrorMessage: false }),
        listPropertyApi({ 'q[sign_eq]': 'task_priority' }, { showErrorMessage: false }),
        listPropertyApi({ 'q[sign_eq]': 'task_category' }, { showErrorMessage: false })
      ])
      const tagData = (tagRes as any).data || []
      tagList.value = Array.isArray(tagData) ? tagData : []

      const priorityData = (priorityRes as any).data || []
      priorityList.value = Array.isArray(priorityData) ? priorityData : []

      const categoryData = (categoryRes as any).data || []
      categoryList.value = Array.isArray(categoryData) ? categoryData : []
    } catch (error) {
      console.error('加载选项数据失败:', error)
    }
  }

  // 更新任务标题
  const handleTitleUpdate = async (): Promise<void> => {
    if (!taskId.value) return
    try {
      await updatePmTaskApi(String(taskId.value), { name: taskData.name })
      // 添加活动记录
      activities.value.unshift({
        user: '当前用户',
        action: '更新了标题',
        detail: taskData.name,
        time: new Date().toISOString(),
        type: 'all'
      })
    } catch (error) {
      console.error('更新任务标题失败:', error)
    }
  }

  // 状态改变
  const handleStatusChange = async (): Promise<void> => {
    if (!taskId.value) return
    try {
      await updatePmTaskApi(String(taskId.value), { is_completed: taskData.is_completed })
    } catch (error) {
      console.error('更新任务状态失败:', error)
    }
  }

  // 选择执行者
  const handleSelectExecutor = (): void => {
    executorSelectDialogVisible.value = true
  }

  // 执行者选择回调
  const handleExecutorSelect = async (user: any): Promise<void> => {
    taskData.executor_id = user.id
    taskData.executor_name = user.name || user.email
    if (taskId.value) {
      try {
        await updatePmTaskApi(String(taskId.value), { executor_id: user.id })
      } catch (error) {
        console.error('更新执行者失败:', error)
      }
    }
  }

  // 时间更新
  const handleTimeUpdate = async (): Promise<void> => {
    if (!taskId.value) return
    try {
      await updatePmTaskApi(String(taskId.value), {
        start_at: taskData.start_at,
        due_at: taskData.due_at
      })
    } catch (error) {
      console.error('更新时间失败:', error)
    }
  }

  // 打开备注编辑器
  const handleOpenDescriptionEditor = (): void => {
    descriptionEditorContent.value = taskData.description || ''
    descriptionEditorVisible.value = true
  }

  // 取消备注编辑
  const handleCancelDescriptionEdit = (): void => {
    descriptionEditorVisible.value = false
    descriptionEditorContent.value = ''
  }

  // 保存备注
  const handleSaveDescription = async (): Promise<void> => {
    if (!taskId.value) return
    try {
      taskData.description = descriptionEditorContent.value
      await updatePmTaskApi(String(taskId.value), { description: taskData.description })
      descriptionEditorVisible.value = false
      ElMessage.success('备注已保存')
    } catch (error) {
      console.error('更新备注失败:', error)
      ElMessage.error('保存备注失败')
    }
  }

  // 获取备注预览（保留HTML格式，全部显示）
  const getDescriptionPreview = (): string => {
    if (!taskData.description) return ''
    return taskData.description
  }

  // 加载活动列表
  const loadActivities = async (): Promise<void> => {
    if (!taskId.value) return
    try {
      const res = await listActivityApi(
        {
          'q[record_type_eq]': 'Task',
          'q[record_id_eq]': taskId.value
        },
        { showErrorMessage: false }
      )
      const data = (res as any).data || {}
      const activityList = Array.isArray(data) ? data : data.list || data.data || data.records || []

      activities.value = activityList.map((item: any) => {
        let activityType: 'all' | 'comments' | 'attachments' = 'all'
        if (item.type === 'comment') {
          activityType = 'comments'
        } else if (item.type === 'attachment') {
          activityType = 'attachments'
        }

        return {
          user: item.user_name || item.user_email || '未知用户',
          action: item.action || '评论',
          detail: item.content || item.description,
          time: item.created_at || item.created_time,
          type: activityType
        }
      })
    } catch (error) {
      console.error('加载活动列表失败:', error)
      // 如果加载失败，至少显示创建任务的活动
      activities.value = [
        {
          user: 'cxhyun@126.com',
          action: '创建了任务',
          time: new Date().toISOString(),
          type: 'all'
        }
      ]
    }
  }

  // 优先级弹窗
  const priorityPopoverVisible = ref(false)

  // 优先级配置对话框
  const priorityConfigDialogVisible = ref(false)

  // 标签弹窗
  const tagPopoverVisible = ref(false)

  // 标签配置对话框
  const tagConfigDialogVisible = ref(false)

  // 任务类型弹窗
  const categoryPopoverVisible = ref(false)

  // 任务类型配置对话框
  const categoryConfigDialogVisible = ref(false)

  // 任务类型列表
  const categoryList = ref<any[]>([])

  // 工时录入对话框
  const workHoursDialogVisible = ref(false)
  const workHoursKind = ref(0) // 0: 计划工时, 1: 实际工时
  const workHoursHistoryDialogVisible = ref(false)
  const workHoursHistoryKind = ref<number | undefined>(undefined) // 工时历史过滤 kind

  // 工时录入成功回调
  const handleWorkHoursSuccess = (): void => {
    loadTaskDetail()
  }

  // 工时历史更新回调
  const handleWorkHoursHistoryUpdated = (): void => {
    loadTaskDetail()
  }

  // 打开计划工时历史
  const handleShowPlanHoursHistory = (): void => {
    workHoursHistoryKind.value = 0
    workHoursHistoryDialogVisible.value = true
  }

  // 打开实际工时历史
  const handleShowActualHoursHistory = (): void => {
    workHoursHistoryKind.value = 1
    workHoursHistoryDialogVisible.value = true
  }

  // 打开优先级配置
  const handleOpenPriorityConfig = (): void => {
    priorityPopoverVisible.value = false
    priorityConfigDialogVisible.value = true
  }

  // 优先级配置更新回调
  const handlePriorityConfigUpdated = (): void => {
    loadOptions()
  }

  // 打开标签配置
  const handleOpenTagConfig = (): void => {
    tagPopoverVisible.value = false
    tagConfigDialogVisible.value = true
  }

  // 标签配置更新回调
  const handleTagConfigUpdated = (): void => {
    loadOptions()
  }

  // 打开任务类型配置
  const handleOpenCategoryConfig = (): void => {
    categoryPopoverVisible.value = false
    categoryConfigDialogVisible.value = true
  }

  // 任务类型配置更新回调
  const handleCategoryConfigUpdated = (): void => {
    loadOptions()
  }

  // 获取优先级颜色
  const getPriorityColor = (priorityName: string): string => {
    if (!priorityName) return 'var(--el-text-color-placeholder)'
    const name = priorityName.toLowerCase()
    if (name.includes('高') || name.includes('urgent') || name.includes('high')) {
      return 'var(--el-color-danger)'
    }
    if (name.includes('中') || name.includes('medium') || name.includes('normal')) {
      return 'var(--el-color-warning)'
    }
    if (name.includes('低') || name.includes('low')) {
      return 'var(--el-color-success)'
    }
    return 'var(--el-color-primary)'
  }

  // 获取标签样式
  const getTagStyle = (tag: any): Record<string, string> => {
    const token = (tag.color || tag.bg_color || 'primary').toLowerCase()
    if (token === 'noset') {
      return {
        backgroundColor: 'var(--el-fill-color-light)',
        borderColor: 'var(--el-border-color)',
        color: 'var(--el-text-color-regular)'
      }
    }
    if (token.startsWith('--')) {
      return {
        backgroundColor: `var(${token}-light-9)`,
        borderColor: `var(${token})`,
        color: `var(${token})`
      }
    }
    return {
      backgroundColor: `var(--el-color-${token}-light-9)`,
      borderColor: `var(--el-color-${token})`,
      color: `var(--el-color-${token})`
    }
  }

  // 检查标签是否被选中
  const isTagSelected = (tagId: string | number): boolean => {
    return taskLabels.value.some((t: any) => t.id === tagId)
  }

  // 切换标签选择
  const handleToggleTag = async (tag: any): Promise<void> => {
    if (!taskId.value) return
    try {
      const currentLabels = [...taskLabels.value]
      const index = currentLabels.findIndex((t: any) => t.id === tag.id)
      if (index >= 0) {
        currentLabels.splice(index, 1)
      } else {
        currentLabels.push({ id: tag.id, name: tag.name, color: tag.color })
      }
      await updatePmTaskApi(String(taskId.value), { labels: currentLabels })
      taskData.labels = currentLabels
      ElMessage.success('标签已更新')
    } catch (error) {
      console.error('更新标签失败:', error)
      ElMessage.error('更新标签失败')
    }
  }

  // 获取任务类型图标
  const getCategoryIcon = (name: string): string => {
    const iconMap: Record<string, string> = {
      任务: 'ri:checkbox-circle-line',
      风险: 'ri:flashlight-line',
      里程碑: 'ri:flag-2-line',
      缺陷: 'ri:bug-line',
      需求: 'ri:file-list-line'
    }
    return iconMap[name] || 'ri:checkbox-circle-line'
  }

  // 选择任务类型
  const handleSelectCategory = async (category: any): Promise<void> => {
    if (!taskId.value) return
    try {
      await updatePmTaskApi(String(taskId.value), { category_id: category.id })
      taskData.category_id = category.id
      taskData.category_name = category.name
      categoryPopoverVisible.value = false
      ElMessage.success('任务类型已更新')
    } catch (error) {
      console.error('更新任务类型失败:', error)
      ElMessage.error('更新任务类型失败')
    }
  }

  // 获取优先级样式
  const getPriorityStyle = (priority: any): Record<string, string> => {
    if (!priority) {
      return {
        backgroundColor: 'var(--el-color-info-light-9)',
        borderColor: 'var(--el-color-info)',
        color: 'var(--el-color-info)'
      }
    }

    const token = (priority.color || priority.bg_color || '').toLowerCase()

    // 无颜色
    if (!token || token === 'noset') {
      return {
        backgroundColor: 'var(--el-fill-color-light)',
        borderColor: 'var(--el-border-color)',
        color: 'var(--el-text-color-regular)'
      }
    }

    // CSS 变量格式 (--el-color-xxx)
    if (token.startsWith('--')) {
      return {
        backgroundColor: `var(${token}-light-9)`,
        borderColor: `var(${token})`,
        color: `var(${token})`
      }
    }

    // 主题色 token (如 primary, success, warning, danger, info)
    if (/^[a-z]+$/.test(token)) {
      return {
        backgroundColor: `var(--el-color-${token}-light-9)`,
        borderColor: `var(--el-color-${token})`,
        color: `var(--el-color-${token})`
      }
    }

    // 默认颜色映射（根据名称）
    const name = priority.name || ''
    let cssVar = 'info'
    if (name.includes('非常紧急') || name.includes('最高')) {
      cssVar = 'danger'
    } else if (name.includes('紧急') || name.includes('高')) {
      cssVar = 'warning'
    } else if (name.includes('普通') || name.includes('中')) {
      cssVar = 'primary'
    } else if (name.includes('低') || name.includes('较低')) {
      cssVar = 'info'
    }
    return {
      backgroundColor: `var(--el-color-${cssVar}-light-9)`,
      borderColor: `var(--el-color-${cssVar})`,
      color: `var(--el-color-${cssVar})`
    }
  }

  // 选择优先级
  const handleSelectPriority = async (priority: any): Promise<void> => {
    if (!taskId.value) return
    try {
      await updatePmTaskApi(String(taskId.value), { priority_id: priority.id })
      taskData.priority_id = priority.id
      taskData.priority_name = priority.name
      taskData.priority_color = priority.color || priority.bg_color
      priorityPopoverVisible.value = false
      ElMessage.success('优先级已更新')
    } catch (error) {
      console.error('更新优先级失败:', error)
      ElMessage.error('更新优先级失败')
    }
  }

  // 添加字段
  const handleAddField = (): void => {
    ElMessage.info('添加字段功能待实现')
  }

  // 添加计划工时
  const handleAddPlanHours = (): void => {
    workHoursKind.value = 0
    workHoursDialogVisible.value = true
  }

  // 添加实际工时
  const handleAddActualHours = (): void => {
    workHoursKind.value = 1
    workHoursDialogVisible.value = true
  }

  // 子任务相关
  const subtasks = ref<any[]>([])
  const showSubtaskForm = ref(false)
  const subtaskSaving = ref(false)
  const subtaskCategoryPopoverVisible = ref(false)
  const subtaskExecutorDialogVisible = ref(false)
  const subtaskForm = ref({
    name: '',
    due_at: '',
    category_id: undefined as string | number | undefined,
    category_name: '',
    executor_id: undefined as string | number | undefined,
    executor_name: ''
  })

  // 已完成子任务数量
  const completedSubtasksCount = computed(() => {
    return subtasks.value.filter((t) => t.is_done).length
  })

  // 加载子任务列表
  const loadSubtasks = async (): Promise<void> => {
    if (!taskId.value) return
    try {
      const res = await listPmTaskApi({ 'q[parent_id_eq]': taskId.value })
      const data = (res as any).data || []
      subtasks.value = Array.isArray(data) ? data : []
    } catch (error) {
      console.error('加载子任务失败:', error)
    }
  }

  // 添加子任务
  const handleAddSubtask = (): void => {
    showSubtaskForm.value = true
    subtaskForm.value = {
      name: '',
      due_at: '',
      category_id: undefined,
      category_name: '',
      executor_id: undefined,
      executor_name: ''
    }
  }

  // 取消添加子任务
  const handleCancelSubtask = (): void => {
    showSubtaskForm.value = false
  }

  // 保存子任务
  const handleSaveSubtask = async (): Promise<void> => {
    if (!subtaskForm.value.name || !taskId.value) return
    subtaskSaving.value = true
    try {
      await createPmTaskApi({
        name: subtaskForm.value.name,
        parent_id: taskId.value,
        project_id: taskData.project_id,
        due_at: subtaskForm.value.due_at || undefined,
        category_id: subtaskForm.value.category_id || undefined,
        executor_id: subtaskForm.value.executor_id || undefined
      })
      ElMessage.success('子任务创建成功')
      showSubtaskForm.value = false
      await loadSubtasks()
    } catch (error) {
      console.error('创建子任务失败:', error)
      ElMessage.error('创建子任务失败')
    } finally {
      subtaskSaving.value = false
    }
  }

  // 点击子任务进入详情页
  const handleSubtaskClick = (subtask: any): void => {
    if (!subtask.id) return
    router.push({ name: 'TaskDetail', params: { id: subtask.id } })
  }

  // 子任务完成状态切换
  const handleSubtaskComplete = async (subtask: any, isDone: boolean): Promise<void> => {
    try {
      await updatePmTaskApi(String(subtask.id), {
        is_done: isDone,
        done_at: isDone ? new Date().toISOString() : null
      })
      subtask.is_done = isDone
    } catch (error) {
      console.error('更新子任务状态失败:', error)
      ElMessage.error('更新失败')
    }
  }

  // 选择子任务类型
  const handleSelectSubtaskCategory = (cat: any): void => {
    subtaskForm.value.category_id = cat.id
    subtaskForm.value.category_name = cat.name
    subtaskCategoryPopoverVisible.value = false
  }

  // 选择子任务执行人
  const handleSelectSubtaskExecutor = (): void => {
    subtaskExecutorDialogVisible.value = true
  }

  // 子任务执行人选择回调
  const handleSubtaskExecutorSelect = (users: any[]): void => {
    if (users.length > 0) {
      subtaskForm.value.executor_id = users[0].id
      subtaskForm.value.executor_name = users[0].name || users[0].email
    }
  }

  // 判断是否逾期
  const isOverdue = (dueAt: string): boolean => {
    if (!dueAt) return false
    return new Date(dueAt) < new Date()
  }

  // 格式化子任务截止日期
  const formatSubtaskDue = (dueAt: string): string => {
    if (!dueAt) return ''
    const date = new Date(dueAt)
    const now = new Date()
    const tomorrow = new Date(now)
    tomorrow.setDate(tomorrow.getDate() + 1)

    const hours = String(date.getHours()).padStart(2, '0')
    const minutes = String(date.getMinutes()).padStart(2, '0')
    const timeStr = `${hours}:${minutes}`

    // 判断是否是今天
    if (date.toDateString() === now.toDateString()) {
      return `今天 ${timeStr}`
    }
    // 判断是否是明天
    if (date.toDateString() === tomorrow.toDateString()) {
      return `明天 ${timeStr}`
    }
    // 其他日期
    return `${date.getMonth() + 1}-${date.getDate()} ${timeStr}`
  }

  // 添加参与者
  const handleAddParticipant = (): void => {
    participantSelectDialogVisible.value = true
  }

  // 参与者选择回调
  const handleParticipantSelect = (users: any[]): void => {
    participants.value = users.map((user) => ({
      id: user.id,
      name: user.name || user.email
    }))
  }

  // 顶部操作
  const handleHeaderAction = (command: string): void => {
    if (command === 'edit') {
      ElMessage.info('编辑功能')
    } else if (command === 'delete') {
      ElMessage.info('删除功能')
    }
  }

  // 简单清理富文本，避免脚本注入
  const sanitizeActivityDetail = (html: string): string => {
    if (!html) return ''
    const container = document.createElement('div')
    container.innerHTML = html

    const unsafeNodes = container.querySelectorAll('script, style, iframe, object, embed')
    unsafeNodes.forEach((node) => node.remove())

    const allNodes = container.querySelectorAll('*')
    allNodes.forEach((node) => {
      Array.from(node.attributes).forEach((attr) => {
        const name = attr.name.toLowerCase()
        const value = attr.value?.toLowerCase() || ''
        if (name.startsWith('on')) {
          node.removeAttribute(attr.name)
        }
        if ((name === 'href' || name === 'src') && value.startsWith('javascript:')) {
          node.removeAttribute(attr.name)
        }
      })
    })

    return container.innerHTML
  }

  // 发送评论
  const handleSendComment = async (): Promise<void> => {
    if (!commentText.value.trim()) {
      ElMessage.warning('请输入评论内容')
      return
    }
    if (!taskId.value) {
      ElMessage.warning('任务ID不存在')
      return
    }

    try {
      // 调用创建活动API
      await createActivityApi({
        record_type: 'Task',
        record_id: taskId.value,
        type: 'comment',
        content: commentText.value
      })

      ElMessage.success('评论发送成功')
      commentText.value = ''

      // 重新加载活动列表
      await loadActivities()
    } catch (error) {
      console.error('发送评论失败:', error)
      ElMessage.error('发送评论失败')
    }
  }

  // 格式化活动时间
  const formatActivityTime = (timeStr: string): string => {
    const date = new Date(timeStr)
    const now = new Date()
    const diffMs = now.getTime() - date.getTime()
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24))

    const year = date.getFullYear()
    const month = date.getMonth() + 1
    const day = date.getDate()
    const hours = String(date.getHours()).padStart(2, '0')
    const minutes = String(date.getMinutes()).padStart(2, '0')

    if (diffDays === 0) {
      return `${month}月${day}日 ${hours}:${minutes}`
    } else if (diffDays === 1) {
      return `昨天 ${hours}:${minutes}`
    } else if (diffDays < 7) {
      return `${diffDays}天前 ${hours}:${minutes}`
    } else {
      return `${year}年${month}月${day}日 ${hours}:${minutes}`
    }
  }

  // 格式化工时（保留1位小数）
  const formatHours = (hours: number | string | undefined): string => {
    if (hours === undefined || hours === null) return '0'
    const num = Number(hours)
    if (isNaN(num)) return '0'
    return num.toFixed(1)
  }

  // 获取首字母
  const getInitials = (name?: string): string => {
    if (!name) return '?'
    return name.substring(0, 1).toUpperCase()
  }

  // 初始化
  onMounted(async () => {
    await loadOptions()
    await loadTaskDetail()
    await loadSubtasks()
  })

  // 监听路由参数变化，重新加载数据（用于同一组件内路由切换）
  watch(
    () => route.params.id,
    async (newId, oldId) => {
      if (newId && newId !== oldId) {
        await loadTaskDetail()
        await loadSubtasks()
      }
    }
  )
</script>

<style scoped lang="scss">
  .task-detail-container {
    display: flex;
    flex-direction: column;
    width: 100%;
    height: 100vh;
    overflow: hidden;
    background: #fff;
  }

  .task-header-bar {
    display: flex;
    flex-shrink: 0;
    align-items: center;
    justify-content: space-between;
    padding: 12px 20px;
    background: #fff;
    border-bottom: 1px solid var(--el-border-color-lighter);

    .header-left {
      display: flex;
      gap: 12px;
      align-items: center;

      .back-btn {
        padding: 6px;
        font-size: 18px;
        color: var(--el-text-color-regular);

        &:hover {
          color: var(--el-color-primary);
        }
      }

      .header-title {
        font-size: 16px;
        font-weight: 500;
        color: var(--el-text-color-primary);
      }

      .header-category {
        display: flex;
        gap: 6px;
        align-items: center;
        padding: 4px 12px;
        font-size: 14px;
        color: var(--el-text-color-primary);
        cursor: pointer;
        background: var(--el-fill-color-light);
        border-radius: 6px;
        transition: all 0.2s;

        &:hover {
          background: var(--el-fill-color);
        }

        .category-icon {
          font-size: 16px;
          color: var(--el-color-primary);
        }
      }

      .header-category-placeholder {
        display: flex;
        gap: 6px;
        align-items: center;
        padding: 4px 12px;
        font-size: 14px;
        color: var(--el-text-color-placeholder);
        cursor: pointer;
        background: var(--el-fill-color-lighter);
        border-radius: 6px;
        transition: all 0.2s;

        &:hover {
          color: var(--el-text-color-regular);
          background: var(--el-fill-color-light);
        }

        .category-icon {
          font-size: 16px;
        }
      }
    }

    .header-right {
      display: flex;
      gap: 8px;
      align-items: center;

      .header-action-btn {
        padding: 6px;
        color: var(--el-text-color-regular);
      }
    }
  }

  .task-breadcrumb-bar {
    display: flex;
    flex-shrink: 0;
    align-items: center;
    justify-content: space-between;
    padding: 12px 20px;
    background: #fff;

    .breadcrumb-left {
      display: flex;
      gap: 16px;
      align-items: center;

      .category-tag {
        display: flex;
        gap: 6px;
        align-items: center;
        padding: 4px 12px;
        font-size: 14px;
        color: var(--el-text-color-primary);
        background: #e3f2fd;
        border-radius: 6px;

        .category-tag-icon {
          font-size: 16px;
          color: var(--el-color-danger);
        }
      }

      .back-parent-btn {
        display: flex;
        gap: 4px;
        align-items: center;
        padding: 4px 8px;
        font-size: 14px;
        color: var(--el-text-color-regular);

        &:hover {
          color: var(--el-color-primary);
        }
      }
    }

    .breadcrumb-path {
      display: flex;
      gap: 8px;
      align-items: center;
      padding: 8px 16px;
      font-size: 14px;
      color: var(--el-text-color-primary);
      background: #fff;
      border-radius: 6px;

      .parent-name {
        color: var(--el-text-color-regular);
      }

      .breadcrumb-separator {
        font-size: 16px;
        color: var(--el-text-color-placeholder);
      }

      .current-name {
        font-weight: 500;
        color: var(--el-text-color-primary);
      }
    }
  }

  .task-content-wrapper {
    display: flex;
    flex: 1;
    min-height: 0;
    overflow: hidden;
  }

  .task-detail-panel {
    flex: 1;
    padding: 24px;
    overflow-y: auto;
    border-right: 1px solid var(--el-border-color-lighter);
  }

  .task-title-section {
    margin-bottom: 24px;

    .task-title-input {
      :deep(.el-textarea__inner) {
        padding: 0;
        font-size: 20px;
        font-weight: 500;
        line-height: 1.5;
        resize: none;
        border: none;
        box-shadow: none;

        &:focus {
          box-shadow: none;
        }
      }
    }
  }

  .detail-section {
    display: flex;
    gap: 16px;
    align-items: flex-start;
    margin-bottom: 16px;

    .section-label {
      display: flex;
      flex-shrink: 0;
      gap: 8px;
      align-items: center;
      width: 80px;
      font-size: 14px;
      color: var(--el-text-color-regular);
    }

    .section-icon {
      font-size: 16px;
      color: var(--el-text-color-placeholder);
    }

    .section-content {
      flex: 1;
      font-size: 14px;
      color: var(--el-text-color-primary);
    }
  }

  .clickable-field {
    display: flex;
    gap: 8px;
    align-items: center;
    min-height: 24px;
    cursor: pointer;

    &:hover {
      color: var(--el-color-primary);
    }

    .field-icon {
      font-size: 16px;
      color: var(--el-text-color-regular);
    }

    .placeholder-text {
      color: var(--el-text-color-placeholder);
    }
  }

  .priority-tag-wrapper {
    padding: 2px 0;
  }

  .priority-tag {
    display: inline-block;
    padding: 4px 12px;
    font-size: 13px;
    background: #fff;
    border: 1px solid;
    border-radius: 4px;
  }

  .priority-popover {
    .priority-option {
      display: flex;
      gap: 8px;
      align-items: center;
      padding: 8px 12px;
      cursor: pointer;
      border-radius: 4px;

      &:hover {
        background: var(--el-fill-color-light);
      }

      .check-icon {
        font-size: 16px;
        color: var(--el-color-primary);
      }

      .check-placeholder {
        width: 16px;
        height: 16px;
      }
    }

    .priority-config-btn {
      display: flex;
      gap: 8px;
      align-items: center;
      padding: 10px 12px;
      margin-top: 8px;
      font-size: 13px;
      color: var(--el-color-primary);
      cursor: pointer;
      border-top: 1px solid var(--el-border-color-lighter);

      &:hover {
        background: var(--el-fill-color-light);
      }

      .config-icon {
        font-size: 16px;
      }
    }
  }

  .time-content {
    display: flex;
    flex-direction: row;
    gap: 8px;

    .time-picker {
      width: 100%;
      max-width: 280px;
    }
  }

  .description-input {
    :deep(.el-textarea__inner) {
      border: 1px solid var(--el-border-color);
      border-radius: 6px;
    }
  }

  .tags-display {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
  }

  .tag-item {
    padding: 4px 12px;
    font-size: 12px;
    border-radius: 12px;

    &.tag-primary {
      color: var(--el-color-primary);
      background: var(--el-color-primary-light-9);
    }

    &.tag-success {
      color: var(--el-color-success);
      background: var(--el-color-success-light-9);
    }

    &.tag-warning {
      color: var(--el-color-warning);
      background: var(--el-color-warning-light-9);
    }

    &.tag-danger {
      color: var(--el-color-danger);
      background: var(--el-color-danger-light-9);
    }
  }

  .add-field-btn,
  .add-subtask-btn,
  .add-related-btn,
  .add-hours-btn {
    display: inline-flex;
    gap: 6px;
    align-items: center;
    padding: 8px 12px;
    color: var(--el-color-primary);
    cursor: pointer;
    border-radius: 6px;
    transition: background 0.2s;

    &:hover {
      background: var(--el-fill-color-light);
    }

    .add-icon {
      font-size: 16px;
    }
  }

  // 子任务样式
  .subtask-section {
    padding-top: 24px;
    margin-top: 24px;
    border-top: 1px solid var(--el-border-color-lighter);

    .subtask-header {
      display: flex;
      align-items: center;
      margin-bottom: 20px;

      .subtask-title {
        position: relative;
        display: inline-block;
        padding-bottom: 8px;
        font-size: 16px;
        font-weight: 500;
        color: var(--el-text-color-primary);

        &::after {
          position: absolute;
          bottom: 0;
          left: 0;
          width: 24px;
          height: 3px;
          content: '';
          background: var(--el-color-primary);
          border-radius: 2px;
        }
      }

      .subtask-count {
        padding-bottom: 8px;
        margin-left: 8px;
        font-size: 14px;
        color: var(--el-text-color-secondary);
      }

      .subtask-header-actions {
        display: flex;
        gap: 4px;
        align-items: center;
        padding-bottom: 8px;
        margin-left: auto;
      }
    }

    .subtask-list {
      width: 100%;
      margin-top: 0;

      .subtask-item {
        display: flex;
        gap: 12px;
        align-items: center;
        width: 100%;
        padding: 12px;
        margin-bottom: 8px;
        cursor: pointer;
        background: #f5f7fa;
        border: 1px solid var(--el-border-color-lighter);
        border-radius: 8px;
        transition: all 0.2s;

        &:hover {
          background: #fff;
          border-color: var(--el-border-color);
          box-shadow: 0 2px 8px rgb(0 0 0 / 4%);
        }

        .subtask-name {
          flex: 1;
          font-size: 14px;
          color: var(--el-text-color-primary);

          &.completed {
            color: var(--el-text-color-placeholder);
            text-decoration: line-through;
          }
        }

        .subtask-meta {
          display: flex;
          gap: 12px;
          align-items: center;

          .subtask-due {
            font-size: 13px;
            color: var(--el-color-primary);

            &.overdue {
              color: var(--el-color-danger);
            }
          }

          .subtask-priority {
            font-size: 16px;
          }

          .subtask-executor {
            font-size: 12px;
            color: #fff;
            background: var(--el-color-warning);
          }
        }

        .subtask-expand-btn {
          color: var(--el-text-color-placeholder);
        }
      }

      .subtask-form {
        display: flex;
        gap: 12px;
        align-items: center;
        padding: 12px;
        margin-bottom: 8px;
        background: #fff;
        border: 1px solid var(--el-color-primary);
        border-radius: 8px;

        .subtask-input {
          flex: 1;

          :deep(.el-input__wrapper) {
            padding: 0;
            box-shadow: none !important;
          }
        }

        .subtask-expand-icon {
          color: var(--el-text-color-placeholder);
        }

        .subtask-date-picker {
          width: 32px;

          :deep(.el-input__wrapper) {
            width: 32px;
            padding: 0;
            box-shadow: none !important;
          }

          :deep(.el-input__inner) {
            display: none;
          }

          :deep(.el-input__prefix) {
            margin: 0;
          }
        }

        .subtask-category-btn {
          color: var(--el-color-primary);
        }

        .subtask-executor-select {
          cursor: pointer;

          .executor-placeholder {
            color: var(--el-text-color-placeholder);
            background: var(--el-fill-color-light);
          }
        }
      }

      .subtask-form-actions {
        display: flex;
        gap: 8px;
        justify-content: flex-end;
        margin-bottom: 12px;
      }

      .subtask-category-options {
        .category-option {
          display: flex;
          gap: 8px;
          align-items: center;
          padding: 8px 12px;
          cursor: pointer;
          border-radius: 4px;

          &:hover {
            background: var(--el-fill-color-light);
          }

          &.active {
            color: var(--el-color-primary);
            background: var(--el-color-primary-light-9);
          }

          .category-icon {
            font-size: 16px;
          }
        }
      }
    }
  }

  // 工时卡片样式
  .work-hours-card {
    padding-top: 24px;
    margin-top: 24px;
    border-top: 1px solid var(--el-border-color-lighter);

    .work-hours-header {
      margin-bottom: 20px;

      .work-hours-title {
        position: relative;
        padding-bottom: 8px;
        font-size: 16px;
        font-weight: 500;
        color: var(--el-text-color-primary);

        &::after {
          position: absolute;
          bottom: 0;
          left: 0;
          width: 24px;
          height: 3px;
          content: '';
          background: var(--el-color-primary);
          border-radius: 2px;
        }
      }
    }

    .work-hours-row {
      display: flex;
      align-items: center;
      padding: 16px 0;
      border-bottom: 1px solid var(--el-border-color-lighter);

      &:last-of-type {
        border-bottom: none;
      }

      .work-hours-left {
        display: flex;
        flex-shrink: 0;
        gap: 12px;
        align-items: center;
        width: 140px;

        .hours-icon {
          font-size: 20px;
          color: var(--el-text-color-secondary);
        }

        .hours-label {
          font-size: 14px;
          color: var(--el-text-color-regular);
        }
      }

      .work-hours-center {
        flex: 1;
        padding-left: 40px;

        &.clickable {
          padding: 4px 8px;
          margin-left: 32px;
          cursor: pointer;
          border-radius: 4px;
          transition: background-color 0.2s;

          &:hover {
            background-color: var(--el-fill-color-light);
          }
        }

        .hours-value {
          font-size: 16px;
          font-weight: 500;
          color: var(--el-text-color-primary);
        }

        .hours-empty {
          color: var(--el-text-color-placeholder);
        }
      }

      .work-hours-right {
        flex-shrink: 0;

        .el-button {
          padding: 8px 16px;
          color: var(--el-text-color-regular);
          border: 1px solid var(--el-border-color);
          border-radius: 4px;

          &:hover {
            color: var(--el-color-primary);
            border-color: var(--el-color-primary);
          }
        }
      }
    }

    .work-hours-records {
      padding-top: 16px;

      .hours-record-item {
        display: flex;
        gap: 12px;
        align-items: flex-start;
        padding: 12px 0;
        padding-left: 152px;

        .record-avatar {
          flex-shrink: 0;
          font-size: 12px;
          color: #fff;
          background: var(--el-color-warning);
        }

        .record-content {
          flex: 1;

          .record-info {
            font-size: 14px;
            line-height: 1.6;
            color: var(--el-text-color-regular);
          }

          .record-tags {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 8px;

            .record-tag {
              display: inline-block;
              padding: 4px 12px;
              font-size: 12px;
              color: var(--el-text-color-regular);
              background: var(--el-fill-color-light);
              border-radius: 4px;
            }
          }
        }
      }
    }
  }

  .related-content-actions {
    display: flex;
    flex-direction: column;
    gap: 12px;

    .related-search-input {
      width: 100%;
    }
  }

  .task-progress-content {
    min-height: 100px;
  }

  .task-activity-panel {
    display: flex;
    flex-direction: column;
    width: 400px;
    background: #fff;
    border-left: 1px solid var(--el-border-color-lighter);
  }

  .participants-section {
    padding: 16px;
    background: #fff;
    border-bottom: 1px solid var(--el-border-color-lighter);

    .participants-label {
      display: block;
      margin-bottom: 12px;
      font-size: 14px;
      color: var(--el-text-color-regular);
    }

    .participants-list {
      display: flex;
      gap: 8px;
      align-items: center;
    }

    .participant-avatar {
      color: white;
      background: var(--el-color-primary);
    }

    .add-participant-avatar {
      color: var(--el-text-color-regular);
      cursor: pointer;
      background: var(--el-fill-color);
      border: 1px dashed var(--el-border-color);

      &:hover {
        background: var(--el-fill-color-light);
      }
    }
  }

  .tabs-section {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 16px;
    background: #fff;
    border-bottom: 1px solid var(--el-border-color-lighter);

    .activity-tabs {
      flex: 1;

      :deep(.el-tabs__header) {
        margin: 0;
      }

      :deep(.el-tabs__nav-wrap::after) {
        display: none;
      }

      :deep(.el-tabs__active-bar) {
        display: none;
      }

      :deep(.el-tabs__item) {
        height: 28px;
        padding: 0 12px;
        margin-right: 8px;
        line-height: 28px;
        color: var(--el-text-color-regular);
        border-radius: 14px;
      }

      :deep(.el-tabs__item.is-active) {
        color: var(--el-color-primary);
        background: #e8f3ff;
      }
    }

    .tabs-actions {
      display: flex;
      gap: 4px;

      .tab-action-btn {
        padding: 6px;
        color: var(--el-text-color-regular);
      }
    }
  }

  .activity-list {
    flex: 1;
    padding: 8px 16px 16px;
    overflow-y: auto;
    background: #fff;
  }

  .activity-item {
    display: flex;
    gap: 12px;
    padding: 12px 0;
    border-bottom: 1px solid var(--el-border-color-lighter);

    &:last-child {
      border-bottom: none;
    }
  }

  .activity-avatar {
    display: flex;
    flex-shrink: 0;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    font-size: 12px;
    font-weight: 500;
    color: #fff;
    background: #f3b16b;
    border-radius: 50%;
  }

  .activity-body {
    flex: 1;
    min-width: 0;
  }

  .activity-header {
    display: flex;
    gap: 12px;
    align-items: center;
    justify-content: space-between;
  }

  .activity-title {
    display: flex;
    gap: 6px;
    align-items: center;
    min-width: 0;
  }

  .activity-user {
    font-weight: 500;
    color: var(--el-text-color-primary);
  }

  .activity-action {
    color: var(--el-text-color-regular);
  }

  .activity-detail {
    margin-top: 4px;
    line-height: 1.5;
    color: var(--el-text-color-regular);
    word-break: break-word;

    :deep(h1) {
      margin: 0 0 6px;
      font-size: 16px;
      font-weight: 600;
      line-height: 1.5;
    }

    :deep(h2) {
      margin: 0 0 6px;
      font-size: 15px;
      font-weight: 600;
      line-height: 1.5;
    }

    :deep(h3) {
      margin: 0 0 6px;
      font-size: 14px;
      font-weight: 600;
      line-height: 1.5;
    }

    :deep(p) {
      margin: 0 0 6px;
      line-height: 1.5;
    }

    :deep(ol),
    :deep(ul) {
      padding-left: 18px;
      margin: 0 0 6px;
    }

    :deep(li) {
      margin: 2px 0;
    }
  }

  .activity-time {
    font-size: 12px;
    color: var(--el-text-color-placeholder);
    white-space: nowrap;
  }

  .comment-section {
    flex-shrink: 0;
    padding: 12px 16px 8px;
    background: #fff;
    border-top: 1px solid var(--el-border-color-lighter);
  }

  .comment-input {
    overflow: hidden;
    background: #fff;
    border: none;
    border-radius: 0;
  }

  .comment-placeholder {
    min-height: 72px;
    padding: 8px 12px;
    line-height: 1.5;
    color: var(--el-text-color-placeholder);
    cursor: text;
  }

  .comment-preview {
    color: var(--el-text-color-primary);
  }

  .comment-editor-wrapper {
    .comment-editor {
      :deep(.editor-wrapper) {
        border: none;
      }

      :deep(.editor-toolbar) {
        padding: 6px 12px;
        background: #fff;
        border-bottom: 1px solid var(--el-border-color-lighter);
      }

      :deep(.w-e-bar-item button) {
        color: var(--el-text-color-regular);
      }

      :deep(.w-e-text-container) {
        min-height: 72px;
        padding: 4px 12px;
      }
    }
  }

  .comment-actions {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 6px 12px 2px;
    border-top: 1px solid var(--el-border-color-lighter);

    .comment-tools {
      display: flex;
      gap: 12px;
      align-items: center;

      .comment-tool-btn {
        display: inline-flex;
        gap: 6px;
        align-items: center;
        padding: 6px;
        color: var(--el-text-color-regular);
      }
    }

    .reply-btn {
      padding: 8px 16px;
    }
  }

  .description-preview {
    display: block;
    max-width: 100%;
    line-height: 1.6;
    word-wrap: break-word;

    :deep(h1) {
      margin: 8px 0;
      font-size: 18px;
      font-weight: 600;
    }

    :deep(h2) {
      margin: 6px 0;
      font-size: 16px;
      font-weight: 600;
    }

    :deep(h3) {
      margin: 4px 0;
      font-size: 15px;
      font-weight: 600;
    }

    :deep(p) {
      margin: 4px 0;
    }

    :deep(ul),
    :deep(ol) {
      padding-left: 20px;
      margin: 4px 0;
    }

    :deep(li) {
      margin: 2px 0;
    }

    :deep(a) {
      color: var(--el-color-primary);
      text-decoration: underline;
    }

    :deep(strong) {
      font-weight: 600;
    }

    :deep(em) {
      font-style: italic;
    }

    :deep(blockquote) {
      padding-left: 12px;
      margin: 8px 0;
      color: var(--el-text-color-secondary);
      border-left: 3px solid var(--el-border-color);
    }

    :deep(code) {
      padding: 2px 6px;
      font-family: monospace;
      background: var(--el-fill-color-light);
      border-radius: 4px;
    }

    :deep(pre) {
      padding: 12px;
      margin: 8px 0;
      overflow-x: auto;
      background: var(--el-fill-color-light);
      border-radius: 6px;

      code {
        padding: 0;
        background: none;
      }
    }
  }

  .description-editor-wrapper {
    width: 100%;
    padding: 12px;
    background: #fff;
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 8px;
  }

  .description-editor {
    :deep(.editor-wrapper) {
      border: none !important;
    }

    :deep(.w-e-bar) {
      background: transparent !important;
      border-radius: 0 !important;
    }

    :deep(.w-e-toolbar) {
      padding-bottom: 8px !important;
      margin-bottom: 8px !important;
      background: transparent !important;
      border: none !important;
      border-bottom: 1px solid var(--el-border-color-lighter) !important;
    }

    :deep(.w-e-text-container) {
      min-height: 150px !important;
      background: transparent !important;
      border: none !important;
    }

    :deep(.w-e-text-container [data-slate-editor]) {
      min-height: 150px !important;
      padding: 8px 0 !important;
      line-height: 1.6 !important;

      p {
        margin: 4px 0 !important;
      }

      h1,
      h2,
      h3 {
        margin: 8px 0 !important;
        font-weight: 600 !important;
      }

      h1 {
        font-size: 20px !important;
      }

      h2 {
        font-size: 18px !important;
      }

      h3 {
        font-size: 16px !important;
      }

      ul,
      ol {
        padding-left: 20px !important;
        margin: 4px 0 !important;
      }

      li {
        margin: 2px 0 !important;
      }

      blockquote {
        padding-left: 12px !important;
        margin: 8px 0 !important;
        color: var(--el-text-color-secondary) !important;
        background: var(--el-fill-color-lighter) !important;
        border-left: 3px solid var(--el-border-color) !important;
      }

      pre {
        padding: 12px !important;
        margin: 8px 0 !important;
        background: var(--el-fill-color-light) !important;
        border-radius: 6px !important;
      }

      code {
        padding: 2px 6px !important;
        font-family: monospace !important;
        background: var(--el-fill-color-light) !important;
        border-radius: 4px !important;
      }

      a {
        color: var(--el-color-primary) !important;
        text-decoration: underline !important;
      }
    }
  }

  .description-actions {
    display: flex;
    gap: 12px;
    justify-content: flex-end;
    margin-top: 12px;
  }

  // 标签弹窗样式
  .tag-popover {
    .tag-option {
      display: flex;
      gap: 8px;
      align-items: center;
      padding: 8px 12px;
      cursor: pointer;
      border-radius: 4px;

      &:hover {
        background: var(--el-fill-color-light);
      }

      .tag-item {
        display: inline-block;
        padding: 4px 12px;
        font-size: 12px;
        border: 1px solid;
        border-radius: 12px;
      }
    }

    .tag-config-btn {
      display: flex;
      gap: 8px;
      align-items: center;
      padding: 10px 12px;
      margin-top: 8px;
      font-size: 13px;
      color: var(--el-color-primary);
      cursor: pointer;
      border-top: 1px solid var(--el-border-color-lighter);

      &:hover {
        background: var(--el-fill-color-light);
      }

      .config-icon {
        font-size: 16px;
      }
    }
  }

  // 任务类型弹窗样式
  .category-popover {
    .category-option {
      display: flex;
      gap: 8px;
      align-items: center;
      padding: 10px 12px;
      cursor: pointer;
      border-radius: 4px;

      &:hover {
        background: var(--el-fill-color-light);
      }

      .check-icon {
        font-size: 16px;
        color: var(--el-color-primary);
      }

      .check-placeholder {
        width: 16px;
        height: 16px;
      }

      .category-icon {
        font-size: 18px;
        color: var(--el-color-primary);
      }
    }

    .category-config-btn {
      display: flex;
      gap: 8px;
      align-items: center;
      padding: 10px 12px;
      margin-top: 8px;
      font-size: 13px;
      color: var(--el-color-primary);
      cursor: pointer;
      border-top: 1px solid var(--el-border-color-lighter);

      &:hover {
        background: var(--el-fill-color-light);
      }

      .config-icon {
        font-size: 16px;
      }
    }
  }

  .category-display {
    display: flex;
    gap: 8px;
    align-items: center;

    .category-icon {
      font-size: 18px;
      color: var(--el-color-primary);
    }
  }

  // 工时弹窗样式
  .work-hours-form {
    .form-item {
      margin-bottom: 20px;

      .form-label {
        margin-bottom: 8px;
        font-size: 14px;
        color: var(--el-text-color-secondary);
      }

      .form-value {
        font-size: 15px;
        color: var(--el-text-color-primary);
      }
    }

    .form-row {
      display: flex;
      gap: 24px;
    }

    .task-time-display {
      font-size: 16px;
      font-weight: 500;
    }

    .executor-display {
      display: flex;
      gap: 8px;
      align-items: center;
      padding: 8px 12px;
      cursor: pointer;
      border: 1px solid var(--el-border-color);
      border-radius: 6px;

      &:hover {
        border-color: var(--el-color-primary);
      }

      .executor-avatar {
        font-size: 12px;
        color: #fff;
        background: var(--el-color-warning);
      }
    }

    .date-range-picker {
      width: 240px;
    }

    .hours-input-wrapper {
      display: flex;
      gap: 12px;
      align-items: center;

      .hours-type-select {
        width: 100px;
      }

      .hours-input {
        flex: 1;
      }

      .hours-total {
        font-size: 14px;
        color: var(--el-text-color-regular);
        white-space: nowrap;
      }
    }

    .daily-hours-hint {
      margin-top: -8px;

      .hint-content {
        display: flex;
        gap: 8px;
        align-items: flex-start;
        padding: 12px 16px;
        font-size: 13px;
        line-height: 1.6;
        color: var(--el-text-color-regular);
        background: var(--el-fill-color-lighter);
        border-radius: 6px;

        .hint-icon {
          flex-shrink: 0;
          margin-top: 2px;
          font-size: 16px;
          color: var(--el-text-color-secondary);
        }
      }
    }

    .add-hours-tag-btn {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 32px;
      height: 32px;
      cursor: pointer;
      background: var(--el-fill-color-light);
      border-radius: 50%;

      &:hover {
        background: var(--el-fill-color);
      }
    }
  }

  .dialog-footer {
    display: flex;
    align-items: center;
    justify-content: space-between;

    .footer-left {
      color: var(--el-color-primary);
    }
  }
</style>
