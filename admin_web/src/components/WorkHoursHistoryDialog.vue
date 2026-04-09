<!-- 工时历史弹窗 -->
<template>
  <ElDialog v-model="dialogVisible" title="工时记录" width="700px" :close-on-click-modal="false">
    <div class="work-hours-history">
      <!-- 加载状态 -->
      <div v-if="loading" class="loading-wrapper">
        <ElIcon class="loading-icon"><Loading /></ElIcon>
        <span>加载中...</span>
      </div>

      <!-- 空状态 -->
      <div v-else-if="timesheets.length === 0" class="empty-wrapper">
        <ArtSvgIcon icon="ri:calendar-schedule-line" class="empty-icon" />
        <span>暂无工时记录</span>
      </div>

      <!-- 工时列表 -->
      <div v-else class="timesheet-list">
        <div v-for="item in timesheets" :key="item.id" class="timesheet-item">
          <div class="timesheet-left">
            <ElAvatar :size="36" class="user-avatar">
              {{ getInitials(item.user_name) }}
            </ElAvatar>
            <div class="timesheet-info">
              <div class="info-row">
                <span class="user-name">{{ item.user_name }}</span>
                <span class="timesheet-date">{{ formatDate(item.date) }}</span>
                <ElTag :type="item.kind === 0 ? 'primary' : 'success'" size="small">
                  {{ item.kind === 0 ? '计划' : '实际' }}
                </ElTag>
              </div>
              <div class="time-row">
                <span class="time-label">工时：</span>
                <ElInputNumber
                  v-if="editingId === item.id"
                  v-model="editingTime"
                  :min="0"
                  :step="0.1"
                  :precision="1"
                  size="small"
                  class="time-input"
                />
                <span v-else class="time-value">{{ item.time }} 小时</span>
              </div>
            </div>
          </div>
          <div class="timesheet-actions">
            <template v-if="editingId === item.id">
              <ElButton size="small" @click="handleCancelEdit">取消</ElButton>
              <ElButton type="primary" size="small" :loading="saving" @click="handleSaveEdit(item)">
                保存
              </ElButton>
            </template>
            <template v-else>
              <ElButton text size="small" @click="handleEdit(item)">
                <ArtSvgIcon icon="ri:edit-line" />
              </ElButton>
              <ElButton text size="small" class="delete-btn" @click="handleDelete(item)">
                <ArtSvgIcon icon="ri:delete-bin-line" />
              </ElButton>
            </template>
          </div>
        </div>
      </div>

      <!-- 统计信息 -->
      <div v-if="timesheets.length > 0" class="summary-section">
        <div class="summary-item">
          <span class="summary-label">计划工时合计：</span>
          <span class="summary-value">{{ planTimeTotal }} 小时</span>
        </div>
        <div class="summary-item">
          <span class="summary-label">实际工时合计：</span>
          <span class="summary-value">{{ realTimeTotal }} 小时</span>
        </div>
      </div>
    </div>

    <template #footer>
      <div class="dialog-footer">
        <ElButton @click="dialogVisible = false">关闭</ElButton>
      </div>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, computed, watch } from 'vue'
  import { ElMessage, ElMessageBox, ElIcon, ElTag } from 'element-plus'
  import { Loading } from '@element-plus/icons-vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { listPmTmApi, updatePmTmApi, deletePmTmApi } from '@/api/pm/project'

  interface TimesheetItem {
    id: string | number
    kind: number // 0: 计划, 1: 实际
    user_id: string | number
    user_name: string
    date: string
    time: number
    [key: string]: any
  }

  interface Props {
    modelValue: boolean
    taskId: string | number
    kind?: number // 0: 计划工时, 1: 实际工时, undefined: 全部
  }

  const props = withDefaults(defineProps<Props>(), {
    kind: undefined
  })

  const emit = defineEmits<{
    (e: 'update:modelValue', value: boolean): void
    (e: 'updated'): void
  }>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const loading = ref(false)
  const saving = ref(false)
  const timesheets = ref<TimesheetItem[]>([])
  const editingId = ref<string | number | null>(null)
  const editingTime = ref<number>(0)

  // 计划工时合计
  const planTimeTotal = computed((): string => {
    const total = timesheets.value
      .filter((t) => t.kind === 0)
      .reduce((sum, t) => sum + (Number(t.time) || 0), 0)
    return total.toFixed(1)
  })

  // 实际工时合计
  const realTimeTotal = computed((): string => {
    const total = timesheets.value
      .filter((t) => t.kind === 1)
      .reduce((sum, t) => sum + (Number(t.time) || 0), 0)
    return total.toFixed(1)
  })

  // 获取姓名首字母
  const getInitials = (name: string): string => {
    if (!name) return '?'
    return name.charAt(0).toUpperCase()
  }

  // 格式化日期
  const formatDate = (date: string): string => {
    if (!date) return '--'
    const d = new Date(date)
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`
  }

  // 加载工时记录
  const loadTimesheets = async (): Promise<void> => {
    if (!props.taskId) return
    loading.value = true
    try {
      const params: Record<string, any> = { 'q[task_id_eq]': props.taskId }
      // 如果传入了 kind，则按 kind 过滤
      if (props.kind !== undefined) {
        params['q[kind_eq]'] = props.kind
      }
      const res = await listPmTmApi(params)
      const data = (res as any).data || []
      timesheets.value = Array.isArray(data) ? data : []
    } catch (error) {
      console.error('加载工时记录失败:', error)
      ElMessage.error('加载工时记录失败')
    } finally {
      loading.value = false
    }
  }

  // 开始编辑
  const handleEdit = (item: TimesheetItem): void => {
    editingId.value = item.id
    editingTime.value = item.time
  }

  // 取消编辑
  const handleCancelEdit = (): void => {
    editingId.value = null
    editingTime.value = 0
  }

  // 保存编辑
  const handleSaveEdit = async (item: TimesheetItem): Promise<void> => {
    if (editingTime.value < 0) {
      ElMessage.warning('工时不能为负数')
      return
    }
    saving.value = true
    try {
      await updatePmTmApi(String(item.id), { time: editingTime.value })
      ElMessage.success('工时更新成功')
      item.time = editingTime.value
      editingId.value = null
      emit('updated')
    } catch (error) {
      console.error('更新工时失败:', error)
      ElMessage.error('更新工时失败')
    } finally {
      saving.value = false
    }
  }

  // 删除工时记录
  const handleDelete = async (item: TimesheetItem): Promise<void> => {
    try {
      await ElMessageBox.confirm(
        `确定要删除 ${item.user_name} 在 ${formatDate(item.date)} 的工时记录吗？`,
        '确认删除',
        {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning'
        }
      )
      await deletePmTmApi(Number(item.id))
      ElMessage.success('工时记录已删除')
      // 从列表中移除
      const index = timesheets.value.findIndex((t) => t.id === item.id)
      if (index >= 0) {
        timesheets.value.splice(index, 1)
      }
      emit('updated')
    } catch (error: any) {
      if (error === 'cancel') return
      console.error('删除工时记录失败:', error)
      ElMessage.error('删除工时记录失败')
    }
  }

  // 监听弹窗打开，加载数据
  watch(
    () => props.modelValue,
    (val) => {
      if (val) {
        loadTimesheets()
      } else {
        // 关闭时重置状态
        editingId.value = null
        editingTime.value = 0
      }
    }
  )
</script>

<style scoped lang="scss">
  .work-hours-history {
    min-height: 200px;

    .loading-wrapper,
    .empty-wrapper {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 60px 0;
      color: var(--el-text-color-placeholder);

      .loading-icon {
        margin-bottom: 12px;
        font-size: 32px;
        animation: rotate 1s linear infinite;
      }

      .empty-icon {
        margin-bottom: 12px;
        font-size: 48px;
      }
    }

    @keyframes rotate {
      from {
        transform: rotate(0deg);
      }

      to {
        transform: rotate(360deg);
      }
    }

    .timesheet-list {
      max-height: 400px;
      overflow-y: auto;

      .timesheet-item {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 16px;
        margin-bottom: 8px;
        background: var(--el-fill-color-light);
        border-radius: 8px;
        transition: all 0.2s;

        &:hover {
          background: var(--el-fill-color);
        }

        &:last-child {
          margin-bottom: 0;
        }
      }

      .timesheet-left {
        display: flex;
        flex: 1;
        gap: 12px;
        align-items: center;
      }

      .user-avatar {
        flex-shrink: 0;
        font-size: 14px;
        color: #fff;
        background: var(--el-color-warning);
      }

      .timesheet-info {
        flex: 1;

        .info-row {
          display: flex;
          gap: 12px;
          align-items: center;
          margin-bottom: 4px;

          .user-name {
            font-weight: 500;
            color: var(--el-text-color-primary);
          }

          .timesheet-date {
            font-size: 13px;
            color: var(--el-text-color-regular);
          }
        }

        .time-row {
          display: flex;
          gap: 8px;
          align-items: center;
          font-size: 14px;

          .time-label {
            color: var(--el-text-color-secondary);
          }

          .time-value {
            font-weight: 500;
            color: var(--el-text-color-primary);
          }

          .time-input {
            width: 100px;
          }
        }
      }

      .timesheet-actions {
        display: flex;
        gap: 8px;
        align-items: center;

        .delete-btn:hover {
          color: var(--el-color-danger);
        }
      }
    }

    .summary-section {
      display: flex;
      gap: 32px;
      justify-content: flex-end;
      padding-top: 16px;
      margin-top: 20px;
      border-top: 1px solid var(--el-border-color-lighter);

      .summary-item {
        display: flex;
        gap: 8px;
        align-items: center;

        .summary-label {
          font-size: 14px;
          color: var(--el-text-color-secondary);
        }

        .summary-value {
          font-size: 16px;
          font-weight: 600;
          color: var(--el-color-primary);
        }
      }
    }
  }

  .dialog-footer {
    display: flex;
    justify-content: flex-end;
  }
</style>
