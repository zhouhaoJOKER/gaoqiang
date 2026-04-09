<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="800px"
    :close-on-click-modal="false"
    align-center
    class="attribute-config-dialog"
  >
    <div class="dialog-content">
      <!-- 属性选择 -->
      <div class="form-section">
        <div class="form-label">
          <span>属性名称</span>
        </div>
        <div class="form-control">
          <ElSelect
            v-model="formData.attribute_id"
            placeholder="请选择属性"
            filterable
            remote
            :remote-method="searchAttributes"
            :loading="attributeSearchLoading"
            style="width: 100%"
            @change="handleAttributeChange"
          >
            <ElOption
              v-for="attr in attributeOptions"
              :key="attr.id"
              :label="attr.name"
              :value="attr.id"
            />
            <ElOption
              :value="''"
              disabled
              style="border-top: 1px solid var(--el-border-color-lighter)"
            >
              <div class="option-footer">
                <ElButton text type="primary" size="small" @click.stop="handleCreateAttribute">
                  创建属性...
                </ElButton>
              </div>
            </ElOption>
          </ElSelect>
        </div>
      </div>

      <!-- 显示类型 -->
      <div v-if="selectedAttribute" class="form-section">
        <div class="form-label">
          <span>显示类型?</span>
          <ArtSvgIcon icon="ri:question-line" class="help-icon" />
        </div>
        <div class="form-control">
          <ElRadioGroup v-model="formData.display_type">
            <ElRadio label="radio">单选</ElRadio>
            <ElRadio label="pill">药丸</ElRadio>
            <ElRadio label="select">选择</ElRadio>
            <ElRadio label="color">颜色</ElRadio>
            <ElRadio label="checkbox">多个复选框</ElRadio>
          </ElRadioGroup>
        </div>
      </div>

      <!-- 变体创建 -->
      <div v-if="selectedAttribute" class="form-section">
        <div class="form-label">
          <span>变体创建?</span>
          <ArtSvgIcon icon="ri:question-line" class="help-icon" />
        </div>
        <div class="form-control">
          <ElRadioGroup v-model="formData.is_variant" :disabled="isComboProduct">
            <ElRadio :label="true">即时</ElRadio>
            <ElRadio :label="false">动态</ElRadio>
            <ElRadio :label="null as any">从不</ElRadio>
          </ElRadioGroup>
          <div v-if="isComboProduct" class="variant-warning">
            <ElMessage type="warning" :closable="false" style="margin-top: 8px">
              组合类型产品不支持变体创建
            </ElMessage>
          </div>
        </div>
      </div>

      <!-- 属性值 -->
      <div v-if="selectedAttribute" class="form-section">
        <div class="form-label">
          <span>属性值</span>
        </div>
        <div class="form-control">
          <div class="values-table">
            <div class="values-header">
              <div class="header-cell">值</div>
              <div class="header-cell">自定义文本</div>
              <div class="header-cell">默认额外价格</div>
              <div class="header-cell actions-cell">操作</div>
            </div>
            <div class="values-body">
              <div v-for="(value, index) in formData.values" :key="index" class="values-row">
                <div class="row-cell">
                  <ElInput
                    v-model="value.name"
                    placeholder="请输入值名称"
                    @blur="handleValueChange"
                  />
                </div>
                <div class="row-cell">
                  <ElCheckbox v-model="value.custom_text" @change="handleValueChange" />
                </div>
                <div class="row-cell">
                  <ElInput
                    v-model="value.extra_price"
                    type="number"
                    placeholder="0.00"
                    @blur="handleValueChange"
                  >
                    <template #suffix>
                      <ElButton text type="danger" size="small" @click="handleRemoveValue(index)">
                        <ArtSvgIcon icon="ri:delete-bin-line" />
                      </ElButton>
                    </template>
                  </ElInput>
                </div>
              </div>
            </div>
            <div class="values-footer">
              <ElButton text type="primary" @click="handleAddValue">添加行</ElButton>
            </div>
          </div>

          <!-- 已存在的属性值标签 -->
          <div v-if="existingValues.length > 0" class="existing-values">
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

    <!-- 创建属性对话框 -->
    <CreateAttributeDialog
      v-model="createAttributeDialogVisible"
      @success="handleAttributeCreated"
    />
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, computed, watch } from 'vue'
  import { ElMessage, ElMessageBox } from 'element-plus'
  import {
    ElDialog,
    ElButton,
    ElSelect,
    ElOption,
    ElRadioGroup,
    ElRadio,
    ElInput,
    ElCheckbox,
    ElTag
  } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import CreateAttributeDialog from './create-attribute-dialog.vue'
  import {
    listMatAttributeApi,
    listMatValueApi,
    createMatAttributeLineApi,
    updateMatAttributeLineApi
  } from '@/api/mat/attribute'

  interface Props {
    modelValue: boolean
    productId?: string | number
    productTypeId?: number
    attributeLine?: any
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'success'): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    productId: undefined,
    productTypeId: undefined,
    attributeLine: undefined
  })

  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const dialogTitle = computed(() => {
    return props.attributeLine ? '编辑 属性' : '创建 属性'
  })

  const attributeOptions = ref<any[]>([])
  const attributeSearchLoading = ref(false)
  const selectedAttribute = ref<any>(null)
  const existingValues = ref<any[]>([])
  const createAttributeDialogVisible = ref(false)

  // 判断是否为组合类型产品（type_id = 2）
  const isComboProduct = computed(() => props.productTypeId === 2)

  const formData = ref({
    attribute_id: undefined as number | undefined,
    name: '',
    display_type: 'radio',
    is_variant: true,
    values: [] as Array<{
      name: string
      custom_text: boolean
      extra_price: number | string
      color?: string
    }>,
    value_ids: [] as number[]
  })

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

  // 属性变化
  const handleAttributeChange = async (attributeId: number): Promise<void> => {
    if (!attributeId) {
      selectedAttribute.value = null
      existingValues.value = []
      formData.value.name = ''
      return
    }

    const attribute = attributeOptions.value.find((a) => a.id === attributeId)
    if (attribute) {
      // 检查：如果是组合类型产品，不能选择变体属性
      if (isComboProduct.value && attribute.is_variant === true) {
        try {
          await ElMessageBox.confirm(
            '组合类型产品不支持变体创建。该属性是变体属性，无法使用。',
            '提示',
            {
              type: 'warning',
              confirmButtonText: '确定'
            }
          )
          // 用户确认后，清空选择
          formData.value.attribute_id = undefined
          return
        } catch {
          // 用户取消，清空选择
          formData.value.attribute_id = undefined
          return
        }
      }

      selectedAttribute.value = attribute
      formData.value.name = attribute.name
      formData.value.display_type = attribute.display_type || 'radio'
      // 如果是组合类型产品，强制设置为不创建变体
      if (isComboProduct.value) {
        formData.value.is_variant = false
      } else {
        formData.value.is_variant = attribute.is_variant !== undefined ? attribute.is_variant : true
      }

      // 加载该属性的值列表
      await loadAttributeValues(attributeId)
    }
  }

  // 加载属性值
  const loadAttributeValues = async (attributeId: number): Promise<void> => {
    try {
      const res = await listMatValueApi({
        'q[attribute_id_eq]': attributeId
      })
      const data = (res as any).data || {}
      existingValues.value = Array.isArray(data) ? data : data.list || data.data || []
    } catch (error) {
      console.error('加载属性值失败:', error)
      existingValues.value = []
    }
  }

  // 添加值
  const handleAddValue = (): void => {
    formData.value.values.push({
      name: '',
      custom_text: false,
      extra_price: 0
    })
  }

  // 移除值
  const handleRemoveValue = (index: number): void => {
    formData.value.values.splice(index, 1)
  }

  // 值变化
  const handleValueChange = (): void => {
    // 可以在这里添加验证逻辑
  }

  // 选择已存在的值
  const handleSelectExistingValue = (value: any): void => {
    // 检查是否已存在
    const exists = formData.value.values.find((v) => v.name === value.name)
    if (!exists) {
      formData.value.values.push({
        name: value.name,
        custom_text: false,
        extra_price: value.extra_price || 0,
        color: value.color
      })
    }
  }

  // 创建属性
  const handleCreateAttribute = (): void => {
    createAttributeDialogVisible.value = true
  }

  // 属性创建成功
  const handleAttributeCreated = async (attribute: any): Promise<void> => {
    // 刷新属性列表
    await searchAttributes('')
    // 自动选择新创建的属性
    if (attribute && attribute.id) {
      formData.value.attribute_id = attribute.id
      await handleAttributeChange(attribute.id)
    }
  }

  // 提交
  const handleSubmit = async (): Promise<void> => {
    if (!formData.value.attribute_id) {
      ElMessage.warning('请选择属性')
      return
    }

    if (!props.productId) {
      ElMessage.warning('产品ID不存在')
      return
    }

    // 检查：组合类型产品不能创建变体
    if (isComboProduct.value && formData.value.is_variant === true) {
      try {
        await ElMessageBox.confirm(
          '组合类型产品不支持变体创建。请将"变体创建"设置为"从不"或"动态"。',
          '提示',
          {
            type: 'warning',
            confirmButtonText: '确定'
          }
        )
        return
      } catch {
        return
      }
    }

    try {
      const params: any = {
        product_id: props.productId,
        attribute_id: formData.value.attribute_id,
        name: formData.value.name,
        display_type: formData.value.display_type,
        // 如果是组合类型产品，强制设置为不创建变体
        is_variant: isComboProduct.value
          ? false
          : formData.value.is_variant === null
            ? false
            : formData.value.is_variant,
        values: formData.value.values.map((v) => ({
          name: v.name,
          custom_text: v.custom_text,
          extra_price: Number(v.extra_price) || 0,
          color: v.color
        })),
        value_ids: formData.value.values
          .map((v) => {
            // 如果值已存在，返回其ID
            const existing = existingValues.value.find((ev) => ev.name === v.name)
            return existing?.id
          })
          .filter((id) => id !== undefined) as number[]
      }

      if (props.attributeLine?.id) {
        // 更新
        await updateMatAttributeLineApi(props.attributeLine.id, params)
        ElMessage.success('更新成功')
      } else {
        // 创建
        await createMatAttributeLineApi(params)
        ElMessage.success('创建成功')
      }

      emit('success')
      handleCancel()
    } catch (error) {
      console.error('保存属性行失败:', error)
      ElMessage.error('保存失败')
    }
  }

  // 取消
  const handleCancel = (): void => {
    dialogVisible.value = false
  }

  // 初始化表单
  const initForm = (): void => {
    if (props.attributeLine) {
      // 编辑模式
      formData.value.attribute_id = props.attributeLine.attribute_id
      formData.value.name = props.attributeLine.name || ''
      formData.value.display_type = props.attributeLine.display_type || 'radio'
      // 如果是组合类型产品，强制设置为不创建变体
      formData.value.is_variant = isComboProduct.value
        ? false
        : props.attributeLine.is_variant !== undefined
          ? props.attributeLine.is_variant
          : true
      formData.value.values = props.attributeLine.values || []
      formData.value.value_ids = props.attributeLine.value_ids || []

      // 加载属性信息
      if (props.attributeLine.attribute_id) {
        handleAttributeChange(props.attributeLine.attribute_id)
      }
    } else {
      // 新建模式
      formData.value = {
        attribute_id: undefined,
        name: '',
        display_type: 'radio',
        // 如果是组合类型产品，默认不创建变体
        is_variant: isComboProduct.value ? false : true,
        values: [],
        value_ids: []
      }
      selectedAttribute.value = null
      existingValues.value = []
    }
  }

  // 监听对话框显示
  watch(
    () => props.modelValue,
    (newVal) => {
      if (newVal) {
        initForm()
        searchAttributes('')
      }
    }
  )
</script>

<style scoped lang="scss">
  .attribute-config-dialog {
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
          .option-footer {
            display: flex;
            justify-content: center;
            padding: 8px 0;
          }
        }
      }

      .values-table {
        border: 1px solid var(--el-border-color-lighter);
        border-radius: 4px;

        .values-header {
          display: grid;
          grid-template-columns: 1fr 120px 150px 80px;
          gap: 12px;
          padding: 12px;
          font-size: 13px;
          font-weight: 500;
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
            grid-template-columns: 1fr 120px 150px 80px;
            gap: 12px;
            padding: 12px;
            border-bottom: 1px solid var(--el-border-color-lighter);

            &:last-child {
              border-bottom: none;
            }

            .row-cell {
              display: flex;
              align-items: center;
            }
          }
        }

        .values-footer {
          padding: 12px;
          border-top: 1px solid var(--el-border-color-lighter);
        }
      }

      .existing-values {
        display: flex;
        flex-wrap: wrap;
        gap: 8px;
        padding-top: 12px;
        margin-top: 12px;
        border-top: 1px solid var(--el-border-color-lighter);

        .value-tag {
          cursor: pointer;
          transition: opacity 0.2s;

          &:hover {
            opacity: 0.8;
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
