<template>
  <ElDialog
    v-model="dialogVisible"
    title="批量添加供应商"
    width="auto"
    :close-on-click-modal="false"
    :close-on-press-escape="false"
  >
    <div class="batch-add-container">
      <div class="table-container">
        <table class="batch-add-table">
          <thead>
            <tr>
              <th>供应商名称</th>
              <th>供应商编码</th>
              <th>公司</th>
              <th>产品</th>
              <th>最小数量</th>
              <th>价格</th>
              <th>货币</th>
              <th>延迟天数</th>
              <th>主供应商</th>
              <th>排序</th>
              <th width="120">操作</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, index) in formData" :key="index">
              <td>
                <ElInput v-model="row.name" placeholder="请输入供应商名称" size="small" />
              </td>
              <td>
                <ElInput v-model="row.code" placeholder="请输入供应商编码" size="small" />
              </td>
              <td>
                <ElSelect
                  v-model="row.company_id"
                  placeholder="选择公司"
                  size="small"
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
              </td>
              <td>
                <ElSelect
                  v-model="row.product_id"
                  placeholder="选择产品"
                  size="small"
                  filterable
                  remote
                  :remote-method="(query) => searchProducts(query, index)"
                  :loading="productSearchLoading"
                  style="width: 100%"
                >
                  <ElOption
                    v-for="product in productOptions[index] || []"
                    :key="product.id"
                    :label="`[${product.code || ''}] ${product.name}`"
                    :value="product.id"
                  />
                </ElSelect>
              </td>
              <td>
                <ElInput v-model="row.min_qty" type="number" placeholder="0.00" size="small" />
              </td>
              <td>
                <ElInput v-model="row.price" type="number" placeholder="0.00" size="small" />
              </td>
              <td>
                <PropertySelectWithAdd v-model="row.currency_id" sign="currency" size="small" />
              </td>
              <td>
                <ElInput v-model="row.delay" type="number" placeholder="0" size="small" />
              </td>
              <td>
                <ElSwitch v-model="row.is_main" size="small" />
              </td>
              <td>
                <ElInput v-model="row.sort" type="number" placeholder="0.00" size="small" />
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
  import { ref, watch } from 'vue'
  import { ElMessage, ElButton, ElInput, ElSelect, ElOption, ElSwitch, ElSpace } from 'element-plus'
  import { batchActionMatSupplierApi } from '@/api/mat/supplier'
  import { listCompanyApi } from '@/api/company'
  import { listMatProductApi } from '@/api/mat/product'
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'

  defineOptions({ name: 'SupplierBatchAddDialog' })

  interface SupplierFormData {
    name: string
    code: string
    company_id?: string | number
    product_id?: string | number
    min_qty: number | string
    price: number | string
    currency_id?: string | number
    delay: number | string
    is_main: boolean
    sort: number | string
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
  const formData = ref<SupplierFormData[]>([])
  const companyList = ref<any[]>([])
  const productOptions = ref<Record<number, any[]>>({})
  const productSearchLoading = ref(false)

  const initFormData = (): SupplierFormData[] => {
    return [
      {
        name: '',
        code: '',
        company_id: undefined,
        product_id: undefined,
        min_qty: 0,
        price: 0,
        currency_id: undefined,
        delay: 0,
        is_main: false,
        sort: 0
      }
    ]
  }

  const loadCompanyList = async (): Promise<void> => {
    try {
      const res = await listCompanyApi({})
      companyList.value = (res as any).data || []
    } catch (error) {
      console.error('加载公司列表失败:', error)
    }
  }

  const searchProducts = async (query: string, index: number): Promise<void> => {
    productSearchLoading.value = true
    try {
      const res = await listMatProductApi({
        'q[name_or_py_cont]': query || '',
        per_page: 50
      })
      productOptions.value[index] = (res as any).data || []
    } catch (error) {
      console.error('搜索产品失败:', error)
      productOptions.value[index] = []
    } finally {
      productSearchLoading.value = false
    }
  }

  watch(
    () => props.modelValue,
    (newVal) => {
      dialogVisible.value = newVal
      if (newVal) {
        formData.value = initFormData()
        loadCompanyList()
      }
    }
  )

  const addRow = (index: number | undefined) => {
    const newRow: SupplierFormData = {
      name: '',
      code: '',
      company_id: undefined,
      product_id: undefined,
      min_qty: 0,
      price: 0,
      currency_id: undefined,
      delay: 0,
      is_main: false,
      sort: 0
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
    const invalidRows = formData.value.filter(
      (row) => !row.name || !row.code || !row.company_id || !row.product_id
    )
    if (invalidRows.length > 0) {
      ElMessage.warning('请确保所有行都填写了供应商名称、编码、公司和产品')
      return
    }

    try {
      const payload = formData.value.map((row) => ({
        ...row,
        min_qty: Number(row.min_qty) || 0,
        price: Number(row.price) || 0,
        delay: Number(row.delay) || 0,
        sort: Number(row.sort) || 0
      }))
      const res = await batchActionMatSupplierApi({
        actions: 'create',
        suppliers: payload
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
