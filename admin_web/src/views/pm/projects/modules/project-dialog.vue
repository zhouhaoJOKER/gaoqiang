<!-- 项目创建/编辑弹窗 -->
<template>
  <ElDialog
    :title="dialogTitle"
    :model-value="visible"
    @update:model-value="handleCancel"
    width="600px"
    align-center
    class="project-dialog"
    @closed="handleClosed"
  >
    <div class="project-form">
      <!-- 项目名称 -->
      <div class="form-item">
        <ElInput v-model="form.name" placeholder="输入项目名称" size="large" clearable />
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

      <!-- 项目集 -->
      <div class="form-item">
        <div class="form-item-label">
          <ArtSvgIcon icon="ri:folder-line" class="mr-2" />
          <span>所属项目集</span>
        </div>
        <ElSelect
          v-model="form.portfolio_id"
          placeholder="请选择项目集"
          size="large"
          style="width: 100%"
          clearable
          filterable
        >
          <ElOption
            v-for="option in portfolioOptions"
            :key="option.value"
            :label="option.label"
            :value="option.value"
          />
        </ElSelect>
      </div>

      <!-- 项目描述 -->
      <div class="form-item">
        <div class="form-item-label">
          <ArtSvgIcon icon="ri:file-text-line" class="mr-2" />
          <span>项目描述</span>
        </div>
        <ElInput
          v-model="form.description"
          type="textarea"
          :rows="3"
          placeholder="请填写项目描述"
          maxlength="500"
          show-word-limit
        />
      </div>

      <!-- 项目成员 -->
      <div class="form-item">
        <div class="form-item-label">
          <span>项目成员 · {{ memberList.length }}</span>
          <ElTooltip content="添加项目成员" placement="top">
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
  import { ref, reactive, computed, watch } from 'vue'
  import { ElMessage } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import UserSelectDialog from '@/components/UserSelectDialog.vue'
  import { listPropertyApi } from '@/api/property'
  import { listPmPortfolioApi } from '@/api/pm/portfolio'
  import { useUserStore } from '@/store/modules/user'

  // 获取当前用户信息
  const userStore = useUserStore()
  const currentUser = computed(() => userStore.info)

  interface Props {
    visible: boolean
    editData?: any
    templateData?: any // 模板数据
  }

  interface Emits {
    (e: 'update:visible', value: boolean): void
    (e: 'submit', formData: any): void
  }

  const props = withDefaults(defineProps<Props>(), {
    visible: false,
    editData: null,
    templateData: null
  })

  const emit = defineEmits<Emits>()

  // 表单数据
  const form = reactive({
    id: undefined as string | number | undefined,
    name: '',
    description: '',
    start_date: '',
    end_date: '',
    manager_id: undefined as string | number | undefined,
    manager_name: '',
    status_id: undefined as string | number | undefined,
    portfolio_id: undefined as string | number | undefined,
    logo: '' as string,
    members: [] as any[]
  })

  // 日期范围
  const dateRange = ref<[Date, Date] | null>(null)

  // 成员列表
  const memberList = ref<Array<{ id: string | number; name: string; email?: string }>>([])

  // 状态选项
  const statusOptions = ref<Array<{ label: string; value: string | number }>>([])

  // 项目集选项
  const portfolioOptions = ref<Array<{ label: string; value: string | number }>>([])

  // 弹窗标题
  const dialogTitle = computed(() => {
    return form.id ? '编辑项目' : '新建项目'
  })

  // 负责人选择弹窗
  const managerSelectDialogVisible = ref(false)
  const memberSelectDialogVisible = ref(false)

  /**
   * 初始化表单
   */
  const initForm = (): void => {
    if (props.editData) {
      // 编辑模式：使用编辑数据
      Object.assign(form, {
        id: props.editData.id,
        name: props.editData.name || '',
        description: props.editData.description || '',
        start_date: props.editData.start_date || '',
        end_date: props.editData.end_date || '',
        manager_id: props.editData.manager_id,
        manager_name: props.editData.manager_name || '',
        status_id: props.editData.status_id,
        portfolio_id: props.editData.portfolio_id,
        logo: props.editData.logo || ''
      })

      // 设置日期范围
      if (form.start_date && form.end_date) {
        dateRange.value = [new Date(form.start_date), new Date(form.end_date)]
      } else {
        dateRange.value = null
      }

      // 加载成员列表
      const members = props.editData.members || []
      memberList.value = Array.isArray(members)
        ? members.map((m: any) => ({
            id: m.id || m,
            name: m.name || '',
            email: m.email || ''
          }))
        : []
    } else if (props.templateData) {
      // 新建模式：使用模板数据，负责人和成员默认使用当前用户
      const user = currentUser.value

      Object.assign(form, {
        id: undefined,
        name: props.templateData.name || '',
        description: props.templateData.description || '',
        start_date: props.templateData.start_date || '',
        end_date: props.templateData.end_date || '',
        manager_id: user?.userId,
        manager_name: user?.userName || user?.email || '',
        status_id: props.templateData.status_id,
        portfolio_id: props.templateData.portfolio_id,
        logo: props.templateData.logo || ''
      })

      // 设置日期范围
      if (form.start_date && form.end_date) {
        dateRange.value = [new Date(form.start_date), new Date(form.end_date)]
      } else {
        dateRange.value = null
      }

      // 项目成员默认使用当前用户
      if (user?.userId) {
        memberList.value = [
          {
            id: user.userId,
            name: user.userName || user.email || '',
            email: user.email || ''
          }
        ]
      } else {
        memberList.value = []
      }
    } else {
      // 新建模式：设置当前用户为负责人和成员
      const user = currentUser.value

      Object.assign(form, {
        id: undefined,
        name: '',
        description: '',
        start_date: '',
        end_date: '',
        manager_id: user?.userId,
        manager_name: user?.userName || user?.email || '',
        status_id: undefined,
        portfolio_id: undefined,
        logo: '',
        members: []
      })
      dateRange.value = null
      // 将当前用户添加为项目成员
      if (user?.userId) {
        memberList.value = [
          {
            id: user.userId,
            name: user.userName || user.email || '',
            email: user.email || ''
          }
        ]
      } else {
        memberList.value = []
      }
    }
  }

  /**
   * 加载状态选项
   */
  const loadStatusOptions = async (): Promise<void> => {
    try {
      const res = await listPropertyApi({ 'q[sign_eq]': 'project_status' })
      const data = (res as any).data || []
      statusOptions.value = Array.isArray(data)
        ? data.map((item: any) => ({
            label: item.name || '',
            value: item.id
          }))
        : []
    } catch (error) {
      console.error('加载状态选项失败:', error)
      statusOptions.value = []
    }
  }

  /**
   * 加载项目集选项
   */
  const loadPortfolioOptions = async (): Promise<void> => {
    try {
      const res = await listPmPortfolioApi({})
      const data = (res as any).data || []
      portfolioOptions.value = Array.isArray(data)
        ? data.map((item: any) => ({
            label: item.name || '',
            value: item.id
          }))
        : []
    } catch (error) {
      console.error('加载项目集选项失败:', error)
      portfolioOptions.value = []
    }
  }

  /**
   * 处理日期范围变化
   */
  const handleDateRangeChange = (dates: [Date, Date] | null): void => {
    if (dates && dates.length === 2) {
      form.start_date = formatDate(dates[0])
      form.end_date = formatDate(dates[1])
    } else {
      form.start_date = ''
      form.end_date = ''
    }
  }

  /**
   * 格式化日期
   */
  const formatDate = (date: Date): string => {
    const year = date.getFullYear()
    const month = String(date.getMonth() + 1).padStart(2, '0')
    const day = String(date.getDate()).padStart(2, '0')
    return `${year}-${month}-${day}`
  }

  /**
   * 显示负责人选择弹窗
   */
  const showManagerSelectDialog = (): void => {
    managerSelectDialogVisible.value = true
  }

  /**
   * 负责人选择回调
   */
  const handleManagerSelect = (user: any): void => {
    form.manager_id = user.id
    form.manager_name = user.name || user.email
  }

  /**
   * 清除负责人
   */
  const clearManager = (): void => {
    form.manager_id = undefined
    form.manager_name = ''
  }

  /**
   * 显示成员选择弹窗
   */
  const showMemberSelectDialog = (): void => {
    memberSelectDialogVisible.value = true
  }

  /**
   * 成员选择回调
   */
  const handleMemberSelect = (users: any[]): void => {
    const newMembers = users.map((user) => ({
      id: user.id,
      name: user.name || user.email || '',
      email: user.email || ''
    }))

    // 合并已存在的成员，避免重复
    const existingIds = memberList.value.map((m) => m.id)
    const uniqueMembers = newMembers.filter((m) => !existingIds.includes(m.id))
    memberList.value.push(...uniqueMembers)
  }

  /**
   * 移除成员
   */
  const removeMember = (memberId: string | number): void => {
    memberList.value = memberList.value.filter((m) => m.id !== memberId)
  }

  /**
   * 获取成员首字母
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
   * 取消
   */
  const handleCancel = (): void => {
    emit('update:visible', false)
  }

  /**
   * 关闭后重置
   */
  const handleClosed = (): void => {
    initForm()
  }

  /**
   * 提交
   */
  const handleSubmit = async (): Promise<void> => {
    if (!form.name?.trim()) {
      ElMessage.warning('请输入项目名称')
      return
    }

    const formData = {
      ...form,
      members: memberList.value.map((m) => ({
        id: m.id,
        name: m.name
      }))
    }

    emit('submit', formData)
  }

  // 监听弹窗显示状态
  watch(
    () => props.visible,
    (newVal) => {
      if (newVal) {
        initForm()
        loadStatusOptions()
        loadPortfolioOptions()
      }
    },
    { immediate: true }
  )

  // 监听模板数据变化
  watch(
    () => props.templateData,
    () => {
      if (props.visible && !props.editData) {
        initForm()
      }
    },
    { deep: true }
  )
</script>

<style scoped lang="scss">
  .project-dialog {
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

  .project-form {
    display: flex;
    flex-direction: column;
    gap: 20px;
  }

  .form-item {
    display: flex;
    flex-direction: column;
    gap: 8px;
  }

  .form-item-label {
    display: flex;
    align-items: center;
    font-size: 14px;
    font-weight: 500;
    color: var(--el-text-color-primary);
  }

  .member-list {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
  }

  .member-item {
    display: flex;
    gap: 8px;
    align-items: center;
    padding: 6px 12px;
    font-size: 14px;
    background: var(--el-fill-color-light);
    border-radius: 16px;
  }

  .member-avatar {
    display: flex;
    flex-shrink: 0;
    align-items: center;
    justify-content: center;
    width: 24px;
    height: 24px;
    font-size: 12px;
    font-weight: 500;
    color: white;
    background: var(--el-color-primary);
    border-radius: 50%;
  }

  .member-name {
    flex: 1;
    min-width: 0;
    overflow: hidden;
    text-overflow: ellipsis;
    white-space: nowrap;
  }

  .add-member-btn {
    display: flex;
    align-items: center;
    justify-content: center;
    width: 32px;
    height: 32px;
    padding: 0;
    cursor: pointer;
    background: var(--el-color-primary);
    border-radius: 50%;
    transition: all 0.2s;

    &:hover {
      background: var(--el-color-primary-light-3);
    }
  }

  .dialog-footer {
    display: flex;
    gap: 12px;
    justify-content: flex-end;
  }
</style>
