<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="1400px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <div class="order-dialog">
      <StatusStepper
        v-if="form.status"
        :id="form.id"
        :status="form.status"
        :readonly="props.readonly"
        @change="handleStatusChange"
        @close="dialogVisible = false"
      />
      <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px">
        <!-- 订单编号：仅编辑/查看时显示 -->
        <ElRow v-if="isEditMode || props.readonly" :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="订单编号" prop="code">
              <ElInput v-model="form.code" placeholder="订单编号" readonly />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="物品" prop="item_id">
              <ElSelect
                v-model="form.item_id"
                placeholder="请选择物品"
                filterable
                remote
                :remote-method="searchItems"
                :loading="itemSearchLoading"
                style="width: 100%"
                :disabled="props.readonly"
                @change="handleItemChange"
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
            <ElFormItem label="BOM">
              <ElSelect
                v-model="form.bom_id"
                placeholder="请选择BOM（与物品关联）"
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
          <ElCol :span="12">
            <ElFormItem label="来源订单类型">
              <PropertySelectWithAdd
                v-model="form.source_order_type_id"
                sign="mfg_source_order_type"
                placeholder="请选择来源订单类型"
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
          <ElCol :span="12">
            <ElFormItem label="需求日期" prop="demand_date">
              <ElDatePicker
                v-model="form.demand_date"
                type="datetime"
                placeholder="请选择需求日期"
                style="width: 100%"
                :disabled="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow v-if="isEditMode || props.readonly" :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="完成数量">
              <ElInput
                v-model="form.finish_qty"
                type="number"
                placeholder="0.00"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="报废数量">
              <ElInput
                v-model="form.scrap_qty"
                type="number"
                placeholder="0.00"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow v-if="isEditMode || props.readonly" :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="来源订单ID">
              <ElInput
                v-model="form.source_order_id"
                type="number"
                placeholder="来源订单ID"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
      </ElForm>

      <!-- 明细行：仅显示物品、需求数量 -->
      <div class="lines-section">
        <div class="lines-header">
          <span class="lines-title">明细行</span>
          <ElButton v-if="!props.readonly" type="primary" size="small" @click="handleAddLine">
            <ArtSvgIcon icon="ri:add-line" />
            添加明细
          </ElButton>
        </div>
        <ElTable :data="form.lines" border style="width: 100%">
          <ElTableColumn type="index" label="序号" width="60" />
          <ElTableColumn label="物品" min-width="280">
            <template #default="{ row, $index }">
              <ElSelect
                v-model="row.item_id"
                placeholder="请选择物品"
                filterable
                remote
                :remote-method="(query) => searchLineItems(query, $index)"
                :loading="lineItemSearchLoading[$index]"
                style="width: 100%"
                :disabled="props.readonly"
              >
                <ElOption
                  v-for="item in lineItemOptions[$index] || []"
                  :key="item.id"
                  :label="`[${item.code || ''}] ${item.name}`"
                  :value="item.id"
                />
              </ElSelect>
            </template>
          </ElTableColumn>
          <ElTableColumn label="需求数量" min-width="140">
            <template #default="{ row }">
              <ElInput
                v-model="row.required_qty"
                type="number"
                placeholder="0.00"
                :readonly="props.readonly"
              />
            </template>
          </ElTableColumn>
          <ElTableColumn v-if="!props.readonly" label="操作" width="80" fixed="right">
            <template #default="{ $index }">
              <ElButton type="danger" size="small" text @click="handleRemoveLine($index)"
                >删除</ElButton
              >
            </template>
          </ElTableColumn>
        </ElTable>
      </div>
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
    ElDatePicker,
    ElTable,
    ElTableColumn
  } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'
  import StatusStepper from '@/components/wms/StatusStepper.vue'
  import WarehouseDialog from '@/views/wms/warehouses/modules/warehouse-dialog.vue'
  import {
    createMfgOrderApi,
    updateMfgOrderApi,
    viewMfgOrderApi,
    listMfgOrderLineApi
  } from '@/api/mfg/order'
  import { listMatItemApi } from '@/api/mat/item'
  import { listMfgBomApi } from '@/api/mfg/bom'
  import { listWmsWarehouseApi } from '@/api/wms/warehouse'

  interface Props {
    modelValue: boolean
    order?: any
    readonly?: boolean
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', order: any): void
    (e: 'updated', order: any): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    order: undefined,
    readonly: false
  })

  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const isEditMode = computed(() => !!props.order && !!props.order.id)
  const dialogTitle = computed(() => {
    if (props.readonly) return '查看生产订单'
    return isEditMode.value ? '编辑生产订单' : '创建生产订单'
  })

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    item_id: [{ required: true, message: '请选择物品', trigger: 'change' }],
    plan_qty: [{ required: true, message: '请输入计划数量', trigger: 'blur' }],
    warehouse_id: [{ required: true, message: '请选择仓库', trigger: 'change' }]
  })

  const form = reactive({
    id: undefined,
    code: '',
    item_id: undefined as string | number | undefined,
    bom_id: undefined as string | number | undefined,
    plan_qty: 0,
    finish_qty: 0,
    scrap_qty: 0,
    status: 'draft',
    demand_date: undefined as string | undefined,
    source_order_type_id: null as string | number | null,
    source_order_type: '',
    source_order_id: undefined as string | number | undefined,
    company_id: undefined as string | number | undefined,
    warehouse_id: undefined as string | number | undefined,
    lines: [] as any[]
  })

  const itemOptions = ref<any[]>([])
  const itemSearchLoading = ref(false)
  const bomOptions = ref<any[]>([])
  const bomSearchLoading = ref(false)
  const warehouseOptions = ref<any[]>([])
  const warehouseSearchLoading = ref(false)
  const lineItemOptions = ref<Record<number, any[]>>({})
  const lineItemSearchLoading = ref<Record<number, boolean>>({})
  const warehouseDialogVisible = ref(false)
  const lastWarehouseId = ref<string | number | undefined>(undefined)

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

  const handleItemChange = (): void => {
    if (form.item_id) {
      searchBoms('')
    }
  }

  const searchLineItems = async (query: string, index: number): Promise<void> => {
    lineItemSearchLoading.value[index] = true
    try {
      const res = await listMatItemApi({
        'q[name_or_code_cont]': query || '',
        per_page: 50
      })
      lineItemOptions.value[index] = (res as any).data || []
    } catch (error) {
      console.error('搜索物品失败:', error)
    } finally {
      lineItemSearchLoading.value[index] = false
    }
  }

  const handleAddLine = () => {
    form.lines.push({
      item_id: undefined,
      required_qty: 0,
      product_id: undefined,
      bom_line_id: undefined,
      required_date: undefined,
      allocated_qty: 0,
      available_qty: 0,
      shortage_qty: 0,
      status: 'pending',
      is_alternative: false,
      alternative_for_id: undefined
    })
  }

  const handleRemoveLine = (index: number) => {
    form.lines.splice(index, 1)
    delete lineItemOptions.value[index]
  }

  const loadOrderDetail = async (): Promise<void> => {
    if (!props.order?.id) return
    try {
      const res = await viewMfgOrderApi({ id: props.order.id })
      const orderData = (res as any).data || {}
      Object.assign(form, {
        id: orderData.id,
        code: orderData.code || '',
        item_id: orderData.item_id,
        bom_id: orderData.bom_id,
        plan_qty: orderData.plan_qty || 0,
        finish_qty: orderData.finish_qty || 0,
        scrap_qty: orderData.scrap_qty || 0,
        status: orderData.status || 'draft',
        demand_date: orderData.demand_date,
        source_order_type_id: orderData.source_order_type_id ?? orderData.source_order_type ?? null,
        source_order_type: orderData.source_order_type || '',
        source_order_id: orderData.source_order_id,
        company_id: orderData.company_id,
        warehouse_id: orderData.warehouse_id,
        lines: []
      })

      // 加载明细行
      const linesRes = await listMfgOrderLineApi({
        'q[order_id_eq]': props.order.id
      })
      const lines = (linesRes as any).data || []
      form.lines = lines.map((line: any, index: number) => {
        searchLineItems('', index)
        return {
          id: line.id,
          item_id: line.item_id,
          required_qty: line.required_qty || 0,
          product_id: line.product_id,
          bom_line_id: line.bom_line_id,
          required_date: line.required_date,
          allocated_qty: line.allocated_qty || 0,
          available_qty: line.available_qty || 0,
          shortage_qty: line.shortage_qty || 0,
          status: line.status || 'pending',
          is_alternative: line.is_alternative || false,
          alternative_for_id: line.alternative_for_id
        }
      })

      // 加载选项数据
      if (form.item_id) {
        await searchItems('')
      }
      if (form.bom_id) {
        await searchBoms('')
      }
      if (form.warehouse_id) {
        await searchWarehouses('')
      }
    } catch (error) {
      console.error('加载生产订单详情失败:', error)
      ElMessage.error('加载生产订单详情失败')
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
      const params: any = {
        item_id: form.item_id,
        bom_id: form.bom_id,
        plan_qty: Number(form.plan_qty) || 0,
        finish_qty: Number(form.finish_qty) || 0,
        scrap_qty: Number(form.scrap_qty) || 0,
        status: form.status,
        demand_date: form.demand_date,
        source_order_type_id: form.source_order_type_id ?? undefined,
        source_order_id: form.source_order_id ? Number(form.source_order_id) : undefined,
        company_id: form.company_id,
        warehouse_id: form.warehouse_id,
        lines: form.lines.map((line) => ({
          item_id: line.item_id,
          required_qty: Number(line.required_qty) || 0,
          product_id: line.product_id,
          bom_line_id: line.bom_line_id ? Number(line.bom_line_id) : undefined,
          required_date: line.required_date,
          allocated_qty: Number(line.allocated_qty) || 0,
          available_qty: Number(line.available_qty) || 0,
          shortage_qty: Number(line.shortage_qty) || 0,
          status: line.status || 'pending',
          is_alternative: line.is_alternative || false,
          alternative_for_id: line.alternative_for_id
        }))
      }
      if (isEditMode.value) {
        params.code = form.code
      }

      if (isEditMode.value) {
        const res = await updateMfgOrderApi(String(props.order.id), params)
        ElMessage.success('更新成功')
        emit('updated', (res as any).data || { ...props.order, ...params })
      } else {
        const res = await createMfgOrderApi(params)
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
      await updateMfgOrderApi(String(props.order.id), { status: nextStatus })
      ElMessage.success('状态更新成功')
      emit('updated', { ...props.order, status: nextStatus })
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
      item_id: undefined,
      bom_id: undefined,
      plan_qty: 0,
      finish_qty: 0,
      scrap_qty: 0,
      status: 'draft',
      demand_date: undefined,
      source_order_type_id: undefined,
      source_order_type: '',
      source_order_id: undefined,
      company_id: undefined,
      warehouse_id: undefined,
      lines: []
    })
    lineItemOptions.value = {}
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
        searchItems('')
        searchBoms('')
        searchWarehouses('')
        if (isEditMode.value) {
          await loadOrderDetail()
          lastWarehouseId.value = form.warehouse_id
        } else {
          form.lines = []
          form.status = 'draft'
          lastWarehouseId.value = undefined
        }
      }
    }
  )

  watch(
    () => props.order,
    async () => {
      if (props.modelValue && isEditMode.value) {
        await loadOrderDetail()
      }
    },
    { deep: true }
  )
</script>

<style scoped lang="scss">
  .order-dialog {
    .dialog-footer {
      display: flex;
      gap: 12px;
      justify-content: flex-end;
    }

    .lines-section {
      padding-top: 20px;
      margin-top: 20px;
      border-top: 1px solid var(--el-border-color);

      .lines-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 12px;

        .lines-title {
          font-size: 14px;
          font-weight: 600;
        }
      }
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
