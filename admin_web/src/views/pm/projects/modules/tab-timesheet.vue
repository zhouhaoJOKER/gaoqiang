<!-- 工时页签 -->
<template>
  <div class="timesheet-container">
    <!-- 统计卡片 -->
    <div class="stats-cards">
      <div class="stat-card">
        <div class="stat-icon plan">
          <ArtSvgIcon icon="ri:time-line" />
        </div>
        <div class="stat-info">
          <div class="stat-value">{{ formatHours(stats.planTotal) }}</div>
          <div class="stat-label">计划工时</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon actual">
          <ArtSvgIcon icon="ri:timer-line" />
        </div>
        <div class="stat-info">
          <div class="stat-value">{{ formatHours(stats.actualTotal) }}</div>
          <div class="stat-label">实际工时</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon progress">
          <ArtSvgIcon icon="ri:pie-chart-line" />
        </div>
        <div class="stat-info">
          <div class="stat-value">{{ stats.progress }}%</div>
          <div class="stat-label">完成进度</div>
        </div>
      </div>
      <div class="stat-card">
        <div class="stat-icon members">
          <ArtSvgIcon icon="ri:team-line" />
        </div>
        <div class="stat-info">
          <div class="stat-value">{{ stats.memberCount }}</div>
          <div class="stat-label">参与人数</div>
        </div>
      </div>
    </div>

    <!-- 工具栏 -->
    <div class="timesheet-toolbar">
      <div class="toolbar-left">
        <ElDatePicker
          v-model="dateRange"
          type="daterange"
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          value-format="YYYY-MM-DD"
          @change="handleDateChange"
        />
        <ElSelect v-model="filterKind" placeholder="工时类型" clearable @change="loadTimesheets">
          <ElOption label="全部" value="" />
          <ElOption label="计划工时" :value="0" />
          <ElOption label="实际工时" :value="1" />
        </ElSelect>
        <ElSelect v-model="filterUserId" placeholder="成员" clearable @change="loadTimesheets">
          <ElOption
            v-for="member in memberList"
            :key="member.id"
            :label="member.name"
            :value="member.id"
          />
        </ElSelect>
      </div>
      <div class="toolbar-right">
        <ElButton type="primary" @click="handleExport">
          <ArtSvgIcon icon="ri:download-line" class="mr-1" />
          导出
        </ElButton>
      </div>
    </div>

    <!-- 工时列表 -->
    <div class="timesheet-list">
      <ElTable :data="timesheetList" style="width: 100%" v-loading="loading">
        <ElTableColumn prop="date" label="日期" width="120">
          <template #default="{ row }">
            {{ formatDate(row.date) }}
          </template>
        </ElTableColumn>
        <ElTableColumn prop="user_name" label="成员" width="120">
          <template #default="{ row }">
            <div class="user-cell">
              <div class="user-avatar">
                {{ getInitials(row.user_name) }}
              </div>
              <span>{{ row.user_name || '-' }}</span>
            </div>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="task_name" label="任务" min-width="200">
          <template #default="{ row }">
            <span class="task-link" @click="handleViewTask(row)">
              {{ row.task_name || '-' }}
            </span>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="kind" label="类型" width="100">
          <template #default="{ row }">
            <ElTag :type="row.kind === 0 ? 'info' : 'success'" size="small">
              {{ row.kind === 0 ? '计划' : '实际' }}
            </ElTag>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="time" label="工时(小时)" width="120" align="right">
          <template #default="{ row }">
            <span class="time-value">{{ formatHours(row.time) }}</span>
          </template>
        </ElTableColumn>
        <ElTableColumn prop="description" label="说明" min-width="150">
          <template #default="{ row }">
            {{ row.description || '-' }}
          </template>
        </ElTableColumn>
        <ElTableColumn prop="created_at" label="记录时间" width="160">
          <template #default="{ row }">
            {{ formatDateTime(row.created_at) }}
          </template>
        </ElTableColumn>
        <ElTableColumn fixed="right" width="100">
          <template #default="{ row }">
            <ElButton text size="small" @click="handleEdit(row)">
              <ArtSvgIcon icon="ri:edit-line" />
            </ElButton>
            <ElButton text size="small" type="danger" @click="handleDelete(row)">
              <ArtSvgIcon icon="ri:delete-bin-line" />
            </ElButton>
          </template>
        </ElTableColumn>
      </ElTable>

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <ElPagination
          v-model:current-page="pagination.page"
          v-model:page-size="pagination.pageSize"
          :total="pagination.total"
          :page-sizes="[20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="loadTimesheets"
          @current-change="loadTimesheets"
        />
      </div>
    </div>

    <!-- 编辑弹窗 -->
    <ElDialog v-model="editDialogVisible" title="编辑工时" width="500px">
      <ElForm :model="editForm" label-width="80px">
        <ElFormItem label="日期">
          <ElDatePicker
            v-model="editForm.date"
            type="date"
            placeholder="选择日期"
            value-format="YYYY-MM-DD"
            style="width: 100%"
          />
        </ElFormItem>
        <ElFormItem label="工时类型">
          <ElRadioGroup v-model="editForm.kind">
            <ElRadio :value="0">计划工时</ElRadio>
            <ElRadio :value="1">实际工时</ElRadio>
          </ElRadioGroup>
        </ElFormItem>
        <ElFormItem label="工时">
          <ElInputNumber
            v-model="editForm.time"
            :min="0"
            :max="24"
            :step="0.1"
            :precision="1"
            style="width: 100%"
          />
        </ElFormItem>
        <ElFormItem label="说明">
          <ElInput
            v-model="editForm.description"
            type="textarea"
            :rows="3"
            placeholder="请输入说明"
          />
        </ElFormItem>
      </ElForm>
      <template #footer>
        <ElButton @click="editDialogVisible = false">取消</ElButton>
        <ElButton type="primary" :loading="saving" @click="handleSaveEdit"> 保存 </ElButton>
      </template>
    </ElDialog>
  </div>
</template>

<script setup lang="ts">
  import { ref, reactive, computed, onMounted, inject, watch } from 'vue'
  import { useRouter } from 'vue-router'
  import { ElMessage, ElMessageBox } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { listPmTmApi, updatePmTmApi, deletePmTmApi } from '@/api/pm/project'

  interface TimesheetItem {
    id: string | number
    date: string
    user_id?: string | number
    user_name?: string
    task_id?: string | number
    task_name?: string
    kind: number // 0: 计划, 1: 实际
    time: number
    description?: string
    created_at?: string
    [key: string]: any
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
  const saving = ref(false)
  const timesheetList = ref<TimesheetItem[]>([])
  const memberList = ref<MemberItem[]>([])

  // 筛选条件
  const dateRange = ref<[string, string] | null>(null)
  const filterKind = ref<number | string>('')
  const filterUserId = ref<string | number | null>(null)

  // 分页
  const pagination = reactive({
    page: 1,
    pageSize: 20,
    total: 0
  })

  // 统计数据
  const stats = computed(() => {
    let planTotal = 0
    let actualTotal = 0
    const userSet = new Set()

    timesheetList.value.forEach((item) => {
      if (item.kind === 0) {
        planTotal += Number(item.time) || 0
      } else {
        actualTotal += Number(item.time) || 0
      }
      if (item.user_id) {
        userSet.add(item.user_id)
      }
    })

    const progress = planTotal > 0 ? Math.min(100, Math.round((actualTotal / planTotal) * 100)) : 0

    return {
      planTotal,
      actualTotal,
      progress,
      memberCount: userSet.size
    }
  })

  // 编辑弹窗
  const editDialogVisible = ref(false)
  const editForm = reactive({
    id: null as string | number | null,
    date: '',
    kind: 0,
    time: 0,
    description: ''
  })

  /**
   * 加载工时列表
   */
  const loadTimesheets = async (): Promise<void> => {
    if (!projectData?.id) return
    loading.value = true
    try {
      const params: any = {
        'q[project_id_eq]': projectData.id,
        page: pagination.page,
        per_page: pagination.pageSize
      }

      if (dateRange.value && dateRange.value[0] && dateRange.value[1]) {
        params['q[date_gteq]'] = dateRange.value[0]
        params['q[date_lteq]'] = dateRange.value[1]
      }

      if (filterKind.value !== '') {
        params['q[kind_eq]'] = filterKind.value
      }

      if (filterUserId.value) {
        params['q[user_id_eq]'] = filterUserId.value
      }

      const res = await listPmTmApi(params)
      const data = (res as any).data || []
      timesheetList.value = Array.isArray(data) ? data : []
      pagination.total = (res as any).total || data.length

      // 提取成员列表
      const members = new Map()
      timesheetList.value.forEach((item) => {
        if (item.user_id && item.user_name) {
          members.set(item.user_id, { id: item.user_id, name: item.user_name })
        }
      })
      memberList.value = Array.from(members.values())
    } catch (error) {
      console.error('加载工时失败:', error)
      ElMessage.error('加载工时失败')
    } finally {
      loading.value = false
    }
  }

  /**
   * 日期范围变化
   */
  const handleDateChange = (): void => {
    pagination.page = 1
    loadTimesheets()
  }

  /**
   * 查看任务
   */
  const handleViewTask = (row: TimesheetItem): void => {
    if (row.task_id) {
      router.push({ name: 'TaskDetail', params: { id: row.task_id } })
    }
  }

  /**
   * 编辑工时
   */
  const handleEdit = (row: TimesheetItem): void => {
    editForm.id = row.id
    editForm.date = row.date
    editForm.kind = row.kind
    editForm.time = row.time
    editForm.description = row.description || ''
    editDialogVisible.value = true
  }

  /**
   * 保存编辑
   */
  const handleSaveEdit = async (): Promise<void> => {
    if (!editForm.date) {
      ElMessage.warning('请选择日期')
      return
    }

    saving.value = true
    try {
      await updatePmTmApi(String(editForm.id), {
        date: editForm.date,
        kind: editForm.kind,
        time: editForm.time,
        description: editForm.description
      })
      ElMessage.success('保存成功')
      editDialogVisible.value = false
      await loadTimesheets()
    } catch (error) {
      console.error('保存失败:', error)
      ElMessage.error('保存失败')
    } finally {
      saving.value = false
    }
  }

  /**
   * 删除工时
   */
  const handleDelete = async (row: TimesheetItem): Promise<void> => {
    try {
      await ElMessageBox.confirm('确定要删除这条工时记录吗？', '确认删除', {
        type: 'warning'
      })
      await deletePmTmApi(Number(row.id))
      ElMessage.success('删除成功')
      await loadTimesheets()
    } catch (error: any) {
      if (error !== 'cancel') {
        ElMessage.error('删除失败')
      }
    }
  }

  /**
   * 导出工时
   */
  const handleExport = (): void => {
    ElMessage.info('导出功能开发中')
  }

  /**
   * 格式化工时
   */
  const formatHours = (hours: number | undefined): string => {
    if (hours === undefined || hours === null) return '0'
    return Number(hours).toFixed(1)
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
   * 格式化日期时间
   */
  const formatDateTime = (datetime?: string): string => {
    if (!datetime) return '-'
    const d = new Date(datetime)
    const year = d.getFullYear()
    const month = String(d.getMonth() + 1).padStart(2, '0')
    const day = String(d.getDate()).padStart(2, '0')
    const hours = String(d.getHours()).padStart(2, '0')
    const minutes = String(d.getMinutes()).padStart(2, '0')
    return `${year}-${month}-${day} ${hours}:${minutes}`
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
    loadTimesheets()
  })

  // 监听项目数据变化，确保刷新时能加载数据
  watch(
    () => projectData?.id,
    (newId) => {
      if (newId) {
        loadTimesheets()
      }
    },
    { immediate: true }
  )
</script>

<style scoped lang="scss">
  @reference '@styles/core/tailwind.css';

  .timesheet-container {
    display: flex;
    flex-direction: column;
    height: 100%;
    overflow: hidden;
    background: #fff;
    border-radius: 8px;
  }

  .stats-cards {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 16px;
    padding: 20px;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  }

  .stat-card {
    display: flex;
    gap: 16px;
    align-items: center;
    padding: 16px 20px;
    background: rgb(255 255 255 / 15%);
    backdrop-filter: blur(10px);
    border-radius: 12px;
  }

  .stat-icon {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 48px;
    height: 48px;
    font-size: 24px;
    color: #fff;
    border-radius: 12px;

    &.plan {
      background: rgb(255 255 255 / 20%);
    }

    &.actual {
      background: rgb(255 255 255 / 20%);
    }

    &.progress {
      background: rgb(255 255 255 / 20%);
    }

    &.members {
      background: rgb(255 255 255 / 20%);
    }
  }

  .stat-info {
    .stat-value {
      font-size: 24px;
      font-weight: 600;
      line-height: 1.2;
      color: #fff;
    }

    .stat-label {
      margin-top: 4px;
      font-size: 13px;
      color: rgb(255 255 255 / 80%);
    }
  }

  .timesheet-toolbar {
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

  .timesheet-list {
    display: flex;
    flex: 1;
    flex-direction: column;
    overflow: hidden;

    .el-table {
      flex: 1;
    }
  }

  .user-cell {
    display: flex;
    gap: 8px;
    align-items: center;
  }

  .user-avatar {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 28px;
    height: 28px;
    font-size: 12px;
    font-weight: 500;
    color: #fff;
    background: var(--el-color-primary);
    border-radius: 50%;
  }

  .task-link {
    color: var(--el-color-primary);
    cursor: pointer;

    &:hover {
      text-decoration: underline;
    }
  }

  .time-value {
    font-weight: 500;
    color: var(--el-text-color-primary);
  }

  .pagination-wrapper {
    display: flex;
    justify-content: flex-end;
    padding: 16px 20px;
    border-top: 1px solid var(--el-border-color-lighter);
  }
</style>
