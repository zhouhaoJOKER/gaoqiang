<template>
  <ElDialog
    v-model="dialogVisible"
    :title="'查看库存流水'"
    width="800px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <div class="inventory-transaction-dialog">
      <ElForm ref="formRef" :model="form" label-width="120px">
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="流水编号">
              <ElInput v-model="form.code" readonly />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="物品">
              <ElInput :value="form.item_name || '-'" readonly />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="货位">
              <ElInput :value="form.location_name || '-'" readonly />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="流水类型">
              <ElInput :value="getTransactionTypeLabel(form.transaction_type)" readonly />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="变动前数量">
              <ElInput :value="Number(form.quantity_before || 0).toFixed(2)" readonly />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="变动数量">
              <ElInput :value="Number(form.quantity_change || 0).toFixed(2)" readonly />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="变动后数量">
              <ElInput :value="Number(form.quantity_after || 0).toFixed(2)" readonly />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="流水时间">
              <ElInput :value="form.transaction_time || '-'" readonly />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="关联订单类型">
              <ElInput :value="form.related_order_type || '-'" readonly />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="关联订单ID">
              <ElInput :value="form.related_order_id || '-'" readonly />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="24">
            <ElFormItem label="备注">
              <ElInput v-model="form.remark" type="textarea" :rows="3" readonly />
            </ElFormItem>
          </ElCol>
        </ElRow>
      </ElForm>
    </div>

    <template #footer>
      <div class="dialog-footer">
        <ElButton @click="handleCancel">关闭</ElButton>
      </div>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, reactive, computed, watch } from 'vue'
  import type { FormInstance } from 'element-plus'
  import { ElDialog, ElForm, ElFormItem, ElInput, ElButton, ElRow, ElCol } from 'element-plus'
  import { viewInvInventoryTransactionApi } from '@/api/inv/inventory-transaction'

  interface Props {
    modelValue: boolean
    transaction?: any
    readonly?: boolean
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    transaction: undefined,
    readonly: true
  })

  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const formRef = ref<FormInstance>()

  const form = reactive({
    id: undefined,
    code: '',
    item_id: undefined,
    item_name: '',
    location_id: undefined,
    location_name: '',
    inventory_id: undefined,
    transaction_type: '',
    related_order_type: '',
    related_order_id: undefined,
    quantity_before: 0,
    quantity_change: 0,
    quantity_after: 0,
    operator_id: undefined,
    transaction_time: '',
    remark: ''
  })

  const getTransactionTypeLabel = (type?: string): string => {
    const typeMap: Record<string, string> = {
      in: '入库',
      out: '出库',
      transfer: '调拨',
      adjust: '调整'
    }
    return typeMap[type || ''] || type || '-'
  }

  const loadTransactionDetail = async (): Promise<void> => {
    if (!props.transaction?.id) return
    try {
      const res = await viewInvInventoryTransactionApi({ id: props.transaction.id })
      const transactionData = (res as any).data || {}
      Object.assign(form, {
        id: transactionData.id,
        code: transactionData.code || '',
        item_id: transactionData.item_id,
        item_name: transactionData.item_name || '',
        location_id: transactionData.location_id,
        location_name: transactionData.location_name || '',
        inventory_id: transactionData.inventory_id,
        transaction_type: transactionData.transaction_type || '',
        related_order_type: transactionData.related_order_type || '',
        related_order_id: transactionData.related_order_id,
        quantity_before: transactionData.quantity_before || 0,
        quantity_change: transactionData.quantity_change || 0,
        quantity_after: transactionData.quantity_after || 0,
        operator_id: transactionData.operator_id,
        transaction_time: transactionData.transaction_time || '',
        remark: transactionData.remark || ''
      })
    } catch (error) {
      console.error('加载库存流水详情失败:', error)
    }
  }

  const handleCancel = (): void => {
    dialogVisible.value = false
  }

  const handleClosed = (): void => {
    Object.assign(form, {
      id: undefined,
      code: '',
      item_id: undefined,
      item_name: '',
      location_id: undefined,
      location_name: '',
      inventory_id: undefined,
      transaction_type: '',
      related_order_type: '',
      related_order_id: undefined,
      quantity_before: 0,
      quantity_change: 0,
      quantity_after: 0,
      operator_id: undefined,
      transaction_time: '',
      remark: ''
    })
  }

  watch(
    () => props.modelValue,
    async (val) => {
      if (val && props.transaction?.id) {
        await loadTransactionDetail()
      } else if (val && props.transaction) {
        // 如果直接传入数据，直接使用
        Object.assign(form, {
          id: props.transaction.id,
          code: props.transaction.code || '',
          item_id: props.transaction.item_id,
          item_name: props.transaction.item_name || '',
          location_id: props.transaction.location_id,
          location_name: props.transaction.location_name || '',
          inventory_id: props.transaction.inventory_id,
          transaction_type: props.transaction.transaction_type || '',
          related_order_type: props.transaction.related_order_type || '',
          related_order_id: props.transaction.related_order_id,
          quantity_before: props.transaction.quantity_before || 0,
          quantity_change: props.transaction.quantity_change || 0,
          quantity_after: props.transaction.quantity_after || 0,
          operator_id: props.transaction.operator_id,
          transaction_time: props.transaction.transaction_time || '',
          remark: props.transaction.remark || ''
        })
      }
    }
  )

  watch(
    () => props.transaction,
    async () => {
      if (props.modelValue && props.transaction?.id) {
        await loadTransactionDetail()
      }
    },
    { deep: true }
  )
</script>

<style scoped lang="scss">
  .inventory-transaction-dialog {
    .dialog-footer {
      display: flex;
      gap: 12px;
      justify-content: flex-end;
    }
  }
</style>
