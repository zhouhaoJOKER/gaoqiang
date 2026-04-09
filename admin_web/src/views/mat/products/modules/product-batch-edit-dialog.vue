<template>
  <ElDialog
    v-model="dialogVisible"
    title="批量编辑产品"
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
          <ElFormItem v-if="selectedFields.includes('type_id')" label="类型">
            <PropertySelectWithAdd v-model="formData.type_id" sign="product_type" />
          </ElFormItem>
          <ElFormItem v-if="selectedFields.includes('category_id')" label="分类">
            <PropertySelectWithAdd v-model="formData.category_id" sign="product_category" />
          </ElFormItem>
          <ElFormItem v-if="selectedFields.includes('uom_id')" label="计量单位">
            <PropertySelectWithAdd v-model="formData.uom_id" sign="product_uom" />
          </ElFormItem>
          <ElFormItem v-if="selectedFields.includes('uom_po_id')" label="采购单位">
            <PropertySelectWithAdd v-model="formData.uom_po_id" sign="product_uom_po" />
          </ElFormItem>
          <ElFormItem v-if="selectedFields.includes('sale_tax_id')" label="销售税">
            <PropertySelectWithAdd v-model="formData.sale_tax_id" sign="product_sale_tax" />
          </ElFormItem>
          <ElFormItem v-if="selectedFields.includes('purchase_tax_id')" label="采购税">
            <PropertySelectWithAdd v-model="formData.purchase_tax_id" sign="product_purchase_tax" />
          </ElFormItem>
          <ElFormItem v-if="selectedFields.includes('price')" label="售价">
            <ElInput v-model="formData.price" type="number" placeholder="0.00" />
          </ElFormItem>
          <ElFormItem v-if="selectedFields.includes('cost_price')" label="成本价">
            <ElInput v-model="formData.cost_price" type="number" placeholder="0.00" />
          </ElFormItem>
          <ElFormItem v-if="selectedFields.includes('market_price')" label="市场价">
            <ElInput v-model="formData.market_price" type="number" placeholder="0.00" />
          </ElFormItem>
          <ElFormItem v-if="selectedFields.includes('is_sale')" label="可销售">
            <ElRadioGroup v-model="formData.is_sale">
              <ElRadio :label="true">启用</ElRadio>
              <ElRadio :label="false">停用</ElRadio>
            </ElRadioGroup>
          </ElFormItem>
          <ElFormItem v-if="selectedFields.includes('is_purchase')" label="可采购">
            <ElRadioGroup v-model="formData.is_purchase">
              <ElRadio :label="true">启用</ElRadio>
              <ElRadio :label="false">停用</ElRadio>
            </ElRadioGroup>
          </ElFormItem>
          <ElFormItem v-if="selectedFields.includes('is_manufacture')" label="可生产">
            <ElRadioGroup v-model="formData.is_manufacture">
              <ElRadio :label="true">启用</ElRadio>
              <ElRadio :label="false">停用</ElRadio>
            </ElRadioGroup>
          </ElFormItem>
          <ElFormItem v-if="selectedFields.includes('is_stock')" label="可库存">
            <ElRadioGroup v-model="formData.is_stock">
              <ElRadio :label="true">启用</ElRadio>
              <ElRadio :label="false">停用</ElRadio>
            </ElRadioGroup>
          </ElFormItem>
          <ElFormItem v-if="selectedFields.includes('is_active')" label="启用">
            <ElRadioGroup v-model="formData.is_active">
              <ElRadio :label="true">启用</ElRadio>
              <ElRadio :label="false">停用</ElRadio>
            </ElRadioGroup>
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
  defineOptions({ name: 'ProductBatchEditDialog' })

  import { ref, defineProps, defineEmits, watch, computed } from 'vue'
  import { ElMessage } from 'element-plus'
  import { batchActionMatProductApi } from '@/api/mat/product'
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'

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

  const formData = ref({
    type_id: undefined as string | number | undefined,
    category_id: undefined as string | number | undefined,
    uom_id: undefined as string | number | undefined,
    uom_po_id: undefined as string | number | undefined,
    sale_tax_id: undefined as string | number | undefined,
    purchase_tax_id: undefined as string | number | undefined,
    price: 0,
    cost_price: 0,
    market_price: 0,
    is_sale: true,
    is_purchase: true,
    is_manufacture: false,
    is_stock: true,
    is_active: true
  })

  const fields = [
    { prop: 'type_id', label: '类型' },
    { prop: 'category_id', label: '分类' },
    { prop: 'uom_id', label: '计量单位' },
    { prop: 'uom_po_id', label: '采购单位' },
    { prop: 'sale_tax_id', label: '销售税' },
    { prop: 'purchase_tax_id', label: '采购税' },
    { prop: 'price', label: '售价' },
    { prop: 'cost_price', label: '成本价' },
    { prop: 'market_price', label: '市场价' },
    { prop: 'is_sale', label: '可销售' },
    { prop: 'is_purchase', label: '可采购' },
    { prop: 'is_manufacture', label: '可生产' },
    { prop: 'is_stock', label: '可库存' },
    { prop: 'is_active', label: '启用' }
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

  watch(dialogVisible, (newVal) => {
    emit('update:modelValue', newVal)
  })

  watch(
    () => props.modelValue,
    (newVal) => {
      dialogVisible.value = newVal
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
        ElMessage.warning('请先选择要编辑的产品')
        return
      }

      const updateData = {
        actions: 'update',
        fields: selectedFields.value,
        values: {
          ...formData.value,
          price: Number(formData.value.price) || 0,
          cost_price: Number(formData.value.cost_price) || 0,
          market_price: Number(formData.value.market_price) || 0
        },
        ids: selectedIds
      }

      await batchActionMatProductApi(updateData)
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
