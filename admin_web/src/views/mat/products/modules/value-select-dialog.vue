<template>
  <ElDialog
    v-model="dialogVisible"
    title="选择属性值"
    width="600px"
    :close-on-click-modal="false"
    align-center
    class="value-select-dialog"
  >
    <div class="dialog-content">
      <!-- 搜索区域 -->
      <div class="search-section">
        <ElInput v-model="searchKeyword" placeholder="搜索值" clearable class="search-input">
          <template #prefix>
            <ArtSvgIcon icon="ri:search-line" />
          </template>
        </ElInput>
        <ElButton type="primary" @click="handleOpenCreateDialog">
          <ArtSvgIcon icon="ri:add-line" class="mr-1" />
          新建
        </ElButton>
      </div>

      <!-- 全选控制 -->
      <div class="select-all-section">
        <ElCheckbox :model-value="isSelectAll" @change="(val: any) => (isSelectAll = Boolean(val))">
          全选
        </ElCheckbox>
        <span class="selected-count">已选择 {{ currentSelectedValueIds.length }} 项</span>
      </div>

      <!-- 值列表 -->
      <div class="values-list">
        <ElTable
          :data="filteredValues"
          style="width: 100%"
          :max-height="360"
          :row-class-name="getRowClassName"
        >
          <ElTableColumn width="55">
            <template #default="{ row }">
              <ElCheckbox
                :model-value="isValueSelected(row.id)"
                @change="(checked: any) => handleValueToggle(row, Boolean(checked))"
              />
            </template>
          </ElTableColumn>
          <ElTableColumn label="值名称" min-width="150">
            <template #default="{ row }">
              <ElTag
                :type="row.color && row.color !== 'noset' ? undefined : 'info'"
                :style="getTagStyle(row)"
                class="value-tag"
              >
                {{ row.name }}
              </ElTag>
            </template>
          </ElTableColumn>
          <ElTableColumn label="额外价格" width="120" align="right">
            <template #default="{ row }">
              <span class="value-price">{{ row.extra_price || 0 }}</span>
            </template>
          </ElTableColumn>
          <ElTableColumn label="操作" width="100" align="center" fixed="right">
            <template #default="{ row }">
              <div class="table-actions">
                <ElButton text size="small" @click="handleEditValue(row)">
                  <ArtSvgIcon icon="ri:edit-line" />
                </ElButton>
                <ElButton text size="small" class="delete-btn" @click="handleDeleteValue(row)">
                  <ArtSvgIcon icon="ri:delete-bin-line" />
                </ElButton>
              </div>
            </template>
          </ElTableColumn>
          <template #empty>
            <div class="empty-state">
              <div v-if="searchKeyword">未找到匹配的值</div>
              <div v-else>暂无值</div>
            </div>
          </template>
        </ElTable>
      </div>
    </div>

    <template #footer>
      <div class="dialog-footer">
        <ElButton @click="handleCancel">取消</ElButton>
        <ElButton type="primary" @click="handleConfirm">确定</ElButton>
      </div>
    </template>

    <!-- 新建/编辑值对话框 -->
    <QuickCreateValueDialog
      v-model="createDialogVisible"
      :attribute-id="props.attributeId"
      @success="handleQuickCreateSuccess"
    />

    <!-- 编辑值对话框 -->
    <QuickCreateValueDialog
      v-model="editDialogVisible"
      :attribute-id="props.attributeId"
      :value="currentEditValue"
      @success="handleEditSuccess"
    />
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, computed, watch } from 'vue'
  import { ElMessage } from 'element-plus'
  import {
    ElDialog,
    ElButton,
    ElInput,
    ElCheckbox,
    ElTag,
    ElMessageBox,
    ElTable,
    ElTableColumn
  } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import QuickCreateValueDialog from './quick-create-value-dialog.vue'
  import { listMatValueApi, deleteMatValueApi } from '@/api/mat/attribute'

  interface Props {
    modelValue: boolean
    attributeId?: number
    selectedValueIds?: (string | number)[]
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'confirm', valueIds: (string | number)[]): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    attributeId: undefined,
    selectedValueIds: () => []
  })

  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const searchKeyword = ref('')
  const values = ref<any[]>([])
  const loading = ref(false)
  const currentSelectedValueIds = ref<(string | number)[]>([])
  const createDialogVisible = ref(false)
  const editDialogVisible = ref(false)
  const currentEditValue = ref<any>(null)

  // 获取标签样式（完全参照 PropertyConfigDialog）
  const getTagStyle = (value: any): Record<string, string> => {
    const token = (value.color || value.bg_color || 'noset').toLowerCase()

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

  // 过滤后的值列表
  const filteredValues = computed(() => {
    if (!searchKeyword.value) {
      return values.value
    }
    return values.value.filter((v) =>
      v.name.toLowerCase().includes(searchKeyword.value.toLowerCase())
    )
  })

  // 是否全选
  const isSelectAll = computed({
    get: () => {
      if (filteredValues.value.length === 0) return false
      return filteredValues.value.every((v) => currentSelectedValueIds.value.includes(v.id))
    },
    set: (val) => {
      if (val) {
        // 全选：添加所有过滤后的值
        filteredValues.value.forEach((v) => {
          if (v.id && !currentSelectedValueIds.value.includes(v.id)) {
            currentSelectedValueIds.value.push(v.id)
          }
        })
      } else {
        // 取消全选：移除所有过滤后的值
        filteredValues.value.forEach((v) => {
          if (v.id) {
            const index = currentSelectedValueIds.value.indexOf(v.id)
            if (index > -1) {
              currentSelectedValueIds.value.splice(index, 1)
            }
          }
        })
      }
    }
  })

  // 加载值列表
  const loadValues = async (): Promise<void> => {
    if (!props.attributeId) {
      values.value = []
      return
    }

    loading.value = true
    try {
      const res = await listMatValueApi({
        'q[attribute_id_eq]': props.attributeId
      })
      const data = (res as any).data || {}
      values.value = Array.isArray(data) ? data : data.list || data.data || []
    } catch (error) {
      console.error('加载值列表失败:', error)
      ElMessage.error('加载值列表失败')
      values.value = []
    } finally {
      loading.value = false
    }
  }

  // 判断值是否被选中
  const isValueSelected = (valueId: number | string | undefined): boolean => {
    if (!valueId) return false
    return currentSelectedValueIds.value.includes(valueId)
  }

  // 获取表格行类名
  const getRowClassName = ({ row }: { row: any }): string => {
    return isValueSelected(row.id) ? 'selected-row' : ''
  }

  // 切换值选择状态
  const handleValueToggle = (value: any, checked: boolean): void => {
    if (!value.id) return

    if (checked) {
      if (!currentSelectedValueIds.value.includes(value.id)) {
        currentSelectedValueIds.value.push(value.id)
      }
    } else {
      const index = currentSelectedValueIds.value.indexOf(value.id)
      if (index > -1) {
        currentSelectedValueIds.value.splice(index, 1)
      }
    }
  }

  // 快速创建值成功回调
  const handleQuickCreateSuccess = async (value: any): Promise<void> => {
    // 检查是否已存在
    const exists = values.value.find((v) => v.name === value.name)
    if (exists && exists.id !== value.id) {
      ElMessage.warning('该值已存在')
      // 自动选中已存在的值
      if (exists.id && !currentSelectedValueIds.value.includes(exists.id)) {
        currentSelectedValueIds.value.push(exists.id)
      }
      return
    }

    // 刷新列表
    await loadValues()

    // 自动选中新创建的值
    if (value.id && !currentSelectedValueIds.value.includes(value.id)) {
      currentSelectedValueIds.value.push(value.id)
    }
  }

  // 删除值
  const handleDeleteValue = async (value: any): Promise<void> => {
    if (!value.id) return

    try {
      await ElMessageBox.confirm('确定要删除该值吗？', '提示', {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning'
      })

      await deleteMatValueApi(value.id)
      ElMessage.success('删除成功')

      // 从选中列表中移除
      const index = currentSelectedValueIds.value.indexOf(value.id)
      if (index > -1) {
        currentSelectedValueIds.value.splice(index, 1)
      }

      // 刷新列表
      await loadValues()
    } catch (error: any) {
      if (error !== 'cancel') {
        console.error('删除值失败:', error)
        ElMessage.error('删除失败')
      }
    }
  }

  // 打开新建对话框
  const handleOpenCreateDialog = (): void => {
    createDialogVisible.value = true
  }

  // 编辑值
  const handleEditValue = (value: any): void => {
    currentEditValue.value = value
    editDialogVisible.value = true
  }

  // 编辑成功回调
  const handleEditSuccess = async (value: any): Promise<void> => {
    // 刷新列表
    await loadValues()

    // 如果编辑的值已被选中，更新选中列表中的值
    if (value.id && currentSelectedValueIds.value.includes(value.id)) {
      // 值已经在选中列表中，无需额外操作
    }
  }

  // 确认选择
  const handleConfirm = (): void => {
    emit('confirm', [...currentSelectedValueIds.value])
    handleCancel()
  }

  // 取消
  const handleCancel = (): void => {
    dialogVisible.value = false
    searchKeyword.value = ''
  }

  // 初始化选中状态
  const initSelectedValues = (): void => {
    currentSelectedValueIds.value = props.selectedValueIds ? [...props.selectedValueIds] : []
  }

  // 监听对话框显示
  watch(
    () => props.modelValue,
    async (newVal) => {
      if (newVal) {
        initSelectedValues()
        if (props.attributeId) {
          await loadValues()
        }
      }
    }
  )

  // 监听属性ID变化
  watch(
    () => props.attributeId,
    async (newVal) => {
      if (dialogVisible.value && newVal) {
        await loadValues()
      }
    }
  )
</script>

<style scoped lang="scss">
  .value-select-dialog {
    .dialog-content {
      .search-section {
        display: flex;
        gap: 12px;
        align-items: center;
        margin-bottom: 20px;

        .search-input {
          flex: 1;
        }
      }

      .select-all-section {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding-bottom: 12px;
        margin-bottom: 12px;
        border-bottom: 1px solid var(--el-border-color-lighter);

        .selected-count {
          font-size: 13px;
          color: var(--el-text-color-regular);
        }
      }

      .values-list {
        margin-bottom: 20px;

        .value-tag {
          margin: 0;
        }

        .value-price {
          font-size: 13px;
          color: var(--el-text-color-regular);
        }

        .table-actions {
          display: flex;
          gap: 4px;
          justify-content: center;

          .delete-btn:hover {
            color: var(--el-color-danger);
          }
        }

        :deep(.el-table) {
          .selected-row {
            background-color: var(--el-fill-color-light);
          }

          .el-table__row {
            &:hover {
              background-color: var(--el-fill-color-lighter);
            }

            &.selected-row:hover {
              background-color: var(--el-fill-color);
            }
          }
        }

        .empty-state {
          padding: 40px;
          color: var(--el-text-color-placeholder);
          text-align: center;
        }
      }
    }

    .dialog-footer {
      display: flex;
      gap: 12px;
      justify-content: flex-end;
    }

    .value-form {
      .form-item {
        margin-bottom: 20px;

        .form-label {
          margin-bottom: 8px;
          font-size: 14px;
          font-weight: 500;
          color: var(--el-text-color-primary);
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
      }
    }
  }
</style>
