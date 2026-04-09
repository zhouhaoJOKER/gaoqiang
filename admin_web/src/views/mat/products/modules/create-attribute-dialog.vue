<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="800px"
    :close-on-click-modal="false"
    align-center
    class="create-attribute-dialog"
  >
    <div class="dialog-content">
      <!-- 属性名称 -->
      <div class="form-section">
        <div class="form-label">
          <span>属性名称</span>
        </div>
        <div class="form-control">
          <ElInput v-model="formData.name" size="small" placeholder="请输入属性名称" clearable />
        </div>
      </div>

      <!-- 显示类型 -->
      <div class="form-section">
        <div class="form-label">
          <span>显示类型</span>
        </div>
        <div class="form-control">
          <ElRadioGroup size="small" v-model="formData.display_type">
            <ElRadio label="radio">单选</ElRadio>
            <ElRadio label="pill">药丸</ElRadio>
            <ElRadio label="select">选择</ElRadio>
            <ElRadio label="color">颜色</ElRadio>
            <ElRadio label="checkbox">多个复选框</ElRadio>
            <ElRadio label="image">图像</ElRadio>
          </ElRadioGroup>
        </div>
      </div>

      <!-- 变体创建 -->
      <div class="form-section">
        <div class="form-label">
          <span>变体创建</span>
        </div>
        <div class="form-control">
          <ElRadioGroup v-model="variantCreationType" size="small">
            <ElRadio :value="'instant'">创建变体</ElRadio>
            <ElRadio :value="'dynamic'">动态</ElRadio>
            <ElRadio :value="'never'">不创建</ElRadio>
          </ElRadioGroup>
        </div>
      </div>

      <!-- 属性值 -->
      <div v-if="formData.name || props.attribute" class="form-section">
        <div class="form-label">
          <span>属性值</span>
        </div>
        <div class="form-control">
          <div class="values-table">
            <div class="values-header">
              <div class="header-cell">值</div>
              <div class="header-cell">默认额外价格</div>
              <div class="header-cell actions-cell">操作</div>
            </div>
            <div class="values-body">
              <div v-for="(value, index) in formData.values" :key="index" class="values-row">
                <div class="row-cell">
                  <ElInput v-model="value.name" placeholder="请输入值名称" size="small" clearable />
                </div>
                <div class="row-cell">
                  <ElInput
                    v-model="value.extra_price"
                    type="number"
                    size="small"
                    placeholder="0.00"
                  />
                </div>
                <div class="row-cell">
                  <ElButton text type="danger" size="small" @click="handleRemoveValue(index)">
                    <ArtSvgIcon icon="ri:delete-bin-line" />
                  </ElButton>
                </div>
              </div>
            </div>
            <div class="values-footer">
              <ElButton type="primary" size="small" @click="handleAddValue">添加行</ElButton>
            </div>
          </div>

          <!-- 已存在的属性值标签 -->
          <div v-if="existingValues.length > 0" class="existing-values">
            <div class="existing-values-title">已存在的值：</div>
            <ElTag
              v-for="value in existingValues"
              :key="value.id"
              :type="value.color ? undefined : 'info'"
              :color="value.color"
              class="value-tag"
              @click="handleSelectExistingValue(value)"
            >
              {{ value.name }}
            </ElTag>
          </div>
        </div>
      </div>
    </div>

    <template #footer>
      <div class="dialog-footer">
        <ElButton @click="handleCancel">关闭</ElButton>
        <ElButton type="primary" @click="handleSubmit">新建</ElButton>
      </div>
    </template>

    <!-- 属性管理对话框 -->
    <AttributeManageDialog
      v-model="attributeManageDialogVisible"
      @success="handleAttributeManageSuccess"
    />

    <!-- 快速创建属性对话框 -->
    <QuickCreateAttributeDialog
      v-model="quickCreateDialogVisible"
      @success="handleQuickCreateSuccess"
    />
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, computed, watch } from 'vue'
  import { ElMessage } from 'element-plus'
  import { ElDialog, ElButton, ElInput, ElRadioGroup, ElRadio, ElTag } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import AttributeManageDialog from './attribute-manage-dialog.vue'
  import QuickCreateAttributeDialog from './quick-create-attribute-dialog.vue'
  import {
    createMatAttributeApi,
    updateMatAttributeApi,
    createMatValueApi,
    listMatAttributeApi,
    listMatValueApi
  } from '@/api/mat/attribute'

  interface Props {
    modelValue: boolean
    attribute?: any // 编辑模式时传入的属性
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'success', attribute: any): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    attribute: undefined
  })

  const emit = defineEmits<Emits>()

  const dialogTitle = computed(() => {
    return props.attribute ? '编辑 属性' : '创建 属性'
  })

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const variantCreationType = ref<'instant' | 'dynamic' | 'never'>('instant')

  const formData = ref({
    name: '',
    py: '',
    display_type: 'radio',
    is_variant: true,
    sort: 0,
    values: [] as Array<{
      id?: number
      attribute_id?: number
      value_id?: number
      name?: string
      custom_text?: boolean
      extra_price: number | string
      color?: string
    }>
  })

  const attributeOptions = ref<any[]>([])
  const attributeSearchLoading = ref(false)
  const attributeValuesMap = ref<Record<number, any[]>>({})
  const attributeManageDialogVisible = ref(false)
  const quickCreateDialogVisible = ref(false)
  const existingValues = ref<any[]>([]) // 已存在的属性值

  // 搜索属性
  const searchAttributes = async (query: string): Promise<void> => {
    attributeSearchLoading.value = true
    try {
      const res = await listMatAttributeApi({
        'q[name_or_py_cont]': query || '',
        per_page: 20
      })
      const data = (res as any).data || {}
      attributeOptions.value = Array.isArray(data) ? data : data.list || data.data || []
    } catch (error) {
      console.error('搜索属性失败:', error)
      attributeOptions.value = []
    } finally {
      attributeSearchLoading.value = false
    }
  }

  // 加载已存在的属性值
  const loadExistingValues = async (attributeId?: number): Promise<void> => {
    if (!attributeId) {
      existingValues.value = []
      return
    }
    try {
      const res = await listMatValueApi({
        'q[attribute_id_eq]': attributeId
      })
      const data = (res as any).data || {}
      existingValues.value = Array.isArray(data) ? data : data.list || data.data || []
    } catch (error) {
      console.error('加载已存在的值失败:', error)
      existingValues.value = []
    }
  }

  // 选择已存在的值
  const handleSelectExistingValue = (value: any): void => {
    // 检查是否已存在于表单中
    const exists = formData.value.values.find((v) => v.id === value.id || v.name === value.name)
    if (!exists) {
      formData.value.values.push({
        id: value.id,
        name: value.name,
        extra_price: value.extra_price || 0,
        color: value.color
      })
    }
  }

  // 添加值
  const handleAddValue = (): void => {
    formData.value.values.push({
      name: '',
      extra_price: 0
    })
  }

  // 移除值
  const handleRemoveValue = (index: number): void => {
    formData.value.values.splice(index, 1)
  }

  // 属性管理成功回调
  const handleAttributeManageSuccess = async (): Promise<void> => {
    // 刷新属性列表
    await searchAttributes('')
  }

  // 快速创建成功回调
  const handleQuickCreateSuccess = async (): Promise<void> => {
    // 刷新属性列表
    await searchAttributes('')
  }

  // 提交
  const handleSubmit = async (): Promise<void> => {
    if (!formData.value.name.trim()) {
      ElMessage.warning('请输入属性名称')
      return
    }

    // 转换变体创建类型
    let isVariant: boolean | null = true
    if (variantCreationType.value === 'never') {
      isVariant = false
    } else if (variantCreationType.value === 'dynamic') {
      isVariant = false // 动态可以设置为false，或者根据业务需求调整
    }

    try {
      let attribute: any

      if (props.attribute?.id) {
        // 编辑模式：更新属性
        const attributeParams: any = {
          name: formData.value.name.trim(),
          py: formData.value.py || formData.value.name.trim(),
          display_type: formData.value.display_type,
          is_variant: isVariant,
          sort: formData.value.sort
        }
        const attributeRes = await updateMatAttributeApi(props.attribute.id, attributeParams)
        attribute = (attributeRes as any).data || { id: props.attribute.id }
      } else {
        // 新建模式：创建属性
        const attributeParams: any = {
          name: formData.value.name.trim(),
          py: formData.value.py || formData.value.name.trim(),
          display_type: formData.value.display_type,
          is_variant: isVariant,
          sort: formData.value.sort
        }
        const attributeRes = await createMatAttributeApi(attributeParams)
        attribute = (attributeRes as any).data || {}
      }

      // 创建属性值（只创建新值，已存在的值不需要创建）
      if (formData.value.values.length > 0 && attribute.id) {
        const valuePromises = formData.value.values
          .filter((v) => !v.id && v.name) // 只创建没有id的新值
          .map(async (v) => {
            if (!v.name) return null
            const valueRes = await createMatValueApi({
              attribute_id: attribute.id,
              name: v.name.trim(),
              color: v.color,
              extra_price: Number(v.extra_price) || 0,
              sort: 0
            })
            return (valueRes as any).data || {}
          })

        await Promise.all(valuePromises.filter((p) => p !== null))
      }

      ElMessage.success(props.attribute ? '更新成功' : '创建成功')
      emit('success', attribute)

      // 创建成功后关闭对话框
      handleCancel()
    } catch (error) {
      console.error('创建属性失败:', error)
      ElMessage.error(props.attribute ? '更新失败' : '创建失败')
    }
  }

  // 取消
  const handleCancel = (): void => {
    dialogVisible.value = false
  }

  // 初始化表单
  const initForm = async (): Promise<void> => {
    if (props.attribute) {
      // 编辑模式
      formData.value = {
        name: props.attribute.name || '',
        py: props.attribute.py || props.attribute.name || '',
        display_type: props.attribute.display_type || 'radio',
        is_variant: props.attribute.is_variant !== undefined ? props.attribute.is_variant : true,
        sort: props.attribute.sort || 0,
        values: []
      }

      // 设置变体创建类型
      if (props.attribute.is_variant === true) {
        variantCreationType.value = 'instant'
      } else if (props.attribute.is_variant === false) {
        variantCreationType.value = 'never'
      } else {
        variantCreationType.value = 'dynamic'
      }

      // 加载已存在的值
      if (props.attribute.id) {
        await loadExistingValues(props.attribute.id)
      }
    } else {
      // 新建模式
      formData.value = {
        name: '',
        py: '',
        display_type: 'radio',
        is_variant: true,
        sort: 0,
        values: []
      }
      variantCreationType.value = 'instant'
      existingValues.value = []
    }
    attributeOptions.value = []
    attributeValuesMap.value = {}
  }

  // 监听对话框显示
  watch(
    () => props.modelValue,
    async (newVal) => {
      if (newVal) {
        await initForm()
        searchAttributes('')
      }
    }
  )

  // 监听属性变化
  watch(
    () => props.attribute,
    async () => {
      if (props.modelValue) {
        await initForm()
      }
    },
    { deep: true }
  )
</script>

<style scoped lang="scss">
  .create-attribute-dialog {
    .dialog-content {
      .form-section {
        margin-bottom: 24px;

        .form-label {
          display: flex;
          gap: 4px;
          align-items: center;
          margin-bottom: 8px;
          font-size: 14px;
          font-weight: 500;
          color: var(--el-text-color-primary);

          .help-icon {
            font-size: 14px;
            color: var(--el-text-color-placeholder);
            cursor: help;
          }
        }

        .form-control {
          .values-table {
            border: 1px solid var(--el-border-color-lighter);
            border-radius: 4px;

            .values-header {
              display: grid;
              grid-template-columns: 200px 1fr 150px 80px;
              gap: 12px;
              padding: 8px;
              font-size: 12px;
              font-weight: 300;
              color: var(--el-text-color-regular);
              background: var(--el-fill-color-light);
              border-bottom: 1px solid var(--el-border-color-lighter);

              .header-cell {
                &.actions-cell {
                  text-align: center;
                }
              }
            }

            .values-body {
              .values-row {
                display: grid;
                grid-template-columns: 200px 1fr 150px 80px;
                gap: 12px;
                padding: 12px;
                border-bottom: 1px solid var(--el-border-color-lighter);

                &:last-child {
                  border-bottom: none;
                }

                .row-cell {
                  display: flex;
                  align-items: center;

                  .option-footer {
                    display: flex;
                    gap: 8px;
                    justify-content: center;
                    padding: 8px 0;
                  }
                }
              }
            }

            .values-footer {
              padding: 12px;
              border-top: 1px solid var(--el-border-color-lighter);
            }
          }

          .existing-values {
            padding-top: 12px;
            margin-top: 12px;
            border-top: 1px solid var(--el-border-color-lighter);

            .existing-values-title {
              margin-bottom: 8px;
              font-size: 13px;
              font-weight: 500;
              color: var(--el-text-color-regular);
            }

            .value-tag {
              margin-right: 8px;
              margin-bottom: 8px;
              cursor: pointer;
              transition: opacity 0.2s;

              &:hover {
                opacity: 0.8;
              }
            }
          }
        }
      }
    }

    .dialog-footer {
      display: flex;
      gap: 12px;
      justify-content: flex-end;
    }
  }
</style>
