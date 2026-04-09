<!-- 组合创建/编辑对话框 -->
<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="800px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <div class="combo-dialog">
      <div class="form-row">
        <!-- 组合选择/名称 -->
        <div class="form-item">
          <div class="form-label">组合名称</div>
          <ElInput
            v-model="form.name"
            placeholder="请输入组合名称"
            size="small"
            :readonly="props.readonly"
          />
        </div>

        <!-- 公司 -->
        <div class="form-item">
          <div class="form-label">公司</div>
          <ElSelect
            v-model="form.company_id"
            placeholder="请选择公司"
            size="small"
            filterable
            style="width: 100%"
            :disabled="props.readonly"
            @change="handleCompanyChange"
          >
            <ElOption
              v-for="company in companyList"
              :key="company.id"
              :label="company.name"
              :value="company.id"
            />
          </ElSelect>
        </div>

        <!-- 价格和折扣 -->
        <div class="form-item">
          <div class="form-label">价格</div>
          <ElInput v-model="form.price" type="number" placeholder="0.00" size="small" readonly />
        </div>
        <div class="form-item">
          <div class="form-label">折扣</div>
          <ElInput
            v-model="form.discount"
            type="number"
            placeholder="0.00"
            size="small"
            :readonly="props.readonly"
            @input="handleDiscountChange"
          />
        </div>
      </div>

      <!-- 描述 -->
      <div class="form-item">
        <div class="form-label">描述</div>
        <ElInput
          v-model="form.description"
          type="textarea"
          size="small"
          :rows="1"
          placeholder="请输入描述"
          :readonly="readonly"
        />
      </div>

      <!-- 选项表格 -->
      <div class="form-item">
        <div class="form-label">选项</div>
        <div class="options-table">
          <div class="table-header" size="small">
            <div class="header-cell">产品</div>
            <div class="header-cell">原价</div>
            <div class="header-cell">额外价格</div>
            <div class="header-cell action-cell">操作</div>
          </div>
          <div class="table-body">
            <!-- 已有选项 -->
            <div v-for="(option, index) in form.options" :key="index" class="table-row">
              <div class="cell">
                <ElSelect
                  v-model="option.product_id"
                  placeholder="选择产品"
                  size="small"
                  filterable
                  remote
                  :remote-method="searchProducts"
                  :loading="productSearchLoading"
                  :disabled="props.readonly"
                  style="width: 100%"
                  @change="(val) => handleProductChange(index, val)"
                >
                  <ElOption
                    v-for="product in productOptions"
                    :key="product.id"
                    :label="`[${product.code || ''}] ${product.name}`"
                    :value="product.id"
                  />
                </ElSelect>
              </div>
              <div class="cell">
                <ElInput
                  size="small"
                  v-model="option.price"
                  type="number"
                  placeholder="0.00"
                  readonly
                />
              </div>
              <div class="cell">
                <ElInput
                  v-model="option.extra_price"
                  size="small"
                  type="number"
                  placeholder="0.00"
                  :readonly="props.readonly"
                  @input="() => calculateTotalPrice()"
                />
              </div>
              <div class="cell action-cell">
                <ElButton
                  v-if="!props.readonly"
                  text
                  type="danger"
                  size="small"
                  @click="removeOption(index)"
                >
                  <ArtSvgIcon icon="ri:delete-bin-line" />
                </ElButton>
              </div>
            </div>

            <!-- 新增行 -->
            <div v-if="showNewRow" class="table-row new-row">
              <div class="cell">
                <ElSelect
                  v-model="newOption.product_id"
                  placeholder="选择产品"
                  filterable
                  size="small"
                  remote
                  :remote-method="searchProducts"
                  :loading="productSearchLoading"
                  style="width: 100%"
                  @change="handleNewProductChange"
                >
                  <ElOption
                    v-for="product in productOptions"
                    :key="product.id"
                    :label="`[${product.code || ''}] ${product.name}`"
                    :value="product.id"
                  />
                </ElSelect>
              </div>
              <div class="cell">
                <ElInput
                  size="small"
                  v-model="newOption.price"
                  type="number"
                  placeholder="0.00"
                  readonly
                />
              </div>
              <div class="cell">
                <ElInput
                  size="small"
                  v-model="newOption.extra_price"
                  type="number"
                  placeholder="0.00"
                  @input="calculateTotalPrice"
                />
              </div>
              <div class="cell action-cell">
                <ElButton size="small" text type="danger" @click="cancelNewRow">
                  <ArtSvgIcon icon="ri:delete-bin-line" />
                </ElButton>
              </div>
            </div>
          </div>
          <div v-if="!props.readonly" class="table-footer">
            <ElButton text size="small" type="primary" @click="addNewRow">
              <ArtSvgIcon icon="ri:add-line" class="mr-1" />
              添加行
            </ElButton>
          </div>
        </div>
      </div>
    </div>

    <template #footer>
      <div class="dialog-footer">
        <ElButton @click="handleCancel">{{ props.readonly ? '关闭' : '放弃' }}</ElButton>
        <template v-if="!props.readonly">
          <ElButton v-if="!isEditMode" type="primary" @click="handleSaveAndNew"
            >保存并新建</ElButton
          >
          <ElButton type="primary" @click="handleSave">{{ isEditMode ? '保存' : '保存' }}</ElButton>
        </template>
      </div>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, reactive, computed, watch } from 'vue'
  import { ElMessage } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { ElDialog, ElInput, ElSelect, ElOption, ElButton } from 'element-plus'
  import {
    createMatProductComboApi,
    updateMatProductComboApi,
    viewMatProductComboApi
  } from '@/api/mat/product'
  import { listMatProductApi } from '@/api/mat/product'
  import { listCompanyApi } from '@/api/company'

  interface Props {
    modelValue: boolean
    combo?: any // 编辑模式时传入的组合数据
    readonly?: boolean // 是否只读模式（查看模式）
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', combo: any): void
    (e: 'updated', combo: any): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    combo: undefined,
    readonly: false
  })

  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const isEditMode = computed(() => !!props.combo && !!props.combo.id)

  const dialogTitle = computed(() => {
    if (props.readonly) return '查看组合'
    return isEditMode.value ? '编辑组合' : '创建组合'
  })

  const form = reactive({
    name: '',
    company_id: undefined as string | number | undefined,
    price: 0,
    discount: 0,
    description: '',
    options: [] as Array<{
      product_id?: string | number
      name?: string
      price: number
      extra_price: number
    }>
  })

  const newOption = reactive({
    product_id: undefined as string | number | undefined,
    name: '',
    price: 0,
    extra_price: 0
  })

  const showNewRow = ref(false)
  const companyList = ref<any[]>([])
  const productOptions = ref<any[]>([])
  const productSearchLoading = ref(false)
  const productMap = ref<Record<string | number, any>>({})

  // 加载公司列表
  const loadCompanyList = async (): Promise<void> => {
    try {
      const res = await listCompanyApi({})
      companyList.value = (res as any).data || []
    } catch (error) {
      console.error('加载公司列表失败:', error)
    }
  }

  // 搜索产品
  const searchProducts = async (query: string): Promise<void> => {
    productSearchLoading.value = true
    try {
      const res = await listMatProductApi({
        'q[name_or_py_cont]': query || '',
        per_page: 50
      })
      const products = (res as any).data || []
      productOptions.value = products
      // 构建产品映射
      products.forEach((product: any) => {
        productMap.value[product.id] = product
      })
    } catch (error) {
      console.error('搜索产品失败:', error)
    } finally {
      productSearchLoading.value = false
    }
  }

  // 计算总价
  const calculateTotalPrice = (): void => {
    let total = 0
    form.options.forEach((option) => {
      total += Number(option.price || 0) + Number(option.extra_price || 0)
    })
    if (showNewRow.value && newOption.product_id) {
      total += Number(newOption.price || 0) + Number(newOption.extra_price || 0)
    }
    form.price = total
  }

  // 处理产品变化
  const handleProductChange = (index: number, productId: string | number): void => {
    const product = productMap.value[productId]
    if (product) {
      form.options[index].product_id = productId
      form.options[index].name = product.name
      form.options[index].price = Number(product.price || 0)
      calculateTotalPrice()
    }
  }

  // 处理新产品变化
  const handleNewProductChange = (productId: string | number): void => {
    const product = productMap.value[productId]
    if (product) {
      newOption.product_id = productId
      newOption.name = product.name
      newOption.price = Number(product.price || 0)
      // 将新选项添加到 options 中
      form.options.push({
        product_id: productId,
        name: product.name,
        price: Number(product.price || 0),
        extra_price: 0
      })
      // 重置新选项
      newOption.product_id = undefined
      newOption.name = ''
      newOption.price = 0
      newOption.extra_price = 0
      calculateTotalPrice()
    }
  }

  // 处理公司变化
  const handleCompanyChange = (): void => {
    // 可以根据公司重新计算价格
    calculateTotalPrice()
  }

  // 处理折扣变化
  const handleDiscountChange = (): void => {
    // 可以根据折扣重新计算价格
    calculateTotalPrice()
  }

  // 添加新行
  const addNewRow = (): void => {
    showNewRow.value = true
    newOption.product_id = undefined
    newOption.name = ''
    newOption.price = 0
    newOption.extra_price = 0
  }

  // 取消新行
  const cancelNewRow = (): void => {
    showNewRow.value = false
    newOption.product_id = undefined
    newOption.name = ''
    newOption.price = 0
    newOption.extra_price = 0
  }

  // 移除选项
  const removeOption = (index: number): void => {
    form.options.splice(index, 1)
    calculateTotalPrice()
  }

  // 加载组合详情
  const loadComboDetail = async (): Promise<void> => {
    if (!props.combo?.id) return
    try {
      const res = await viewMatProductComboApi({ id: props.combo.id })
      const comboData = (res as any).data || {}
      form.name = comboData.name || ''
      form.company_id = comboData.company_id
      form.price = comboData.price || 0
      form.discount = comboData.discount || 0
      form.description = comboData.description || ''
      form.options = (comboData.options || []).map((opt: any) => ({
        product_id: opt.product_id,
        name: opt.name || opt.product_name,
        price: Number(opt.price || 0),
        extra_price: Number(opt.extra_price || 0)
      }))
      // 加载产品信息到 productMap
      if (form.options.length > 0) {
        const productIds = form.options.map((opt) => opt.product_id).filter(Boolean)
        if (productIds.length > 0) {
          await searchProducts('')
          // 确保产品映射包含所有需要的产品
          form.options.forEach((opt) => {
            if (opt.product_id && !productMap.value[opt.product_id]) {
              productMap.value[opt.product_id] = {
                id: opt.product_id,
                name: opt.name,
                price: opt.price
              }
            }
          })
        }
      }
      calculateTotalPrice()
    } catch (error) {
      console.error('加载组合详情失败:', error)
      ElMessage.error('加载组合详情失败')
    }
  }

  // 保存
  const handleSave = async (): Promise<void> => {
    if (props.readonly) {
      handleCancel()
      return
    }

    if (!form.name.trim()) {
      ElMessage.warning('请输入组合名称')
      return
    }
    if (form.options.length === 0) {
      ElMessage.warning('请至少添加一个产品选项')
      return
    }

    try {
      const params = {
        name: form.name,
        company_id: form.company_id,
        price: form.price,
        discount: form.discount || 0,
        description: form.description,
        products: form.options
          .filter((opt) => opt.product_id)
          .map((opt) => ({
            product_id: opt.product_id,
            name: opt.name,
            price: opt.price,
            extra_price: opt.extra_price || 0
          }))
      }

      if (isEditMode.value) {
        // 编辑模式
        const res = await updateMatProductComboApi(String(props.combo.id), params)
        ElMessage.success('更新成功')
        emit('updated', (res as any).data || { ...props.combo, ...params })
        handleCancel()
      } else {
        // 创建模式
        const res = await createMatProductComboApi(params)
        ElMessage.success('创建成功')
        emit('created', (res as any).data)
        handleCancel()
      }
    } catch (error) {
      console.error(isEditMode.value ? '更新组合失败:' : '创建组合失败:', error)
      ElMessage.error(isEditMode.value ? '更新组合失败' : '创建组合失败')
    }
  }

  // 保存并新建
  const handleSaveAndNew = async (): Promise<void> => {
    if (!form.name.trim()) {
      ElMessage.warning('请输入组合名称')
      return
    }
    if (form.options.length === 0) {
      ElMessage.warning('请至少添加一个产品选项')
      return
    }
    try {
      const params: any = {
        name: form.name,
        company_id: form.company_id,
        price: form.price,
        discount: form.discount || 0,
        description: form.description,
        products: form.options
          .filter((opt) => opt.product_id)
          .map((opt) => ({
            product_id: opt.product_id,
            name: opt.name,
            price: opt.price,
            extra_price: opt.extra_price || 0
          }))
      }
      const res = await createMatProductComboApi(params)
      ElMessage.success('创建成功')
      emit('created', (res as any).data)
      // 重置表单，保持弹窗打开
      form.name = ''
      form.company_id = undefined
      form.price = 0
      form.discount = 0
      form.description = ''
      form.options = []
      showNewRow.value = false
      cancelNewRow()
    } catch (error) {
      console.error('创建组合失败:', error)
      ElMessage.error('创建组合失败')
    }
  }

  // 取消
  const handleCancel = (): void => {
    dialogVisible.value = false
  }

  // 关闭后重置
  const handleClosed = (): void => {
    form.name = ''
    form.company_id = undefined
    form.price = 0
    form.discount = 0
    form.description = ''
    form.options = []
    showNewRow.value = false
    cancelNewRow()
    productOptions.value = []
    productMap.value = {}
  }

  watch(
    () => props.modelValue,
    async (val) => {
      if (val) {
        loadCompanyList()
        searchProducts('')
        if (isEditMode.value) {
          await loadComboDetail()
        }
      }
    }
  )

  watch(
    () => props.combo,
    async () => {
      if (props.modelValue && isEditMode.value) {
        await loadComboDetail()
      }
    },
    { deep: true }
  )
</script>

<style scoped lang="scss">
  .combo-dialog {
    .form-item {
      margin-bottom: 8px;

      .form-label {
        margin-bottom: 4px;
        font-size: 14px;
        font-weight: 300;
        color: var(--el-text-color-primary);
      }
    }

    .form-row {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 12px;
    }

    .options-table {
      overflow: hidden;
      border: 1px solid var(--el-border-color-lighter);
      border-radius: 4px;

      .table-header {
        display: grid;
        grid-template-columns: 2fr 1fr 1fr 60px;
        background: var(--el-fill-color-light);
        border-bottom: 1px solid var(--el-border-color-lighter);

        .header-cell {
          padding: 8px;
          font-size: 11px;
          font-weight: 300;
          color: var(--el-text-color-primary);
          border-right: 1px solid var(--el-border-color-lighter);

          &:last-child {
            border-right: none;
          }

          &.action-cell {
            text-align: center;
          }
        }
      }

      .table-body {
        .table-row {
          display: grid;
          grid-template-columns: 2fr 1fr 1fr 60px;
          border-bottom: 1px solid var(--el-border-color-lighter);

          &:last-child {
            border-bottom: none;
          }

          &.new-row {
            background: var(--el-fill-color-lighter);
          }

          .cell {
            padding: 12px;
            border-right: 1px solid var(--el-border-color-lighter);

            &:last-child {
              border-right: none;
            }

            &.action-cell {
              display: flex;
              align-items: center;
              justify-content: center;
            }
          }
        }
      }

      .table-footer {
        padding: 12px;
        background: var(--el-fill-color-lighter);
        border-top: 1px solid var(--el-border-color-lighter);
      }
    }
  }

  .dialog-footer {
    display: flex;
    gap: 12px;
    justify-content: flex-end;
  }
</style>
