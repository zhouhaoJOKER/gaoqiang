<template>
  <ElDialog
    v-model="dialogVisible"
    title="批量编辑供应商"
    width="820px"
    :close-on-click-modal="false"
    :close-on-press-escape="false"
  >
    <div class="batch-edit-container">
      <div class="field-selection">
        <div class="flex justify-between items-center mb-0">
          <h3>选择要修改的字段</h3>
          <ElButton type="primary" size="small" @click="toggleSelectAll">
            {{ isAllSelected ? '取消全选' : '全选' }}
          </ElButton>
        </div>
        <ElCheckboxGroup v-model="selectedFields">
          <ElSpace wrap>
            <ElCheckbox v-for="field in fields" :key="field.prop" :label="field.prop">
              {{ field.label }}
            </ElCheckbox>
          </ElSpace>
        </ElCheckboxGroup>
      </div>

      <div class="form-container">
        <h3>修改内容</h3>
        <ElForm ref="formRef" :model="formData" label-width="120px">
          <ElFormItem v-if="selectedFields.includes('company_id')" label="公司">
            <ElSelect
              v-model="formData.company_id"
              placeholder="选择公司"
              filterable
              style="width: 100%"
            >
              <ElOption
                v-for="company in companyList"
                :key="company.id"
                :label="company.name"
                :value="company.id"
              />
            </ElSelect>
          </ElFormItem>
          <ElFormItem v-if="selectedFields.includes('product_id')" label="产品">
            <ElSelect
              v-model="formData.product_id"
              placeholder="选择产品"
              filterable
              remote
              :remote-method="searchProducts"
              :loading="productSearchLoading"
              style="width: 100%"
            >
              <ElOption
                v-for="product in productOptions"
                :key="product.id"
                :label="`[${product.code || ''}] ${product.name}`"
                :value="product.id"
              />
            </ElSelect>
          </ElFormItem>
          <ElFormItem v-if="selectedFields.includes('min_qty')" label="最小数量">
            <ElInput v-model="formData.min_qty" type="number" placeholder="0.00" />
          </ElFormItem>
          <ElFormItem v-if="selectedFields.includes('price')" label="价格">
            <ElInput v-model="formData.price" type="number" placeholder="0.00" />
          </ElFormItem>
          <ElFormItem v-if="selectedFields.includes('currency_id')" label="货币">
            <PropertySelectWithAdd
              v-model="formData.currency_id"
              sign="currency"
              placeholder="选择货币"
            />
          </ElFormItem>
          <ElFormItem v-if="selectedFields.includes('delay')" label="延迟天数">
            <ElInput v-model="formData.delay" type="number" placeholder="0" />
          </ElFormItem>
          <ElFormItem v-if="selectedFields.includes('is_main')" label="主供应商">
            <ElRadioGroup v-model="formData.is_main">
              <ElRadio :label="true">是</ElRadio>
              <ElRadio :label="false">否</ElRadio>
            </ElRadioGroup>
          </ElFormItem>
          <ElFormItem v-if="selectedFields.includes('sort')" label="排序">
            <ElInput v-model="formData.sort" type="number" placeholder="0.00" />
          </ElFormItem>
        </ElForm>
      </div>
    </div>

    <template #footer>
      <span class="dialog-footer">
        <ElButton @click="handleClose">取消</ElButton>
        <ElButton type="primary" @click="handleSubmit">提交修改</ElButton>
      </span>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, watch, computed } from 'vue'
  import {
    ElMessage,
    ElButton,
    ElForm,
    ElFormItem,
    ElInput,
    ElSelect,
    ElOption,
    ElCheckboxGroup,
    ElCheckbox,
    ElRadioGroup,
    ElRadio,
    ElSpace
  } from 'element-plus'
  import { batchActionMatSupplierApi } from '@/api/mat/supplier'
  import { listCompanyApi } from '@/api/company'
  import { listMatProductApi } from '@/api/mat/product'
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'

  defineOptions({ name: 'SupplierBatchEditDialog' })

  const props = defineProps<{
    modelValue: boolean
    selectedRows?: any[]
  }>()

  const emit = defineEmits<{
    'update:modelValue': [value: boolean]
    success: []
  }>()

  const dialogVisible = ref(props.modelValue)
  const formRef = ref()
  const companyList = ref<any[]>([])
  const productOptions = ref<any[]>([])
  const productSearchLoading = ref(false)

  const formData = ref({
    company_id: undefined as string | number | undefined,
    product_id: undefined as string | number | undefined,
    min_qty: 0,
    price: 0,
    currency_id: undefined as string | number | undefined,
    delay: 0,
    is_main: false,
    sort: 0
  })

  const fields = [
    { prop: 'company_id', label: '公司' },
    { prop: 'product_id', label: '产品' },
    { prop: 'min_qty', label: '最小数量' },
    { prop: 'price', label: '价格' },
    { prop: 'currency_id', label: '货币' },
    { prop: 'delay', label: '延迟天数' },
    { prop: 'is_main', label: '主供应商' },
    { prop: 'sort', label: '排序' }
  ]

  const selectedFields = ref(fields.map((field) => field.prop))

  const isAllSelected = computed(() => {
    return selectedFields.value.length === fields.length
  })

  const toggleSelectAll = () => {
    if (isAllSelected.value) {
      selectedFields.value = []
    } else {
      selectedFields.value = fields.map((field) => field.prop)
    }
  }

  const loadCompanyList = async (): Promise<void> => {
    try {
      const res = await listCompanyApi({})
      companyList.value = (res as any).data || []
    } catch (error) {
      console.error('加载公司列表失败:', error)
    }
  }

  const searchProducts = async (query: string): Promise<void> => {
    productSearchLoading.value = true
    try {
      const res = await listMatProductApi({
        'q[name_or_py_cont]': query || '',
        per_page: 50
      })
      productOptions.value = (res as any).data || []
    } catch (error) {
      console.error('搜索产品失败:', error)
      productOptions.value = []
    } finally {
      productSearchLoading.value = false
    }
  }

  watch(dialogVisible, (newVal) => {
    emit('update:modelValue', newVal)
    if (newVal) {
      loadCompanyList()
      searchProducts('')
    }
  })

  watch(
    () => props.modelValue,
    (newVal) => {
      dialogVisible.value = newVal
      if (newVal) {
        loadCompanyList()
        searchProducts('')
      }
    }
  )

  const handleClose = () => {
    dialogVisible.value = false
  }

  const handleSubmit = async () => {
    if (!selectedFields.value.length) {
      ElMessage.warning('请至少选择一个要修改的字段')
      return
    }

    try {
      const selectedIds = props.selectedRows?.map((row) => row.id) || []
      if (selectedIds.length === 0) {
        ElMessage.warning('请先选择要编辑的供应商')
        return
      }

      const updateData = {
        actions: 'update',
        fields: selectedFields.value,
        values: {
          ...formData.value,
          min_qty: Number(formData.value.min_qty) || 0,
          price: Number(formData.value.price) || 0,
          delay: Number(formData.value.delay) || 0,
          sort: Number(formData.value.sort) || 0
        },
        ids: selectedIds
      }

      await batchActionMatSupplierApi(updateData)
      ElMessage.success('批量修改成功')
      dialogVisible.value = false
      emit('success')
    } catch (error) {
      console.error('批量修改失败:', error)
      ElMessage.error('批量修改失败，请重试')
    }
  }
</script>

<style scoped>
  .batch-edit-container {
    display: flex;
    flex-direction: column;
    gap: 24px;
  }

  .field-selection,
  .form-container {
    padding: 16px;
    background-color: #fafafa;
    border: 1px solid #ebeef5;
    border-radius: 4px;
  }

  h3 {
    margin: 0 0 16px;
    font-size: 14px;
    font-weight: 600;
    color: #303133;
  }

  .field-selection {
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .form-container {
    background-color: #fff;
  }
</style>
