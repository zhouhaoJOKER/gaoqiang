<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="1000px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <div class="work-order-dialog">
      <StatusStepper
        v-if="form.status"
        :id="form.id"
        :status="form.status"
        :readonly="props.readonly"
        @change="handleStatusChange"
        @close="dialogVisible = false"
      />
      <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px">
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="工单编号" prop="code">
              <ElInput
                v-model="form.code"
                placeholder="请输入工单编号"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="产品" prop="product_id">
              <ElSelect
                v-model="form.product_id"
                placeholder="请选择产品"
                filterable
                remote
                :remote-method="searchProducts"
                :loading="productSearchLoading"
                style="width: 100%"
                :disabled="props.readonly"
              >
                <ElOption
                  v-for="product in productOptions"
                  :key="product.id"
                  :label="`[${product.code || ''}] ${product.name}`"
                  :value="product.id"
                />
              </ElSelect>
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="BOM">
              <ElSelect
                v-model="form.bom_id"
                placeholder="请选择BOM"
                filterable
                remote
                :remote-method="searchBoms"
                :loading="bomSearchLoading"
                style="width: 100%"
                :disabled="props.readonly"
              >
                <ElOption
                  v-for="bom in bomOptions"
                  :key="bom.id"
                  :label="`[${bom.code || ''}] ${bom.name || ''}`"
                  :value="bom.id"
                />
              </ElSelect>
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="计划数量" prop="plan_qty">
              <ElInput
                v-model="form.plan_qty"
                type="number"
                placeholder="0.00"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="实际数量">
              <ElInput
                v-model="form.actual_qty"
                type="number"
                placeholder="0.00"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="计划开始" prop="plan_start">
              <ElDatePicker
                v-model="form.plan_start"
                type="datetime"
                placeholder="请选择计划开始时间"
                style="width: 100%"
                :disabled="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="计划完成" prop="plan_finish">
              <ElDatePicker
                v-model="form.plan_finish"
                type="datetime"
                placeholder="请选择计划完成时间"
                style="width: 100%"
                :disabled="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="实际开始">
              <ElDatePicker
                v-model="form.actual_start"
                type="datetime"
                placeholder="请选择实际开始时间"
                style="width: 100%"
                :disabled="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="实际完成">
              <ElDatePicker
                v-model="form.actual_finish"
                type="datetime"
                placeholder="请选择实际完成时间"
                style="width: 100%"
                :disabled="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="仓库" prop="warehouse_id">
              <ElSelect
                v-model="form.warehouse_id"
                placeholder="请选择仓库"
                filterable
                remote
                :remote-method="searchWarehouses"
                :loading="warehouseSearchLoading"
                style="width: 100%"
                :disabled="props.readonly"
                @change="handleWarehouseSelectChange"
              >
                <ElOption
                  v-for="warehouse in warehouseOptions"
                  :key="warehouse.id"
                  :label="`[${warehouse.code || ''}] ${warehouse.name}`"
                  :value="warehouse.id"
                />
                <ElOption v-if="!props.readonly" value="__add_warehouse__" class="add-option">
                  <span
                    style="
                      display: flex;
                      gap: 4px;
                      align-items: center;
                      color: var(--el-color-primary);
                    "
                  >
                    <ArtSvgIcon icon="ri:add-line" />
                    新增仓库
                  </span>
                </ElOption>
              </ElSelect>
            </ElFormItem>
          </ElCol>
        </ElRow>
      </ElForm>
    </div>

    <!-- 仓库创建对话框 -->
    <WarehouseDialog v-model="warehouseDialogVisible" @created="handleWarehouseCreated" />

    <template #footer>
      <div class="dialog-footer">
        <ElButton @click="handleCancel">{{ props.readonly ? '关闭' : '取消' }}</ElButton>
        <template v-if="!props.readonly">
          <ElButton type="primary" @click="handleSave">{{ isEditMode ? '保存' : '保存' }}</ElButton>
        </template>
      </div>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, reactive, computed, watch, nextTick } from 'vue'
  import { ElMessage } from 'element-plus'
  import type { FormInstance, FormRules } from 'element-plus'
  import {
    ElDialog,
    ElForm,
    ElFormItem,
    ElInput,
    ElSelect,
    ElOption,
    ElButton,
    ElRow,
    ElCol,
    ElDatePicker
  } from 'element-plus'
  import {
    createMfgWorkOrderApi,
    updateMfgWorkOrderApi,
    viewMfgWorkOrderApi
  } from '@/api/mfg/work-order'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import StatusStepper from '@/components/wms/StatusStepper.vue'
  import WarehouseDialog from '@/views/wms/warehouses/modules/warehouse-dialog.vue'
  import { listMatProductApi } from '@/api/mat/product'
  import { listMfgBomApi } from '@/api/mfg/bom'
  import { listWmsWarehouseApi } from '@/api/wms/warehouse'

  interface Props {
    modelValue: boolean
    workOrder?: any
    readonly?: boolean
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', workOrder: any): void
    (e: 'updated', workOrder: any): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    workOrder: undefined,
    readonly: false
  })

  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const isEditMode = computed(() => !!props.workOrder && !!props.workOrder.id)
  const dialogTitle = computed(() => {
    if (props.readonly) return '查看工单'
    return isEditMode.value ? '编辑工单' : '创建工单'
  })

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    code: [{ required: true, message: '请输入工单编号', trigger: 'blur' }],
    product_id: [{ required: true, message: '请选择产品', trigger: 'change' }],
    bom_id: [{ required: true, message: '请选择BOM', trigger: 'change' }],
    warehouse_id: [{ required: true, message: '请选择仓库', trigger: 'change' }],
    status: [{ required: true, message: '请选择状态', trigger: 'change' }]
  })

  const form = reactive({
    id: undefined,
    code: '',
    bom_id: undefined as string | number | undefined,
    product_id: undefined as string | number | undefined,
    plan_qty: 0,
    actual_qty: 0,
    status: 'draft',
    plan_start: undefined as string | undefined,
    plan_finish: undefined as string | undefined,
    actual_start: undefined as string | undefined,
    actual_finish: undefined as string | undefined,
    warehouse_id: undefined as string | number | undefined,
    company_id: undefined as string | number | undefined
  })

  const productOptions = ref<any[]>([])
  const productSearchLoading = ref(false)
  const bomOptions = ref<any[]>([])
  const bomSearchLoading = ref(false)
  const warehouseOptions = ref<any[]>([])
  const warehouseSearchLoading = ref(false)
  const warehouseDialogVisible = ref(false)
  const lastWarehouseId = ref<string | number | undefined>(undefined)

  const searchProducts = async (query: string): Promise<void> => {
    productSearchLoading.value = true
    try {
      const res = await listMatProductApi({
        'q[name_or_code_cont]': query || '',
        per_page: 50
      })
      productOptions.value = (res as any).data || []
    } catch (error) {
      console.error('搜索产品失败:', error)
    } finally {
      productSearchLoading.value = false
    }
  }

  const searchBoms = async (query: string): Promise<void> => {
    bomSearchLoading.value = true
    try {
      const res = await listMfgBomApi({
        'q[code_cont]': query || '',
        per_page: 50
      })
      bomOptions.value = (res as any).data || []
    } catch (error) {
      console.error('搜索BOM失败:', error)
    } finally {
      bomSearchLoading.value = false
    }
  }

  const handleWarehouseSelectChange = (value: string | number): void => {
    if (value === '__add_warehouse__') {
      form.warehouse_id = lastWarehouseId.value
      nextTick(() => {
        warehouseDialogVisible.value = true
      })
    } else {
      lastWarehouseId.value = value
    }
  }

  const handleWarehouseCreated = async (warehouse: any): Promise<void> => {
    if (warehouse?.id) {
      await searchWarehouses('')
      form.warehouse_id = warehouse.id
      lastWarehouseId.value = warehouse.id
    }
  }

  const searchWarehouses = async (query: string): Promise<void> => {
    warehouseSearchLoading.value = true
    try {
      const res = await listWmsWarehouseApi({
        'q[name_or_code_cont]': query || '',
        per_page: 50
      })
      warehouseOptions.value = (res as any).data || []
    } catch (error) {
      console.error('搜索仓库失败:', error)
    } finally {
      warehouseSearchLoading.value = false
    }
  }

  const loadWorkOrderDetail = async (): Promise<void> => {
    if (!props.workOrder?.id) return
    try {
      const res = await viewMfgWorkOrderApi({ id: props.workOrder.id })
      const orderData = (res as any).data || {}
      Object.assign(form, {
        id: orderData.id,
        code: orderData.code || '',
        bom_id: orderData.bom_id,
        product_id: orderData.product_id,
        plan_qty: orderData.plan_qty || 0,
        actual_qty: orderData.actual_qty || 0,
        status: orderData.status || 'draft',
        plan_start: orderData.plan_start,
        plan_finish: orderData.plan_finish,
        actual_start: orderData.actual_start,
        actual_finish: orderData.actual_finish,
        warehouse_id: orderData.warehouse_id,
        company_id: orderData.company_id
      })

      if (form.product_id) {
        await searchProducts('')
      }
      if (form.bom_id) {
        await searchBoms('')
      }
      if (form.warehouse_id) {
        await searchWarehouses('')
      }
    } catch (error) {
      console.error('加载工单详情失败:', error)
      ElMessage.error('加载工单详情失败')
    }
  }

  const handleSave = async (): Promise<void> => {
    if (props.readonly) {
      handleCancel()
      return
    }
    if (!formRef.value) return
    try {
      await formRef.value.validate()
      const params = {
        code: form.code,
        bom_id: form.bom_id,
        product_id: form.product_id,
        plan_qty: Number(form.plan_qty) || 0,
        actual_qty: Number(form.actual_qty) || 0,
        status: form.status,
        plan_start: form.plan_start,
        plan_finish: form.plan_finish,
        actual_start: form.actual_start,
        actual_finish: form.actual_finish,
        warehouse_id: form.warehouse_id,
        company_id: form.company_id
      }

      if (isEditMode.value) {
        const res = await updateMfgWorkOrderApi(String(props.workOrder.id), params)
        ElMessage.success('更新成功')
        emit('updated', (res as any).data || { ...props.workOrder, ...params })
      } else {
        const res = await createMfgWorkOrderApi(params)
        ElMessage.success('创建成功')
        emit('created', (res as any).data)
      }
      handleCancel()
    } catch (error) {
      console.log('表单验证失败:', error)
    }
  }

  const handleStatusChange = async (nextStatus: string): Promise<void> => {
    form.status = nextStatus
    if (!isEditMode.value) return
    try {
      await updateMfgWorkOrderApi(String(props.workOrder.id), { status: nextStatus })
      ElMessage.success('状态更新成功')
      emit('updated', { ...props.workOrder, status: nextStatus })
    } catch (error) {
      console.error('更新状态失败:', error)
      ElMessage.error('更新状态失败')
    }
  }

  const handleCancel = (): void => {
    dialogVisible.value = false
  }

  const handleClosed = (): void => {
    Object.assign(form, {
      id: undefined,
      code: '',
      bom_id: undefined,
      product_id: undefined,
      plan_qty: 0,
      actual_qty: 0,
      status: 'draft',
      plan_start: undefined,
      plan_finish: undefined,
      actual_start: undefined,
      actual_finish: undefined,
      warehouse_id: undefined,
      company_id: undefined
    })
    formRef.value?.resetFields()
  }

  watch(
    () => form.warehouse_id,
    (val) => {
      if (val && val !== '__add_warehouse__') {
        lastWarehouseId.value = val
      }
    }
  )

  watch(
    () => props.modelValue,
    async (val) => {
      if (val) {
        searchProducts('')
        searchBoms('')
        searchWarehouses('')
        if (isEditMode.value) {
          await loadWorkOrderDetail()
          lastWarehouseId.value = form.warehouse_id
        } else {
          form.status = 'draft'
          lastWarehouseId.value = undefined
        }
      }
    }
  )

  watch(
    () => props.workOrder,
    async () => {
      if (props.modelValue && isEditMode.value) {
        await loadWorkOrderDetail()
      }
    },
    { deep: true }
  )
</script>

<style scoped lang="scss">
  .work-order-dialog {
    .dialog-footer {
      display: flex;
      gap: 12px;
      justify-content: flex-end;
    }
  }

  :deep(.add-option) {
    padding: 8px 12px;
    cursor: pointer;
    border-top: 1px solid var(--el-border-color-lighter);
    transition: background-color 0.2s;

    &:hover {
      background-color: var(--el-fill-color-light);
    }
  }
</style>
