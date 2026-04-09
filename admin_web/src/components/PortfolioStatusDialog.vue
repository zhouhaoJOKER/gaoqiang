<!-- 状态管理弹窗 -->
<template>
  <ElDialog v-model="visible" title="状态管理" width="600px" align-center @close="handleClose">
    <div class="status-management">
      <!-- 创建按钮 -->
      <div class="mb-4">
        <ElButton type="primary" @click="handleOpenCreateDialog($event)">
          <ArtSvgIcon icon="ri:add-line" class="mr-1" />
          创建项目状态
        </ElButton>
      </div>

      <!-- 状态列表 -->
      <div class="status-list">
        <VueDraggable v-model="statusList" handle=".drag-handle" @end="handleDragEnd">
          <div v-for="item in statusList" :key="item.id" class="status-item">
            <div class="flex items-center justify-between">
              <div class="flex items-center gap-3">
                <ElRadio
                  v-if="selectable && selectionMode === 'single'"
                  :model-value="selectedIds.size > 0 ? Array.from(selectedIds)[0] : undefined"
                  :label="item.id"
                  @change="() => handleSelectChange(item, true)"
                />
                <ElCheckbox
                  v-if="selectable && selectionMode === 'multiple'"
                  :model-value="isItemSelected(item)"
                  @update:model-value="
                    (val: CheckboxValueType) => handleSelectChange(item, Boolean(val))
                  "
                />
                <div class="drag-handle cursor-move text-g-400 hover:text-g-600">
                  <ArtSvgIcon icon="ri:drag-move-2-fill" class="text-base" />
                </div>
                <div class="w-4 h-4 rounded-full border-2" :style="getColorStyle(item.color)"></div>
                <span class="text-sm">{{ item.name }}</span>
              </div>
              <div class="flex items-center gap-2">
                <ElButton text size="small" @click="handleEdit(item, $event)">
                  <ArtSvgIcon icon="ri:edit-line" />
                </ElButton>
                <ElButton text size="small" type="danger" @click="handleDelete(item)">
                  <ArtSvgIcon icon="ri:delete-bin-line" />
                </ElButton>
              </div>
            </div>
          </div>
        </VueDraggable>

        <div v-if="statusList.length === 0 && !loading" class="text-center py-8 text-g-400">
          暂无状态数据
        </div>
      </div>

      <!-- 底部按钮 -->
      <div class="footer-actions">
        <ElButton @click="handleClose">取消</ElButton>
        <ElButton type="primary" @click="handleConfirm">确定</ElButton>
      </div>
    </div>

    <!-- 创建/编辑状态弹窗 -->
    <ElPopover
      v-model:visible="createDialogVisible"
      :title="editData ? '编辑项目状态' : '创建项目状态'"
      width="400"
      placement="bottom-start"
      trigger="click"
      :virtual-ref="createDialogAnchorEl"
      virtual-triggering
      teleported
      :z-index="5000"
      :show-arrow="false"
      popper-class="status-create-popper"
      @hide="handleCloseCreateDialog"
    >
      <div class="create-status-dialog">
        <ElForm :model="form" label-width="80px">
          <ElFormItem label="状态名称" required>
            <ElInput v-model="form.name" placeholder="状态名称" clearable />
          </ElFormItem>

          <ElFormItem label="状态颜色" required>
            <div class="flex items-center gap-3 flex-wrap">
              <div
                v-for="token in themeColorTokens"
                :key="token"
                class="cursor-pointer relative"
                :class="form.color === token ? 'rounded-full' : ''"
                :style="form.color === token ? { boxShadow: `0 0 0 2px ${getPrimaryColor()}` } : {}"
                @click="form.color = token"
              >
                <div class="relative w-8 h-8 flex items-center justify-center">
                  <div class="w-6 h-6 rounded-full border-2" :style="getColorStyle(token)"></div>
                  <div
                    v-if="form.color === token"
                    class="absolute inset-0 flex items-center justify-center"
                  >
                    <ArtSvgIcon icon="ri:check-line" class="text-white text-xs" />
                  </div>
                </div>
              </div>
            </div>
          </ElFormItem>
        </ElForm>

        <div class="mt-4 flex justify-end gap-3">
          <ElButton @click="handleCloseCreateDialog">取消</ElButton>
          <ElButton
            type="primary"
            :disabled="!form.name || !form.color"
            @click="handleSubmitCreate"
          >
            确定
          </ElButton>
        </div>
      </div>
    </ElPopover>
  </ElDialog>
</template>

<script setup lang="ts">
  import { computed, ref, watch } from 'vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { ElMessage, ElMessageBox, type CheckboxValueType } from 'element-plus'
  import { VueDraggable } from 'vue-draggable-plus'
  import {
    listPropertyApi,
    createPropertyApi,
    updatePropertyApi,
    deletePropertyApi
  } from '@/api/property'

  interface StatusItem {
    id?: string | number
    name: string
    color: string
    sort?: number
    [key: string]: any
  }

  interface Props {
    modelValue: boolean
    sign?: string
    // 是否可选中
    selectable?: boolean
    // 选择模式：'single' 单选，'multiple' 多选
    selectionMode?: 'single' | 'multiple'
    // 初始选中的值（单选时为 id，多选时为 id 数组）
    selectedValue?: string | number | (string | number)[]
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'confirm', statusList: StatusItem[]): void
    (e: 'update:selectedValue', value: string | number | (string | number)[] | undefined): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    sign: '',
    selectable: false,
    selectionMode: 'multiple',
    selectedValue: undefined
  })

  const emit = defineEmits<Emits>()

  const visible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  /**
   * 读取 CSS 变量（从系统主题注入的 style 中提取）
   */
  const readCssVar = (name: string): string => {
    if (typeof window === 'undefined') return ''
    return getComputedStyle(document.documentElement).getPropertyValue(name).trim()
  }

  const cssVarFirst = (names: string[]): string => {
    for (const n of names) {
      const v = readCssVar(n)
      if (v) return v
    }
    return ''
  }

  const cssVar = (name: string): string => {
    return readCssVar(name) || `var(${name})`
  }

  const getPrimaryColor = (): string => cssVar('--el-color-primary')

  /**
   * 从主题中提取所有已定义的颜色 token（--el-color-xxx）
   * - 只取基础 token（不包含 -light/-dark/-custom 等后缀）
   */
  const themeColorTokens = computed<string[]>(() => {
    if (typeof window === 'undefined') return ['noset']

    const style = getComputedStyle(document.documentElement)
    const tokens = new Set<string>()

    for (let i = 0; i < style.length; i++) {
      const name = style[i]
      const m = name.match(/^--el-color-([a-z0-9-]+)$/i)
      if (!m) continue

      const token = m[1]
      // 过滤掉 light/dark/custom 等派生 token（它们通常包含 -）
      if (token.includes('-')) continue
      tokens.add(token.toLowerCase())
    }

    const preferredOrder = ['primary', 'success', 'warning', 'danger', 'error', 'info', 'secondary']
    const list = Array.from(tokens)
    list.sort((a, b) => {
      const ia = preferredOrder.indexOf(a)
      const ib = preferredOrder.indexOf(b)
      if (ia !== -1 || ib !== -1) return (ia === -1 ? 999 : ia) - (ib === -1 ? 999 : ib)
      return a.localeCompare(b)
    })

    // 保留一个“未设置”选项，其他都来源于主题
    return ['noset', ...list]
  })

  /**
   * 获取颜色样式（优先用 computedStyle 中解析到的实际颜色值）
   */
  const getColorStyle = (color: string): Record<string, string> => {
    const c = (color || 'noset').toLowerCase()

    if (c === 'noset') {
      const border = cssVar('--el-border-color')
      return {
        backgroundColor: cssVar('--el-fill-color-light'),
        borderColor: border,
        backgroundImage: `linear-gradient(135deg, transparent 44%, ${border} 44%, ${border} 56%, transparent 56%)`,
        backgroundRepeat: 'no-repeat'
      }
    }

    const bg = cssVarFirst([`--el-color-${c}`]) || `var(--el-color-${c})`
    const border =
      cssVarFirst([`--el-color-${c}-light-3`, `--el-color-${c}-light-2`, `--el-color-${c}`]) ||
      `var(--el-color-${c}-light-3)`

    return {
      backgroundColor: bg,
      borderColor: border
    }
  }

  const statusList = ref<StatusItem[]>([])
  const loading = ref(false)
  const createDialogVisible = ref(false)
  const createDialogAnchorEl = ref<HTMLElement | null>(null)
  const editData = ref<StatusItem | null>(null)

  const form = ref({
    name: '',
    color: 'noset'
  })

  // 选中状态管理
  const selectedIds = ref<Set<string | number>>(new Set())

  /**
   * 初始化选中状态
   */
  const initSelectedValue = (): void => {
    if (!props.selectable || !props.selectedValue) {
      selectedIds.value.clear()
      return
    }

    if (props.selectionMode === 'single') {
      selectedIds.value = new Set([props.selectedValue as string | number])
    } else {
      selectedIds.value = new Set(props.selectedValue as (string | number)[])
    }
  }

  /**
   * 判断项是否被选中
   */
  const isItemSelected = (item: StatusItem): boolean => {
    if (!item.id) return false
    return selectedIds.value.has(item.id)
  }

  /**
   * 处理选择变化
   */
  const handleSelectChange = (item: StatusItem, checked: boolean): void => {
    if (!item.id) return

    if (props.selectionMode === 'single') {
      // 单选模式
      if (checked) {
        selectedIds.value = new Set([item.id])
      } else {
        selectedIds.value.clear()
      }
    } else {
      // 多选模式
      if (checked) {
        selectedIds.value.add(item.id)
      } else {
        selectedIds.value.delete(item.id)
      }
    }

    // 触发更新事件
    if (props.selectionMode === 'single') {
      const selectedId = selectedIds.value.size > 0 ? Array.from(selectedIds.value)[0] : undefined
      emit('update:selectedValue', selectedId)
    } else {
      emit('update:selectedValue', Array.from(selectedIds.value))
    }
  }

  /**
   * 加载状态列表
   */
  const loadStatusList = async (): Promise<void> => {
    if (!props.sign) return

    loading.value = true
    try {
      const res = await listPropertyApi({
        sign: props.sign
      })
      const data = (res as any).data || []
      // 按 sort 字段排序，如果没有 sort 则按 id 排序
      statusList.value = data.sort((a: StatusItem, b: StatusItem) => {
        const sortA = a.sort ?? a.id ?? 0
        const sortB = b.sort ?? b.id ?? 0
        return Number(sortA) - Number(sortB)
      })
    } catch (error) {
      console.error('加载状态列表失败:', error)
      ElMessage.error('加载状态列表失败')
    } finally {
      loading.value = false
    }
  }

  /**
   * 打开创建弹窗
   */
  const handleOpenCreateDialog = (evt?: MouseEvent): void => {
    createDialogAnchorEl.value = (evt?.currentTarget as HTMLElement) || null
    editData.value = null
    form.value = {
      name: '',
      color: 'noset'
    }
    createDialogVisible.value = true
  }

  /**
   * 编辑状态
   */
  const handleEdit = (item: StatusItem, evt?: MouseEvent): void => {
    createDialogAnchorEl.value = (evt?.currentTarget as HTMLElement) || null
    editData.value = item
    form.value = {
      name: item.name,
      color: item.color || 'noset'
    }
    createDialogVisible.value = true
  }

  /**
   * 删除状态
   */
  const handleDelete = async (item: StatusItem): Promise<void> => {
    if (!item.id) {
      ElMessage.warning('状态ID不存在')
      return
    }

    try {
      await ElMessageBox.confirm('确定要删除该状态吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })

      await deletePropertyApi(item.id as number)
      ElMessage.success('删除成功')
      await loadStatusList()
    } catch (error) {
      if (error !== 'cancel') {
        console.error('删除失败:', error)
        ElMessage.error('删除失败')
      }
    }
  }

  /**
   * 提交创建/编辑
   */
  const handleSubmitCreate = async (): Promise<void> => {
    if (!form.value.name.trim()) {
      ElMessage.warning('请输入状态名称')
      return
    }

    if (!form.value.color) {
      ElMessage.warning('请选择状态颜色')
      return
    }

    try {
      const params = {
        sign: props.sign,
        name: form.value.name.trim(),
        color: form.value.color
      }

      if (editData.value?.id) {
        // 编辑
        await updatePropertyApi(String(editData.value.id), params)
        ElMessage.success('更新成功')
      } else {
        // 创建
        await createPropertyApi(params)
        ElMessage.success('创建成功')
      }

      createDialogVisible.value = false
      await loadStatusList()
    } catch (error) {
      console.error('操作失败:', error)
      ElMessage.error('操作失败')
    }
  }

  /**
   * 关闭创建弹窗
   */
  const handleCloseCreateDialog = (): void => {
    createDialogVisible.value = false
    createDialogAnchorEl.value = null
    editData.value = null
    form.value = {
      name: '',
      color: 'noset'
    }
  }

  /**
   * 确认
   */
  const handleConfirm = (): void => {
    if (props.selectable) {
      // 如果可选中，返回选中的状态列表
      const selectedList = statusList.value.filter(
        (item) => item.id && selectedIds.value.has(item.id)
      )
      emit('confirm', selectedList)
    } else {
      // 否则返回全部状态列表
      emit('confirm', statusList.value)
    }
    handleClose()
  }

  /**
   * 拖拽结束处理
   */
  const handleDragEnd = async (): Promise<void> => {
    // 保存原始顺序，用于失败时恢复
    const originalOrder = [...statusList.value]

    // 更新每个项的 sort 值（从 1 开始）
    const updates = statusList.value
      .map((item, index) => {
        const newSort = index + 1
        if (item.sort !== newSort && item.id) {
          return {
            id: item.id,
            promise: updatePropertyApi(String(item.id), {
              ...item,
              sort: newSort
            })
          }
        }
        return null
      })
      .filter((item): item is { id: string | number; promise: Promise<any> } => item !== null)

    if (updates.length === 0) {
      // 没有需要更新的项，直接更新本地 sort 值
      statusList.value.forEach((item, index) => {
        item.sort = index + 1
      })
      return
    }

    try {
      await Promise.all(updates.map((u) => u.promise))
      // 更新本地数据中的 sort 值
      statusList.value.forEach((item, index) => {
        item.sort = index + 1
      })
    } catch (error) {
      console.error('更新排序失败:', error)
      ElMessage.error('更新排序失败')
      // 恢复原始顺序
      statusList.value = originalOrder
    }
  }

  /**
   * 关闭弹窗
   */
  const handleClose = (): void => {
    visible.value = false
    // 关闭时重置选中状态（可选，根据需求决定）
    // initSelectedValue()
  }

  /**
   * 监听弹窗打开
   */
  watch(
    () => props.modelValue,
    (newVal) => {
      if (newVal && props.sign) {
        loadStatusList()
        initSelectedValue()
      }
    }
  )

  /**
   * 监听 sign 变化
   */
  watch(
    () => props.sign,
    (newVal) => {
      if (newVal && props.modelValue) {
        loadStatusList()
        initSelectedValue()
      }
    }
  )

  /**
   * 监听选中值变化（从外部传入）
   */
  watch(
    () => props.selectedValue,
    () => {
      initSelectedValue()
    },
    { immediate: true }
  )
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';

  .status-management {
    @apply space-y-4;
  }

  .status-list {
    @apply space-y-2 max-h-96 overflow-y-auto;
  }

  .status-item {
    @apply p-3 border border-g-200 rounded hover:bg-g-100 transition-colors;
  }

  .footer-actions {
    @apply flex justify-end gap-3 pt-4 border-t border-g-200;
  }

  .create-status-dialog {
    @apply space-y-4;
  }

  .dialog-footer {
    @apply flex justify-end gap-3;
  }

  :deep(.status-create-popper) {
    @apply shadow-lg;

    z-index: 5000 !important;
  }
</style>
