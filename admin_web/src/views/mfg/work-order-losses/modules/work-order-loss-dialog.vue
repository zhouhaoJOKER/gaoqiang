<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="800px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <div class="work-order-loss-dialog">
      <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px">
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="工单" prop="work_order_id">
              <ElSelect
                v-model="form.work_order_id"
                placeholder="请选择工单"
                filterable
                remote
                :remote-method="searchWorkOrders"
                :loading="workOrderSearchLoading"
                style="width: 100%"
                :disabled="props.readonly"
              >
                <ElOption
                  v-for="wo in workOrderOptions"
                  :key="wo.id"
                  :label="`[${wo.code || ''}] ${wo.product_name || ''}`"
                  :value="wo.id"
                />
              </ElSelect>
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
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="BOM损耗">
              <ElInput
                v-model="form.bom_loss_id"
                type="number"
                placeholder="BOM损耗ID"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="计划损耗" prop="plan_loss_qty">
              <ElInput
                v-model="form.plan_loss_qty"
                type="number"
                placeholder="0.00"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="实际损耗">
              <ElInput
                v-model="form.actual_loss_qty"
                type="number"
                placeholder="0.00"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
      </ElForm>
    </div>

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
  import {
    createMfgWorkOrderLossApi,
    updateMfgWorkOrderLossApi,
    viewMfgWorkOrderLossApi
  } from '@/api/mfg/work-order'
  import { listMfgWorkOrderApi } from '@/api/mfg/work-order'
  import { listMatProductApi } from '@/api/mat/product'

  interface Props {
    modelValue: boolean
    workOrderLoss?: any
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
    if (props.readonly) return '查看工单损耗'
    return props.workOrderLoss?.id ? '编辑工单损耗' : '新建工单损耗'
  })

  const isEditMode = computed(() => !!props.workOrderLoss?.id)

  const formRef = ref<FormInstance>()
  const form = reactive({
    id: undefined,
    work_order_id: undefined,
    bom_loss_id: undefined,
    product_id: undefined,
    plan_loss_qty: '',
    actual_loss_qty: ''
  })

  const rules: FormRules = {
    work_order_id: [{ required: true, message: '请选择工单', trigger: 'change' }],
    product_id: [{ required: true, message: '请选择产品', trigger: 'change' }],
    plan_loss_qty: [{ required: true, message: '请输入计划损耗', trigger: 'blur' }]
  }

  const workOrderOptions = ref<any[]>([])
  const workOrderSearchLoading = ref(false)
  const productOptions = ref<any[]>([])
  const productSearchLoading = ref(false)

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

  const loadWorkOrderLoss = async () => {
    if (!props.workOrderLoss?.id) {
      Object.assign(form, {
        id: undefined,
        work_order_id: undefined,
        bom_loss_id: undefined,
        product_id: undefined,
        plan_loss_qty: '',
        actual_loss_qty: ''
      })
      return
    }
    try {
      const res = await viewMfgWorkOrderLossApi({ id: props.workOrderLoss.id })
      const data = (res as any).data || {}
      Object.assign(form, {
        id: data.id,
        work_order_id: data.work_order_id,
        bom_loss_id: data.bom_loss_id,
        product_id: data.product_id,
        plan_loss_qty: data.plan_loss_qty || '',
        actual_loss_qty: data.actual_loss_qty || ''
      })
      if (data.work_order_id) {
        searchWorkOrders('')
      }
      if (data.product_id) {
        searchProducts('')
      }
    } catch (error) {
      console.error('加载工单损耗失败:', error)
      ElMessage.error('加载失败')
    }
  }

  watch(
    () => props.modelValue,
    (val) => {
      if (val) {
        loadWorkOrderLoss()
      }
    },
    { immediate: true }
  )

  watch(
    () => props.workOrderLoss,
    () => {
      if (props.modelValue) {
        loadWorkOrderLoss()
      }
    }
  )

  const handleCancel = () => {
    dialogVisible.value = false
  }

  const handleClosed = () => {
    formRef.value?.resetFields()
    Object.assign(form, {
      id: undefined,
      work_order_id: undefined,
      bom_loss_id: undefined,
      product_id: undefined,
      plan_loss_qty: '',
      actual_loss_qty: ''
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
        bom_loss_id: form.bom_loss_id ? Number(form.bom_loss_id) : undefined,
        product_id: form.product_id ? Number(form.product_id) : undefined,
        plan_loss_qty: form.plan_loss_qty ? Number(form.plan_loss_qty) : 0,
        actual_loss_qty: form.actual_loss_qty ? Number(form.actual_loss_qty) : 0
      }
      if (isEditMode.value) {
        const res = await updateMfgWorkOrderLossApi(String(form.id), params)
        ElMessage.success('更新成功')
        emit('updated', (res as any).data)
        dialogVisible.value = false
      } else {
        const res = await createMfgWorkOrderLossApi(params)
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
        bom_loss_id: form.bom_loss_id ? Number(form.bom_loss_id) : undefined,
        product_id: form.product_id ? Number(form.product_id) : undefined,
        plan_loss_qty: form.plan_loss_qty ? Number(form.plan_loss_qty) : 0,
        actual_loss_qty: form.actual_loss_qty ? Number(form.actual_loss_qty) : 0
      }
      const res = await createMfgWorkOrderLossApi(params)
      ElMessage.success('创建成功')
      emit('created', (res as any).data)
      // 重置表单，保持弹窗打开
      Object.assign(form, {
        id: undefined,
        work_order_id: undefined,
        bom_loss_id: undefined,
        product_id: undefined,
        plan_loss_qty: '',
        actual_loss_qty: ''
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
  .work-order-loss-dialog {
    padding: 20px 0;
  }
</style>
