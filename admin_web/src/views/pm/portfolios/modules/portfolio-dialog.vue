<!-- 项目集弹窗 -->
<template>
  <ElDialog
    :title="dialogTitle"
    :model-value="visible"
    @update:model-value="handleCancel"
    width="600px"
    align-center
    class="portfolio-dialog"
    @closed="handleClosed"
  >
    <div class="portfolio-form">
      <!-- 项目集名称 -->
      <div class="form-item">
        <ElInput v-model="form.name" placeholder="输入项目集名称" size="large" clearable />
      </div>

      <!-- 负责人 -->
      <div class="form-item">
        <div class="form-item-label">
          <ArtSvgIcon icon="ri:user-line" class="mr-2" />
          <span>设置负责人</span>
        </div>
        <div class="flex items-center gap-2">
          <ElInput
            v-model="form.manager_name"
            placeholder="选择负责人"
            readonly
            style="flex: 1; cursor: pointer"
            @click="showManagerSelectDialog"
          />
          <ElButton v-if="form.manager_id" @click="clearManager">清除</ElButton>
        </div>
      </div>

      <!-- 开始和截止时间 -->
      <div class="form-item">
        <div class="form-item-label">
          <ArtSvgIcon icon="ri:calendar-line" class="mr-2" />
          <span>设置时间</span>
        </div>
        <ElDatePicker
          v-model="dateRange"
          type="daterange"
          range-separator=" - "
          start-placeholder="设置开始时间"
          end-placeholder="设置截止时间"
          size="large"
          style="width: 100%"
          @change="handleDateRangeChange"
        />
      </div>

      <!-- 项目集目标 -->
      <div class="form-item">
        <div class="form-item-label">
          <ArtSvgIcon icon="ri:target-line" class="mr-2" />
          <span>项目集目标</span>
        </div>
        <ElInput
          v-model="form.description"
          type="textarea"
          :rows="3"
          placeholder="请填写项目集目标"
          maxlength="500"
          show-word-limit
        />
      </div>

      <!-- 项目集成员 -->
      <div class="form-item">
        <div class="form-item-label">
          <span>项目集成员 · {{ memberList.length }}</span>
          <ElTooltip content="添加项目集成员" placement="top">
            <ArtSvgIcon icon="ri:question-line" class="ml-2 text-g-400 cursor-help" />
          </ElTooltip>
        </div>
        <div class="member-list">
          <div v-for="member in memberList" :key="member.id" class="member-item">
            <div class="member-avatar">
              {{ getMemberInitials(member.name || member.email) }}
            </div>
            <span class="member-name">{{ member.name || member.email }}</span>
            <ElButton text type="danger" size="small" @click="removeMember(member.id)">
              <ArtSvgIcon icon="ri:close-line" />
            </ElButton>
          </div>
          <div class="member-item add-member-btn" @click="showMemberSelectDialog">
            <ArtSvgIcon icon="ri:add-line" class="text-white" />
          </div>
        </div>
      </div>

      <!-- 私有模式 -->
      <div class="form-item">
        <div class="form-item-label">
          <ArtSvgIcon icon="ri:lock-line" class="mr-2" />
          <span>私有模式</span>
        </div>
        <div class="flex items-center gap-2">
          <ElSwitch v-model="form.is_star" />
          <span class="text-sm text-g-500">仅项目集成员可见</span>
        </div>
      </div>

      <!-- 状态（如果需要） -->
      <div v-if="statusOptions.length" class="form-item">
        <div class="form-item-label">
          <span>状态</span>
        </div>
        <ElSelect
          v-model="form.status_id"
          placeholder="请选择状态"
          size="large"
          style="width: 100%"
          clearable
        >
          <ElOption
            v-for="option in statusOptions"
            :key="option.value"
            :label="option.label"
            :value="option.value"
          />
        </ElSelect>
      </div>
    </div>

    <template #footer>
      <div class="dialog-footer">
        <ElButton @click="handleCancel">取消</ElButton>
        <ElButton type="primary" @click="handleSubmit">完成</ElButton>
        <ElButton type="primary" plain @click="handleSubmitAndAdd">完成并添加项目</ElButton>
      </div>
    </template>
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
</template>

<script setup lang="ts">
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import UserSelectDialog from '@/components/UserSelectDialog.vue'
  import { ElMessage } from 'element-plus'
  import { ref, reactive, computed, watch, nextTick } from 'vue'
  import { useUserStore } from '@/store/modules/user'
  import { storeToRefs } from 'pinia'

  interface PortfolioFormData {
    id?: string | number
    name: string
    status_id?: string | number
    start_date?: string
    end_date?: string
    is_star: boolean
    manager_id?: string | number
    manager_name?: string
    description?: string
    user_id?: string | number
    members?: (string | number)[]
  }

  interface Member {
    id: string | number
    name?: string
    email?: string
  }

  interface Props {
    visible: boolean
    editData?: any
  }

  interface Emits {
    (e: 'update:visible', value: boolean): void
    (e: 'submit', data: PortfolioFormData): void
    (e: 'submit-and-add', data: PortfolioFormData): void
  }

  const props = withDefaults(defineProps<Props>(), {
    visible: false
  })

  const emit = defineEmits<Emits>()

  // 获取当前用户信息
  const userStore = useUserStore()
  const { getUserInfo: userInfo } = storeToRefs(userStore)

  const form = reactive<PortfolioFormData>({
    name: '',
    status_id: undefined,
    start_date: '',
    end_date: '',
    is_star: false,
    manager_id: undefined,
    manager_name: '',
    description: '',
    user_id: '',
    members: []
  })

  const dateRange = ref<[Date, Date] | null>(null)
  const memberList = ref<Member[]>([])
  const managerSelectDialogVisible = ref(false)
  const memberSelectDialogVisible = ref(false)

  // 状态选项（可根据实际API获取）
  const statusOptions = ref([
    { label: '进度正常', value: 1 },
    { label: '进度异常', value: 2 },
    { label: '暂未开始', value: 3 }
  ])

  const dialogTitle = computed(() => {
    return props.editData ? '编辑项目集' : '新建项目集'
  })

  /**
   * 获取成员姓名首字母
   */
  const getMemberInitials = (text: string | undefined): string => {
    if (!text) return '?'
    const match = text.match(/[\u4e00-\u9fa5]/)
    if (match) {
      return match[0]
    }
    return text.charAt(0).toUpperCase()
  }

  /**
   * 显示负责人选择弹窗
   */
  const showManagerSelectDialog = () => {
    managerSelectDialogVisible.value = true
  }

  /**
   * 处理负责人选择
   */
  const handleManagerSelect = (user: any) => {
    form.manager_id = user.id
    form.manager_name = user.name || user.email
  }

  /**
   * 清除负责人
   */
  const clearManager = () => {
    form.manager_id = undefined
    form.manager_name = ''
  }

  /**
   * 显示成员选择弹窗
   */
  const showMemberSelectDialog = () => {
    memberSelectDialogVisible.value = true
  }

  /**
   * 处理成员选择（多选）
   */
  const handleMemberSelect = (users: any[]) => {
    const newMembers = users.map((user) => ({
      id: user.id,
      name: user.name,
      email: user.email
    }))

    // 合并已存在的成员，避免重复
    const existingIds = memberList.value.map((m) => m.id)
    const uniqueMembers = newMembers.filter((m) => !existingIds.includes(m.id))
    memberList.value.push(...uniqueMembers)

    // 更新 members 数组
    form.members = memberList.value.map((m) => m.id)
  }

  /**
   * 移除成员
   */
  const removeMember = (memberId: string | number) => {
    memberList.value = memberList.value.filter((m) => m.id !== memberId)
    form.members = memberList.value.map((m) => m.id)
  }

  /**
   * 处理日期范围变化
   */
  const handleDateRangeChange = (dates: [Date, Date] | null) => {
    if (dates && dates.length === 2) {
      form.start_date = formatDate(dates[0])
      form.end_date = formatDate(dates[1])
    } else {
      form.start_date = ''
      form.end_date = ''
    }
  }

  /**
   * 格式化日期为 YYYY-MM-DD
   */
  const formatDate = (date: Date): string => {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  /**
   * 解析日期字符串为 Date 对象
   */
  const parseDate = (dateStr: string): Date | null => {
    if (!dateStr) return null
    const date = new Date(dateStr)
    return isNaN(date.getTime()) ? null : date
  }

  /**
   * 重置表单
   */
  const resetForm = (isNew = false): void => {
    form.name = ''
    form.status_id = undefined
    form.start_date = ''
    form.end_date = ''
    form.is_star = false
    form.manager_id = undefined
    form.manager_name = ''
    form.description = ''
    form.user_id = undefined
    form.members = []
    memberList.value = []
    dateRange.value = null

    // 新建模式下，默认选中当前用户作为负责人和成员
    if (isNew && userInfo.value) {
      const userId = (userInfo.value as any).userId
      const userName = (userInfo.value as any).userName
      const userEmail = (userInfo.value as any).email

      if (userId) {
        const currentUser: Member = {
          id: userId,
          name: userName || '',
          email: userEmail || ''
        }

        // 设置负责人
        form.manager_id = currentUser.id
        form.manager_name = currentUser.name || currentUser.email || `用户${userId}`

        // 设置成员（默认包含自己）
        memberList.value = [currentUser]
        form.members = [currentUser.id]
      }
    }
  }

  /**
   * 加载表单数据（编辑模式）
   */
  const loadFormData = (): void => {
    if (!props.editData) return

    const row = props.editData
    form.name = row.name || ''
    form.status_id = row.status_id
    form.start_date = row.start_date || ''
    form.end_date = row.end_date || ''
    form.is_star = row.is_star || false
    form.manager_id = row.manager_id
    form.manager_name = row.manager_name || ''
    form.description = row.description || ''
    form.members = row.members || []

    // 设置日期范围
    if (form.start_date && form.end_date) {
      const start = parseDate(form.start_date)
      const end = parseDate(form.end_date)
      if (start && end) {
        dateRange.value = [start, end]
      }
    }

    // 加载成员列表（如果有）
    if (row.members && Array.isArray(row.members)) {
      memberList.value = row.members
    } else if (form.members && form.members.length) {
      // 如果只有 members，需要从用户列表获取用户信息
      // 这里暂时用 ID 作为占位
      memberList.value = form.members.map((id) => ({
        id,
        name: `用户${id}`,
        email: ''
      }))
    }
  }

  /**
   * 提交表单
   */
  const handleSubmit = async (): Promise<void> => {
    if (!form.name.trim()) {
      ElMessage.warning('请输入项目集名称')
      return
    }

    const submitData: PortfolioFormData = {
      ...form,
      members: memberList.value.map((m) => m.id)
    }

    emit('submit', submitData)
    handleCancel()
  }

  /**
   * 完成并添加项目
   */
  const handleSubmitAndAdd = async (): Promise<void> => {
    if (!form.name.trim()) {
      ElMessage.warning('请输入项目集名称')
      return
    }

    const submitData: PortfolioFormData = {
      ...form,
      members: memberList.value.map((m) => m.id)
    }

    emit('submit-and-add', submitData)
    handleCancel()
  }

  /**
   * 取消操作
   */
  const handleCancel = (): void => {
    emit('update:visible', false)
  }

  /**
   * 对话框关闭后的回调
   */
  const handleClosed = (): void => {
    resetForm(false)
  }

  /**
   * 监听对话框显示状态
   */
  watch(
    () => props.visible,
    (newVal) => {
      if (newVal) {
        const isNew = !props.editData
        resetForm(isNew)
        nextTick(() => {
          if (props.editData) {
            loadFormData()
          }
        })
      }
    }
  )
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';

  .portfolio-form {
    @apply space-y-4;
  }

  .form-item {
    @apply space-y-2;
  }

  .form-item-label {
    @apply flex items-center text-sm font-medium text-g-700;
  }

  .member-list {
    @apply flex flex-wrap gap-2;
  }

  .member-item {
    @apply flex items-center gap-2 px-3 py-1.5 bg-g-100 rounded-full;
  }

  .member-avatar {
    @apply flex items-center justify-center w-6 h-6 rounded-full bg-g-500 text-white text-xs font-medium;
  }

  .member-name {
    @apply text-sm text-g-700;
  }

  .add-member-btn {
    @apply w-6 h-6 p-0 bg-g-500 rounded-full cursor-pointer flex items-center justify-center hover:bg-g-600 transition-colors;
  }

  .dialog-footer {
    @apply flex justify-end gap-3;
  }
</style>
