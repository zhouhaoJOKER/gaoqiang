<template>
  <ElDialog
    v-model="dialogVisible"
    title="批量添加产品"
    width="auto"
    :close-on-click-modal="false"
    :close-on-press-escape="false"
  >
    <div class="batch-add-container">
      <div class="table-container">
        <table class="batch-add-table">
          <thead>
            <tr>
              <th>产品名称</th>
              <th>产品编码</th>
              <th>类型</th>
              <th>分类</th>
              <th>售价</th>
              <th>成本价</th>
              <th>市场价</th>
              <th>启用</th>
              <th width="120">操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, index) in formData" :key="index">
              <td>
                <ElInput v-model="row.name" placeholder="请输入产品名称" size="small" />
              </td>
              <td>
                <ElInput v-model="row.code" placeholder="请输入产品编码" size="small" />
              </td>
              <td>
                <PropertySelectWithAdd v-model="row.type_id" sign="product_type" />
              </td>
              <td>
                <PropertySelectWithAdd v-model="row.category_id" sign="product_category" />
              </td>
              <td>
                <ElInput v-model="row.price" type="number" placeholder="0.00" size="small" />
              </td>
              <td>
                <ElInput v-model="row.cost_price" type="number" placeholder="0.00" size="small" />
              </td>
              <td>
                <ElInput v-model="row.market_price" type="number" placeholder="0.00" size="small" />
              </td>
              <td>
                <ElSwitch v-model="row.is_active" size="small" />
              </td>
              <td class="operation-buttons">
                <ElSpace>
                  <ElButton
                    type="primary"
                    size="small"
                    @click="addRow(index)"
                    circle
                    title="新增行"
                  >
                    <ArtSvgIcon icon="ri:add-line" />
                  </ElButton>
                  <ElButton
                    type="success"
                    size="small"
                    @click="copyRow(index)"
                    circle
                    title="复制行"
                  >
                    <ArtSvgIcon icon="ri:file-copy-2-line" />
                  </ElButton>
                  <ElButton
                    type="danger"
                    size="small"
                    @click="removeRow(index)"
                    circle
                    :disabled="formData.length <= 1"
                    title="删除行"
                  >
                    <ArtSvgIcon icon="ri:delete-row" />
                  </ElButton>
                </ElSpace>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>

    <template #footer>
      <span class="dialog-footer">
        <ElButton @click="handleClose">取消</ElButton>
        <ElButton type="primary" @click="handleSubmit">确定</ElButton>
      </span>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  defineOptions({ name: 'ProductBatchAddDialog' })

  import { ref, watch } from 'vue'
  import { ElMessage } from 'element-plus'
  import { batchActionMatProductApi } from '@/api/mat/product'
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'

  interface ProductFormData {
    name: string
    code: string
    type_id?: string | number
    category_id?: string | number
    price: number | string
    cost_price: number | string
    market_price: number | string
    is_active: boolean
  }

  const props = defineProps<{
    modelValue: boolean
  }>()

  const emit = defineEmits<{
    'update:modelValue': [value: boolean]
    addData: [data: any[]]
    success: []
  }>()

  const dialogVisible = ref(false)
  const formData = ref<ProductFormData[]>([])

  const initFormData = (): ProductFormData[] => {
    return [
      {
        name: '',
        code: '',
        type_id: undefined,
        category_id: undefined,
        price: 0,
        cost_price: 0,
        market_price: 0,
        is_active: true
      }
    ]
  }

  watch(
    () => props.modelValue,
    (newVal) => {
      dialogVisible.value = newVal
      if (newVal) {
        formData.value = initFormData()
      }
    }
  )

  const addRow = (index: number | undefined) => {
    const newRow: ProductFormData = {
      name: '',
      code: '',
      type_id: undefined,
      category_id: undefined,
      price: 0,
      cost_price: 0,
      market_price: 0,
      is_active: true
    }

    if (typeof index === 'number') {
      formData.value.splice(index + 1, 0, newRow)
    } else {
      formData.value.push(newRow)
    }
  }

  const copyRow = (index: number) => {
    const rowToCopy = { ...formData.value[index] }
    formData.value.splice(index + 1, 0, rowToCopy)
  }

  const removeRow = (index: number) => {
    if (formData.value.length > 1) {
      formData.value.splice(index, 1)
    } else {
      ElMessage.warning('至少保留一行数据')
    }
  }

  const handleClose = () => {
    emit('update:modelValue', false)
    formData.value = []
  }

  const handleSubmit = async () => {
    const invalidRows = formData.value.filter((row) => !row.name || !row.code)
    if (invalidRows.length > 0) {
      ElMessage.warning('请确保所有行都填写了产品名称和产品编码')
      return
    }

    try {
      const payload = formData.value.map((row) => ({
        ...row,
        price: Number(row.price) || 0,
        cost_price: Number(row.cost_price) || 0,
        market_price: Number(row.market_price) || 0
      }))
      const res = await batchActionMatProductApi({
        actions: 'create',
        products: payload
      })
      if (res?.code === 200) {
        ElMessage.success(res?.msg || '批量新增成功')
        emit('update:modelValue', false)
        emit('success')
        emit('addData', res?.data)
        formData.value = initFormData()
      } else {
        ElMessage.error(res?.message || '批量新增失败')
      }
    } catch (error) {
      console.error('批量新增失败:', error)
      ElMessage.error('批量新增失败')
    }
  }
</script>

<style scoped>
  .batch-add-container {
    max-height: 500px;
    overflow-y: auto;
  }

  .table-container {
    overflow: hidden;
    border: 1px solid #dcdfe6;
    border-radius: 4px;
  }

  .batch-add-table {
    width: 100%;
    table-layout: fixed;
    border-collapse: collapse;
    background-color: #fff;
  }

  .batch-add-table th,
  .batch-add-table td {
    padding: 12px 8px;
    text-align: left;
    vertical-align: middle;
    border: 1px solid #dcdfe6;
  }

  .batch-add-table th {
    font-size: 14px;
    font-weight: 700;
    color: #303133;
    white-space: nowrap;
    background-color: #f5f7fa;
  }

  .operation-buttons {
    display: flex;
    gap: 6px;
    justify-content: center;
    padding: 4px 0;
  }
</style>
