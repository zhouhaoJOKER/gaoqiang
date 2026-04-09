<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="1200px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <div class="pick-order-dialog">
      <!-- 状态显示区域 -->
      <StatusStepper
        :id="form.id"
        :status="form.status"
        :readonly="props.readonly"
        @change="handleStatusChange"
        @close="dialogVisible = false"
      />

      <ElForm
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="120px"
        :disabled="props.readonly || isFinalStatus"
      >
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="单据编号" prop="code">
              <ElInput
                v-model="form.code"
                placeholder="请输入单据编号"
                :readonly="props.readonly"
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
            <ElFormItem label="计划日期" prop="plan_date">
              <ElDatePicker
                v-model="form.plan_date"
                type="datetime"
                placeholder="请选择计划日期"
                style="width: 100%"
                :disabled="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="工单ID" prop="work_order_id">
              <ElInput
                v-model="form.work_order_id"
                type="number"
                placeholder="请输入工单ID"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="单据类别">
              <PropertySelectWithAdd
                v-model="form.order_category_id"
                sign="wms_order_category"
                placeholder="请选择单据类别"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="24">
            <ElFormItem label="描述">
              <ElInput
                v-model="form.description"
                type="textarea"
                :rows="3"
                placeholder="请输入描述"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
      </ElForm>

      <div class="lines-section">
        <div class="lines-header">
          <span>明细行</span>
          <ElButton v-if="!props.readonly" type="primary" size="small" @click="handleAddLine"
            >添加行</ElButton
          >
        </div>
        <ElTable :data="form.lines" border style="width: 100%">
          <ElTableColumn type="index" label="序号" width="60" />
          <ElTableColumn label="物料" min-width="200">
            <template #default="{ row, $index }">
              <ElSelect
                v-model="row.item_id"
                placeholder="请选择物料"
                filterable
                remote
                :remote-method="(query) => searchItems(query, $index)"
                :loading="itemSearchLoading[$index]"
                style="width: 100%"
                :disabled="props.readonly"
              >
                <ElOption
                  v-for="item in itemOptions[$index] || []"
                  :key="item.id"
                  :label="`[${item.code || ''}] ${item.name}`"
                  :value="item.id"
                />
              </ElSelect>
            </template>
          </ElTableColumn>
          <ElTableColumn label="货位" min-width="150">
            <template #default="{ row, $index }">
              <ElSelect
                v-if="form.warehouse_id"
                v-model="row.location_id"
                placeholder="请选择货位"
                filterable
                remote
                :remote-method="(query) => searchLocations(query, $index)"
                :loading="locationSearchLoading[$index]"
                style="width: 100%"
                :disabled="props.readonly"
                @change="(val) => handleLocationSelectChange(val, $index)"
              >
                <ElOption
                  v-for="location in locationOptions[$index] || []"
                  :key="location.id"
                  :label="`[${location.code || ''}] ${location.name}`"
                  :value="location.id"
                />
                <ElOption
                  v-if="!props.readonly && form.warehouse_id"
                  value="__add_location__"
                  class="add-option"
                >
                  <span
                    style="
                      display: flex;
                      gap: 4px;
                      align-items: center;
                      color: var(--el-color-primary);
                    "
                  >
                    <ArtSvgIcon icon="ri:add-line" />
                    新增货位
                  </span>
                </ElOption>
              </ElSelect>
            </template>
          </ElTableColumn>
          <ElTableColumn label="计划数量" min-width="120">
            <template #default="{ row }">
              <ElInput
                v-model="row.plan_qty"
                type="number"
                placeholder="0.00"
                :readonly="props.readonly"
              />
            </template>
          </ElTableColumn>
          <ElTableColumn label="已领数量" min-width="120">
            <template #default="{ row }">
              <ElInput
                v-model="row.picked_qty"
                type="number"
                placeholder="0.00"
                :readonly="props.readonly"
              />
            </template>
          </ElTableColumn>
          <ElTableColumn label="状态" min-width="100">
            <template #default="{ row }">
              <ElSelect v-model="row.status" style="width: 100%" :disabled="props.readonly">
                <ElOption label="待处理" value="pending" />
                <ElOption label="处理中" value="processing" />
                <ElOption label="已完成" value="completed" />
              </ElSelect>
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

    <!-- 货位创建对话框 -->
    <LocationDialog
      v-model="locationDialogVisible"
      :initial-warehouse-id="form.warehouse_id"
      @created="handleLocationCreated"
    />

    <template #footer>
      <div class="dialog-footer">
        <ElButton @click="handleCancel">{{ props.readonly ? '关闭' : '关闭' }}</ElButton>
        <template v-if="!props.readonly && form.status === 'pending'">
          <ElButton type="primary" @click="handleSave">提交</ElButton>
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
  import WarehouseDialog from '@/views/wms/warehouses/modules/warehouse-dialog.vue'
  import LocationDialog from '@/views/wms/locations/modules/location-dialog.vue'
  import StatusStepper from '@/components/wms/StatusStepper.vue'
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'
  import {
    createWmsPickOrderApi,
    updateWmsPickOrderApi,
    viewWmsPickOrderApi,
    listWmsPickOrderLineApi
  } from '@/api/wms/pick-order'
  import { listWmsWarehouseApi } from '@/api/wms/warehouse'
  import { listWmsLocationApi } from '@/api/wms/location'
  import { listMatItemApi } from '@/api/mat/item'

  interface Props {
    modelValue: boolean
    pickOrder?: any
    readonly?: boolean
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', pickOrder: any): void
    (e: 'updated', pickOrder: any): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    pickOrder: undefined,
    readonly: false
  })

  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const isEditMode = computed(() => !!props.pickOrder && !!props.pickOrder.id)
  const dialogTitle = computed(() => {
    if (props.readonly) return '查看领料出库单'
    return isEditMode.value ? '编辑领料出库单' : '创建领料出库单'
  })

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    code: [{ required: true, message: '请输入单据编号', trigger: 'blur' }],
    warehouse_id: [{ required: true, message: '请选择仓库', trigger: 'change' }],
    status: [{ required: true, message: '请选择状态', trigger: 'change' }]
  })

  // 状态步骤配置
  // 已移至通用组件 StatusStepper.vue

  // 判断是否为最终状态
  const isFinalStatus = computed(() => {
    return form.status === 'completed' || form.status === 'cancelled'
  })

  const form = reactive({
    id: undefined,
    code: '',
    status: 'pending',
    warehouse_id: undefined as string | number | undefined,
    plan_date: '',
    work_order_id: undefined as string | number | undefined,
    order_category_id: null as string | number | null,
    order_category: '',
    description: '',
    lines: [] as any[]
  })

  // 仓库搜索
  const warehouseOptions = ref<any[]>([])
  const warehouseSearchLoading = ref(false)

  // 货位搜索
  const locationOptions = reactive<Record<number, any[]>>({})
  const locationSearchLoading = reactive<Record<number, boolean>>({})
  const currentLocationIndex = ref<number | undefined>(undefined)

  // 物料搜索
  const itemOptions = reactive<Record<number, any[]>>({})
  const itemSearchLoading = reactive<Record<number, boolean>>({})

  // 对话框状态
  const warehouseDialogVisible = ref(false)
  const locationDialogVisible = ref(false)

  // 初始化加载仓库数据
  const initWarehouseOptions = async (): Promise<void> => {
    warehouseSearchLoading.value = true
    try {
      const res = await listWmsWarehouseApi({ per_page: 20 })
      warehouseOptions.value = (res as any).data || []
    } catch (error) {
      console.error('加载仓库失败:', error)
      warehouseOptions.value = []
    } finally {
      warehouseSearchLoading.value = false
    }
  }

  // 搜索仓库
  const searchWarehouses = async (query: string): Promise<void> => {
    warehouseSearchLoading.value = true
    try {
      const res = await listWmsWarehouseApi({
        q: query ? { name_or_code_cont: query } : {},
        per_page: 20
      })
      warehouseOptions.value = (res as any).data || []
    } catch (error) {
      console.error('搜索仓库失败:', error)
      warehouseOptions.value = []
    } finally {
      warehouseSearchLoading.value = false
    }
  }

  // 仓库选择变化
  const handleWarehouseSelectChange = async (val: string | number): Promise<void> => {
    if (val === '__add_warehouse__') {
      warehouseDialogVisible.value = true
      return
    }
    // 清空货位选择并重新加载该仓库的货位
    form.lines.forEach((line, index) => {
      line.location_id = undefined
      locationOptions[index] = []
      // 如果有仓库ID，自动加载该仓库的货位
      if (form.warehouse_id) {
        loadLocationsByWarehouse(index, form.warehouse_id)
      }
    })
  }

  // 根据仓库加载货位
  const loadLocationsByWarehouse = async (
    lineIndex: number,
    warehouseId: string | number
  ): Promise<void> => {
    locationSearchLoading[lineIndex] = true
    try {
      const res = await listWmsLocationApi({
        q: { warehouse_id_eq: warehouseId },
        per_page: 50
      })
      locationOptions[lineIndex] = (res as any).data || []
    } catch (error) {
      console.error('加载货位失败:', error)
      locationOptions[lineIndex] = []
    } finally {
      locationSearchLoading[lineIndex] = false
    }
  }

  // 仓库创建成功
  const handleWarehouseCreated = (warehouse: any): void => {
    if (warehouse?.id) {
      warehouseOptions.value.push(warehouse)
      if (!form.warehouse_id) {
        form.warehouse_id = warehouse.id
      }
    }
  }

  // 搜索货位
  const searchLocations = async (query: string, lineIndex: number): Promise<void> => {
    if (!form.warehouse_id) {
      ElMessage.warning('请先选择仓库')
      return
    }
    locationSearchLoading[lineIndex] = true
    try {
      const res = await listWmsLocationApi({
        q: {
          warehouse_id_eq: form.warehouse_id,
          ...(query ? { name_or_code_cont: query } : {})
        },
        per_page: 50
      })
      locationOptions[lineIndex] = (res as any).data || []
    } catch (error) {
      console.error('搜索货位失败:', error)
      locationOptions[lineIndex] = []
    } finally {
      locationSearchLoading[lineIndex] = false
    }
  }

  // 货位选择变化
  const handleLocationSelectChange = (val: string | number, lineIndex: number): void => {
    if (val === '__add_location__') {
      currentLocationIndex.value = lineIndex
      locationDialogVisible.value = true
    }
  }

  // 货位创建成功
  const handleLocationCreated = (location: any): void => {
    if (location?.id && currentLocationIndex.value !== undefined) {
      const index = currentLocationIndex.value
      locationOptions[index] = locationOptions[index] || []
      locationOptions[index].push(location)
      if (form.lines[index]) {
        form.lines[index].location_id = location.id
      }
    }
  }

  // 搜索物料
  const searchItems = async (query: string, lineIndex: number): Promise<void> => {
    itemSearchLoading[lineIndex] = true
    try {
      const res = await listMatItemApi({
        q: query ? { name_or_code_cont: query } : {},
        per_page: 50
      })
      itemOptions[lineIndex] = (res as any).data || []
    } catch (error) {
      console.error('搜索物料失败:', error)
      itemOptions[lineIndex] = []
    } finally {
      itemSearchLoading[lineIndex] = false
    }
  }

  // 添加明细行
  const handleAddLine = (): void => {
    form.lines.push({
      item_id: undefined,
      location_id: undefined,
      plan_qty: 0,
      picked_qty: 0,
      status: 'pending'
    })
  }

  // 删除明细行
  const handleRemoveLine = (index: number): void => {
    form.lines.splice(index, 1)
    // 清理对应的选项数据
    delete itemOptions[index]
    delete itemSearchLoading[index]
    delete locationOptions[index]
    delete locationSearchLoading[index]
  }

  // 加载数据
  const loadData = async (): Promise<void> => {
    if (!isEditMode.value || !props.pickOrder?.id) return

    try {
      const res = await viewWmsPickOrderApi({ id: props.pickOrder.id })
      const data = (res as any).data || {}
      Object.assign(form, {
        id: data.id,
        code: data.code || '',
        status: data.status || 'pending',
        warehouse_id: data.warehouse_id,
        plan_date: data.plan_date || '',
        work_order_id: data.work_order_id,
        order_category_id: data.order_category_id ?? data.order_category ?? null,
        order_category: data.order_category || '',
        description: data.description || '',
        lines: []
      })

      // 加载明细行
      const linesRes = await listWmsPickOrderLineApi({ q: { pick_order_id_eq: data.id } })
      const linesData = (linesRes as any).data || []
      if (Array.isArray(linesData)) {
        form.lines = linesData.map((line: any) => ({
          id: line.id,
          item_id: line.item_id,
          location_id: line.location_id,
          plan_qty: line.plan_qty || 0,
          picked_qty: line.picked_qty || 0,
          status: line.status || 'pending'
        }))
      }
    } catch (error) {
      console.error('加载数据失败:', error)
      ElMessage.error('加载数据失败')
    }
  }

  // 保存（提交后保持当前状态，默认为草稿）
  const handleSave = async (): Promise<void> => {
    if (!formRef.value) return
    await formRef.value.validate((valid) => {
      if (!valid) return

      const submitData = {
        ...form,
        lines: form.lines.map((line) => ({
          item_id: line.item_id,
          location_id: line.location_id,
          plan_qty: line.plan_qty,
          picked_qty: line.picked_qty,
          status: line.status
        }))
      }

      if (isEditMode.value) {
        updateWmsPickOrderApi(String(form.id!), submitData)
          .then((res) => {
            ElMessage.success('更新成功')
            emit('updated', (res as any).data)
            dialogVisible.value = false
          })
          .catch((error) => {
            console.error('更新失败:', error)
            ElMessage.error('更新失败')
          })
      } else {
        createWmsPickOrderApi(submitData)
          .then((res) => {
            ElMessage.success('创建成功')
            form.id = (res as any).data?.id
            emit('created', (res as any).data)
            dialogVisible.value = false
          })
          .catch((error) => {
            console.error('创建失败:', error)
            ElMessage.error('创建失败')
          })
      }
    })
  }

  /**
   * 状态变更处理
   * @param nextStatus 目标状态
   */
  const handleStatusChange = async (nextStatus: string): Promise<void> => {
    try {
      const submitData = {
        status: nextStatus
      }

      const res = await updateWmsPickOrderApi(String(form.id), submitData)
      ElMessage.success('状态更新成功')
      form.status = nextStatus
      emit('updated', (res as any).data)
    } catch (error) {
      console.error('更新状态失败:', error)
      ElMessage.error('更新状态失败')
    }
  }

  // 取消
  const handleCancel = (): void => {
    dialogVisible.value = false
  }

  // 关闭后重置
  const handleClosed = (): void => {
    formRef.value?.resetFields()
    Object.assign(form, {
      id: undefined,
      code: '',
      status: 'pending',
      warehouse_id: undefined,
      plan_date: '',
      work_order_id: undefined,
      order_category_id: undefined,
      order_category: '',
      description: '',
      lines: []
    })
    warehouseOptions.value = []
    Object.keys(locationOptions).forEach((key) => {
      const numKey = Number(key)
      if (!isNaN(numKey)) {
        delete locationOptions[numKey]
      }
    })
    Object.keys(itemOptions).forEach((key) => {
      const numKey = Number(key)
      if (!isNaN(numKey)) {
        delete itemOptions[numKey]
      }
    })
  }

  // 监听弹窗打开
  watch(
    () => props.modelValue,
    (newVal) => {
      if (newVal) {
        nextTick(async () => {
          if (isEditMode.value) {
            await loadData()
          } else {
            // 新建时初始化
            form.status = 'pending'
            const today = new Date()
            form.plan_date = today.toISOString().slice(0, 19).replace('T', ' ')
            // 初始化加载仓库数据
            await initWarehouseOptions()
          }
        })
      }
    },
    { immediate: true }
  )

  // 监听 pickOrder 变化
  watch(
    () => props.pickOrder,
    () => {
      if (dialogVisible.value && isEditMode.value) {
        loadData()
      }
    }
  )
</script>

<style scoped lang="scss">
  .pick-order-dialog {
    .lines-section {
      margin-top: 20px;

      .lines-header {
        display: flex;
        align-items: center;
        justify-content: space-between;
        margin-bottom: 12px;
        font-weight: 500;
      }
    }
  }
</style>
