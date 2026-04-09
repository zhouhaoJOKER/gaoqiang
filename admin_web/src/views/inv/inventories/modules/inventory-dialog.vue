<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="800px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <div class="inventory-dialog">
      <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px">
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
            <ElFormItem label="货位" prop="location_id">
              <ElSelect
                v-model="form.location_id"
                placeholder="请选择货位"
                filterable
                remote
                :remote-method="searchLocations"
                :loading="locationSearchLoading"
                style="width: 100%"
                :disabled="props.readonly"
                @change="handleLocationSelectChange"
              >
                <ElOption
                  v-for="location in locationOptions"
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
            <ElFormItem label="状态">
              <ElInput
                v-model="form.status_id"
                type="number"
                placeholder="请输入状态ID"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="在手数量" prop="on_hand_qty">
              <ElInput
                v-model="form.on_hand_qty"
                type="number"
                placeholder="0.00"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="可用数量">
              <ElInput
                v-model="form.available_qty"
                type="number"
                placeholder="0.00"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="分配数量">
              <ElInput
                v-model="form.allocated_qty"
                type="number"
                placeholder="0.00"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="在途数量">
              <ElInput
                v-model="form.in_transit_qty"
                type="number"
                placeholder="0.00"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="最后盘点日期">
              <ElDatePicker
                v-model="form.last_count_date"
                type="datetime"
                placeholder="请选择最后盘点日期"
                style="width: 100%"
                :disabled="props.readonly"
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

    <!-- 仓库创建对话框 -->
    <WarehouseDialog v-model="warehouseDialogVisible" @created="handleWarehouseCreated" />

    <!-- 货位创建对话框 -->
    <LocationDialog v-model="locationDialogVisible" @created="handleLocationCreated" />
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
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import WarehouseDialog from '@/views/wms/warehouses/modules/warehouse-dialog.vue'
  import LocationDialog from '@/views/wms/locations/modules/location-dialog.vue'
  import {
    createInvInventoryApi,
    updateInvInventoryApi,
    viewInvInventoryApi
  } from '@/api/inv/inventory'
  import { listMatItemApi } from '@/api/mat/item'
  import { listWmsLocationApi } from '@/api/wms/location'
  import { listWmsWarehouseApi } from '@/api/wms/warehouse'

  interface Props {
    modelValue: boolean
    inventory?: any
    readonly?: boolean
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', inventory: any): void
    (e: 'updated', inventory: any): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    inventory: undefined,
    readonly: false
  })

  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const isEditMode = computed(() => !!props.inventory && !!props.inventory.id)
  const dialogTitle = computed(() => {
    if (props.readonly) return '查看库存'
    return isEditMode.value ? '编辑库存' : '创建库存'
  })

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    item_id: [{ required: true, message: '请选择物品', trigger: 'change' }],
    location_id: [{ required: true, message: '请选择货位', trigger: 'change' }],
    warehouse_id: [{ required: true, message: '请选择仓库', trigger: 'change' }]
  })

  const form = reactive({
    id: undefined,
    item_id: undefined as string | number | undefined,
    location_id: undefined as string | number | undefined,
    company_id: undefined as string | number | undefined,
    warehouse_id: undefined as string | number | undefined,
    on_hand_qty: 0,
    available_qty: 0,
    allocated_qty: 0,
    in_transit_qty: 0,
    status_id: undefined as string | number | undefined,
    last_count_date: undefined as string | undefined,
    labels: [],
    custom_fields: {}
  })

  const itemOptions = ref<any[]>([])
  const itemSearchLoading = ref(false)
  const locationOptions = ref<any[]>([])
  const locationSearchLoading = ref(false)
  const warehouseOptions = ref<any[]>([])
  const warehouseSearchLoading = ref(false)
  const warehouseDialogVisible = ref(false)
  const locationDialogVisible = ref(false)
  const lastWarehouseId = ref<string | number | undefined>(undefined)
  const lastLocationId = ref<string | number | undefined>(undefined)

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

  const searchLocations = async (query: string): Promise<void> => {
    locationSearchLoading.value = true
    try {
      const res = await listWmsLocationApi({
        'q[name_or_code_cont]': query || '',
        per_page: 50
      })
      locationOptions.value = (res as any).data || []
    } catch (error) {
      console.error('搜索货位失败:', error)
    } finally {
      locationSearchLoading.value = false
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

  const handleLocationSelectChange = (value: string | number): void => {
    if (value === '__add_location__') {
      form.location_id = lastLocationId.value
      nextTick(() => {
        locationDialogVisible.value = true
      })
    } else {
      lastLocationId.value = value
    }
  }

  const handleWarehouseCreated = async (warehouse: any): Promise<void> => {
    if (warehouse?.id) {
      await searchWarehouses('')
      form.warehouse_id = warehouse.id
      lastWarehouseId.value = warehouse.id
    }
  }

  const handleLocationCreated = async (location: any): Promise<void> => {
    if (location?.id) {
      await searchLocations('')
      form.location_id = location.id
      lastLocationId.value = location.id
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

  const loadInventoryDetail = async (): Promise<void> => {
    if (!props.inventory?.id) return
    try {
      const res = await viewInvInventoryApi({ id: props.inventory.id })
      const inventoryData = (res as any).data || {}
      Object.assign(form, {
        id: inventoryData.id,
        item_id: inventoryData.item_id,
        location_id: inventoryData.location_id,
        company_id: inventoryData.company_id,
        warehouse_id: inventoryData.warehouse_id,
        on_hand_qty: inventoryData.on_hand_qty || 0,
        available_qty: inventoryData.available_qty || 0,
        allocated_qty: inventoryData.allocated_qty || 0,
        in_transit_qty: inventoryData.in_transit_qty || 0,
        status_id: inventoryData.status_id,
        last_count_date: inventoryData.last_count_date,
        labels: inventoryData.labels || [],
        custom_fields: inventoryData.custom_fields || {}
      })

      if (form.item_id) {
        await searchItems('')
      }
      if (form.location_id) {
        await searchLocations('')
      }
      if (form.warehouse_id) {
        await searchWarehouses('')
      }
    } catch (error) {
      console.error('加载库存详情失败:', error)
      ElMessage.error('加载库存详情失败')
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
        item_id: form.item_id,
        location_id: form.location_id,
        company_id: form.company_id,
        warehouse_id: form.warehouse_id,
        on_hand_qty: Number(form.on_hand_qty) || 0,
        available_qty: Number(form.available_qty) || 0,
        allocated_qty: Number(form.allocated_qty) || 0,
        in_transit_qty: Number(form.in_transit_qty) || 0,
        status_id: form.status_id ? Number(form.status_id) : undefined,
        last_count_date: form.last_count_date,
        labels: form.labels || [],
        custom_fields: form.custom_fields || {}
      }

      if (isEditMode.value) {
        const res = await updateInvInventoryApi(String(props.inventory.id), params)
        ElMessage.success('更新成功')
        emit('updated', (res as any).data || { ...props.inventory, ...params })
      } else {
        const res = await createInvInventoryApi(params)
        ElMessage.success('创建成功')
        emit('created', (res as any).data)
      }
      handleCancel()
    } catch (error) {
      console.log('表单验证失败:', error)
    }
  }

  const handleCancel = (): void => {
    dialogVisible.value = false
  }

  const handleClosed = (): void => {
    Object.assign(form, {
      id: undefined,
      item_id: undefined,
      location_id: undefined,
      company_id: undefined,
      warehouse_id: undefined,
      on_hand_qty: 0,
      available_qty: 0,
      allocated_qty: 0,
      in_transit_qty: 0,
      status_id: undefined,
      last_count_date: undefined,
      labels: [],
      custom_fields: {}
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
    () => form.location_id,
    (val) => {
      if (val && val !== '__add_location__') {
        lastLocationId.value = val
      }
    }
  )

  watch(
    () => props.modelValue,
    async (val) => {
      if (val) {
        searchItems('')
        searchLocations('')
        searchWarehouses('')
        if (isEditMode.value) {
          await loadInventoryDetail()
          lastWarehouseId.value = form.warehouse_id
          lastLocationId.value = form.location_id
        } else {
          lastWarehouseId.value = undefined
          lastLocationId.value = undefined
        }
      }
    }
  )

  watch(
    () => props.inventory,
    async () => {
      if (props.modelValue && isEditMode.value) {
        await loadInventoryDetail()
        lastWarehouseId.value = form.warehouse_id
        lastLocationId.value = form.location_id
      }
    },
    { deep: true }
  )
</script>

<style scoped lang="scss">
  .inventory-dialog {
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
  }

  :deep(.add-option:hover) {
    background-color: var(--el-fill-color-light);
  }
</style>
