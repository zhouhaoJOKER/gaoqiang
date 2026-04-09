<!-- 项目集详情页 -->
<template>
  <div class="portfolio-detail-page">
    <!-- 顶部导航栏 -->
    <div class="detail-header">
      <div class="header-left">
        <ElButton text class="back-btn" @click="handleBack">
          <ArtSvgIcon icon="ri:arrow-left-line" class="mr-1" />
          返回
        </ElButton>
        <div class="document-title">
          <ArtSvgIcon icon="ri:file-text-line" class="mr-2" />
          <span>{{ portfolioData.name || '项目集' }}</span>
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
        <ElButton text>
          <ArtSvgIcon icon="ri:question-line" class="mr-1" />
          帮助
        </ElButton>
      </div>
    </div>

    <!-- 主内容区 -->
    <div class="detail-content">
      <!-- 左侧主内容 -->
      <div class="content-left">
        <!-- 配置布局 -->
        <!-- <ElCard class="config-card" shadow="never">
          <div class="flex items-center justify-between">
            <span class="text-sm font-medium text-g-700">配置布局</span>
            <ElSwitch v-model="layoutConfig" />
          </div>
        </ElCard> -->

        <!-- Tab 内容 -->
        <component :is="currentTabComponent" :key="activeTab" />

        <!-- 项目状态 -->
        <template v-if="activeTab === 'overview'">
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
        </template>
      </div>

      <!-- 右侧边栏 -->
      <div class="content-right">
        <template v-if="activeTab === 'overview'">
          <ElCard class="sidebar-card" shadow="never">
            <!-- 文档 -->
            <div class="sidebar-section">
              <div class="card-header">
                <ElInput
                  v-model="portfolioData.name"
                  placeholder="请输入项目集名称"
                  size="large"
                  clearable
                  @blur="handleNameBlur"
                  @keyup.enter="handleNameBlur"
                />
              </div>
              <div class="card-subtitle">
                {{ portfolioData.user_name || '未知用户' }}于{{ portfolioData.created_time || '' }}
                创建
                <br />
                {{ portfolioData.updater_name || '未知用户' }}于{{
                  portfolioData.updated_time || ''
                }}
                更新
              </div>
              <ElInput
                v-model="portfolioData.description"
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
                  v-model="portfolioData.start_date"
                  type="date"
                  placeholder="设置开始时间"
                  style="width: 100%"
                  @change="handleStartDateChange"
                />
                <span class="period-separator">-</span>
                <ElDatePicker
                  v-model="portfolioData.end_date"
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
                <div v-if="portfolioData.manager_id" class="manager-display">
                  <div class="manager-avatar">
                    {{ getInitials(portfolioData.manager_name) }}
                  </div>
                  <span class="manager-name">{{ portfolioData.manager_name }}</span>
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
                <span class="card-title">成员</span>
              </div>
              <div class="member-content">
                <div v-if="memberList.length > 0" class="member-list">
                  <div v-for="member in memberList" :key="member.id" class="member-item">
                    <div class="member-avatar">
                      {{ getInitials(member.name) }}
                    </div>
                    <span class="member-name">{{ member.name }}</span>
                    <ElButton
                      text
                      size="small"
                      type="danger"
                      @click="handleRemoveMember(member.id)"
                    >
                      <ArtSvgIcon icon="ri:close-line" />
                    </ElButton>
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
        </template>
      </div>
    </div>

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
  import { ref, reactive, computed, onMounted, watch, markRaw } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import UserSelectDialog from '@/components/UserSelectDialog.vue'
  import {
    ElMessage,
    ElDropdown,
    ElDropdownMenu,
    ElDropdownItem,
    ElIcon,
    ElMention,
    ElTimeline,
    ElTimelineItem,
    ElDialog
  } from 'element-plus'
  import { ArrowDown } from '@element-plus/icons-vue'
  import { viewPmPortfolioApi, updatePmPortfolioApi } from '@/api/pm/portfolio'
  import { createActivityApi, listActivityApi } from '@/api/activity'
  import { listPropertyApi } from '@/api/property'
  import { searchUserApi } from '@/api/user'
  import TabMonitor from './modules/tab-monitor.vue'
  import TabGantt from './modules/tab-gantt.vue'
  import TabStatistics from './modules/tab-statistics.vue'
  import TabOverview from './modules/tab-overview.vue'
  import TabSummary from './modules/tab-summary.vue'

  const route = useRoute()
  const router = useRouter()

  interface PortfolioData {
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
    warning?: boolean
  }

  // 标签页
  const tabs = [
    { key: 'overview', label: '概览', component: markRaw(TabOverview) },
    { key: 'monitor', label: '项目监控', component: markRaw(TabMonitor) },
    { key: 'gantt', label: '甘特图', component: markRaw(TabGantt) },
    { key: 'statistics', label: '统计', component: markRaw(TabStatistics) },
    { key: 'summary', label: '事务汇总', component: markRaw(TabSummary) }
  ]

  const activeTab = ref('overview')

  // 切换tab
  const handleTabChange = (tabKey: string): void => {
    activeTab.value = tabKey
  }

  // 当前tab组件
  const currentTabComponent = computed(() => {
    const tab = tabs.find((t) => t.key === activeTab.value)
    return tab?.component
  })

  // 当前选中的状态
  const selectedStatus = computed(() => {
    if (!selectedStatusId.value) return null
    return statusList.value.find((s) => s.id === selectedStatusId.value) || null
  })
  // 项目集数据
  const portfolioData = reactive<PortfolioData>({
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
    user_id: undefined
  })

  const lastSavedName = ref('')

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

  // 负责人选择
  const managerSelectDialogVisible = ref(false)

  // 成员相关
  const memberList = ref<Array<{ id: string | number; name: string; email?: string }>>([])
  const memberSelectDialogVisible = ref(false)

  // 状态记录 Timeline
  const statusTimelineDialogVisible = ref(false)
  const allStatusItems = ref<StatusRecord[]>([])

  /**
   * 加载项目集详情
   */
  const loadPortfolioDetail = async (): Promise<void> => {
    const portfolioId = route.params.id
    if (!portfolioId) {
      ElMessage.error('项目集ID不存在')
      return
    }

    try {
      const res = await viewPmPortfolioApi({ id: portfolioId })
      Object.assign(portfolioData as any, (res as any).data || {})
      lastSavedName.value = (portfolioData.name || '').trim()

      // 加载成员列表
      const members = (portfolioData as any).members || []
      if (Array.isArray(members)) {
        memberList.value = members.map((m: any) => ({
          id: m.id || m,
          name: m.name || '',
          email: m.email || ''
        }))
      } else {
        memberList.value = []
      }

      // 加载状态记录
      await loadStatusItems()

      // 设置默认选中第一个状态
      if (statusList.value.length > 0 && !selectedStatusId.value) {
        selectedStatusId.value = statusList.value[0].id
      }
    } catch (error) {
      console.error('加载项目集详情失败:', error)
      ElMessage.error('加载项目集详情失败')
    }
  }

  /**
   * 加载状态列表
   */
  const loadStatusList = async (): Promise<void> => {
    try {
      const res = await listPropertyApi({
        sign: 'portfolio_status'
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
    if (!portfolioData.id) return

    try {
      const res = await listActivityApi({
        record_type: 'Pm::Portfolio',
        record_id: portfolioData.id,
        per_page: 1
      })
      const data = (res as any).data || []
      statusItems.value = (Array.isArray(data) ? data : []).map((item: any) => ({
        id: item.id,
        content: item.content,
        user_name: item.user_name,
        created_at: item.created_at,
        status_name: item.status_name,
        status_color: item.status_color,
        status_id: item.status_id
      }))
    } catch (error) {
      console.error('加载状态记录失败:', error)
      statusItems.value = []
    }
  }

  /**
   * 加载全部状态记录
   */
  const loadAllStatusItems = async (): Promise<void> => {
    if (!portfolioData.id) return

    try {
      const res = await listActivityApi({
        record_type: 'Pm::Portfolio',
        record_id: portfolioData.id
      })
      const data = (res as any).data || []
      allStatusItems.value = (Array.isArray(data) ? data : []).map((item: any) => ({
        id: item.id,
        content: item.content,
        user_name: item.user_name,
        created_at: item.created_at,
        status_name: item.status_name,
        status_color: item.status_color,
        status_id: item.status_id
      }))
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
   * 根据ID获取状态
   */
  const getStatusById = (id: number | string | undefined): StatusItem | null => {
    if (!id) return null
    return statusList.value.find((s) => s.id === id) || null
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
        value: user.name || user.email || '', // 使用名称作为 value，这样选中后显示的是名称
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
        value: user.name || user.email || '', // 使用名称作为 value，这样选中后显示的是名称
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
      author: portfolioData.manager_name || '当前用户',
      time: '刚刚'
    }

    statusItems.value.unshift(newItem)

    // 一起提交状态和mention_ids
    try {
      if (!portfolioData.id) {
        ElMessage.warning('项目集ID不存在')
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
        updateData.record_type = 'Pm::Portfolio'
        updateData.record_id = portfolioData.id
      }

      const res = await createActivityApi(updateData)
      // 更新项目集数据
      Object.assign(portfolioData as any, (res as any).data || {})

      // 清空输入
      statusInput.value = ''
      mentionIds.value = []

      ElMessage.success('状态已更新')
    } catch (error) {
      console.error('保存状态失败:', error)
      ElMessage.error('保存状态失败')
    }
  }

  /**
   * 处理描述失焦
   */
  const handleDescriptionBlur = async (): Promise<void> => {
    await savePortfolioField('description', portfolioData.description)
  }

  /**
   * 处理名称失焦
   */
  const handleNameBlur = async (): Promise<void> => {
    const nextName = (portfolioData.name || '').trim()
    if (!nextName) {
      ElMessage.warning('项目集名称不能为空')
      portfolioData.name = lastSavedName.value
      return
    }
    if (nextName === lastSavedName.value) return
    portfolioData.name = nextName
    const saved = await savePortfolioField('name', nextName)
    if (saved) {
      lastSavedName.value = nextName
    }
  }

  /**
   * 处理开始日期变化
   */
  const handleStartDateChange = async (date: Date | null): Promise<void> => {
    if (date) {
      portfolioData.start_date = formatDateString(date)
      await savePortfolioField('start_date', portfolioData.start_date)
    }
  }

  /**
   * 处理结束日期变化
   */
  const handleEndDateChange = async (date: Date | null): Promise<void> => {
    if (date) {
      portfolioData.end_date = formatDateString(date)
      await savePortfolioField('end_date', portfolioData.end_date)
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
    portfolioData.manager_id = user.id
    portfolioData.manager_name = user.name || user.email
    await savePortfolioField('manager_id', portfolioData.manager_id)
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
    if (!portfolioData.id) {
      ElMessage.warning('项目集ID不存在')
      return
    }

    try {
      const members = memberList.value.map((m) => ({
        id: m.id,
        name: m.name
      }))
      const res = await updatePmPortfolioApi(String(portfolioData.id), {
        members: members
      })
      // 更新项目集数据
      Object.assign(portfolioData as any, (res as any).data || {})
      ElMessage.success('成员已更新')
    } catch (error) {
      console.error('保存成员失败:', error)
      ElMessage.error('保存成员失败')
    }
  }

  /**
   * 保存项目集字段
   */
  const savePortfolioField = async (field: string, value: any): Promise<boolean> => {
    if (!portfolioData.id) {
      ElMessage.warning('项目集ID不存在')
      return false
    }

    try {
      const res = await updatePmPortfolioApi(String(portfolioData.id), {
        [field]: value
      })
      // 更新项目集数据
      Object.assign(portfolioData as any, (res as any).data || {})
      ElMessage.success(`保存${field}成功`)
      if (field === 'name') {
        lastSavedName.value = (portfolioData.name || '').trim()
      }
      return true
    } catch (error) {
      console.error(`保存${field}失败:`, error)
      ElMessage.error(`保存${field}失败`)
      return false
    }
  }

  /**
   * 返回上一页
   */
  const handleBack = (): void => {
    router.back()
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
      return record.status_color
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
        backgroundColor: record.status_color,
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

  onMounted(async () => {
    // 先加载状态列表，再加载详情
    await loadStatusList()
    await loadPortfolioDetail()
    // 加载默认用户列表
    await loadDefaultUsers()
  })
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';

  .portfolio-detail-page {
    @apply h-full flex flex-col bg-g-100;
  }

  .detail-header {
    @apply flex items-center justify-between px-4 py-3 bg-white border-b border-g-200;
  }

  .header-left {
    @apply flex items-center gap-4;
  }

  .document-title {
    @apply flex items-center text-base font-medium text-g-900;
  }

  .back-btn {
    @apply text-g-600;
  }

  .back-btn:hover {
    @apply text-g-900;
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

  .user-avatar {
    @apply w-8 h-8 rounded-full bg-g-200 flex items-center justify-center text-g-600;
  }

  .detail-content {
    @apply flex-1 overflow-auto p-4 gap-4;

    display: grid;
    grid-template-columns: 1fr 320px;
  }

  .content-left {
    @apply space-y-4;
  }

  .content-right {
    @apply space-y-4;
  }

  .config-card,
  .status-card,
  .info-card {
    @apply p-4;
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

  .name-input :deep(.el-input__wrapper) {
    background: rgb(242 243 245);
    border: 1px solid var(--el-border-color-light);
  }

  .card-title {
    @apply text-sm font-medium text-g-900;
  }

  .card-subtitle {
    @apply text-xs text-g-500 mb-3;
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

  .status-selector {
    @apply space-y-1;
  }

  .status-option {
    @apply flex items-center px-3 py-2 cursor-pointer hover:bg-g-100 rounded transition-colors;
  }

  .status-option.active {
    @apply bg-g-100;

    color: var(--el-color-primary);
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

  .status-warning {
    @apply text-xs text-orange-500;
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
