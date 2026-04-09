<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="800px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <div class="disassembly-order-dialog">
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
            <ElFormItem label="拆解单编号" prop="code">
              <ElInput
                v-model="form.code"
                placeholder="请输入拆解单编号"
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
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="物品">
              <ElSelect
                v-model="form.item_id"
                placeholder="请选择物品"
                filterable
                remote
                :remote-method="searchItems"
                :loading="itemSearchLoading"
                style="width: 100%"
                :disabled="props.readonly"
              >
                <ElOption
                  v-for="item in itemOptions"
                  :key="item.id"
                  :label="`[${item.code || ''}] ${item.name}`"
                  :value="item.id"
                />
              </ElSelect>
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="批次">
              <ElInput
                v-model="form.lot_id"
                type="number"
                placeholder="请输入批次ID"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="计划数量" prop="planned_qty">
              <ElInput
                v-model="form.planned_qty"
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
          <ElButton type="primary" @click="handleSave">{{ isEditMode ? '保存' : '保存' }}</ElButton>
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
  import StatusStepper from '@/components/wms/StatusStepper.vue'
  import {
    createMfgDisassemblyOrderApi,
    updateMfgDisassemblyOrderApi,
    viewMfgDisassemblyOrderApi
  } from '@/api/mfg/disassembly-order'
  import { listMatProductApi } from '@/api/mat/product'
  import { listMatItemApi } from '@/api/mat/item'

  interface Props {
    modelValue: boolean
    disassemblyOrder?: any
    readonly?: boolean
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', disassemblyOrder: any): void
    (e: 'updated', disassemblyOrder: any): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    disassemblyOrder: undefined,
    readonly: false
  })

  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const isEditMode = computed(() => !!props.disassemblyOrder && !!props.disassemblyOrder.id)
  const dialogTitle = computed(() => {
    if (props.readonly) return '查看拆解单'
    return isEditMode.value ? '编辑拆解单' : '创建拆解单'
  })

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    code: [{ required: true, message: '请输入拆解单编号', trigger: 'blur' }],
    product_id: [{ required: true, message: '请选择产品', trigger: 'change' }],
    planned_qty: [{ required: true, message: '请输入计划数量', trigger: 'blur' }]
  })

  const form = reactive({
    id: undefined,
    code: '',
    status: 'draft',
    product_id: undefined as string | number | undefined,
    item_id: undefined as string | number | undefined,
    lot_id: undefined as string | number | undefined,
    planned_qty: 0
  })

  const productOptions = ref<any[]>([])
  const productSearchLoading = ref(false)
  const itemOptions = ref<any[]>([])
  const itemSearchLoading = ref(false)

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

  const searchItems = async (query: string): Promise<void> => {
    itemSearchLoading.value = true
    try {
      const res = await listMatItemApi({
        'q[name_or_code_cont]': query || '',
        per_page: 50
      })
      itemOptions.value = (res as any).data || []
    } catch (error) {
      console.error('搜索物品失败:', error)
    } finally {
      itemSearchLoading.value = false
    }
  }

  const loadDisassemblyOrderDetail = async (): Promise<void> => {
    if (!props.disassemblyOrder?.id) return
    try {
      const res = await viewMfgDisassemblyOrderApi({ id: props.disassemblyOrder.id })
      const orderData = (res as any).data || {}
      Object.assign(form, {
        id: orderData.id,
        code: orderData.code || '',
        status: orderData.status || 'draft',
        product_id: orderData.product_id,
        item_id: orderData.item_id,
        lot_id: orderData.lot_id,
        planned_qty: orderData.planned_qty || 0
      })

      if (form.product_id) {
        await searchProducts('')
      }
      if (form.item_id) {
        await searchItems('')
      }
    } catch (error) {
      console.error('加载拆解单详情失败:', error)
      ElMessage.error('加载拆解单详情失败')
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
        status: form.status,
        product_id: form.product_id,
        item_id: form.item_id,
        lot_id: form.lot_id ? Number(form.lot_id) : undefined,
        planned_qty: Number(form.planned_qty) || 0
      }

      if (isEditMode.value) {
        const res = await updateMfgDisassemblyOrderApi(String(props.disassemblyOrder.id), params)
        ElMessage.success('更新成功')
        emit('updated', (res as any).data || { ...props.disassemblyOrder, ...params })
      } else {
        const res = await createMfgDisassemblyOrderApi(params)
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
      await updateMfgDisassemblyOrderApi(String(props.disassemblyOrder.id), { status: nextStatus })
      ElMessage.success('状态更新成功')
      emit('updated', { ...props.disassemblyOrder, status: nextStatus })
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
      status: 'draft',
      product_id: undefined,
      item_id: undefined,
      lot_id: undefined,
      planned_qty: 0
    })
    formRef.value?.resetFields()
  }

  watch(
    () => props.modelValue,
    async (val) => {
      if (val) {
        searchProducts('')
        searchItems('')
        if (isEditMode.value) {
          await loadDisassemblyOrderDetail()
        } else {
          form.status = 'draft'
        }
      }
    }
  )

  watch(
    () => props.disassemblyOrder,
    async () => {
      if (props.modelValue && isEditMode.value) {
        await loadDisassemblyOrderDetail()
      }
    },
    { deep: true }
  )
</script>

<style scoped lang="scss">
  .disassembly-order-dialog {
    .dialog-footer {
      display: flex;
      gap: 12px;
      justify-content: flex-end;
    }
  }
</style>
