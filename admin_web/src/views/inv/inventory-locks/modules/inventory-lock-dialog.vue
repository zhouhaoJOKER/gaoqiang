<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="800px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <div class="inventory-lock-dialog">
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
                <ElOption v-if="!props.readonly" value="__add_location__" class="add-option">
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
            <ElFormItem label="锁定数量" prop="locked_qty">
              <ElInput
                v-model="form.locked_qty"
                type="number"
                placeholder="0.00"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="订单类型" prop="order_type">
              <ElInput
                v-model="form.order_type"
                placeholder="请输入订单类型"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="订单ID" prop="order_id">
              <ElInput
                v-model="form.order_id"
                type="number"
                placeholder="请输入订单ID"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="锁定类型" prop="lock_type">
              <ElInput
                v-model="form.lock_type"
                placeholder="请输入锁定类型"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="状态" prop="status">
              <ElSelect
                v-model="form.status"
                placeholder="请选择状态"
                style="width: 100%"
                :disabled="props.readonly"
              >
                <ElOption label="有效" value="active" />
                <ElOption label="已过期" value="expired" />
                <ElOption label="已释放" value="released" />
              </ElSelect>
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="过期时间" prop="expires_at">
              <ElDatePicker
                v-model="form.expires_at"
                type="datetime"
                placeholder="请选择过期时间"
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
  import {
    createInvInventoryLockApi,
    updateInvInventoryLockApi,
    viewInvInventoryLockApi
  } from '@/api/inv/inventory-lock'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import LocationDialog from '@/views/wms/locations/modules/location-dialog.vue'
  import { listMatItemApi } from '@/api/mat/item'
  import { listWmsLocationApi } from '@/api/wms/location'

  interface Props {
    modelValue: boolean
    inventoryLock?: any
    readonly?: boolean
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', inventoryLock: any): void
    (e: 'updated', inventoryLock: any): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    inventoryLock: undefined,
    readonly: false
  })

  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const isEditMode = computed(() => !!props.inventoryLock && !!props.inventoryLock.id)
  const dialogTitle = computed(() => {
    if (props.readonly) return '查看库存锁定'
    return isEditMode.value ? '编辑库存锁定' : '创建库存锁定'
  })

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    item_id: [{ required: true, message: '请选择物品', trigger: 'change' }],
    location_id: [{ required: true, message: '请选择货位', trigger: 'change' }],
    locked_qty: [{ required: true, message: '请输入锁定数量', trigger: 'blur' }],
    order_type: [{ required: true, message: '请输入订单类型', trigger: 'blur' }],
    order_id: [{ required: true, message: '请输入订单ID', trigger: 'blur' }]
  })

  const form = reactive({
    id: undefined,
    item_id: undefined as string | number | undefined,
    location_id: undefined as string | number | undefined,
    inventory_id: undefined as string | number | undefined,
    locked_qty: 0,
    order_type: '',
    order_id: undefined as string | number | undefined,
    lock_type: '',
    status: 'active',
    expires_at: undefined as string | undefined
  })

  const itemOptions = ref<any[]>([])
  const itemSearchLoading = ref(false)
  const locationOptions = ref<any[]>([])
  const locationSearchLoading = ref(false)
  const locationDialogVisible = ref(false)
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

  const handleLocationCreated = async (location: any): Promise<void> => {
    if (location?.id) {
      await searchLocations('')
      form.location_id = location.id
      lastLocationId.value = location.id
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

  const loadInventoryLockDetail = async (): Promise<void> => {
    if (!props.inventoryLock?.id) return
    try {
      const res = await viewInvInventoryLockApi({ id: props.inventoryLock.id })
      const lockData = (res as any).data || {}
      Object.assign(form, {
        id: lockData.id,
        item_id: lockData.item_id,
        location_id: lockData.location_id,
        inventory_id: lockData.inventory_id,
        locked_qty: lockData.locked_qty || 0,
        order_type: lockData.order_type || '',
        order_id: lockData.order_id,
        lock_type: lockData.lock_type || '',
        status: lockData.status || 'active',
        expires_at: lockData.expires_at
      })

      if (form.item_id) {
        await searchItems('')
      }
      if (form.location_id) {
        await searchLocations('')
      }
    } catch (error) {
      console.error('加载库存锁定详情失败:', error)
      ElMessage.error('加载库存锁定详情失败')
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
        inventory_id: form.inventory_id,
        locked_qty: Number(form.locked_qty) || 0,
        order_type: form.order_type,
        order_id: form.order_id ? Number(form.order_id) : undefined,
        lock_type: form.lock_type || '',
        status: form.status,
        expires_at: form.expires_at
      }

      if (isEditMode.value) {
        const res = await updateInvInventoryLockApi(String(props.inventoryLock.id), params)
        ElMessage.success('更新成功')
        emit('updated', (res as any).data || { ...props.inventoryLock, ...params })
      } else {
        const res = await createInvInventoryLockApi(params)
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
      inventory_id: undefined,
      locked_qty: 0,
      order_type: '',
      order_id: undefined,
      lock_type: '',
      status: 'active',
      expires_at: undefined
    })
    formRef.value?.resetFields()
  }

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
        if (isEditMode.value) {
          await loadInventoryLockDetail()
          lastLocationId.value = form.location_id
        } else {
          lastLocationId.value = undefined
        }
      }
    }
  )

  watch(
    () => props.inventoryLock,
    async () => {
      if (props.modelValue && isEditMode.value) {
        await loadInventoryLockDetail()
      }
    },
    { deep: true }
  )
</script>

<style scoped lang="scss">
  .inventory-lock-dialog {
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
