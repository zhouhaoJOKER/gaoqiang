<!-- 属性配置对话框 -->
<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="560px"
    :close-on-click-modal="false"
    class="property-config-dialog"
    @closed="handleClosed"
  >
    <div class="property-config">
      <!-- 属性列表 -->
      <div class="property-list">
        <div
          v-for="item in propertyList"
          :key="item.id"
          class="property-item"
          :class="{ 'is-editing': String(editingId) === String(item.id) }"
        >
          <div v-if="String(editingId) === String(item.id)" class="property-edit">
            <div class="edit-input-row">
              <ElInput
                v-model="editForm.name"
                placeholder="请输入名称"
                size="small"
                class="edit-input"
              />
              <ElInput
                v-model="editForm.abbr"
                placeholder="标识"
                size="small"
                class="edit-abbr-input"
              />
            </div>
            <div class="color-selector">
              <div
                v-for="token in themeColorTokens"
                :key="token"
                class="color-option"
                :class="{ active: editForm.color === token }"
                :style="getColorOptionStyle(token)"
                :title="getColorLabel(token)"
                @click="editForm.color = token"
              >
                <ArtSvgIcon v-if="editForm.color === token" icon="ri:check-line" class="check" />
              </div>
            </div>
            <div class="edit-actions">
              <ElButton size="small" @click="handleCancelEdit">取消</ElButton>
              <ElButton type="primary" size="small" @click="handleSaveEdit">保存</ElButton>
            </div>
          </div>
          <div v-else class="property-display">
            <span class="property-tag" :style="getTagStyle(item)">
              {{ item.name }}
            </span>
            <div class="property-actions">
              <ElButton text size="small" @click="handleEdit(item)">
                <ArtSvgIcon icon="ri:edit-line" />
              </ElButton>
              <ElButton text size="small" class="delete-btn" @click="handleDelete(item)">
                <ArtSvgIcon icon="ri:delete-bin-line" />
              </ElButton>
            </div>
          </div>
        </div>

        <div v-if="propertyList.length === 0" class="empty-tip">暂无数据，请添加</div>
      </div>

      <!-- 新建表单 -->
      <div class="property-add">
        <div class="add-form">
          <div class="add-input-row">
            <ElInput
              v-model="addForm.name"
              placeholder="输入名称，按回车新建"
              class="add-input"
              @keyup.enter="handleAdd"
            />
            <ElSelect
              v-model="addForm.parent_id"
              placeholder="选择父级（可选）"
              clearable
              class="add-parent-select"
            >
              <ElOption
                v-for="item in propertyList"
                :key="item.id"
                :label="item.name"
                :value="item.id"
              />
            </ElSelect>

            <ElInput v-model="addForm.abbr" placeholder="标识" class="add-abbr-input" />
          </div>
          <div class="color-selector">
            <div
              v-for="token in themeColorTokens"
              :key="token"
              class="color-option"
              :class="{ active: addForm.color === token }"
              :style="getColorOptionStyle(token)"
              :title="getColorLabel(token)"
              @click="addForm.color = token"
            >
              <ArtSvgIcon v-if="addForm.color === token" icon="ri:check-line" class="check" />
            </div>
          </div>
        </div>
        <ElButton type="primary" :disabled="!addForm.name.trim()" @click="handleAdd">
          <ArtSvgIcon icon="ri:add-line" class="mr-1" />
          新建
        </ElButton>
      </div>
    </div>
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, computed, watch } from 'vue'
  import { ElMessage, ElMessageBox } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { ElSelect, ElOption } from 'element-plus'
  import {
    listPropertyApi,
    createPropertyApi,
    updatePropertyApi,
    deletePropertyApi
  } from '@/api/property'

  interface PropertyItem {
    id: string | number
    name: string
    color?: string
    bg_color?: string
    sort?: number
    [key: string]: any
  }

  const props = defineProps<{
    modelValue: boolean
    sign: string
    title?: string
  }>()

  const emit = defineEmits<{
    (e: 'update:modelValue', value: boolean): void
    (e: 'updated'): void
  }>()

  // ==================== 主题颜色提取 ====================

  /**
   * 获取 CSS 变量的实际值
   */
  const cssVar = (name: string): string => {
    if (typeof window === 'undefined') return ''
    return getComputedStyle(document.documentElement).getPropertyValue(name).trim()
  }

  /**
   * 预设的主题颜色列表
   */
  const themeColorTokens: string[] = [
    'noset',
    'primary',
    'success',
    'warning',
    'danger',
    'info',
    'primary-light-3',
    'success-light-3',
    'warning-light-3',
    'danger-light-3',
    'info-light-3',
    'primary-light-5',
    'success-light-5',
    'warning-light-5',
    'danger-light-5',
    'info-light-5',
    'primary-light-7',
    'success-light-7',
    'warning-light-7',
    'danger-light-7',
    'info-light-7'
  ]

  const colorLabelMap: Record<string, string> = {
    noset: '无颜色',
    purple: '紫色',
    cyan: '青色',
    pink: '粉色',
    orange: '橙色',
    teal: '蓝绿',
    indigo: '靛蓝',
    lime: '青柠',
    amber: '琥珀',
    rose: '玫瑰',
    sky: '天蓝',
    violet: '紫罗兰',
    fuchsia: '洋红',
    emerald: '翠绿',
    slate: '石板灰',
    zinc: '锌灰',
    neutral: '中性',
    stone: '石灰'
  }

  const getColorLabel = (token: string): string => {
    return colorLabelMap[token] || token
  }

  /**
   * 获取颜色选项的样式
   */
  const getColorOptionStyle = (token: string): Record<string, string> => {
    if (token === 'noset') {
      const border = cssVar('--el-border-color') || '#dcdfe6'
      return {
        backgroundColor: cssVar('--el-fill-color-light') || '#f5f7fa',
        borderColor: border,
        backgroundImage: `linear-gradient(135deg, transparent 44%, ${border} 44%, ${border} 56%, transparent 56%)`,
        backgroundRepeat: 'no-repeat'
      }
    }

    const bg = cssVar(`--el-color-${token}`) || `var(--el-color-${token})`
    return {
      backgroundColor: bg,
      borderColor: bg
    }
  }

  /**
   * 获取标签样式
   */
  const getTagStyle = (item: PropertyItem): Record<string, string> => {
    const token = (item.color || item.bg_color || 'noset').toLowerCase()

    if (token === 'noset') {
      return {
        backgroundColor: 'var(--el-fill-color-light)',
        borderColor: 'var(--el-border-color)',
        color: 'var(--el-text-color-regular)'
      }
    }

    // 如果是 CSS 变量格式 (--el-color-xxx)
    if (token.startsWith('--')) {
      return {
        backgroundColor: `var(${token}-light-9)`,
        borderColor: `var(${token})`,
        color: `var(${token})`
      }
    }

    // 如果是主题色 token (如 primary, success)
    return {
      backgroundColor: `var(--el-color-${token}-light-9)`,
      borderColor: `var(--el-color-${token})`,
      color: `var(--el-color-${token})`
    }
  }

  // ==================== 对话框状态 ====================

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const dialogTitle = computed(() => {
    if (props.title) return props.title
    const titleMap: Record<string, string> = {
      task_priority: '配置优先级',
      task_status: '配置状态',
      task_tag: '配置标签',
      task_category: '配置分类',
      project_status: '配置项目状态'
    }
    return titleMap[props.sign] || '配置属性'
  })

  // ==================== 数据状态 ====================

  const propertyList = ref<PropertyItem[]>([])
  const editingId = ref<string | number | null>(null)
  const editForm = ref({
    name: '',
    abbr: '',
    color: 'noset'
  })
  const addForm = ref({
    name: '',
    abbr: '',
    color: 'primary',
    parent_id: undefined as string | number | undefined
  })

  // ==================== 方法 ====================

  const loadPropertyList = async (): Promise<void> => {
    try {
      const res = await listPropertyApi({ 'q[sign_eq]': props.sign })
      const data = (res as any).data || []
      propertyList.value = Array.isArray(data) ? data : []
    } catch (error) {
      console.error('加载属性列表失败:', error)
    }
  }

  const handleAdd = async (): Promise<void> => {
    if (!addForm.value.name.trim()) return
    try {
      await createPropertyApi({
        sign: props.sign,
        name: addForm.value.name.trim(),
        color: addForm.value.color,
        abbr: addForm.value.abbr.trim(),
        parent_id: addForm.value.parent_id,
        sort: propertyList.value.length + 1
      })
      ElMessage.success('新建成功')
      addForm.value.name = ''
      addForm.value.abbr = ''
      addForm.value.parent_id = undefined
      await loadPropertyList()
      emit('updated')
    } catch (error) {
      console.error('新建属性失败:', error)
      ElMessage.error('新建属性失败')
    }
  }

  const handleEdit = (item: PropertyItem): void => {
    // 确保只编辑当前项，先取消其他项的编辑状态
    if (editingId.value !== null && String(editingId.value) !== String(item.id)) {
      handleCancelEdit()
    }
    editingId.value = item.id
    editForm.value.name = item.name
    editForm.value.abbr = item.abbr || ''
    editForm.value.color = item.color || item.bg_color || 'noset'
  }

  const handleCancelEdit = (): void => {
    editingId.value = null
    editForm.value.name = ''
    editForm.value.abbr = ''
    editForm.value.color = 'noset'
  }

  const handleSaveEdit = async (): Promise<void> => {
    if (!editingId.value || !editForm.value.name.trim()) return
    try {
      await updatePropertyApi(String(editingId.value), {
        name: editForm.value.name.trim(),
        abbr: editForm.value.abbr.trim(),
        color: editForm.value.color
      })
      ElMessage.success('保存成功')
      editingId.value = null
      await loadPropertyList()
      emit('updated')
    } catch (error) {
      console.error('保存属性失败:', error)
      ElMessage.error('保存属性失败')
    }
  }

  const handleDelete = async (item: PropertyItem): Promise<void> => {
    try {
      await ElMessageBox.confirm(`确定要删除"${item.name}"吗？`, '确认删除', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })
      await deletePropertyApi(Number(item.id))
      ElMessage.success('删除成功')
      await loadPropertyList()
      emit('updated')
    } catch (error: any) {
      if (error === 'cancel') return
      console.error('删除属性失败:', error)
      ElMessage.error('删除属性失败')
    }
  }

  const handleClosed = (): void => {
    editingId.value = null
    editForm.value.name = ''
    editForm.value.abbr = ''
    editForm.value.color = 'noset'
    addForm.value.name = ''
    addForm.value.abbr = ''
    addForm.value.parent_id = undefined
  }

  watch(
    () => props.modelValue,
    (val) => {
      if (val) {
        loadPropertyList()
      }
    }
  )
</script>

<style scoped lang="scss">
  .property-config {
    .property-list {
      max-height: 360px;
      padding-right: 4px;
      margin-bottom: 2px;
      overflow-y: auto;

      &::-webkit-scrollbar {
        width: 4px;
      }

      &::-webkit-scrollbar-thumb {
        background: var(--el-border-color);
        border-radius: 2px;
      }
    }

    .property-item {
      padding: 1px 12px;
      margin-bottom: 6px;
      background: var(--el-fill-color-light);
      border-radius: 6px;
      transition: all 0.2s;

      &:hover {
        background: var(--el-fill-color);
      }

      &.is-editing {
        background: var(--el-fill-color);
        box-shadow: 0 2px 8px rgb(0 0 0 / 8%);
      }
    }

    .property-display {
      display: flex;
      align-items: center;
      justify-content: space-between;
      height: 24px;
    }

    .property-tag {
      display: inline-flex;
      align-items: center;
      height: 24px;
      padding: 0 10px;
      font-size: 12px;
      font-weight: 500;
      line-height: 24px;
      border: 1px solid;
      border-radius: 4px;
    }

    .property-actions {
      display: flex;
      gap: 4px;
      opacity: 0;
      transition: opacity 0.2s;

      .delete-btn:hover {
        color: var(--el-color-danger);
      }
    }

    .property-item:hover .property-actions {
      opacity: 1;
    }

    .property-edit {
      display: flex;
      flex-direction: column;
      gap: 12px;

      .edit-input-row {
        display: flex;
        gap: 8px;
        align-items: center;
      }

      .edit-input {
        flex: 1;
      }

      .edit-abbr-input {
        flex-shrink: 0;
        width: 80px;
      }

      .edit-actions {
        display: flex;
        gap: 8px;
        justify-content: flex-end;
      }
    }

    .color-selector {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
    }

    .color-option {
      display: flex;
      align-items: center;
      justify-content: center;
      width: 24px;
      height: 24px;
      cursor: pointer;
      border: 2px solid transparent;
      border-radius: 6px;
      transition: all 0.2s;

      &:hover {
        transform: scale(1.15);
      }

      &.active {
        border-color: var(--el-color-primary);
        box-shadow: 0 0 0 2px var(--el-color-primary-light-7);
      }

      .check {
        font-size: 12px;
        color: #fff;
        text-shadow: 0 1px 2px rgb(0 0 0 / 30%);
      }
    }

    .empty-tip {
      padding: 40px 0;
      font-size: 14px;
      color: var(--el-text-color-placeholder);
      text-align: center;
    }

    .property-add {
      display: flex;
      gap: 12px;
      align-items: flex-end;
      padding-top: 20px;
      border-top: 1px solid var(--el-border-color-lighter);

      .add-form {
        display: flex;
        flex: 1;
        flex-direction: column;
        gap: 12px;
      }

      .add-input-row {
        display: flex;
        gap: 8px;
        align-items: center;
      }

      .add-input {
        flex: 1;
      }

      .add-abbr-input {
        flex-shrink: 0;
        width: 65px;
      }

      .add-parent-select {
        flex-shrink: 0;
        width: 140px;
      }
    }
  }
</style>

<style lang="scss">
  .property-config-dialog {
    .el-dialog__header {
      padding-bottom: 16px;
      border-bottom: 1px solid var(--el-border-color-lighter);
    }

    .el-dialog__body {
      padding: 20px 24px;
    }
  }
</style>
