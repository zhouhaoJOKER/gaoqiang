<!-- 工时录入弹窗 -->
<template>
  <ElDialog
    v-model="dialogVisible"
    :title="kind === 0 ? '计划工时录入' : '实际工时录入'"
    width="500px"
    :close-on-click-modal="false"
    @closed="handleDialogClosed"
  >
    <div class="work-hours-form">
      <!-- 任务时间 -->
      <div class="form-item">
        <div class="form-label">任务时间</div>
        <div class="form-value task-time-display">
          {{ formatTaskTime(taskStartAt) }} - {{ formatTaskTime(taskDueAt) }}
        </div>
      </div>

      <!-- 工时执行者 -->
      <div class="form-row">
        <div class="form-item flex-1">
          <div class="form-label">工时执行者</div>
          <div class="form-value executor-display" @click="handleSelectExecutor">
            <ElAvatar :size="24" class="executor-avatar">
              {{ getInitials(form.executor_name) }}
            </ElAvatar>
            <span>{{ form.executor_name || '选择执行者' }}</span>
          </div>
        </div>
        <div class="form-item flex-1">
          <div class="form-label">执行时间</div>
          <div class="form-value">
            <ElDatePicker
              v-model="form.date_range"
              type="daterange"
              range-separator="-"
              start-placeholder="开始日期"
              end-placeholder="结束日期"
              value-format="YYYY-MM-DD"
              class="date-range-picker"
            />
          </div>
        </div>
        <div class="form-item" style="width: 140px">
          <div class="form-label">工时标签</div>
          <div class="form-value">
            <ElPopover
              v-model:visible="tagPopoverVisible"
              placement="bottom-start"
              :width="200"
              trigger="click"
            >
              <template #reference>
                <div class="tag-select-btn">
                  <span
                    v-if="form.tag_id && form.tag_name"
                    class="selected-tag"
                    :style="getTagStyle(form.tag_color)"
                  >
                    {{ form.tag_name }}
                  </span>
                  <span v-else class="tag-placeholder">选择标签</span>
                  <ArtSvgIcon icon="ri:arrow-down-s-line" class="tag-arrow" />
                </div>
              </template>
              <div class="tag-options">
                <div
                  v-for="tag in tagList"
                  :key="tag.id"
                  class="tag-option"
                  :class="{ active: form.tag_id === tag.id }"
                  @click="handleSelectTag(tag)"
                >
                  <span
                    class="tag-color-dot"
                    :style="{ backgroundColor: getTagColor(tag.color) }"
                  ></span>
                  <span>{{ tag.name }}</span>
                </div>
                <div class="tag-option config-btn" @click="handleOpenTagConfig">
                  <ArtSvgIcon icon="ri:settings-3-line" class="config-icon" />
                  <span>配置标签</span>
                </div>
              </div>
            </ElPopover>
          </div>
        </div>
      </div>

      <!-- 计划工时数 -->
      <div class="form-item">
        <div class="form-label">{{ kind === 0 ? '计划工时数' : '实际工时数' }}</div>
        <div class="form-value hours-input-wrapper">
          <ElSelect v-model="form.hours_type" class="hours-type-select">
            <ElOption label="总计" value="total" />
            <ElOption label="每天" value="daily" />
          </ElSelect>
          <ElInputNumber
            v-model="form.hours"
            :min="0"
            :step="0.1"
            :precision="1"
            :placeholder="form.hours_type === 'total' ? '总工时（小时）' : '每日工时（小时）'"
            class="hours-input"
          />
          <span v-if="form.hours_type === 'daily' && form.hours" class="hours-total">
            = {{ calculateTotalHours }} 小时
          </span>
        </div>
      </div>

      <!-- 每日工时分配提示（仅总计模式显示） -->
      <div
        v-if="form.hours_type === 'total' && form.hours && dailyHoursDistribution.length > 0"
        class="form-item daily-hours-hint"
      >
        <div class="hint-content">
          <ArtSvgIcon icon="ri:information-line" class="hint-icon" />
          <span>每日工时数依次为{{ dailyHoursDistribution.join('、') }}</span>
        </div>
      </div>

      <!-- 包含休息日 -->
      <div class="form-item">
        <ElCheckbox v-model="form.include_weekend">包含休息日</ElCheckbox>
      </div>

      <!-- 工时描述（仅实际工时显示） -->
      <div v-if="kind === 1" class="form-item">
        <div class="form-label">工时描述（选填）</div>
        <div class="form-value">
          <ElInput
            v-model="form.description"
            type="textarea"
            :rows="3"
            placeholder="请输入工时描述..."
          />
        </div>
      </div>
    </div>

    <template #footer>
      <div class="dialog-footer">
        <ElButton @click="dialogVisible = false">取消</ElButton>
        <ElButton
          type="primary"
          :disabled="!form.hours"
          :loading="submitting"
          @click="handleSubmit"
        >
          提交
        </ElButton>
      </div>
    </template>
  </ElDialog>

  <!-- 执行者选择对话框 -->
  <UserSelectDialog
    v-model="executorDialogVisible"
    :multiple="false"
    @select="handleExecutorSelect"
  />

  <!-- 标签配置对话框 -->
  <PropertyConfigDialog
    v-model="tagConfigDialogVisible"
    sign="timesheet_tag"
    title="配置工时标签"
    @updated="handleTagConfigUpdated"
  />
</template>

<script setup lang="ts">
  import { ref, computed, watch, onMounted } from 'vue'
  import { ElMessage } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import UserSelectDialog from '@/components/UserSelectDialog.vue'
  import PropertyConfigDialog from '@/components/PropertyConfigDialog.vue'
  import { createPmTmApi } from '@/api/pm/project'
  import { listPropertyApi } from '@/api/property'

  interface Props {
    modelValue: boolean
    kind: number // 0: 计划工时, 1: 实际工时
    taskId: string | number
    projectId?: string | number
    taskStartAt?: string
    taskDueAt?: string
    defaultExecutorId?: string | number
    defaultExecutorName?: string
  }

  const props = withDefaults(defineProps<Props>(), {
    kind: 0,
    projectId: undefined,
    taskStartAt: undefined,
    taskDueAt: undefined,
    defaultExecutorId: undefined,
    defaultExecutorName: ''
  })

  const emit = defineEmits<{
    (e: 'update:modelValue', value: boolean): void
    (e: 'success'): void
  }>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const executorDialogVisible = ref(false)
  const submitting = ref(false)
  const tagPopoverVisible = ref(false)
  const tagConfigDialogVisible = ref(false)
  const tagList = ref<any[]>([])

  const form = ref({
    executor_id: undefined as string | number | undefined,
    executor_name: '',
    date_range: [] as string[],
    include_weekend: false,
    hours_type: 'total',
    hours: undefined as number | undefined,
    tag_id: undefined as string | number | undefined,
    tag_name: '',
    tag_color: '',
    description: ''
  })

  // 初始化表单
  const initForm = (): void => {
    form.value = {
      executor_id: props.defaultExecutorId,
      executor_name: props.defaultExecutorName,
      date_range:
        props.taskStartAt && props.taskDueAt
          ? [props.taskStartAt.split(' ')[0], props.taskDueAt.split(' ')[0]]
          : [],
      include_weekend: false,
      hours_type: 'total',
      hours: undefined,
      tag_id: undefined,
      tag_name: '',
      tag_color: '',
      description: ''
    }
  }

  // 加载工时标签列表
  const loadTagList = async (): Promise<void> => {
    try {
      const res = await listPropertyApi({ 'q[sign_eq]': 'timesheet_tag' })
      const data = (res as any).data || []
      tagList.value = Array.isArray(data) ? data : []
    } catch (error) {
      console.error('加载工时标签失败:', error)
    }
  }

  // 获取标签颜色
  const getTagColor = (color: string): string => {
    if (!color || color === 'noset') return 'var(--el-text-color-placeholder)'
    if (color.startsWith('--')) return `var(${color})`
    if (color.startsWith('#') || color.startsWith('rgb')) return color
    return `var(--el-color-${color})`
  }

  // 获取标签样式
  const getTagStyle = (color: string): Record<string, string> => {
    const token = (color || 'primary').toLowerCase()
    if (token === 'noset') {
      return {
        backgroundColor: 'var(--el-fill-color-light)',
        color: 'var(--el-text-color-regular)'
      }
    }
    return {
      backgroundColor: `var(--el-color-${token}-light-9)`,
      color: `var(--el-color-${token})`
    }
  }

  // 选择标签
  const handleSelectTag = (tag: any): void => {
    form.value.tag_id = tag.id
    form.value.tag_name = tag.name
    form.value.tag_color = tag.color
    tagPopoverVisible.value = false
  }

  // 打开标签配置
  const handleOpenTagConfig = (): void => {
    tagPopoverVisible.value = false
    tagConfigDialogVisible.value = true
  }

  // 标签配置更新回调
  const handleTagConfigUpdated = (): void => {
    loadTagList()
  }

  // 格式化任务时间
  const formatTaskTime = (time: string | undefined): string => {
    if (!time) return '--'
    const date = new Date(time)
    return `${date.getMonth() + 1}月${date.getDate()}日 ${String(date.getHours()).padStart(2, '0')}:${String(date.getMinutes()).padStart(2, '0')}`
  }

  // 获取姓名首字母
  const getInitials = (name: string): string => {
    if (!name) return '?'
    return name.charAt(0).toUpperCase()
  }

  // 计算日期范围内的工作日数
  const getWorkDaysCount = (): number => {
    if (!form.value.date_range || form.value.date_range.length < 2) {
      return 0
    }
    const startDate = new Date(form.value.date_range[0])
    const endDate = new Date(form.value.date_range[1])
    let count = 0

    const current = new Date(startDate)
    while (current <= endDate) {
      const dayOfWeek = current.getDay()
      if (form.value.include_weekend || (dayOfWeek !== 0 && dayOfWeek !== 6)) {
        count++
      }
      current.setDate(current.getDate() + 1)
    }
    return count
  }

  // 获取工作日列表
  const getWorkDaysList = (): string[] => {
    if (!form.value.date_range || form.value.date_range.length < 2) {
      return []
    }
    const startDate = new Date(form.value.date_range[0])
    const endDate = new Date(form.value.date_range[1])
    const days: string[] = []

    const current = new Date(startDate)
    while (current <= endDate) {
      const dayOfWeek = current.getDay()
      if (form.value.include_weekend || (dayOfWeek !== 0 && dayOfWeek !== 6)) {
        const year = current.getFullYear()
        const month = String(current.getMonth() + 1).padStart(2, '0')
        const day = String(current.getDate()).padStart(2, '0')
        days.push(`${year}-${month}-${day}`)
      }
      current.setDate(current.getDate() + 1)
    }
    return days
  }

  // 每日工时分配（总计模式）
  const dailyHoursDistribution = computed((): string[] => {
    if (form.value.hours_type !== 'total' || !form.value.hours) {
      return []
    }
    const days = getWorkDaysCount()
    if (days === 0) return []

    const totalHours = form.value.hours
    const avgHours = totalHours / days
    const result: string[] = []

    let remaining = totalHours
    for (let i = 0; i < days; i++) {
      if (i === days - 1) {
        result.push(remaining.toFixed(1) + '小时')
      } else {
        const dailyHours = Math.round(avgHours * 10) / 10
        result.push(dailyHours.toFixed(1) + '小时')
        remaining -= dailyHours
      }
    }
    return result
  })

  // 合计工时（每天模式）
  const calculateTotalHours = computed((): string => {
    if (form.value.hours_type !== 'daily' || !form.value.hours) {
      return '0'
    }
    const days = getWorkDaysCount()
    const total = form.value.hours * days
    return total.toFixed(1)
  })

  // 选择执行者
  const handleSelectExecutor = (): void => {
    executorDialogVisible.value = true
  }

  // 执行者选择回调
  const handleExecutorSelect = (users: any[]): void => {
    if (users.length > 0) {
      form.value.executor_id = users[0].id
      form.value.executor_name = users[0].name || users[0].email
    }
  }

  // 提交工时
  const handleSubmit = async (): Promise<void> => {
    if (!props.taskId || !form.value.hours) return
    if (!form.value.date_range || form.value.date_range.length < 2) {
      ElMessage.warning('请选择执行时间')
      return
    }
    if (!form.value.executor_id) {
      ElMessage.warning('请选择工时执行者')
      return
    }

    submitting.value = true
    try {
      const workDays = getWorkDaysList()
      if (workDays.length === 0) {
        ElMessage.warning('选择的日期范围内没有工作日')
        return
      }

      // 计算每日工时
      let dailyHoursArray: number[] = []
      const totalDays = workDays.length

      if (form.value.hours_type === 'total') {
        const totalHours = form.value.hours
        const avgHours = totalHours / totalDays
        let remaining = totalHours

        for (let i = 0; i < totalDays; i++) {
          if (i === totalDays - 1) {
            dailyHoursArray.push(Math.round(remaining * 10) / 10)
          } else {
            const daily = Math.round(avgHours * 10) / 10
            dailyHoursArray.push(daily)
            remaining -= daily
          }
        }
      } else {
        const dailyHours = form.value.hours
        dailyHoursArray = workDays.map(() => dailyHours)
      }

      // 构建工时记录数组
      const timesheets = workDays.map((date, index) => {
        const entry: Record<string, any> = {
          kind: props.kind,
          project_id: props.projectId,
          task_id: props.taskId,
          user_id: form.value.executor_id,
          date: date,
          time: dailyHoursArray[index]
        }
        // 添加标签
        if (form.value.tag_id) {
          entry.property_id = form.value.tag_id
        }
        // 实际工时添加描述
        if (props.kind === 1 && form.value.description) {
          entry.description = form.value.description
        }
        return entry
      })

      await createPmTmApi({ timesheets })

      ElMessage.success('工时录入成功')
      dialogVisible.value = false
      emit('success')
    } catch (error) {
      console.error('工时录入失败:', error)
      ElMessage.error('工时录入失败')
    } finally {
      submitting.value = false
    }
  }

  const handleDialogClosed = (): void => {
    form.value = {
      executor_id: undefined,
      executor_name: '',
      date_range: [],
      include_weekend: false,
      hours_type: 'total',
      hours: undefined,
      tag_id: undefined,
      tag_name: '',
      tag_color: '',
      description: ''
    }
  }

  // 监听弹窗打开，初始化表单
  watch(
    () => props.modelValue,
    (val) => {
      if (val) {
        initForm()
        if (tagList.value.length === 0) {
          loadTagList()
        }
      }
    }
  )

  onMounted(() => {
    loadTagList()
  })
</script>

<style scoped lang="scss">
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

    .flex-1 {
      flex: 1;
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
      width: 100%;
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

    .tag-select-btn {
      display: flex;
      gap: 4px;
      align-items: center;
      min-height: 40px;
      padding: 8px 12px;
      cursor: pointer;
      border: 1px solid var(--el-border-color);
      border-radius: 6px;

      &:hover {
        border-color: var(--el-color-primary);
      }

      .tag-placeholder {
        font-size: 14px;
        color: var(--el-text-color-placeholder);
      }

      .selected-tag {
        padding: 2px 8px;
        font-size: 13px;
        border-radius: 4px;
      }

      .tag-arrow {
        margin-left: auto;
        color: var(--el-text-color-placeholder);
      }
    }

    .tag-options {
      max-height: 240px;
      overflow-y: auto;

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

        &.active {
          color: var(--el-color-primary);
          background: var(--el-color-primary-light-9);
        }

        &.config-btn {
          padding-top: 12px;
          margin-top: 8px;
          color: var(--el-text-color-secondary);
          border-top: 1px solid var(--el-border-color-lighter);

          .config-icon {
            font-size: 16px;
          }
        }

        .tag-color-dot {
          flex-shrink: 0;
          width: 12px;
          height: 12px;
          border-radius: 50%;
        }
      }
    }
  }

  .dialog-footer {
    display: flex;
    gap: 12px;
    justify-content: flex-end;
  }
</style>
