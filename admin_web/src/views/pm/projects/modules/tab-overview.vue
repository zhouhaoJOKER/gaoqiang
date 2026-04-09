<!-- 项目概览 -->
<template>
  <div class="tab-overview">
    <!-- 项目状态 -->
    <ElCard class="status-card" shadow="never">
      <div class="card-header">
        <span class="card-title">项目状态</span>
      </div>
      <el-divider />
      <div class="status-display-new">
        <ElDropdown
          v-if="selectedStatus"
          @command="handleStatusCommand"
          placement="bottom-start"
          popper-class="status-selector-popper"
        >
          <span
            class="status-text-highlight cursor-pointer hover:opacity-80 transition-opacity"
            :style="getStatusHighlightStyle(selectedStatus)"
          >
            {{ selectedStatus.name }}
            <ElIcon class="el-icon--right"><ArrowDown /></ElIcon>
          </span>
          <template #dropdown>
            <ElDropdownMenu>
              <ElDropdownItem
                v-for="status in statusList"
                :key="status.id"
                :command="status.id"
                :class="{ 'is-selected': selectedStatusId === status.id }"
              >
                <div class="flex items-center gap-2">
                  <div class="w-3 h-3 rounded-full" :style="getStatusDotStyle(status)"></div>
                  <span>{{ status.name }}</span>
                </div>
              </ElDropdownItem>
            </ElDropdownMenu>
          </template>
        </ElDropdown>
        <div v-else class="status-text-placeholder">请选择状态</div>
        <div class="status-dots-row">
          <div
            v-for="status in statusList"
            :key="`status-${status.id}`"
            class="status-dot-item"
            :class="{ active: selectedStatusId === status.id }"
            :style="getStatusDotStyle(status)"
            @click.stop="handleStatusClick(status)"
          ></div>
        </div>
      </div>
      <div class="status-input-wrapper">
        <ElMention
          v-model="statusInput"
          :prefix="['@']"
          :options="userMentionOptions"
          :loading="userSearchLoading"
          type="textarea"
          :rows="3"
          placeholder="请输入信息,支持@成员"
          @search="handleUserSearch"
        />
        <ElButton class="el-button--primary" circle size="small" @click="handleStatusSubmit">
          <ArtSvgIcon icon="ri:arrow-up-line" />
        </ElButton>
      </div>
      <div class="status-list">
        <div
          v-for="(item, index) in statusItems"
          :key="index"
          class="status-item cursor-pointer hover:bg-g-50 transition-colors rounded p-2"
          @click="handleStatusItemClick"
        >
          <div class="status-item-main">
            <div class="status-item-header">
              <div class="status-item-left">
                <span class="status-dot" :style="getStatusDotStyleFromRecord(item)"></span>
                <span class="status-name" :style="getStatusNameStyle(item)">{{
                  item.status_name
                }}</span>
                <span class="status-date">{{
                  formatStatusDate(item.created_at || item.date)
                }}</span>
              </div>
              <div class="status-item-right">
                <div class="status-author-avatar">
                  {{ getInitials(item.user_name || item.author) }}
                </div>
                <span class="status-author">{{ item.user_name || item.author }}</span>
                <span class="status-time">{{
                  formatStatusTime(item.created_at || item.time)
                }}</span>
              </div>
            </div>
            <div class="status-item-content-text">
              {{ item.content || item.text }}
            </div>
          </div>
        </div>
        <div v-if="statusItems.length === 0" class="empty-status">暂无状态记录</div>
      </div>
    </ElCard>

    <!-- 项目信息 -->
    <ElCard class="info-card" shadow="never">
      <div class="card-header">
        <span class="card-title">项目信息</span>
      </div>
      <div class="info-content">
        <div v-if="projectInfo" class="info-display">
          <ArtSvgIcon icon="ri:pie-chart-line" class="info-icon" />
          <span>{{ projectInfo }}</span>
        </div>
        <div v-else class="empty-info">
          <ArtSvgIcon icon="ri:file-line" class="empty-icon" />
          <span>暂无项目信息</span>
        </div>
      </div>
    </ElCard>

    <!-- 状态记录 Timeline 弹窗 -->
    <ElDialog
      v-model="statusTimelineDialogVisible"
      title="状态记录"
      width="600px"
      :close-on-click-modal="false"
    >
      <ElTimeline>
        <ElTimelineItem
          v-for="(item, index) in allStatusItems"
          :key="index"
          :timestamp="formatStatusTime(item.created_at)"
          :color="getStatusColorFromRecord(item)"
          placement="top"
        >
          <div class="timeline-content">
            <div class="timeline-header">
              <span class="status-badge" :style="getStatusBadgeStyle(item)">
                {{ item.status_name }}
              </span>
              <span class="timeline-user">{{ item.user_name }}</span>
            </div>
            <div class="timeline-text">{{ item.content }}</div>
            <div class="timeline-date">{{ formatStatusDate(item.created_at) }}</div>
          </div>
        </ElTimelineItem>
      </ElTimeline>
      <div v-if="allStatusItems.length === 0" class="empty-timeline">暂无状态记录</div>
    </ElDialog>
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onMounted, watch, inject } from 'vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import {
    ElMessage,
    ElDropdown,
    ElDropdownMenu,
    ElDropdownItem,
    ElIcon,
    ElMention,
    ElTimeline,
    ElTimelineItem,
    ElDialog,
    ElDivider,
    ElButton,
    ElCard
  } from 'element-plus'
  import { ArrowDown } from '@element-plus/icons-vue'
  import { createActivityApi, listActivityApi } from '@/api/activity'
  import { listPropertyApi } from '@/api/property'
  import { searchUserApi } from '@/api/user'

  defineOptions({ name: 'ProjectTabOverview' })

  interface ProjectData {
    id?: string | number
    portfolio_id?: string | number
    portfolio_name?: string
    parent_id?: string | number
    code?: string
    name?: string
    py?: string
    pinyin?: string
    logo?: string
    status_id?: string | number
    source_id?: string | number
    start_date?: string
    end_date?: string
    is_star?: boolean
    manager_id?: string | number
    manager_name?: string
    user_name?: string
    updater_name?: string
    description?: string
    custom_fields?: any
    user_id?: string | number
    updater_id?: string | number
    company_id?: string | number
    is_public?: boolean
    created_time?: string
    updated_time?: string
    [key: string]: any
  }

  interface StatusItem {
    id?: number | string
    name: string
    color: string
    [key: string]: any
  }

  interface StatusRecord {
    id?: number | string
    status_id?: number | string
    text?: string
    content?: string
    date?: string
    author?: string
    user_name?: string
    time?: string
    created_at?: string
    status_name?: string
    status_color?: string
    color?: string
    warning?: boolean
  }

  // 从父组件注入项目数据
  const projectData = inject<ProjectData>('projectData') as ProjectData

  // 状态相关
  const statusList = ref<StatusItem[]>([])
  const selectedStatusId = ref<string | number | undefined>(undefined)
  const statusInput = ref('')
  const statusItems = ref<StatusRecord[]>([])

  // @用户相关
  const userMentionOptions = ref<
    Array<{ value: string; label: string; id?: string | number; [key: string]: any }>
  >([])
  const userSearchLoading = ref(false)
  const mentionIds = ref<Array<string | number>>([]) // 存储@的用户id数组

  // 项目信息
  const projectInfo = ref('')

  // 状态记录 Timeline
  const statusTimelineDialogVisible = ref(false)
  const allStatusItems = ref<StatusRecord[]>([])

  // 当前选中的状态
  const selectedStatus = computed(() => {
    if (!selectedStatusId.value) return null
    return statusList.value.find((s) => s.id === selectedStatusId.value) || null
  })

  /**
   * 加载状态列表
   */
  const loadStatusList = async (): Promise<void> => {
    try {
      const res = await listPropertyApi({
        'q[sign_eq]': 'project_status'
      })
      const data = (res as any).data || []
      statusList.value = data.sort((a: StatusItem, b: StatusItem) => {
        const sortA = a.sort ?? a.id ?? 0
        const sortB = b.sort ?? b.id ?? 0
        return Number(sortA) - Number(sortB)
      })
    } catch (error) {
      console.error('加载状态列表失败:', error)
      statusList.value = []
    }
  }

  /**
   * 加载状态记录
   */
  const loadStatusItems = async (): Promise<void> => {
    if (!projectData || !projectData.id) return

    // 确保状态列表已加载
    if (statusList.value.length === 0) {
      await loadStatusList()
    }

    try {
      const res = await listActivityApi({
        'q[record_type_eq]': 'Pm::Project',
        'q[record_id_eq]': projectData.id || '',
        per_page: 1
      })
      const data = (res as any).data || []
      statusItems.value = (Array.isArray(data) ? data : []).map((item: any) => {
        // 从状态列表中查找对应的状态信息
        const status = statusList.value.find((s) => s.id === item.status_id)
        return {
          id: item.id,
          content: item.content,
          user_name: item.user_name,
          created_at: item.created_at,
          status_name: item.status_name || status?.name || '',
          status_color: item.status_color || status?.color || item.color || 'primary',
          status_id: item.status_id
        }
      })
    } catch (error) {
      console.error('加载状态记录失败:', error)
      statusItems.value = []
    }
  }

  /**
   * 加载全部状态记录
   */
  const loadAllStatusItems = async (): Promise<void> => {
    if (!projectData || !projectData.id) return

    // 确保状态列表已加载
    if (statusList.value.length === 0) {
      await loadStatusList()
    }

    try {
      const res = await listActivityApi({
        'q[record_type_eq]': 'Pm::Project',
        'q[record_id_eq]': projectData.id || ''
      })
      const data = (res as any).data || []
      allStatusItems.value = (Array.isArray(data) ? data : []).map((item: any) => {
        // 从状态列表中查找对应的状态信息
        const status = statusList.value.find((s) => s.id === item.status_id)
        return {
          id: item.id,
          content: item.content,
          user_name: item.user_name,
          created_at: item.created_at,
          status_name: item.status_name || status?.name || '',
          status_color: item.status_color || status?.color || item.color || 'primary',
          status_id: item.status_id
        }
      })
    } catch (error) {
      console.error('加载全部状态记录失败:', error)
      allStatusItems.value = []
    }
  }

  /**
   * 处理状态记录点击
   */
  const handleStatusItemClick = async (): Promise<void> => {
    await loadAllStatusItems()
    statusTimelineDialogVisible.value = true
  }

  /**
   * 获取状态高亮样式
   */
  const getStatusHighlightStyle = (status: StatusItem): Record<string, string> => {
    const color = status.color || 'primary'
    return {
      color: `var(--el-color-${color})`
    }
  }

  /**
   * 根据ID获取状态
   */
  const getStatusById = (id: number | string | undefined): StatusItem | null => {
    if (!id) return null
    return statusList.value.find((s) => s.id === id) || null
  }

  /**
   * 获取状态点样式
   */
  const getStatusDotStyle = (status: StatusItem | null): Record<string, string> => {
    if (!status) {
      return {
        backgroundColor: 'var(--el-color-info)',
        borderColor: 'var(--el-color-info)'
      }
    }
    const color = status.color || 'primary'
    return {
      backgroundColor: `var(--el-color-${color})`,
      borderColor: `var(--el-color-${color})`
    }
  }

  /**
   * 处理状态点击（从状态点点击）
   */
  const handleStatusClick = (status: StatusItem): void => {
    if (!status || !status.id) {
      console.warn('状态数据无效:', status)
      return
    }

    // 只更新选中状态，不自动提交
    selectedStatusId.value = status.id
  }

  /**
   * 处理状态下拉菜单选择（从 ElDropdown 的 command 事件）
   */
  const handleStatusCommand = (statusId: string | number): void => {
    const status = statusList.value.find((s) => s.id === statusId)
    if (!status) {
      console.warn('状态数据无效:', statusId)
      return
    }

    // 只更新选中状态，不自动提交
    selectedStatusId.value = status.id
  }

  /**
   * 加载默认用户列表
   */
  const loadDefaultUsers = async (): Promise<void> => {
    userSearchLoading.value = true
    try {
      const res = await searchUserApi({})
      const data = (res as any).data || []
      userMentionOptions.value = data.map((user: any) => ({
        value: user.name || user.email || '',
        label: user.name || user.email || '',
        id: user.id,
        ...user
      }))
    } catch (error) {
      console.error('加载用户列表失败:', error)
      userMentionOptions.value = []
    } finally {
      userSearchLoading.value = false
    }
  }

  /**
   * 处理用户搜索（用于 @ 提及）
   */
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  const handleUserSearch = async (pattern: string, _prefix: string): Promise<void> => {
    // 如果没有搜索词，加载默认用户列表
    if (!pattern || pattern.trim() === '') {
      await loadDefaultUsers()
      return
    }

    userSearchLoading.value = true
    try {
      const res = await searchUserApi({
        'q[name_cont]': pattern.trim()
      })
      const data = (res as any).data || []
      userMentionOptions.value = data.map((user: any) => ({
        value: user.name || user.email || '',
        label: user.name || user.email || '',
        id: user.id,
        ...user
      }))
    } catch (error) {
      console.error('搜索用户失败:', error)
      userMentionOptions.value = []
    } finally {
      userSearchLoading.value = false
    }
  }

  /**
   * 从文本中解析@用户并提取id
   */
  const parseMentionIds = (text: string): Array<string | number> => {
    if (!text) return []

    // 匹配 @用户名 格式
    const mentionRegex = /@([^\s@]+)/g
    const mentions: string[] = []
    let match

    while ((match = mentionRegex.exec(text)) !== null) {
      mentions.push(match[1])
    }

    // 从 userMentionOptions 中找到对应的id
    const ids: Array<string | number> = []
    mentions.forEach((mentionName) => {
      const user = userMentionOptions.value.find(
        (u) => u.value === mentionName || u.label === mentionName
      )
      if (user && user.id) {
        ids.push(user.id)
      }
    })

    // 去重
    return Array.from(new Set(ids))
  }

  /**
   * 处理状态提交
   */
  const handleStatusSubmit = async (): Promise<void> => {
    if (!projectData) {
      ElMessage.warning('项目数据未加载')
      return
    }

    if (!statusInput.value.trim()) {
      ElMessage.warning('请输入状态信息')
      return
    }

    if (!selectedStatusId.value) {
      ElMessage.warning('请先选择状态')
      return
    }

    // 解析@用户id
    const parsedMentionIds = parseMentionIds(statusInput.value)
    mentionIds.value = parsedMentionIds

    // 添加状态记录
    const newItem: StatusRecord = {
      status_id: selectedStatusId.value,
      text: statusInput.value.trim(),
      date: new Date().toISOString().split('T')[0],
      author: projectData?.manager_name || '当前用户',
      time: '刚刚'
    }

    statusItems.value.unshift(newItem)

    // 一起提交状态和mention_ids
    try {
      if (!projectData.id) {
        ElMessage.warning('项目ID不存在')
        return
      }

      const updateData: any = {
        status_id: selectedStatusId.value
      }

      // 如果有@用户，添加mention_ids字段
      if (parsedMentionIds.length > 0) {
        updateData.mention_ids = parsedMentionIds
      }

      // statusInput 内容
      if (statusInput.value.trim()) {
        updateData.content = statusInput.value.trim()
        updateData.record_type = 'Pm::Project'
        updateData.record_id = projectData.id
      }

      const res = await createActivityApi(updateData)
      // 更新项目数据，但保留项目ID，避免被活动的ID覆盖
      const responseData = (res as any).data || {}
      const originalProjectId = projectData.id
      Object.assign(projectData as any, responseData)
      // 确保项目ID不被覆盖
      if (projectData.id !== originalProjectId) {
        projectData.id = originalProjectId
      }

      // 清空输入
      // statusInput.value = ''
      mentionIds.value = []

      ElMessage.success('状态已更新')
    } catch (error) {
      console.error('保存状态失败:', error)
      ElMessage.error('保存状态失败')
    }
  }

  /**
   * 格式化状态日期
   */
  const formatStatusDate = (dateStr: string | undefined): string => {
    if (!dateStr) return ''
    const date = new Date(dateStr)
    if (isNaN(date.getTime())) return dateStr
    const month = date.getMonth() + 1
    const day = date.getDate()
    return `${month}月${day}日`
  }

  /**
   * 格式化状态时间
   */
  const formatStatusTime = (dateStr: string | undefined): string => {
    if (!dateStr) return ''
    const date = new Date(dateStr)
    if (isNaN(date.getTime())) return dateStr
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    const hours = String(date.getHours()).padStart(2, '0')
    const minutes = String(date.getMinutes()).padStart(2, '0')
    return `${year}-${month}-${day} ${hours}:${minutes}`
  }

  /**
   * 从记录获取状态点样式
   */
  const getStatusDotStyleFromRecord = (record: StatusRecord): Record<string, string> => {
    if (record.status_color) {
      return {
        backgroundColor: `var(--el-color-${record.status_color})`,
        borderColor: `var(--el-color-${record.status_color})`
      }
    }
    if (record.color) {
      return {
        backgroundColor: `var(--el-color-${record.color})`,
        borderColor: `var(--el-color-${record.color})`
      }
    }
    if (record.status_id) {
      const status = getStatusById(record.status_id)
      if (status) {
        return getStatusDotStyle(status)
      }
    }
    return {
      backgroundColor: 'var(--el-color-info)',
      borderColor: 'var(--el-color-info)'
    }
  }

  /**
   * 从记录获取状态名称样式（颜色与状态点一致）
   */
  const getStatusNameStyle = (record: StatusRecord): Record<string, string> => {
    if (record.status_color) {
      return {
        color: `var(--el-color-${record.status_color})`
      }
    }
    if (record.color) {
      return {
        color: `var(--el-color-${record.color})`
      }
    }
    if (record.status_id) {
      const status = getStatusById(record.status_id)
      if (status && status.color) {
        return {
          color: `var(--el-color-${status.color})`
        }
      }
    }
    return {
      color: 'var(--el-color-info)'
    }
  }

  /**
   * 从记录获取状态颜色
   */
  const getStatusColorFromRecord = (record: StatusRecord): string => {
    if (record.status_color) {
      return `var(--el-color-${record.status_color})`
    }
    if (record.color) {
      return `var(--el-color-${record.color})`
    }
    if (record.status_id) {
      const status = getStatusById(record.status_id)
      if (status && status.color) {
        return `var(--el-color-${status.color})`
      }
    }
    return 'var(--el-color-info)'
  }

  /**
   * 从记录获取状态徽章样式
   */
  const getStatusBadgeStyle = (record: StatusRecord): Record<string, string> => {
    if (record.status_color) {
      return {
        backgroundColor: `var(--el-color-${record.status_color})`,
        color: '#fff'
      }
    }
    if (record.color) {
      return {
        backgroundColor: `var(--el-color-${record.color})`,
        color: '#fff'
      }
    }
    if (record.status_id) {
      const status = getStatusById(record.status_id)
      if (status && status.color) {
        return {
          backgroundColor: `var(--el-color-${status.color})`,
          color: '#fff'
        }
      }
    }
    return {
      backgroundColor: 'var(--el-color-info)',
      color: '#fff'
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

  // 监听状态列表加载完成（只在初始化时设置默认值）
  watch(
    () => statusList.value.length,
    (newLength, oldLength) => {
      // 只在从0变为有值时，且没有选中状态时，才设置默认值
      if (newLength > 0 && oldLength === 0 && !selectedStatusId.value) {
        selectedStatusId.value = statusList.value[0].id
      }
    }
  )

  // 监听输入文本变化，动态更新mention_ids
  watch(
    () => statusInput.value,
    (newText) => {
      mentionIds.value = parseMentionIds(newText)
    }
  )

  // 监听 projectData 变化，更新状态
  watch(
    () => projectData?.id,
    async (newId) => {
      if (newId && projectData) {
        // 加载状态记录
        await loadStatusItems()

        // 设置默认选中第一个状态
        if (statusList.value.length > 0 && !selectedStatusId.value) {
          selectedStatusId.value = statusList.value[0].id
        }
      }
    },
    { immediate: true }
  )

  onMounted(async () => {
    // 先加载状态列表
    await loadStatusList()
    // 加载默认用户列表
    await loadDefaultUsers()
  })
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';

  .tab-overview {
    @apply space-y-8;
  }

  .status-card,
  .info-card {
    @apply p-4;
  }

  .sidebar-section {
    @apply mb-6;
  }

  .sidebar-section:last-child {
    @apply mb-0;
  }

  .card-header {
    @apply mb-3;
  }

  .card-title {
    @apply text-sm font-medium text-g-900;
  }

  .card-subtitle {
    @apply text-xs text-g-500 mb-3;
  }

  .name-input :deep(.el-input__wrapper) {
    background: rgb(242 243 245);
    border: 1px solid var(--el-border-color-light);
  }

  .status-display-new {
    @apply flex items-center gap-3 mb-3;
  }

  .status-text-highlight {
    @apply text-base font-medium;
  }

  .status-text-placeholder {
    @apply text-sm text-g-400;
  }

  .status-dots-row {
    @apply flex items-center gap-2;
  }

  .status-dot-item {
    @apply w-4 h-4 rounded-full border-2 cursor-pointer transition-all;
  }

  .status-dot-item.active {
    @apply ring-2 ring-offset-1;

    --tw-ring-color: var(--el-color-primary);
  }

  .status-input-wrapper {
    @apply flex items-center gap-2 mb-3;
  }

  .status-submit-btn {
    @apply flex-shrink-0;
  }

  .status-list {
    @apply space-y-3;
  }

  .status-item {
    @apply py-2;
  }

  .status-item-main {
    @apply flex flex-col gap-2;
  }

  .status-item-header {
    @apply flex items-center justify-between;
  }

  .status-item-left {
    @apply flex items-center gap-2;
  }

  .status-item-right {
    @apply flex items-center gap-2;
  }

  .status-dot {
    @apply w-3 h-3 rounded-full flex-shrink-0;

    border: none;
  }

  .status-name {
    @apply text-sm font-medium;
  }

  .status-date {
    @apply text-xs text-g-500;
  }

  .status-item-content-text {
    @apply text-sm text-g-700;

    line-height: 1.5;
  }

  .status-author-avatar {
    @apply w-6 h-6 rounded-full text-white flex items-center justify-center text-xs font-medium flex-shrink-0;

    background-color: #ffa940;
  }

  .status-author {
    @apply text-sm text-g-700;
  }

  .status-time {
    @apply text-xs text-g-500;
  }

  .empty-status,
  .empty-info {
    @apply flex flex-col items-center justify-center py-8 text-g-400;
  }

  .empty-icon {
    @apply text-2xl mb-2;
  }

  .info-content {
    @apply py-4;
  }

  .info-display {
    @apply flex items-center gap-2 text-sm text-g-700;
  }

  .info-icon {
    @apply text-lg;

    color: var(--el-color-primary);
  }

  .period-content {
    @apply flex items-center gap-2;
  }

  .period-separator {
    @apply text-g-400 flex-shrink-0;
  }

  .portfolio-content {
    @apply py-2;
  }

  .portfolio-display {
    @apply flex items-center gap-2;
  }

  .portfolio-name {
    @apply flex-1 text-sm text-g-700;
  }

  .portfolio-empty {
    @apply py-2;
  }

  .manager-content {
    @apply py-2;
  }

  .manager-display {
    @apply flex items-center gap-2;
  }

  .manager-avatar {
    @apply w-8 h-8 rounded-full text-white flex items-center justify-center text-sm font-medium;

    background-color: var(--el-color-primary);
  }

  .manager-name {
    @apply flex-1 text-sm text-g-700;
  }

  .manager-empty {
    @apply py-2;
  }

  .member-content {
    @apply py-2;
  }

  .member-list {
    @apply space-y-2 mb-3;
  }

  .member-item {
    @apply flex items-center gap-2 py-2;
  }

  .member-avatar {
    @apply w-8 h-8 rounded-full text-white flex items-center justify-center text-sm font-medium flex-shrink-0;

    background-color: var(--el-color-primary);
  }

  .member-name {
    @apply flex-1 text-sm text-g-700;
  }

  .member-actions {
    @apply py-2;
  }

  .timeline-content {
    @apply pb-4;
  }

  .timeline-header {
    @apply flex items-center gap-2 mb-2;
  }

  .status-badge {
    @apply px-2 py-1 rounded text-xs font-medium;
  }

  .timeline-user {
    @apply text-sm text-g-600;
  }

  .timeline-text {
    @apply text-sm text-g-700 mb-2;

    line-height: 1.6;
  }

  .timeline-date {
    @apply text-xs text-g-500;
  }

  .empty-timeline {
    @apply text-center py-8 text-g-400;
  }
</style>
