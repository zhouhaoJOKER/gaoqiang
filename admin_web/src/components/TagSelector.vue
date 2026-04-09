<template>
  <div class="tag-selector">
    <ElPopover
      v-model:visible="tagPopoverVisible"
      placement="bottom-start"
      trigger="click"
      :width="280"
      popper-class="tag-select-popover"
    >
      <template #reference>
        <div class="tags-trigger" @click="handleTagClick">
          <div v-if="selectedTags.length > 0" class="selected-tags">
            <span
              v-for="tag in selectedTags"
              :key="tag.id"
              class="tag-pill"
              :class="tag.color ? `tag-pill-${tag.color}` : 'tag-pill-primary'"
            >
              {{ tag.name }}
              <ArtSvgIcon icon="ri:add-line" class="tag-add-icon" />
            </span>
          </div>
          <span v-else class="attribute-value">{{ placeholder }}</span>
        </div>
      </template>
      <div class="tag-select-content">
        <!-- 搜索框 -->
        <div class="tag-search-header">
          <ElInput
            v-model="tagSearchKeyword"
            placeholder="搜索标签"
            clearable
            class="tag-search-input"
            size="small"
            @input="handleTagSearch"
          />
          <!-- 添加按钮 -->
          <ElButton type="primary" circle size="small" class="tag-add-btn" @click="handleCreateTag">
            <ArtSvgIcon icon="ri:add-line" />
          </ElButton>
          <!-- 管理按钮 -->
          <ElButton
            type="primary"
            circle
            size="small"
            class="tag-add-btn"
            @click="handleShowConfig"
          >
            <ArtSvgIcon icon="ri:settings-3-line" />
          </ElButton>
        </div>
        <!-- 标签列表 -->
        <div class="tag-list">
          <div
            v-for="tag in filteredTagList"
            :key="tag.id"
            class="tag-item"
            @click="handleTagToggle(tag)"
          >
            <div class="tag-checkbox" :class="{ checked: isTagSelected(tag.id) }">
              <ArtSvgIcon v-if="isTagSelected(tag.id)" icon="ri:check-line" class="checkbox-icon" />
            </div>
            <span
              class="tag-pill-item"
              :class="tag.color ? `tag-pill-${tag.color}` : 'tag-pill-primary'"
            >
              {{ tag.name }}
            </span>
          </div>
          <div v-if="filteredTagList.length === 0" class="tag-empty">暂无标签</div>
        </div>
        <!-- 配置标签 -->
        <!-- <div class="tag-config-footer">
          <div class="tag-config-btn" @click="handleShowConfig">
            <ArtSvgIcon icon="ri:settings-3-line" class="config-icon" />
            <span>配置标签</span>
          </div>
        </div> -->
      </div>
    </ElPopover>

    <!-- 配置标签对话框 -->
    <PropertyConfigDialog
      v-model="configDialogVisible"
      :sign="sign"
      title="配置标签"
      @updated="handleConfigUpdated"
    />

    <!-- 创建标签对话框 -->
    <ElDialog
      v-model="createTagDialogVisible"
      title="创建标签"
      width="400px"
      :close-on-click-modal="false"
      align-center
      class="create-tag-dialog"
    >
      <div class="create-tag-content">
        <!-- 标签名称输入 -->
        <ElInput
          v-model="newTagName"
          placeholder="标签名称"
          class="tag-name-input"
          maxlength="50"
          clearable
          autofocus
        />

        <!-- 颜色选择 -->
        <div class="color-selection">
          <div
            v-for="color in tagColors"
            :key="color.value"
            class="color-swatch"
            :class="{ selected: newTagColor === color.value, [`color-${color.value}`]: true }"
            @click="newTagColor = color.value"
          >
            <ArtSvgIcon
              v-if="newTagColor === color.value"
              icon="ri:check-line"
              class="color-check-icon"
            />
          </div>
        </div>
      </div>

      <template #footer>
        <div class="dialog-footer">
          <ElButton
            type="primary"
            :disabled="!newTagName.trim() || !newTagColor"
            class="create-tag-btn"
            @click="handleSubmitCreateTag"
          >
            创建
          </ElButton>
        </div>
      </template>
    </ElDialog>
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, watch, onMounted } from 'vue'
  import { ElMessage } from 'element-plus'
  import { ElPopover, ElInput, ElButton, ElDialog } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import PropertyConfigDialog from '@/components/PropertyConfigDialog.vue'
  import { listPropertyApi, createPropertyApi } from '@/api/property'

  interface Tag {
    id: string | number
    name: string
    color?: string
  }

  interface Props {
    modelValue: Tag[] | (string | number)[]
    sign: string // 标签类型标识，如 'task_tag', 'product_label'
    placeholder?: string
  }

  interface Emits {
    (e: 'update:modelValue', value: Tag[]): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: () => [],
    sign: 'task_tag',
    placeholder: '添加标签'
  })

  const emit = defineEmits<Emits>()

  // 标签列表
  const tagList = ref<Tag[]>([])
  const selectedTags = ref<Tag[]>([])
  const tagSearchKeyword = ref('')
  const tagPopoverVisible = ref(false)

  // 配置标签对话框
  const configDialogVisible = ref(false)

  // 创建标签对话框
  const createTagDialogVisible = ref(false)
  const newTagName = ref('')
  const newTagColor = ref<string>('')

  // 标签颜色选项（使用 Element Plus 系统颜色）
  const tagColors = [
    { value: 'primary' }, // 蓝色
    { value: 'success' }, // 深绿色
    { value: 'info' }, // 青色/青绿色
    { value: 'warning' }, // 橙色
    { value: 'danger' } // 红色
  ]

  // 过滤后的标签列表
  const filteredTagList = computed(() => {
    if (!tagSearchKeyword.value.trim()) {
      return tagList.value
    }
    const keyword = tagSearchKeyword.value.trim().toLowerCase()
    return tagList.value.filter((tag) => tag.name.toLowerCase().includes(keyword))
  })

  // 加载标签列表
  const loadTags = async (): Promise<void> => {
    try {
      const res = await listPropertyApi({ 'q[sign_eq]': props.sign })
      const data = (res as any).data || {}
      tagList.value = Array.isArray(data) ? data : data.list || data.data || []
      updateSelectedTags()
    } catch (error) {
      console.error('加载标签列表失败:', error)
    }
  }

  // 更新选中的标签
  const updateSelectedTags = (): void => {
    if (!props.modelValue || props.modelValue.length === 0) {
      selectedTags.value = []
      return
    }

    // 如果 modelValue 是对象数组，直接使用
    if (props.modelValue.length > 0 && typeof props.modelValue[0] === 'object') {
      selectedTags.value = props.modelValue as Tag[]
      return
    }

    // 如果 modelValue 是 ID 数组，需要从 tagList 中查找
    const labelIds = props.modelValue as (string | number)[]
    selectedTags.value = tagList.value.filter((tag) => labelIds.includes(tag.id))
  }

  // 标签点击
  const handleTagClick = (): void => {
    // Popover 会自动处理显示/隐藏
  }

  // 标签搜索
  const handleTagSearch = (): void => {
    // 搜索逻辑在 computed 中处理
  }

  // 标签切换选择
  const handleTagToggle = (tag: Tag): void => {
    const index = selectedTags.value.findIndex((t) => t.id === tag.id)
    if (index > -1) {
      // 取消选择
      selectedTags.value.splice(index, 1)
    } else {
      // 选择
      selectedTags.value.push(tag)
    }
    // 更新父组件
    emit('update:modelValue', [...selectedTags.value])
  }

  // 检查标签是否已选择
  const isTagSelected = (tagId: string | number): boolean => {
    return selectedTags.value.some((t) => t.id === tagId)
  }

  // 打开创建标签对话框
  const handleCreateTag = (): void => {
    newTagName.value = ''
    newTagColor.value = tagColors[0].value // 默认选择第一个颜色（蓝色）
    createTagDialogVisible.value = true
    tagPopoverVisible.value = false // 关闭标签选择弹窗
  }

  // 显示配置标签
  const handleShowConfig = (): void => {
    // 关闭弹窗
    tagPopoverVisible.value = false
    // 打开配置对话框
    configDialogVisible.value = true
  }

  // 配置更新回调
  const handleConfigUpdated = (): void => {
    // 重新加载标签列表
    loadTags()
  }

  // 提交创建标签
  const handleSubmitCreateTag = async (): Promise<void> => {
    if (!newTagName.value.trim()) {
      ElMessage.warning('请输入标签名称')
      return
    }

    if (!newTagColor.value) {
      ElMessage.warning('请选择标签颜色')
      return
    }

    try {
      const res = await createPropertyApi({
        sign: props.sign,
        name: newTagName.value.trim(),
        color: newTagColor.value
      })

      const newTag = (res as any).data || {}
      // 添加到标签列表
      const createdTag: Tag = {
        id: newTag.id,
        name: newTag.name || newTagName.value.trim(),
        color: newTag.color || newTagColor.value
      }
      tagList.value.push(createdTag)

      ElMessage.success('标签创建成功')
      createTagDialogVisible.value = false
      newTagName.value = ''
      newTagColor.value = ''

      // 自动选中新创建的标签
      handleTagToggle(createdTag)
    } catch (error: any) {
      console.error('创建标签失败:', error)
      const errorMessage = error?.response?.data?.message || error?.message || '创建标签失败'
      ElMessage.error(errorMessage)
    }
  }

  // 监听 modelValue 变化
  watch(
    () => props.modelValue,
    () => {
      updateSelectedTags()
    },
    { deep: true }
  )

  // 监听 sign 变化，重新加载标签
  watch(
    () => props.sign,
    () => {
      loadTags()
    }
  )

  onMounted(() => {
    loadTags()
  })
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
