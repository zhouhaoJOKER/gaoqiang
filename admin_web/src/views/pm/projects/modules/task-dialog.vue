<!-- 任务创建对话框 -->
<template>
  <ElDialog
    v-model="dialogVisible"
    title="任务"
    width="600px"
    :close-on-click-modal="false"
    class="task-dialog"
  >
    <!-- 任务类型/分类选择 -->
    <div class="task-header">
      <div class="task-type-selector">
        <div class="task-type-icon">
          <ArtSvgIcon icon="ri:checkbox-circle-line" class="icon" />
        </div>
        <ElDropdown @command="handleCategoryChange">
          <span class="task-type-text">
            任务
            <ArtSvgIcon icon="ri:arrow-down-s-line" class="dropdown-icon" />
          </span>
          <template #dropdown>
            <ElDropdownMenu>
              <ElDropdownItem
                v-for="category in categoryList"
                :key="category.id"
                :command="category.id"
              >
                {{ category.name }}
              </ElDropdownItem>
            </ElDropdownMenu>
          </template>
        </ElDropdown>
      </div>
    </div>

    <!-- 任务标题 -->
    <div class="task-title-section">
      <ElInput
        v-model="form.name"
        type="textarea"
        :rows="3"
        placeholder="输入标题以新建任务"
        class="task-title-input"
        resize="vertical"
      />
    </div>

    <!-- 任务属性 -->
    <div class="task-attributes">
      <!-- 执行人 -->
      <div class="attribute-item" @click="handleSelectExecutor">
        <div class="attribute-icon">
          <ArtSvgIcon v-if="!form.executor_id" icon="ri:user-line" />
          <ElAvatar v-else :size="20" :src="form.executor_avatar" class="executor-avatar">
            {{ getInitials(form.executor_name) }}
          </ElAvatar>
        </div>
        <span class="attribute-value">{{ form.executor_name || '待认领' }}</span>
      </div>

      <!-- 开始时间 -->
      <div class="attribute-item">
        <div class="attribute-icon">
          <ArtSvgIcon icon="ri:calendar-line" />
        </div>
        <ElDatePicker
          v-model="form.start_at"
          type="datetime"
          placeholder="设置开始时间"
          format="YYYY-MM-DD HH:mm"
          value-format="YYYY-MM-DD HH:mm:ss"
          class="date-picker"
          @change="handleStartDateChange"
        />
      </div>

      <!-- 截止时间 -->
      <div class="attribute-item">
        <div class="attribute-icon">
          <ArtSvgIcon icon="ri:calendar-line" />
        </div>
        <ElDatePicker
          v-model="form.due_at"
          type="datetime"
          placeholder="设置截止时间"
          format="YYYY-MM-DD HH:mm"
          value-format="YYYY-MM-DD HH:mm:ss"
          class="date-picker"
          @change="handleDueDateChange"
        />
      </div>

      <!-- 提醒 -->
      <div class="attribute-item" @click="handleReminderClick">
        <div class="attribute-icon">
          <ArtSvgIcon icon="ri:alarm-line" />
        </div>
        <span class="attribute-value">{{ reminderText }}</span>
      </div>

      <!-- 优先级 -->
      <div class="attribute-item">
        <div class="attribute-icon">
          <ArtSvgIcon icon="ri:flag-line" />
        </div>
        <ElRadioGroup v-model="form.priority_id" class="priority-group">
          <ElRadio
            v-for="priority in priorityList"
            :key="priority.id"
            :label="priority.id"
            class="priority-radio"
          >
            {{ priority.name }}
          </ElRadio>
        </ElRadioGroup>
      </div>

      <!-- 标签 -->
      <div class="attribute-item">
        <div class="attribute-icon">
          <ArtSvgIcon icon="ri:price-tag-3-line" />
        </div>
        <div class="tags-display">
          <TagSelector v-model="form.labels" sign="task_tag" placeholder="添加标签" />
        </div>
      </div>
    </div>

    <!-- 参与者部分 -->
    <div class="participants-section">
      <div class="participants-header">
        <span class="participants-label">参与者 {{ participants.length }}?</span>
      </div>
      <div class="participants-list">
        <ElAvatar
          v-for="participant in participants"
          :key="participant.id"
          :size="32"
          :src="participant.avatar"
          class="participant-avatar"
        >
          {{ getInitials(participant.name) }}
        </ElAvatar>
        <ElAvatar :size="32" class="add-participant-btn" @click="handleAddParticipant">
          <ArtSvgIcon icon="ri:add-line" />
        </ElAvatar>
      </div>
    </div>

    <!-- 公开模式 -->
    <div class="public-section">
      <div class="public-mode-item" @click="handleTogglePublic">
        <ArtSvgIcon
          :icon="form.is_public ? 'ri:lock-unlock-line' : 'ri:lock-line'"
          class="public-icon"
        />
        <div class="public-content">
          <span class="public-label">公开模式</span>
          <span class="public-subtitle">所有成员可见</span>
        </div>
      </div>
    </div>

    <!-- 底部按钮 -->
    <template #footer>
      <div class="dialog-footer">
        <ElButton type="primary" :disabled="!form.name?.trim()" @click="handleSubmit">
          创建
        </ElButton>
      </div>
    </template>

    <!-- 用户选择弹窗 -->
    <UserSelectDialog
      v-model="executorSelectDialogVisible"
      :multiple="false"
      @select="handleExecutorSelect"
    />

    <!-- 参与者选择弹窗 -->
    <UserSelectDialog
      v-model="participantSelectDialogVisible"
      :multiple="true"
      @select-multiple="handleParticipantSelect"
    />
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, reactive, computed, watch } from 'vue'
  import { storeToRefs } from 'pinia'
  import { ElMessage } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import UserSelectDialog from '@/components/UserSelectDialog.vue'
  import TagSelector from '@/components/TagSelector.vue'
  import {
    ElDialog,
    ElInput,
    ElButton,
    ElDropdown,
    ElDropdownMenu,
    ElDropdownItem,
    ElAvatar,
    ElDatePicker,
    ElRadioGroup,
    ElRadio
  } from 'element-plus'
  import { useUserStore } from '@/store/modules/user'
  import { createPmTaskApi } from '@/api/pm/project'
  import { listPropertyApi } from '@/api/property'

  interface Props {
    modelValue: boolean
    projectId?: string | number
    stageId?: string | number
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created'): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    projectId: undefined,
    stageId: undefined
  })

  const emit = defineEmits<Emits>()

  const userStore = useUserStore()
  const { getUserInfo: userInfo } = storeToRefs(userStore)

  const dialogVisible = ref(false)

  // 表单数据
  const form = reactive({
    project_id: undefined as string | number | undefined,
    stage_id: undefined as string | number | undefined,
    category_id: undefined as string | number | undefined,
    status_id: undefined as string | number | undefined,
    name: '',
    description: '',
    priority_id: undefined as string | number | undefined,
    labels: [] as any[],
    due_at: undefined as string | undefined,
    start_at: undefined as string | undefined,
    is_star: false,
    is_public: false,
    executor_id: undefined as string | number | undefined,
    executor_name: '',
    executor_avatar: undefined as string | undefined
  })

  // 参与者列表
  const participants = ref<Array<{ id: string | number; name: string; avatar?: string }>>([])

  // 提醒设置
  const reminder = ref<string>('none') // none, before_1h, before_1d, etc.

  // 分类列表
  const categoryList = ref<Array<{ id: string | number; name: string }>>([])

  // 优先级列表
  const priorityList = ref<Array<{ id: string | number; name: string }>>([])

  // 状态列表
  const statusList = ref<Array<{ id: string | number; name: string }>>([])

  // 标签相关功能已移至 TagSelector 组件

  // 用户选择弹窗
  const executorSelectDialogVisible = ref(false)
  const participantSelectDialogVisible = ref(false)

  // 提醒文本
  const reminderText = computed(() => {
    const reminderMap: Record<string, string> = {
      none: '不提醒',
      before_1h: '截止前1小时',
      before_1d: '截止前1天',
      before_3d: '截止前3天'
    }
    return reminderMap[reminder.value] || '不提醒'
  })

  // 监听弹窗显示状态
  watch(
    () => props.modelValue,
    (newVal) => {
      dialogVisible.value = newVal
      if (newVal) {
        initForm()
        loadOptions()
      }
    },
    { immediate: true }
  )

  watch(dialogVisible, (newVal) => {
    emit('update:modelValue', newVal)
  })

  // 初始化表单
  const initForm = (): void => {
    form.project_id = props.projectId
    form.stage_id = props.stageId
    form.category_id = undefined
    form.status_id = undefined
    form.name = ''
    form.description = ''
    form.priority_id = undefined
    form.labels = []
    form.due_at = undefined
    form.start_at = undefined
    form.is_star = false
    form.is_public = false
    form.executor_id = undefined
    form.executor_name = ''
    form.executor_avatar = undefined
    reminder.value = 'none'

    // 默认添加当前用户到参与者列表
    const currentUser = userInfo.value as any
    if (currentUser && (currentUser.userId || currentUser.id)) {
      participants.value = [
        {
          id: currentUser.userId || currentUser.id,
          name: currentUser.userName || currentUser.name || currentUser.email || '当前用户',
          avatar: currentUser.avatar || currentUser.avatar_url
        }
      ]
    } else {
      participants.value = []
    }
  }

  // 标签相关功能已移至 TagSelector 组件

  // 加载选项数据
  const loadOptions = async (): Promise<void> => {
    try {
      // 加载分类列表
      const categoryRes = await listPropertyApi({ 'q[sign_eq]': 'task_category' })
      const categoryData = (categoryRes as any).data || []
      categoryList.value = Array.isArray(categoryData) ? categoryData : []

      // 加载优先级列表
      const priorityRes = await listPropertyApi({ 'q[sign_eq]': 'task_priority' })
      const priorityData = (priorityRes as any).data || []
      priorityList.value = Array.isArray(priorityData) ? priorityData : []

      // 加载状态列表
      const statusRes = await listPropertyApi({ 'q[sign_eq]': 'task_status' })
      const statusData = (statusRes as any).data || []
      statusList.value = Array.isArray(statusData) ? statusData : []

      // 标签列表由 TagSelector 组件管理，这里不再需要加载

      // 设置默认优先级
      if (priorityList.value.length > 0 && !form.priority_id) {
        form.priority_id = priorityList.value[0].id
      }
    } catch (error) {
      console.error('加载选项数据失败:', error)
    }
  }

  // 处理分类变化
  const handleCategoryChange = (categoryId: string | number): void => {
    form.category_id = categoryId
  }

  // 选择执行人
  const handleSelectExecutor = (): void => {
    executorSelectDialogVisible.value = true
  }

  // 执行人选择回调
  const handleExecutorSelect = (user: any): void => {
    form.executor_id = user.id
    form.executor_name = user.name || user.email
    form.executor_avatar = user.avatar || user.avatar_url
  }

  // 开始时间变化
  const handleStartDateChange = (): void => {
    // 可以在这里添加逻辑
  }

  // 截止时间变化
  const handleDueDateChange = (): void => {
    // 可以在这里添加逻辑
  }

  // 提醒点击
  const handleReminderClick = (): void => {
    // TODO: 实现提醒选择
    ElMessage.info('提醒功能待实现')
  }

  // 标签相关功能已移至 TagSelector 组件

  // 添加参与者
  const handleAddParticipant = (): void => {
    participantSelectDialogVisible.value = true
  }

  // 参与者选择回调
  const handleParticipantSelect = (users: any[]): void => {
    participants.value = users.map((user) => ({
      id: user.id,
      name: user.name || user.email,
      avatar: user.avatar || user.avatar_url
    }))
  }

  // 切换公开模式
  const handleTogglePublic = (): void => {
    form.is_public = !form.is_public
  }

  // 获取首字母
  const getInitials = (name?: string): string => {
    if (!name) return '?'
    return name.substring(0, 1).toUpperCase()
  }

  // 提交
  const handleSubmit = async (): Promise<void> => {
    if (!form.name?.trim()) {
      ElMessage.warning('请输入任务标题')
      return
    }

    if (!form.project_id) {
      ElMessage.warning('项目ID不存在')
      return
    }

    try {
      const params: any = {
        project_id: form.project_id,
        stage_id: form.stage_id,
        category_id: form.category_id,
        status_id: form.status_id,
        name: form.name.trim(),
        description: form.description,
        priority_id: form.priority_id,
        labels: form.labels.length > 0 ? JSON.stringify(form.labels) : undefined,
        due_at: form.due_at,
        start_at: form.start_at,
        is_star: form.is_star,
        is_public: form.is_public,
        executor_id: form.executor_id
      }

      // 移除 undefined 字段
      Object.keys(params).forEach((key) => {
        if (params[key] === undefined) {
          delete params[key]
        }
      })

      await createPmTaskApi(params)
      ElMessage.success('任务创建成功')
      dialogVisible.value = false
      emit('created')
    } catch (error: any) {
      console.error('创建任务失败:', error)
      const errorMessage = error?.response?.data?.message || error?.message || '创建任务失败'
      ElMessage.error(errorMessage)
    }
  }
</script>

<style scoped lang="scss">
  .task-dialog {
    :deep(.el-dialog__header) {
      padding: 20px 20px 10px;
    }

    :deep(.el-dialog__body) {
      padding: 20px;
    }

    :deep(.el-dialog__footer) {
      padding: 10px 20px 20px;
      border-top: 1px solid var(--el-border-color-lighter);
    }
  }

  .task-header {
    margin-bottom: 16px;
  }

  .task-type-selector {
    display: flex;
    gap: 8px;
    align-items: center;
  }

  .task-type-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    color: white;
    background: var(--el-color-primary);
    border-radius: 6px;

    .icon {
      font-size: 18px;
    }
  }

  .task-type-text {
    display: flex;
    gap: 4px;
    align-items: center;
    font-size: 14px;
    font-weight: 500;
    color: var(--el-text-color-primary);
    cursor: pointer;

    .dropdown-icon {
      font-size: 14px;
      color: var(--el-text-color-regular);
    }
  }

  .task-title-section {
    margin-bottom: 12px;
  }

  .task-title-input {
    :deep(.el-textarea__inner) {
      padding: 12px;
      font-size: 16px;
      line-height: 1.5;
      resize: vertical;
      border: 1px solid var(--el-border-color);
      border-radius: 6px;
    }
  }

  .task-attributes {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .attribute-item {
    display: flex;
    gap: 8px;
    align-items: center;
    padding: 4px 0;
    cursor: pointer;
    transition: color 0.2s;

    &:hover {
      color: var(--el-color-primary);
    }
  }

  .attribute-icon {
    display: flex;
    flex-shrink: 0;
    align-items: center;
    justify-content: center;
    width: 20px;
    height: 20px;
    font-size: 16px;
    color: var(--el-text-color-regular);
  }

  .executor-avatar {
    flex-shrink: 0;
    font-size: 10px;
    font-weight: 500;
    color: white;
    background-color: var(--el-color-primary);
  }

  .attribute-value {
    flex: 1;
    font-size: 14px;
    color: var(--el-text-color-primary);
  }

  .date-picker {
    flex: 1;
    max-width: 200px;
  }

  .priority-group {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
  }

  .priority-radio {
    margin-right: 0;
  }

  .participants-section {
    padding-top: 16px;
    margin-top: 16px;
    border-top: 1px solid var(--el-border-color-lighter);
  }

  .participants-header {
    margin-bottom: 12px;
  }

  .participants-label {
    font-size: 14px;
    font-weight: 500;
    color: var(--el-text-color-primary);
  }

  .participants-list {
    display: flex;
    gap: 8px;
    align-items: center;
  }

  .participant-avatar {
    font-size: 12px;
    font-weight: 500;
    color: white;
    background-color: #f3b16b;
  }

  .add-participant-btn {
    color: white;
    cursor: pointer;
    background-color: var(--el-color-primary);
    border: none;

    &:hover {
      background-color: var(--el-color-primary-light-3);
    }
  }

  .public-section {
    padding-top: 16px;
    margin-top: 16px;
    border-top: 1px solid var(--el-border-color-lighter);
  }

  .public-mode-item {
    display: flex;
    gap: 8px;
    align-items: center;
    cursor: pointer;
  }

  .public-icon {
    font-size: 16px;
    color: var(--el-text-color-regular);
  }

  .public-content {
    display: flex;
    flex-direction: column;
    gap: 2px;
  }

  .public-label {
    font-size: 14px;
    color: var(--el-text-color-primary);
  }

  .public-subtitle {
    font-size: 12px;
    color: var(--el-text-color-placeholder);
  }

  .dialog-footer {
    display: flex;
    gap: 12px;
    justify-content: flex-end;
    padding: 0;
  }

  .tags-display {
    width: 100%;
  }

  .tags-trigger {
    min-height: 24px;
    cursor: pointer;
  }

  .selected-tags {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
  }

  .tag-pill {
    display: inline-flex;
    gap: 4px;
    align-items: center;
    padding: 4px 12px;
    font-size: 12px;
    line-height: 1.5;
    border-radius: 12px;

    .tag-add-icon {
      font-size: 14px;
    }
  }

  .tag-pill-primary {
    color: var(--el-color-primary);
    background: var(--el-color-primary-light-9);
  }

  .tag-pill-success {
    color: var(--el-color-success);
    background: var(--el-color-success-light-9);
  }

  .tag-pill-info {
    color: var(--el-color-info);
    background: var(--el-color-info-light-9);
  }

  .tag-pill-warning {
    color: var(--el-color-warning);
    background: var(--el-color-warning-light-9);
  }

  .tag-pill-danger {
    color: var(--el-color-danger);
    background: var(--el-color-danger-light-9);
  }

  .tag-select-content {
    padding: 8px 0;
  }

  .tag-search-header {
    display: flex;
    gap: 8px;
    align-items: center;
    padding: 0 12px 8px;
    margin-bottom: 8px;
    border-bottom: 1px solid var(--el-border-color-lighter);
  }

  .tag-search-input {
    flex: 1;
  }

  .tag-add-btn {
    flex-shrink: 0;
  }

  .tag-list {
    max-height: 200px;
    overflow-y: auto;
  }

  .tag-item {
    display: flex;
    gap: 8px;
    align-items: center;
    padding: 8px 12px;
    cursor: pointer;
    transition: background-color 0.2s;

    &:hover {
      background-color: var(--el-fill-color-light);
    }
  }

  .tag-dot {
    flex-shrink: 0;
    width: 8px;
    height: 8px;
    border-radius: 50%;
  }

  .tag-dot-primary {
    background-color: var(--el-color-primary);
  }

  .tag-dot-success {
    background-color: var(--el-color-success);
  }

  .tag-dot-info {
    background-color: var(--el-color-info);
  }

  .tag-dot-warning {
    background-color: var(--el-color-warning);
  }

  .tag-dot-danger {
    background-color: var(--el-color-danger);
  }

  .tag-name {
    flex: 1;
    font-size: 14px;
    color: var(--el-text-color-primary);
  }

  .tag-check-icon {
    flex-shrink: 0;
    font-size: 16px;
    color: var(--el-text-color-regular);
  }

  .tag-empty {
    padding: 16px;
    font-size: 14px;
    color: var(--el-text-color-placeholder);
    text-align: center;
  }

  .create-tag-dialog {
    :deep(.el-dialog__header) {
      padding: 0;
    }

    :deep(.el-dialog__body) {
      padding: 20px;
    }

    :deep(.el-dialog__footer) {
      padding: 10px 20px 20px;
      border-top: 1px solid var(--el-border-color-lighter);
    }
  }

  .create-tag-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 20px;
    border-bottom: 1px solid var(--el-border-color-lighter);
  }

  .back-btn,
  .close-btn {
    padding: 4px;
    color: var(--el-text-color-regular);
  }

  .dialog-title {
    font-size: 16px;
    font-weight: 500;
    color: var(--el-text-color-primary);
  }

  .create-tag-content {
    display: flex;
    flex-direction: column;
    gap: 20px;
  }

  .tag-name-input {
    :deep(.el-input__wrapper) {
      border-radius: 6px;
    }
  }

  .color-selection {
    display: flex;
    gap: 12px;
    align-items: center;
  }

  .color-swatch {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 40px;
    height: 40px;
    cursor: pointer;
    border: 2px solid transparent;
    border-radius: 50%;
    transition: all 0.2s;

    &.color-primary {
      background-color: var(--el-color-primary);
    }

    &.color-success {
      background-color: var(--el-color-success);
    }

    &.color-info {
      background-color: var(--el-color-info);
    }

    &.color-warning {
      background-color: var(--el-color-warning);
    }

    &.color-danger {
      background-color: var(--el-color-danger);
    }

    &:hover {
      transform: scale(1.1);
    }

    &.selected {
      border-color: var(--el-color-primary);
      box-shadow: 0 0 0 2px rgb(64 158 255 / 20%);
    }
  }

  .color-check-icon {
    font-size: 20px;
    color: white;
    filter: drop-shadow(0 1px 2px rgb(0 0 0 / 30%));
  }

  .create-tag-btn {
    width: 100%;
  }
</style>

<style>
  .tag-select-popover {
    padding: 8px 0 !important;
  }
</style>
