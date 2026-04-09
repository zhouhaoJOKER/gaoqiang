<template>
  <ElDialog
    :title="dialogTitle"
    :model-value="visible"
    @update:model-value="handleCancel"
    width="920px"
    align-center
    class="menu-dialog"
    @closed="handleClosed"
  >
    <ArtForm
      ref="formRef"
      v-model="form"
      :items="formItems"
      :rules="rules"
      :span="width > 640 ? 12 : 24"
      :gutter="20"
      label-width="100px"
      :show-reset="false"
      :show-submit="false"
    >
      <template #menuType>
        <ElRadioGroup v-model="form.menuType" :disabled="disableMenuType">
          <ElRadioButton value="menu" label="menu">菜单</ElRadioButton>
          <ElRadioButton value="button" label="button">按钮</ElRadioButton>
        </ElRadioGroup>
      </template>

      <!-- 图标选择自定义插槽 -->
      <template #icon>
        <div class="icon-input-wrapper">
          <ElInput
            v-model="form.icon"
            placeholder="如：ri:user-line"
            @click="showIconPicker = true"
            clearable
          >
            <template #suffix>
              <ArtSvgIcon v-if="form.icon" :icon="form.icon" class="icon-preview cursor-pointer" />
              <ElButton
                type="text"
                size="small"
                class="icon-picker-btn"
                @click="showIconPicker = true"
              >
                选择
              </ElButton>
            </template>
          </ElInput>
        </div>
      </template>

      <!-- 按钮权限选择自定义插槽 -->
      <template #authList>
        <div class="auth-list-wrapper">
          <div class="auth-list-header flex justify-between items-center mb-4">
            <h4 class="text-sm font-medium text-gray-700">选择常用权限标识</h4>
            <ElButton type="primary" size="small" @click="toggleSelectAll">
              {{ isAllSelected ? '取消全选' : '全选' }}
            </ElButton>
          </div>

          <ElCheckboxGroup v-model="selectedAuths" @change="handleAuthSelect">
            <ElSpace wrap>
              <ElCheckbox
                v-for="item in authList"
                :key="item.authMark"
                :label="item.authMark"
                class="auth-checkbox"
              >
                <div class="auth-item flex items-center">
                  <span class="auth-label">{{ item.title }}</span>
                  <span class="auth-mark text-gray-500 text-xs ml-2">({{ item.authMark }})</span>
                </div>
              </ElCheckbox>
            </ElSpace>
          </ElCheckboxGroup>

          <!-- 权限表格 -->
          <div class="mt-1">
            <h4 class="text-sm font-medium text-gray-700 mb-2">权限列表</h4>
            <div class="auth-table-container">
              <table class="auth-table">
                <thead>
                  <tr>
                    <th width="30%">权限名称</th>
                    <th width="30%">权限标识</th>
                    <th width="12%">操作</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="(row, index) in permissionItems" :key="index">
                    <td>
                      <ElInput v-model="row.title" placeholder="请输入权限名称" size="small" />
                    </td>
                    <td>
                      <ElInput v-model="row.name" placeholder="请输入权限标识" size="small" />
                    </td>
                    <td class="operation-buttons">
                      <ElSpace>
                        <ElButton
                          type="primary"
                          size="small"
                          @click="addPermissionItem(index)"
                          title="新增行"
                        >
                          <ArtSvgIcon icon="ri:add-line" />
                        </ElButton>
                        <ElButton
                          type="success"
                          size="small"
                          @click="copyPermissionItem(index)"
                          title="复制行"
                        >
                          <ArtSvgIcon icon="ri:file-copy-2-line" />
                        </ElButton>
                        <ElButton
                          type="danger"
                          size="small"
                          @click="removePermissionItem(index)"
                          title="删除行"
                        >
                          <ArtSvgIcon icon="ri:delete-row" />
                        </ElButton>
                      </ElSpace>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </template>
    </ArtForm>

    <!-- 图标选择弹窗 -->
    <IconPickerDialog
      v-model:visible="showIconPicker"
      :model-value="form.icon"
      @confirm="selectIcon"
    />

    <template #footer>
      <span class="dialog-footer">
        <ElButton @click="handleCancel">取 消</ElButton>
        <ElButton type="primary" @click="handleSubmit">确 定</ElButton>
      </span>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import type { FormRules } from 'element-plus'
  import {
    ElButton,
    ElCheckbox,
    ElCheckboxGroup,
    ElIcon,
    ElInput,
    ElSpace,
    ElTooltip,
    ElMessage
  } from 'element-plus'
  import { QuestionFilled } from '@element-plus/icons-vue'
  import { formatMenuTitle } from '@/utils/router'
  import type { AppRouteRecord } from '@/types/router'
  import type { FormItem } from '@/components/core/forms/art-form/index.vue'
  import ArtForm from '@/components/core/forms/art-form/index.vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import IconPickerDialog from '@/components/IconPickerDialog.vue'
  import { computed, reactive, ref, watch } from 'vue'
  import { useWindowSize } from '@vueuse/core'

  const { width } = useWindowSize()

  // 图标选择弹窗显示状态
  const showIconPicker = ref(false)

  // 权限列表数据
  const authList = [
    { authMark: 'add', title: '新增' },
    { authMark: 'delete', title: '删除' },
    { authMark: 'edit', title: '编辑' },
    { authMark: 'view', title: '查看' },
    { authMark: 'clone', title: '克隆' },
    { authMark: 'batchAdd', title: '批量新增' },
    { authMark: 'batchEdit', title: '批量修改' },
    { authMark: 'batchDelete', title: '批量删除' },
    { authMark: 'import', title: '导入' },
    { authMark: 'export', title: '导出' }
  ]

  // 选中的权限
  const selectedAuths = ref<string[]>([])

  // 权限表格数据
  const permissionItems = ref<any[]>([{ title: '', name: '' }])

  // 是否全选
  const isAllSelected = computed(() => {
    return selectedAuths.value.length === authList.length
  })

  // 全选/取消全选
  const toggleSelectAll = () => {
    if (isAllSelected.value) {
      selectedAuths.value = []
    } else {
      selectedAuths.value = authList.map((item) => item.authMark)
    }
    // 直接调用handleAuthSelect函数，确保表格数据更新
    handleAuthSelect()
  }

  // 处理权限选择变化
  const handleAuthSelect = () => {
    // 根据选中的权限更新表格数据
    if (selectedAuths.value.length > 0) {
      // 获取当前表格中已有的权限标识
      const existingAuthMarks = permissionItems.value.map((item) => item.name)

      // 遍历选中的权限，只添加不存在的
      selectedAuths.value.forEach((authMark) => {
        if (!existingAuthMarks.includes(authMark)) {
          const authItem = authList.find((item) => item.authMark === authMark)
          if (authItem) {
            permissionItems.value.push({
              title: authItem.title,
              name: authItem.authMark
            })
          }
        }
      })
      // // 确保至少有一行数据
      // if (permissionItems.value.length === 0) {
      //   permissionItems.value.push({ title: '', name: '' })
      // }
    } else {
      // 取消全选时，不清空表格数据，保留用户已经添加的权限
      // 只需要确保至少有一行数据
      // if (permissionItems.value.length === 0) {
      //   permissionItems.value.push({ title: '', name: '' })
      // }
    }
  }

  // 添加权限项
  const addPermissionItem = (index: number) => {
    permissionItems.value.splice(index + 1, 0, { title: '', name: '' })
  }

  // 复制权限项
  const copyPermissionItem = (index: number) => {
    const rowToCopy = { ...permissionItems.value[index] }
    permissionItems.value.splice(index + 1, 0, rowToCopy)
  }

  // 删除权限项
  const removePermissionItem = (index: number) => {
    permissionItems.value.splice(index, 1)
  }

  /**
   * 创建带 tooltip 的表单标签
   * @param label 标签文本
   * @param tooltip 提示文本
   * @returns 渲染函数
   */
  const createLabelTooltip = (label: string, tooltip: string) => {
    return () =>
      h('span', { class: 'flex items-center' }, [
        h('span', label),
        h(
          ElTooltip,
          {
            content: tooltip,
            placement: 'top'
          },
          () => h(ElIcon, { class: 'ml-0.5 cursor-help' }, () => h(QuestionFilled))
        )
      ])
  }

  interface MenuFormData {
    parent_id: string
    id: string
    name: string
    path: string
    label: string
    component: string
    icon: string
    isEnable: boolean
    sort: number
    isMenu: boolean
    keepAlive: boolean
    isHide: boolean
    isHideTab: boolean
    link: string
    isIframe: boolean
    showBadge: boolean
    showTextBadge: string
    fixedTab: boolean
    activePath: string
    roles: string[]
    isFullPage: boolean
    authMark: string
    title: string
    authIcon: string
    authSort: number
    permissions?: any[]
  }

  interface Props {
    visible: boolean
    editData?: AppRouteRecord | any
    type?: 'menu' | 'button'
    lockType?: boolean
  }

  interface Emits {
    (e: 'update:visible', value: boolean): void
    (e: 'submit', data: MenuFormData): void
  }

  const props = withDefaults(defineProps<Props>(), {
    visible: false,
    type: 'menu',
    lockType: false
  })

  const emit = defineEmits<Emits>()

  const formRef = ref()
  const isEdit = ref(false)

  const form = reactive<MenuFormData & { menuType: 'menu' | 'button' }>({
    parent_id: '',
    menuType: 'menu',
    id: '',
    name: '',
    path: '',
    label: '',
    component: '',
    icon: '',
    isEnable: true,
    sort: 1,
    isMenu: true,
    keepAlive: true,
    isHide: false,
    isHideTab: false,
    link: '',
    isIframe: false,
    showBadge: false,
    showTextBadge: '',
    fixedTab: false,
    activePath: '',
    roles: [],
    isFullPage: false,
    authMark: '',
    title: '',
    authIcon: '',
    authSort: 1
  })

  const rules = reactive<FormRules>({
    title: [
      { required: true, message: '请输入菜单名称', trigger: 'blur' },
      { min: 2, max: 32, message: '长度在 2 到 32 个字符', trigger: 'blur' }
    ],
    path: [{ required: true, message: '请输入路由地址', trigger: 'blur' }],
    name: [{ required: true, message: '输入权限标识', trigger: 'blur' }],
    authName: [{ required: true, message: '请输入权限名称', trigger: 'blur' }],
    authLabel: [{ required: true, message: '请输入权限标识', trigger: 'blur' }]
  })

  /**
   * 表单项配置
   */
  const formItems = computed<FormItem[]>(() => {
    const baseItems: FormItem[] = [{ label: '菜单类型', key: 'menuType', span: 24 }]

    // Switch 组件的 span：小屏幕 12，大屏幕 6
    const switchSpan = width.value < 640 ? 12 : 6

    if (form.menuType === 'menu') {
      return [
        ...baseItems,
        {
          label: createLabelTooltip('菜单名称', '此处需要配置国际化显示,数据库返回的 title 字段'),
          key: 'title',
          type: 'input',
          props: { placeholder: '如: menus.dashboard.console' }
        },
        {
          label: createLabelTooltip('标题', '新建时候无需填写，仅展示'),
          key: 'label',
          type: 'input',
          props: { placeholder: '如：控制台', readonly: true }
        },
        {
          label: createLabelTooltip(
            '路由地址',
            '一级菜单：以 / 开头的绝对路径（如 /dashboard）\n二级及以下：相对路径（如 console、user）'
          ),
          key: 'path',
          type: 'input',
          props: { placeholder: '如：/dashboard 或 console' }
        },
        {
          label: createLabelTooltip('权限标识', '数据库返回的 name 字段'),
          key: 'name',
          type: 'input',
          props: { placeholder: '如：User' }
        },
        {
          label: createLabelTooltip(
            '组件路径',
            '一级父级菜单：填写 /index/index\n具体页面：填写组件路径（如 /system/user）\n目录菜单：留空'
          ),
          key: 'component',
          type: 'input',
          props: { placeholder: '如：/system/user 或留空' }
        },
        { label: '图标', key: 'icon', type: 'input', props: { placeholder: '如：ri:user-line' } },
        {
          label: '菜单排序',
          key: 'sort',
          type: 'number',
          props: { min: 1, controlsPosition: 'right', style: { width: '100%' } }
        },
        {
          label: '外部链接',
          key: 'link',
          type: 'input',
          props: { placeholder: '如：https://www.example.com' }
        },
        {
          label: '文本徽章',
          key: 'showTextBadge',
          type: 'input',
          props: { placeholder: '如：New、Hot' }
        },
        {
          label: createLabelTooltip(
            '激活路径',
            '用于详情页等隐藏菜单，指定高亮显示的父级菜单路径\n例如：用户详情页高亮显示"用户管理"菜单'
          ),
          key: 'activePath',
          type: 'input',
          props: { placeholder: '如：/system/user' }
        },
        { label: '是否启用', key: 'isEnable', type: 'switch', span: switchSpan },
        { label: '页面缓存', key: 'keepAlive', type: 'switch', span: switchSpan },
        { label: '隐藏菜单', key: 'isHide', type: 'switch', span: switchSpan },
        { label: '是否内嵌', key: 'isIframe', type: 'switch', span: switchSpan },
        { label: '显示徽章', key: 'showBadge', type: 'switch', span: switchSpan },
        { label: '固定标签', key: 'fixedTab', type: 'switch', span: switchSpan },
        { label: '标签隐藏', key: 'isHideTab', type: 'switch', span: switchSpan },
        { label: '全屏页面', key: 'isFullPage', type: 'switch', span: switchSpan }
      ]
    } else {
      return [
        ...baseItems,
        {
          label: '常用权限标识',
          key: 'authList',
          type: 'custom',
          span: 24
        }
      ]
    }
  })

  const dialogTitle = computed(() => {
    const type = form.menuType === 'menu' ? '菜单' : '按钮'
    return isEdit.value ? `编辑${type}` : `新建${type}`
  })

  /**
   * 是否禁用菜单类型切换
   */
  const disableMenuType = computed(() => {
    if (isEdit.value) return true
    if (!isEdit.value && form.menuType === 'menu' && props.lockType) return true
    return false
  })

  /**
   * 监听权限标识变化，自动更新选中状态（仅菜单模式）
   */
  watch(
    () => form.name,
    (newVal) => {
      // 仅在菜单模式下更新选中状态
      if (form.menuType === 'menu') {
        if (newVal) {
          selectedAuths.value = newVal.split(',').filter((auth) => auth)
        } else {
          selectedAuths.value = []
        }
      }
    },
    { immediate: true }
  )

  /**
   * 选择图标
   */
  const selectIcon = (icon: string) => {
    form.icon = icon
  }

  /**
   * 重置表单数据
   */
  const resetForm = (): void => {
    formRef.value?.reset()
    form.menuType = 'menu'
  }

  /**
   * 加载表单数据（编辑模式）
   */
  const loadFormData = (): void => {
    if (!props.editData) return

    isEdit.value = true

    if (form.menuType === 'menu') {
      const row = props.editData
      form.parent_id = row.parent_id || ''
      form.id = row.id || 0
      form.label = formatMenuTitle(row.meta?.title || '')
      form.name = row.name
      form.path = row.path || ''
      form.title = row.meta?.title || ''
      form.component = row.component || ''
      form.icon = row.meta?.icon || ''
      form.sort = row.sort || 1
      form.isMenu = row.meta?.isMenu ?? true
      form.keepAlive = row.meta?.keepAlive ?? false
      form.isHide = row.meta?.isHide ?? false
      form.isHideTab = row.meta?.isHideTab ?? false
      form.isEnable = row.meta?.isEnable ?? true
      form.link = row.meta?.link || ''
      form.isIframe = row.meta?.isIframe ?? false
      form.showBadge = row.meta?.showBadge ?? false
      form.showTextBadge = row.meta?.showTextBadge || ''
      form.fixedTab = row.meta?.fixedTab ?? false
      form.activePath = row.meta?.activePath || ''
      form.roles = row.meta?.roles || []
      form.isFullPage = row.meta?.isFullPage ?? false
    } else {
      const row = props.editData
      form.id = row.id || ''
      form.parent_id = row.parent_id || ''
      form.title = row.title || ''
      form.name = row.name || ''
      form.icon = row.icon || ''
      form.sort = row.sort || 1

      // 处理currentAuthList数据，填充到表格中
      if (row.currentAuthList && Array.isArray(row.currentAuthList)) {
        // 使用currentAuthList数据填充表格
        permissionItems.value = row.currentAuthList.map((auth: any) => ({
          title: auth.title || '',
          name: auth.authMark || auth.name || ''
        }))
        // 确保至少有一行数据
        if (permissionItems.value.length === 0) {
          permissionItems.value.push({ title: '', name: '' })
        }
      } else {
        // 如果没有currentAuthList数据，只显示一行空数据
        permissionItems.value = [{ title: '', name: '' }]
      }
    }
  }

  /**
   * 提交表单
   */
  const handleSubmit = async (): Promise<void> => {
    if (!formRef.value) return

    try {
      await formRef.value.validate()

      // 处理权限表格数据，转换为需要的格式
      const submitForm = { ...form }
      // 可以根据需要处理permissionItems数据
      // 例如：可以将表格数据作为数组传递，或者拼接成字符串
      submitForm.permissions = permissionItems.value

      emit('submit', submitForm)
      // ElMessage.success(`${isEdit.value ? '编辑' : '新增'}成功`)
      handleCancel()
    } catch {
      ElMessage.error('表单校验失败，请检查输入')
    }
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
    resetForm()
    isEdit.value = false
  }

  /**
   * 监听对话框显示状态
   */
  watch(
    () => props.visible,
    (newVal) => {
      if (newVal) {
        form.menuType = props.type
        nextTick(() => {
          if (props.editData) {
            loadFormData()
          }
        })
      }
    }
  )

  /**
   * 监听菜单类型变化
   */
  watch(
    () => props.type,
    (newType) => {
      if (props.visible) {
        form.menuType = newType
      }
    }
  )
</script>

<style scoped>
  .icon-input-wrapper {
    position: relative;
  }

  .icon-preview {
    margin-right: 8px;
    font-size: 20px;
    color: #1890ff;
  }

  .cursor-pointer {
    cursor: pointer;
  }

  .icon-picker-btn {
    padding: 0;
    margin-left: 4px;
  }

  /* 权限选择区域样式 */
  .auth-list-wrapper {
    padding: 12px;
    margin-top: 4px;
    background-color: #f8f9fa;
    border: 1px solid #e9ecef;
    border-radius: 4px;
  }

  .auth-list-header {
    margin-bottom: 12px;
  }

  .auth-checkbox {
    margin-bottom: 8px;
  }

  .auth-item {
    display: flex;
    align-items: center;
  }

  .auth-label {
    font-weight: 500;
  }

  .auth-mark {
    margin-left: 4px;
    font-size: 12px;
    color: #6c757d;
  }

  /* 美化选择框样式 */
  :deep(.el-checkbox) {
    margin-right: 12px;
    margin-bottom: 8px;
  }

  :deep(.el-checkbox__input.is-checked .el-checkbox__inner) {
    background-color: #409eff;
    border-color: #409eff;
  }

  :deep(.el-checkbox__input.is-checked + .el-checkbox__label) {
    color: #409eff;
  }

  /* 权限表格样式 */
  .auth-table-container {
    max-height: 400px;
    overflow-y: auto;
    border: 1px solid #e9ecef;
    border-radius: 4px;
  }

  .auth-table {
    width: 100%;
    border-collapse: collapse;
    background-color: #fff;
  }

  .auth-table th,
  .auth-table td {
    padding: 1px;
    text-align: left;
    vertical-align: middle;
    border: 1px solid #e9ecef;
  }

  .auth-table th {
    position: sticky;
    top: 0;
    z-index: 10;
    font-size: 14px;
    font-weight: 600;
    color: #495057;
    background-color: #f8f9fa;
  }

  .auth-table tr:hover td {
    background-color: #fafafa;
  }

  /* 操作按钮样式 */
  .operation-buttons {
    display: flex;
    gap: 2px;
    justify-content: left;
    padding: 2px 0;
  }

  .el-space {
    display: inline-flex;
    margin: 2px;
  }

  /* 输入控件样式调整 */
  :deep(.el-input),
  :deep(.el-input-number),
  :deep(.el-textarea) {
    width: 100%;
  }

  /* 自定义滚动条样式 */
  .auth-table-container::-webkit-scrollbar {
    width: 8px;
    height: 8px;
  }

  .auth-table-container::-webkit-scrollbar-track {
    background: #f1f1f1;
    border-radius: 4px;
  }

  .auth-table-container::-webkit-scrollbar-thumb {
    background: #c1c1c1;
    border: 2px solid #f1f1f1;
    border-radius: 4px;
  }

  .auth-table-container::-webkit-scrollbar-thumb:hover {
    background: #a8a8a8;
  }
</style>
