<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="700px"
    :close-on-click-modal="false"
    align-center
    class="quick-create-attribute-dialog"
  >
    <div class="dialog-content">
      <!-- 属性名称 -->
      <div class="form-section">
        <div class="form-label">
          <span>属性名称</span>
        </div>
        <div class="form-control">
          <ElInput v-model="formData.name" placeholder="请输入属性名称" clearable />
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
              <div class="header-cell">值名称 / 额外价格</div>
              <div class="header-cell actions-cell">操作</div>
            </div>
            <div class="values-body">
              <div v-for="(value, index) in formData.values" :key="index" class="values-row">
                <div class="row-cell value-input-cell">
                  <div class="value-inputs">
                    <ElInput
                      v-model="value.name"
                      placeholder="请输入值名称"
                      size="small"
                      clearable
                      class="value-name-input"
                    />
                    <ElInput
                      v-model="value.extra_price"
                      type="number"
                      size="small"
                      placeholder="0.00"
                      class="value-price-input"
                    />
                  </div>
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
              <ElButton type="primary" size="small" @click="handleOpenQuickCreateValue">
                <ArtSvgIcon icon="ri:add-line" class="mr-1" />
                快速创建
              </ElButton>
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

      <!-- 快速创建值对话框 -->
      <QuickCreateValueDialog
        v-model="quickCreateValueDialogVisible"
        :attribute-id="currentAttributeId"
        @success="handleQuickCreateValueSuccess"
      />
    </div>

    <template #footer>
      <div class="dialog-footer">
        <ElButton @click="handleCancel">取消</ElButton>
        <ElButton type="primary" @click="handleSubmit">{{ isEditMode ? '保存' : '创建' }}</ElButton>
      </div>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, computed, watch } from 'vue'
  import { ElMessage } from 'element-plus'
  import { ElDialog, ElButton, ElInput, ElRadioGroup, ElRadio, ElTag } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import QuickCreateValueDialog from './quick-create-value-dialog.vue'
  import {
    createMatAttributeApi,
    updateMatAttributeApi,
    listMatValueApi,
    createMatValueApi
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

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  // 是否为编辑模式
  const isEditMode = computed(() => !!props.attribute && !!props.attribute.id)

  // 对话框标题
  const dialogTitle = computed(() => (isEditMode.value ? '编辑属性' : '快速创建属性'))

  const variantCreationType = ref<'instant' | 'dynamic' | 'never'>('instant')

  const formData = ref({
    name: '',
    display_type: 'radio',
    is_variant: true,
    values: [] as Array<{
      id?: number
      name: string
      extra_price: number | string
      color?: string
    }>
  })

  const existingValues = ref<any[]>([]) // 已存在的属性值
  const quickCreateValueDialogVisible = ref(false)
  const currentAttributeId = ref<number | undefined>(undefined)

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

  // 打开快速创建值对话框
  const handleOpenQuickCreateValue = (): void => {
    // 如果是编辑模式，使用已有属性ID；如果是创建模式，需要先创建属性
    if (isEditMode.value && props.attribute?.id) {
      currentAttributeId.value = props.attribute.id
      quickCreateValueDialogVisible.value = true
    } else {
      // 创建模式下，需要先保存属性才能创建值
      ElMessage.warning('请先保存属性后再创建值')
    }
  }

  // 快速创建值成功回调
  const handleQuickCreateValueSuccess = (value: any): Promise<void> => {
    // 将新创建的值添加到表单中
    if (value && value.id) {
      const exists = formData.value.values.find((v) => v.id === value.id || v.name === value.name)
      if (!exists) {
        formData.value.values.push({
          id: value.id,
          name: value.name,
          extra_price: value.extra_price || 0,
          color: value.color
        })
      }
      // 刷新已存在的值列表
      if (currentAttributeId.value) {
        loadExistingValues(currentAttributeId.value)
      }
    }
    quickCreateValueDialogVisible.value = false
    return Promise.resolve()
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
      isVariant = false
    }

    if (isEditMode.value) {
      // 编辑模式
      if (!props.attribute?.id) {
        ElMessage.warning('属性ID不存在')
        return
      }

      try {
        const res = await updateMatAttributeApi(props.attribute.id, {
          name: formData.value.name.trim(),
          display_type: formData.value.display_type,
          is_variant: isVariant
        })

        const attribute = (res as any).data || { ...props.attribute, ...formData.value }

        // 创建新的属性值（如果值不存在）
        if (formData.value.values.length > 0 && props.attribute.id) {
          const valuePromises = formData.value.values
            .filter((v) => !v.id && v.name) // 只创建新值（没有id的）
            .map(async (v) => {
              const valueRes = await createMatValueApi({
                attribute_id: props.attribute.id,
                name: v.name.trim(),
                color: v.color,
                extra_price: Number(v.extra_price) || 0,
                sort: 0
              })
              return (valueRes as any).data || {}
            })

          await Promise.all(valuePromises)
        }

        ElMessage.success('保存成功')
        emit('success', attribute)
        handleCancel()
      } catch (error) {
        console.error('更新属性失败:', error)
        ElMessage.error('保存失败')
      }
    } else {
      // 创建模式
      try {
        const res = await createMatAttributeApi({
          name: formData.value.name.trim(),
          py: formData.value.name.trim(),
          display_type: formData.value.display_type,
          is_variant: isVariant,
          sort: 0
        })

        const attribute = (res as any).data || {}

        // 创建属性值
        if (formData.value.values.length > 0 && attribute.id) {
          const valuePromises = formData.value.values
            .filter((v) => v.name) // 只创建有名称的值
            .map(async (v) => {
              const valueRes = await createMatValueApi({
                attribute_id: attribute.id,
                name: v.name.trim(),
                color: v.color,
                extra_price: Number(v.extra_price) || 0,
                sort: 0
              })
              return (valueRes as any).data || {}
            })

          await Promise.all(valuePromises)
        }

        ElMessage.success('创建成功')
        emit('success', attribute)
        handleCancel()
      } catch (error) {
        console.error('创建属性失败:', error)
        ElMessage.error('创建失败')
      }
    }
  }

  // 取消
  const handleCancel = (): void => {
    dialogVisible.value = false
  }

  // 初始化表单
  const initForm = async (): Promise<void> => {
    if (isEditMode.value && props.attribute) {
      formData.value = {
        name: props.attribute.name || '',
        display_type: props.attribute.display_type || 'radio',
        is_variant: props.attribute.is_variant !== undefined ? props.attribute.is_variant : true,
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
      formData.value = {
        name: '',
        display_type: 'radio',
        is_variant: true,
        values: []
      }
      variantCreationType.value = 'instant'
      existingValues.value = []
    }
  }

  // 监听对话框显示和属性变化
  watch(
    () => props.modelValue,
    async (newVal) => {
      if (newVal) {
        await initForm()
      }
    }
  )

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
  .quick-create-attribute-dialog {
    .dialog-content {
      .form-section {
        margin-bottom: 24px;

        .form-label {
          margin-bottom: 8px;
          font-size: 12px;
          font-weight: 500;
          color: var(--el-text-color-primary);
        }

        .form-control {
          .values-table {
            border: 1px solid var(--el-border-color-lighter);
            border-radius: 4px;

            .values-header {
              display: grid;
              grid-template-columns: 1fr 80px;
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
                grid-template-columns: 1fr 80px;
                gap: 12px;
                padding: 12px;
                border-bottom: 1px solid var(--el-border-color-lighter);

                &:last-child {
                  border-bottom: none;
                }

                .row-cell {
                  display: flex;
                  align-items: center;

                  &.value-input-cell {
                    .value-inputs {
                      display: flex;
                      gap: 8px;
                      width: 100%;

                      .value-name-input {
                        flex: 1;
                      }

                      .value-price-input {
                        flex-shrink: 0;
                        width: 120px;
                      }
                    }
                  }
                }
              }
            }

            .values-footer {
              display: flex;
              gap: 8px;
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
              font-size: 10px;
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
