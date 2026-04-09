<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="800px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <div class="work-order-byproduct-dialog">
      <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px">
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="工单" prop="work_order_id">
              <div style="display: flex; gap: 8px; align-items: flex-start">
                <ElSelect
                  v-model="form.work_order_id"
                  placeholder="请选择工单"
                  filterable
                  remote
                  :remote-method="searchWorkOrders"
                  :loading="workOrderSearchLoading"
                  style="flex: 1"
                  :disabled="props.readonly"
                >
                  <ElOption
                    v-for="wo in workOrderOptions"
                    :key="wo.id"
                    :label="`[${wo.code || ''}] ${wo.product_name || ''}`"
                    :value="wo.id"
                  />
                </ElSelect>
                <ElButton
                  v-if="!props.readonly"
                  type="primary"
                  text
                  @click="handleCreateWorkOrder"
                  title="新增工单"
                >
                  <ArtSvgIcon icon="ri:add-line" />
                </ElButton>
              </div>
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="产品" prop="product_id">
              <div style="display: flex; gap: 8px; align-items: flex-start">
                <ElSelect
                  v-model="form.product_id"
                  placeholder="请选择产品"
                  filterable
                  remote
                  :remote-method="searchProducts"
                  :loading="productSearchLoading"
                  style="flex: 1"
                  :disabled="props.readonly"
                >
                  <ElOption
                    v-for="product in productOptions"
                    :key="product.id"
                    :label="`[${product.code || ''}] ${product.name}`"
                    :value="product.id"
                  />
                </ElSelect>
                <ElButton
                  v-if="!props.readonly"
                  type="primary"
                  text
                  @click="handleCreateProduct"
                  title="新增产品"
                >
                  <ArtSvgIcon icon="ri:add-line" />
                </ElButton>
              </div>
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="BOM副产品">
              <ElInput
                v-model="form.bom_byproduct_id"
                type="number"
                placeholder="BOM副产品ID"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
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
        </ElRow>
        <ElRow :gutter="20">
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
      </ElForm>
    </div>

    <!-- 工单创建对话框 -->
    <WorkOrderDialog v-model="workOrderDialogVisible" @created="handleWorkOrderCreated" />

    <!-- 产品创建对话框（通过路由跳转） -->
    <ElDialog v-model="productDialogVisible" title="提示" width="400px">
      <p>产品创建功能请在产品管理页面操作</p>
      <template #footer>
        <ElButton @click="productDialogVisible = false">确定</ElButton>
      </template>
    </ElDialog>

    <template #footer>
      <div class="dialog-footer">
        <ElButton @click="handleCancel">{{ props.readonly ? '关闭' : '取消' }}</ElButton>
        <template v-if="!props.readonly">
          <ElButton v-if="!isEditMode" type="primary" @click="handleSaveAndNew"
            >保存并新建</ElButton
          >
          <ElButton type="primary" @click="handleSave">保存</ElButton>
        </template>
      </div>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, reactive, computed, watch } from 'vue'
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
    ElCol
  } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import WorkOrderDialog from '@/views/mfg/work-orders/modules/work-order-dialog.vue'
  import {
    createMfgWorkOrderByproductApi,
    updateMfgWorkOrderByproductApi,
    viewMfgWorkOrderByproductApi
  } from '@/api/mfg/work-order'
  import { listMfgWorkOrderApi } from '@/api/mfg/work-order'
  import { listMatProductApi } from '@/api/mat/product'

  interface Props {
    modelValue: boolean
    workOrderByproduct?: any
    readonly?: boolean
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', data: any): void
    (e: 'updated', data: any): void
  }

  const props = defineProps<Props>()
  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const dialogTitle = computed(() => {
    if (props.readonly) return '查看工单副产品'
    return props.workOrderByproduct?.id ? '编辑工单副产品' : '新建工单副产品'
  })

  const isEditMode = computed(() => !!props.workOrderByproduct?.id)

  const formRef = ref<FormInstance>()
  const form = reactive({
    id: undefined,
    work_order_id: undefined,
    bom_byproduct_id: undefined,
    product_id: undefined,
    plan_qty: '',
    actual_qty: ''
  })

  const rules: FormRules = {
    work_order_id: [{ required: true, message: '请选择工单', trigger: 'change' }],
    product_id: [{ required: true, message: '请选择产品', trigger: 'change' }],
    plan_qty: [{ required: true, message: '请输入计划数量', trigger: 'blur' }]
  }

  const workOrderOptions = ref<any[]>([])
  const workOrderSearchLoading = ref(false)
  const productOptions = ref<any[]>([])
  const productSearchLoading = ref(false)
  const workOrderDialogVisible = ref(false)
  const productDialogVisible = ref(false)

  const searchWorkOrders = async (query: string) => {
    if (!query) {
      workOrderOptions.value = []
      return
    }
    workOrderSearchLoading.value = true
    try {
      const res = await listMfgWorkOrderApi({ 'q[code_cont]': query, per_page: 50 })
      const list = (res as any).data || []
      workOrderOptions.value = list.map((wo: any) => ({
        id: wo.id,
        code: wo.code,
        product_name: wo.product_name
      }))
    } catch (error) {
      console.error('搜索工单失败:', error)
    } finally {
      workOrderSearchLoading.value = false
    }
  }

  const searchProducts = async (query: string) => {
    if (!query) {
      productOptions.value = []
      return
    }
    productSearchLoading.value = true
    try {
      const res = await listMatProductApi({ 'q[name_cont]': query, per_page: 50 })
      const list = (res as any).data || []
      productOptions.value = list.map((p: any) => ({
        id: p.id,
        code: p.code,
        name: p.name
      }))
    } catch (error) {
      console.error('搜索产品失败:', error)
    } finally {
      productSearchLoading.value = false
    }
  }

  const loadWorkOrderByproduct = async () => {
    if (!props.workOrderByproduct?.id) {
      Object.assign(form, {
        id: undefined,
        work_order_id: undefined,
        bom_byproduct_id: undefined,
        product_id: undefined,
        plan_qty: '',
        actual_qty: ''
      })
      return
    }
    try {
      const res = await viewMfgWorkOrderByproductApi({ id: props.workOrderByproduct.id })
      const data = (res as any).data || {}
      Object.assign(form, {
        id: data.id,
        work_order_id: data.work_order_id,
        bom_byproduct_id: data.bom_byproduct_id,
        product_id: data.product_id,
        plan_qty: data.plan_qty || '',
        actual_qty: data.actual_qty || ''
      })
      if (data.work_order_id) {
        searchWorkOrders('')
      }
      if (data.product_id) {
        searchProducts('')
      }
    } catch (error) {
      console.error('加载工单副产品失败:', error)
      ElMessage.error('加载失败')
    }
  }

  watch(
    () => props.modelValue,
    (val) => {
      if (val) {
        loadWorkOrderByproduct()
      }
    },
    { immediate: true }
  )

  watch(
    () => props.workOrderByproduct,
    () => {
      if (props.modelValue) {
        loadWorkOrderByproduct()
      }
    }
  )

  const handleCreateWorkOrder = (): void => {
    workOrderDialogVisible.value = true
  }

  const handleWorkOrderCreated = async (workOrder: any): Promise<void> => {
    if (workOrder?.id) {
      await searchWorkOrders('')
      form.work_order_id = workOrder.id
    }
  }

  const handleCreateProduct = (): void => {
    productDialogVisible.value = true
  }

  const handleCancel = () => {
    dialogVisible.value = false
  }

  const handleClosed = () => {
    formRef.value?.resetFields()
    Object.assign(form, {
      id: undefined,
      work_order_id: undefined,
      bom_byproduct_id: undefined,
      product_id: undefined,
      plan_qty: '',
      actual_qty: ''
    })
    workOrderOptions.value = []
    productOptions.value = []
  }

  const handleSave = async () => {
    if (!formRef.value) return
    await formRef.value.validate()
    try {
      const params: any = {
        work_order_id: form.work_order_id ? Number(form.work_order_id) : undefined,
        bom_byproduct_id: form.bom_byproduct_id ? Number(form.bom_byproduct_id) : undefined,
        product_id: form.product_id ? Number(form.product_id) : undefined,
        plan_qty: form.plan_qty ? Number(form.plan_qty) : 0,
        actual_qty: form.actual_qty ? Number(form.actual_qty) : 0
      }
      if (isEditMode.value) {
        const res = await updateMfgWorkOrderByproductApi(String(form.id), params)
        ElMessage.success('更新成功')
        emit('updated', (res as any).data)
        dialogVisible.value = false
      } else {
        const res = await createMfgWorkOrderByproductApi(params)
        ElMessage.success('创建成功')
        emit('created', (res as any).data)
        dialogVisible.value = false
      }
    } catch (error: any) {
      console.error('保存失败:', error)
      ElMessage.error(error?.message || '保存失败')
    }
  }

  const handleSaveAndNew = async () => {
    if (!formRef.value) return
    try {
      await formRef.value.validate()
      const params: any = {
        work_order_id: form.work_order_id ? Number(form.work_order_id) : undefined,
        bom_byproduct_id: form.bom_byproduct_id ? Number(form.bom_byproduct_id) : undefined,
        product_id: form.product_id ? Number(form.product_id) : undefined,
        plan_qty: form.plan_qty ? Number(form.plan_qty) : 0,
        actual_qty: form.actual_qty ? Number(form.actual_qty) : 0
      }
      const res = await createMfgWorkOrderByproductApi(params)
      ElMessage.success('创建成功')
      emit('created', (res as any).data)
      // 重置表单，保持弹窗打开
      Object.assign(form, {
        id: undefined,
        work_order_id: undefined,
        bom_byproduct_id: undefined,
        product_id: undefined,
        plan_qty: '',
        actual_qty: ''
      })
      formRef.value?.resetFields()
      workOrderOptions.value = []
      productOptions.value = []
    } catch (error: any) {
      console.error('保存失败:', error)
      ElMessage.error(error?.message || '保存失败')
    }
  }
</script>

<style scoped>
  .work-order-byproduct-dialog {
    padding: 20px 0;
  }
</style>
