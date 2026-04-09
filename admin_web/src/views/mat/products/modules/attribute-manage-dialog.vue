<template>
  <ElDialog
    v-model="dialogVisible"
    title="属性管理"
    width="900px"
    :close-on-click-modal="false"
    align-center
    class="attribute-manage-dialog"
  >
    <div class="dialog-content">
      <!-- 搜索栏 -->
      <div class="search-bar">
        <ElInput v-model="searchKeyword" placeholder="搜索..." clearable @input="handleSearch">
          <template #prefix>
            <ArtSvgIcon icon="ri:search-line" />
          </template>
        </ElInput>
        <ElButton type="primary" @click="handleCreate">
          <ArtSvgIcon icon="ri:add-line" class="mr-1" />
          产品属性新增
        </ElButton>
      </div>

      <!-- 属性列表 -->
      <div class="attributes-list">
        <div v-for="attribute in filteredAttributes" :key="attribute.id" class="attribute-item">
          <div class="attribute-header">
            <div class="attribute-name">{{ attribute.name }}</div>
            <div class="attribute-actions">
              <ElButton text size="small" @click="handleEdit(attribute)">编辑</ElButton>
              <ElButton text size="small" type="danger" @click="handleDelete(attribute)">
                删除
              </ElButton>
            </div>
          </div>
          <div class="attribute-info">
            <span class="info-item"
              >显示类型: {{ getDisplayTypeName(attribute.display_type) }}</span
            >
            <span class="info-item">变体创建: {{ getVariantName(attribute.is_variant) }}</span>
          </div>
          <div class="attribute-values">
            <ElTag
              v-for="value in attribute.values || []"
              :key="value.id"
              :type="value.color ? undefined : 'info'"
              :color="value.color"
              class="value-tag"
            >
              {{ value.name }}
            </ElTag>
          </div>
        </div>
        <div v-if="filteredAttributes.length === 0" class="empty-list">暂无属性</div>
      </div>

      <!-- 分页 -->
      <div class="pagination">
        <span class="pagination-info">{{ paginationInfo }}</span>
        <div class="pagination-controls">
          <ElButton text size="small" :disabled="currentPage === 1" @click="handlePrevPage">
            <ArtSvgIcon icon="ri:arrow-left-line" />
          </ElButton>
          <ElButton text size="small" :disabled="currentPage >= totalPages" @click="handleNextPage">
            <ArtSvgIcon icon="ri:arrow-right-line" />
          </ElButton>
        </div>
      </div>
    </div>

    <template #footer>
      <div class="dialog-footer">
        <ElButton @click="handleCancel">关闭</ElButton>
      </div>
    </template>

    <!-- 编辑属性对话框 -->
    <QuickCreateAttributeDialog
      v-model="editDialogVisible"
      :attribute="currentAttribute"
      @success="handleEditSuccess"
    />

    <!-- 创建属性对话框 -->
    <QuickCreateAttributeDialog v-model="createDialogVisible" @success="handleCreateSuccess" />
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, computed, watch, onMounted } from 'vue'
  import { ElMessage, ElMessageBox } from 'element-plus'
  import { ElDialog, ElButton, ElInput, ElTag } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import QuickCreateAttributeDialog from './quick-create-attribute-dialog.vue'
  import { listMatAttributeApi, deleteMatAttributeApi, listMatValueApi } from '@/api/mat/attribute'

  interface Props {
    modelValue: boolean
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'success'): void
  }

  const props = defineProps<Props>()
  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const searchKeyword = ref('')
  const attributes = ref<any[]>([])
  const currentPage = ref(1)
  const pageSize = ref(20)
  const totalCount = ref(0)
  const editDialogVisible = ref(false)
  const createDialogVisible = ref(false)
  const currentAttribute = ref<any>(null)

  const totalPages = computed(() => Math.ceil(totalCount.value / pageSize.value))

  const paginationInfo = computed(() => {
    const start = (currentPage.value - 1) * pageSize.value + 1
    const end = Math.min(currentPage.value * pageSize.value, totalCount.value)
    return `${start}-${end} / ${totalCount.value}`
  })

  const filteredAttributes = computed(() => {
    if (!searchKeyword.value) {
      return attributes.value
    }
    const keyword = searchKeyword.value.toLowerCase()
    return attributes.value.filter(
      (attr) =>
        attr.name?.toLowerCase().includes(keyword) || attr.py?.toLowerCase().includes(keyword)
    )
  })

  // 获取显示类型名称
  const getDisplayTypeName = (type: string): string => {
    const typeMap: Record<string, string> = {
      radio: '单选',
      pill: '药丸',
      select: '选择',
      color: '颜色',
      checkbox: '多个复选框',
      image: '图像'
    }
    return typeMap[type] || type
  }

  // 获取变体创建名称
  const getVariantName = (isVariant: boolean | null): string => {
    if (isVariant === true) return '创建变体'
    if (isVariant === false) return '不创建'
    return '动态'
  }

  // 加载属性列表
  const loadAttributes = async (): Promise<void> => {
    try {
      const res = await listMatAttributeApi({
        'q[name_or_py_cont]': searchKeyword.value || '',
        page: currentPage.value,
        per_page: pageSize.value
      })
      const data = (res as any).data || {}
      const list = Array.isArray(data) ? data : data.list || data.data || data.records || []

      // 加载每个属性的值列表
      const attributesWithValues = await Promise.all(
        list.map(async (attr: any) => {
          try {
            const valuesRes = await listMatValueApi({
              'q[attribute_id_eq]': attr.id
            })
            const valuesData = (valuesRes as any).data || {}
            attr.values = Array.isArray(valuesData)
              ? valuesData
              : valuesData.list || valuesData.data || []
          } catch (error) {
            console.error(`加载属性 ${attr.id} 的值失败:`, error)
            attr.values = []
          }
          return attr
        })
      )

      attributes.value = attributesWithValues
      totalCount.value = (res as any).total || attributes.value.length
    } catch (error) {
      console.error('加载属性列表失败:', error)
      attributes.value = []
      totalCount.value = 0
    }
  }

  // 搜索
  const handleSearch = (): void => {
    currentPage.value = 1
    loadAttributes()
  }

  // 上一页
  const handlePrevPage = (): void => {
    if (currentPage.value > 1) {
      currentPage.value--
      loadAttributes()
    }
  }

  // 下一页
  const handleNextPage = (): void => {
    if (currentPage.value < totalPages.value) {
      currentPage.value++
      loadAttributes()
    }
  }

  // 编辑
  const handleEdit = (attribute: any): void => {
    currentAttribute.value = attribute
    editDialogVisible.value = true
  }

  // 删除
  const handleDelete = async (attribute: any): Promise<void> => {
    try {
      await ElMessageBox.confirm(`确定要删除属性"${attribute.name}"吗？`, '确认删除', {
        type: 'warning'
      })
      await deleteMatAttributeApi(attribute.id)
      ElMessage.success('删除成功')
      await loadAttributes()
      emit('success')
    } catch (error: any) {
      if (error !== 'cancel') {
        console.error('删除属性失败:', error)
        ElMessage.error('删除失败')
      }
    }
  }

  // 编辑成功回调
  const handleEditSuccess = (): void => {
    loadAttributes()
    emit('success')
  }

  // 创建属性
  const handleCreate = (): void => {
    createDialogVisible.value = true
  }

  // 创建成功回调
  const handleCreateSuccess = (): void => {
    loadAttributes()
    emit('success')
  }

  // 取消
  const handleCancel = (): void => {
    dialogVisible.value = false
  }

  // 监听对话框显示
  watch(
    () => props.modelValue,
    (newVal) => {
      if (newVal) {
        searchKeyword.value = ''
        currentPage.value = 1
        loadAttributes()
      }
    }
  )

  onMounted(() => {
    if (props.modelValue) {
      loadAttributes()
    }
  })
</script>

<style scoped lang="scss">
  .attribute-manage-dialog {
    .dialog-content {
      .search-bar {
        display: flex;
        gap: 12px;
        align-items: center;
        margin-bottom: 16px;

        .el-input {
          flex: 1;
        }
      }

      .attributes-list {
        max-height: 500px;
        margin-bottom: 16px;
        overflow-y: auto;

        .attribute-item {
          padding: 16px;
          margin-bottom: 12px;
          background: var(--el-fill-color-lighter);
          border-radius: 4px;
          transition: background-color 0.2s;

          &:hover {
            background: var(--el-fill-color);
          }

          .attribute-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 8px;

            .attribute-name {
              font-size: 14px;
              font-weight: 500;
              color: var(--el-text-color-primary);
            }

            .attribute-actions {
              display: flex;
              gap: 8px;
            }
          }

          .attribute-info {
            display: flex;
            gap: 16px;
            margin-bottom: 8px;
            font-size: 12px;
            color: var(--el-text-color-regular);

            .info-item {
              &::before {
                content: '';
              }
            }
          }

          .attribute-values {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;

            .value-tag {
              margin: 0;
            }
          }
        }

        .empty-list {
          display: flex;
          align-items: center;
          justify-content: center;
          padding: 60px 16px;
          font-size: 14px;
          color: var(--el-text-color-placeholder);
        }
      }

      .pagination {
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding-top: 16px;
        border-top: 1px solid var(--el-border-color-lighter);

        .pagination-info {
          font-size: 13px;
          color: var(--el-text-color-regular);
        }

        .pagination-controls {
          display: flex;
          gap: 8px;
        }
      }
    }

    .dialog-footer {
      display: flex;
      justify-content: flex-end;
    }
  }
</style>
