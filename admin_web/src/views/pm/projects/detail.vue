<!-- 项目详情页 -->
<template>
  <div class="project-detail-page art-full-height">
    <!-- 顶部导航栏 -->
    <div class="detail-header">
      <div class="header-left">
        <ElButton text class="back-btn" @click="handleBack">
          <ArtSvgIcon icon="ri:arrow-left-line" class="mr-1" />
          返回
        </ElButton>
        <div class="document-title">
          <ArtSvgIcon icon="ri:file-text-line" class="mr-2" />
          <span>{{ projectData.name || '项目' }}</span>
        </div>
        <div class="tabs">
          <div
            v-for="tab in tabs"
            :key="tab.key"
            class="tab-item"
            :class="{ active: activeTab === tab.key }"
            @click="handleTabChange(tab.key)"
          >
            {{ tab.label }}
          </div>
          <ElButton text class="add-tab-btn">
            <ArtSvgIcon icon="ri:add-line" />
          </ElButton>
        </div>
      </div>
      <div class="header-right">
        <ElButton text @click="handleRefresh">
          <ArtSvgIcon icon="ri:refresh-line" class="mr-1" />
          刷新
        </ElButton>
      </div>
    </div>

    <!-- 主内容区 -->
    <div class="detail-content" :class="{ 'detail-content--full': activeTab !== 'overview' }">
      <!-- 左侧主内容 -->
      <div class="content-left">
        <!-- Tab 内容 -->
        <component :is="currentTabComponent" :key="activeTab" />
      </div>

      <!-- 右侧边栏 -->
      <div v-if="activeTab === 'overview'" class="content-right">
        <ElCard class="sidebar-card" shadow="never">
          <!-- 文档 -->
          <div class="sidebar-section">
            <div class="card-header">
              <ElInput
                v-model="projectData.name"
                placeholder="请输入项目名称"
                size="large"
                clearable
                @blur="handleNameBlur"
                @keyup.enter="handleNameBlur"
              />
            </div>
            <div class="card-subtitle">
              {{ projectData.user_name || '未知用户' }}于{{ projectData.created_time || '' }}
              创建
              <br />
              {{ projectData.updater_name || '未知用户' }}于{{ projectData.updated_time || '' }}
              更新
            </div>
            <ElInput
              v-model="projectData.description"
              class="name-input"
              type="textarea"
              :rows="5"
              placeholder="请描述项目概述"
              maxlength="10000"
              show-word-limit
              @blur="handleDescriptionBlur"
            />
          </div>

          <!-- 项目周期 -->
          <div class="sidebar-section">
            <div class="card-header">
              <span class="card-title">项目周期</span>
            </div>
            <div class="period-content">
              <ElDatePicker
                v-model="projectData.start_date"
                type="date"
                placeholder="设置开始时间"
                style="width: 100%"
                @change="handleStartDateChange"
              />
              <span class="period-separator">-</span>
              <ElDatePicker
                v-model="projectData.end_date"
                type="date"
                placeholder="设置截止时间"
                style="width: 100%"
                @change="handleEndDateChange"
              />
            </div>
          </div>

          <!-- 负责人 -->
          <div class="sidebar-section">
            <div class="card-header">
              <span class="card-title">负责人</span>
            </div>
            <div class="manager-content">
              <div v-if="projectData.manager_id" class="manager-display">
                <div class="manager-avatar">
                  {{ getInitials(projectData.manager_name) }}
                </div>
                <span class="manager-name">{{ projectData.manager_name }}</span>
                <ElButton text size="small" @click="handleSelectManager">更改</ElButton>
              </div>
              <div v-else class="manager-empty">
                <ElButton text @click="handleSelectManager">
                  <ArtSvgIcon icon="ri:user-add-line" class="mr-1" />
                  设置负责人
                </ElButton>
              </div>
            </div>
          </div>

          <!-- 成员 -->
          <div class="sidebar-section">
            <div class="card-header">
              <span class="card-title">项目成员</span>
            </div>
            <div class="member-content">
              <div v-if="memberList.length > 0" class="member-list">
                <div v-for="member in memberList" :key="member.id" class="member-item">
                  <div class="member-avatar-wrapper">
                    <div class="member-avatar">
                      {{ getInitials(member.name) }}
                    </div>
                    <ElButton
                      class="member-remove-btn"
                      text
                      size="small"
                      type="danger"
                      circle
                      @click.stop="handleRemoveMember(member.id)"
                    >
                      <ArtSvgIcon icon="ri:close-line" />
                    </ElButton>
                  </div>
                  <span class="member-name">{{ member.name }}</span>
                </div>
              </div>
              <div class="member-actions">
                <ElButton text @click="handleSelectMembers">
                  <ArtSvgIcon icon="ri:user-add-line" class="mr-1" />
                  添加成员
                </ElButton>
              </div>
            </div>
          </div>
        </ElCard>
      </div>
    </div>

    <!-- 负责人选择弹窗 -->
    <UserSelectDialog
      v-model="managerSelectDialogVisible"
      :multiple="false"
      @select="handleManagerSelect"
    />

    <!-- 成员选择弹窗 -->
    <UserSelectDialog
      v-model="memberSelectDialogVisible"
      :multiple="true"
      @select-multiple="handleMemberSelect"
    />
  </div>
</template>

<script setup lang="ts">
  import { ref, reactive, computed, onMounted, markRaw, provide } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import UserSelectDialog from '@/components/UserSelectDialog.vue'
  import { ElMessage } from 'element-plus'
  import { viewPmProjectApi, updatePmProjectApi } from '@/api/pm/project'
  import TabOverview from './modules/tab-overview.vue'
  import TabKanban from './modules/tab-kanban.vue'
  import TabDocument from './modules/tab-document.vue'
  import TabFiles from './modules/tab-files.vue'
  import TabTimesheet from './modules/tab-timesheet.vue'
  import TabTasks from './modules/tab-tasks.vue'

  const route = useRoute()
  const router = useRouter()

  interface ProjectData {
    id?: string | number
    name?: string
    description?: string
    start_date?: string
    end_date?: string
    user_id?: string | number
    manager_id?: string | number
    manager_name?: string
    user_name?: string
    status_id?: string | number
    created_time?: string
    updated_time?: string
    updater_name?: string
    [key: string]: any
  }

  // 标签页
  const tabs = [
    { key: 'overview', label: '概览', component: markRaw(TabOverview) },
    { key: 'kanban', label: '看板', component: markRaw(TabKanban) },
    { key: 'tasks', label: '任务', component: markRaw(TabTasks) },
    { key: 'document', label: '文档', component: markRaw(TabDocument) },
    { key: 'files', label: '文件库', component: markRaw(TabFiles) },
    { key: 'timesheet', label: '工时', component: markRaw(TabTimesheet) }
  ]

  // 从 URL 参数获取默认 tab
  const getDefaultTab = (): string => {
    const tag = route.query.tag as string
    if (tag && tabs.some((t) => t.key === tag)) {
      return tag
    }
    return 'overview'
  }

  const activeTab = ref(getDefaultTab())

  // 切换tab
  const handleTabChange = (tabKey: string): void => {
    activeTab.value = tabKey
    // 更新 URL 参数
    router.replace({
      path: route.path,
      query: { ...route.query, tag: tabKey }
    })
  }

  // 当前tab组件
  const currentTabComponent = computed(() => {
    const tab = tabs.find((t) => t.key === activeTab.value)
    return tab?.component
  })

  // 项目数据
  const projectData = reactive<ProjectData>({
    id: undefined,
    name: '',
    description: '',
    start_date: '',
    end_date: '',
    manager_id: undefined,
    manager_name: '',
    status_id: undefined,
    created_at: '',
    user_name: '',
    created_time: '',
    updated_time: '',
    updater_name: '',
    user_id: undefined
  })

  const lastSavedName = ref('')

  // 负责人选择
  const managerSelectDialogVisible = ref(false)

  // 成员相关
  const memberList = ref<Array<{ id: string | number; name: string; email?: string }>>([])
  const memberSelectDialogVisible = ref(false)

  /**
   * 加载项目详情
   */
  const loadProjectDetail = async (): Promise<void> => {
    const projectId = route.params.id
    if (!projectId) {
      ElMessage.error('项目ID不存在')
      return
    }

    try {
      const res = await viewPmProjectApi({ id: projectId })
      Object.assign(projectData as any, (res as any).data || {})

      // 保存名称用于回退
      lastSavedName.value = projectData.name || ''

      // 加载成员列表
      const members = (projectData as any).members || []
      if (Array.isArray(members)) {
        memberList.value = members.map((m: any) => ({
          id: m.id || m,
          name: m.name || '',
          email: m.email || ''
        }))
      } else {
        memberList.value = []
      }
    } catch (error) {
      console.error('加载项目详情失败:', error)
      ElMessage.error('加载项目详情失败')
    }
  }

  /**
   * 处理名称失焦
   */
  const handleNameBlur = async (): Promise<void> => {
    const name = projectData.name?.trim()
    if (!name) {
      ElMessage.warning('项目名称不能为空')
      projectData.name = lastSavedName.value
      return
    }

    if (name === lastSavedName.value) {
      return
    }

    await saveProjectField('name', name)
    lastSavedName.value = name
  }

  /**
   * 处理描述失焦
   */
  const handleDescriptionBlur = async (): Promise<void> => {
    await saveProjectField('description', projectData.description)
  }

  /**
   * 处理开始日期变化
   */
  const handleStartDateChange = async (date: Date | null): Promise<void> => {
    if (date) {
      projectData.start_date = formatDateString(date)
      await saveProjectField('start_date', projectData.start_date)
    }
  }

  /**
   * 处理结束日期变化
   */
  const handleEndDateChange = async (date: Date | null): Promise<void> => {
    if (date) {
      projectData.end_date = formatDateString(date)
      await saveProjectField('end_date', projectData.end_date)
    }
  }

  /**
   * 处理选择负责人
   */
  const handleSelectManager = (): void => {
    managerSelectDialogVisible.value = true
  }

  /**
   * 处理负责人选择
   */
  const handleManagerSelect = async (user: any): Promise<void> => {
    projectData.manager_id = user.id
    projectData.manager_name = user.name || user.email
    await saveProjectField('manager_id', projectData.manager_id)
    managerSelectDialogVisible.value = false
  }

  /**
   * 显示成员选择弹窗
   */
  const handleSelectMembers = (): void => {
    memberSelectDialogVisible.value = true
  }

  /**
   * 处理成员选择（多选）
   */
  const handleMemberSelect = async (users: any[]): Promise<void> => {
    const newMembers = users.map((user) => ({
      id: user.id,
      name: user.name || user.email || '',
      email: user.email || ''
    }))

    // 合并已存在的成员，避免重复
    const existingIds = memberList.value.map((m) => m.id)
    const uniqueMembers = newMembers.filter((m) => !existingIds.includes(m.id))
    memberList.value.push(...uniqueMembers)

    // 保存成员列表
    await saveMembers()
    memberSelectDialogVisible.value = false
  }

  /**
   * 移除成员
   */
  const handleRemoveMember = async (memberId: string | number): Promise<void> => {
    memberList.value = memberList.value.filter((m) => m.id !== memberId)
    // 保存成员列表
    await saveMembers()
  }

  /**
   * 保存成员列表
   */
  const saveMembers = async (): Promise<void> => {
    if (!projectData.id) {
      ElMessage.warning('项目ID不存在')
      return
    }

    try {
      const members = memberList.value.map((m) => ({
        id: m.id,
        name: m.name
      }))
      const res = await updatePmProjectApi(String(projectData.id), {
        members: members
      })
      // 更新项目数据
      Object.assign(projectData as any, (res as any).data || {})
      ElMessage.success('成员已更新')
    } catch (error) {
      console.error('保存成员失败:', error)
      ElMessage.error('保存成员失败')
    }
  }

  /**
   * 保存项目字段
   */
  const saveProjectField = async (field: string, value: any): Promise<void> => {
    if (!projectData.id) {
      ElMessage.warning('项目ID不存在')
      return
    }

    try {
      const res = await updatePmProjectApi(String(projectData.id), {
        [field]: value
      })
      // 更新项目数据
      Object.assign(projectData as any, (res as any).data || {})
      ElMessage.success(`保存${field}成功`)
    } catch (error) {
      console.error(`保存${field}失败:`, error)
      ElMessage.error(`保存${field}失败`)
    }
  }

  /**
   * 格式化日期字符串
   */
  const formatDateString = (date: Date): string => {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
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

  /**
   * 返回
   */
  const handleBack = (): void => {
    router.back()
  }

  /**
   * 刷新
   */
  const handleRefresh = async (): Promise<void> => {
    await loadProjectDetail()
    ElMessage.success('刷新成功')
  }

  // 提供项目数据给子组件
  provide('projectData', projectData)

  onMounted(async () => {
    await loadProjectDetail()
  })
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';

  .project-detail-page {
    @apply h-full flex flex-col bg-g-100;

    height: var(--art-full-height);
    min-height: 0;
  }

  .detail-header {
    @apply flex items-center justify-between px-4 py-3 bg-white border-b border-g-200;
  }

  .header-left {
    @apply flex items-center gap-4;
  }

  .back-btn {
    @apply mr-2;
  }

  .document-title {
    @apply flex items-center text-base font-medium text-g-900;
  }

  .tabs {
    @apply flex items-center gap-1;
  }

  .tab-item {
    @apply px-3 py-1.5 text-sm text-g-600 cursor-pointer hover:text-g-900 transition-colors;

    border-bottom: 2px solid transparent;
  }

  .tab-item.active {
    color: var(--el-color-primary);
    border-bottom-color: var(--el-color-primary);
  }

  .add-tab-btn {
    @apply ml-2;
  }

  .header-right {
    @apply flex items-center gap-2;
  }

  .detail-content {
    @apply flex-1 overflow-hidden p-4 gap-4;

    display: grid;
    grid-template-rows: 1fr;
    grid-template-columns: 1fr 320px;
    height: 100%;
    min-height: 0;
  }

  .detail-content--full {
    grid-template-columns: 1fr;
  }

  .content-left {
    display: flex;
    flex-direction: column;
    height: 100%;
    min-height: 0;
    overflow: hidden;
  }

  .content-right {
    @apply space-y-4;
  }

  .sidebar-card {
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

  .name-input {
    @apply mt-2;
  }

  .period-content {
    @apply flex items-center gap-2;
  }

  .period-separator {
    @apply text-g-400 flex-shrink-0;
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
    @apply flex flex-wrap gap-2 mb-3;
  }

  .member-item {
    @apply flex items-center gap-1.5;
  }

  .member-avatar-wrapper {
    @apply relative;
  }

  .member-avatar {
    @apply w-8 h-8 rounded-full text-white flex items-center justify-center text-sm font-medium flex-shrink-0;

    background-color: var(--el-color-primary);
  }

  .member-remove-btn {
    @apply absolute -top-1 -right-1 w-4 h-4 p-0 opacity-0 transition-opacity;

    z-index: 10;
    color: white !important;
    background-color: var(--el-color-danger) !important;
  }

  .member-remove-btn:hover {
    color: white !important;
    background-color: var(--el-color-danger) !important;
  }

  .member-item:hover .member-remove-btn {
    @apply opacity-100;
  }

  .member-name {
    @apply text-sm text-g-700 whitespace-nowrap;
  }

  .member-actions {
    @apply py-2;
  }
</style>
