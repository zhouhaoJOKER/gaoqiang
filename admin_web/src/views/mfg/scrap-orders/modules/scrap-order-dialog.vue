<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="800px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <div class="scrap-order-dialog">
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
            <ElFormItem label="报废单编号" prop="code">
              <ElInput
                v-model="form.code"
                placeholder="请输入报废单编号"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="报废类别" prop="scrap_category_id">
              <PropertySelectWithAdd
                v-model="form.scrap_category_id"
                sign="mfg_scrap_category"
                placeholder="请选择报废类别"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
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
        </ElRow>
        <ElRow :gutter="20">
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

    <!-- 货位创建对话框 -->
    <LocationDialog v-model="locationDialogVisible" @created="handleLocationCreated" />

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
    ElCol
  } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import StatusStepper from '@/components/wms/StatusStepper.vue'
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'
  import LocationDialog from '@/views/wms/locations/modules/location-dialog.vue'
  import {
    createMfgScrapOrderApi,
    updateMfgScrapOrderApi,
    viewMfgScrapOrderApi
  } from '@/api/mfg/scrap-order'
  import { listMatProductApi } from '@/api/mat/product'
  import { listMatItemApi } from '@/api/mat/item'
  import { listWmsLocationApi } from '@/api/wms/location'

  interface Props {
    modelValue: boolean
    scrapOrder?: any
    readonly?: boolean
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', scrapOrder: any): void
    (e: 'updated', scrapOrder: any): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    scrapOrder: undefined,
    readonly: false
  })

  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const isEditMode = computed(() => !!props.scrapOrder && !!props.scrapOrder.id)
  const dialogTitle = computed(() => {
    if (props.readonly) return '查看报废单'
    return isEditMode.value ? '编辑报废单' : '创建报废单'
  })

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    code: [{ required: true, message: '请输入报废单编号', trigger: 'blur' }],
    product_id: [{ required: true, message: '请选择产品', trigger: 'change' }],
    location_id: [{ required: true, message: '请选择货位', trigger: 'change' }],
    planned_qty: [{ required: true, message: '请输入计划数量', trigger: 'blur' }]
  })

  const form = reactive({
    id: undefined,
    code: '',
    status: 'draft',
    scrap_category_id: null as string | number | null,
    scrap_category: '',
    product_id: undefined as string | number | undefined,
    item_id: undefined as string | number | undefined,
    lot_id: undefined as string | number | undefined,
    location_id: undefined as string | number | undefined,
    planned_qty: 0
  })

  const productOptions = ref<any[]>([])
  const productSearchLoading = ref(false)
  const itemOptions = ref<any[]>([])
  const itemSearchLoading = ref(false)
  const locationOptions = ref<any[]>([])
  const locationSearchLoading = ref(false)
  const locationDialogVisible = ref(false)
  const lastLocationId = ref<string | number | undefined>(undefined)

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

  const loadScrapOrderDetail = async (): Promise<void> => {
    if (!props.scrapOrder?.id) return
    try {
      const res = await viewMfgScrapOrderApi({ id: props.scrapOrder.id })
      const orderData = (res as any).data || {}
      Object.assign(form, {
        id: orderData.id,
        code: orderData.code || '',
        status: orderData.status || 'draft',
        scrap_category_id: orderData.scrap_category_id ?? orderData.scrap_category ?? null,
        scrap_category: orderData.scrap_category || '',
        product_id: orderData.product_id,
        item_id: orderData.item_id,
        lot_id: orderData.lot_id,
        location_id: orderData.location_id,
        planned_qty: orderData.planned_qty || 0
      })

      if (form.product_id) {
        await searchProducts('')
      }
      if (form.item_id) {
        await searchItems('')
      }
      if (form.location_id) {
        await searchLocations('')
      }
    } catch (error) {
      console.error('加载报废单详情失败:', error)
      ElMessage.error('加载报废单详情失败')
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
        scrap_category_id: form.scrap_category_id ?? undefined,
        product_id: form.product_id,
        item_id: form.item_id,
        lot_id: form.lot_id ? Number(form.lot_id) : undefined,
        location_id: form.location_id,
        planned_qty: Number(form.planned_qty) || 0
      }

      if (isEditMode.value) {
        const res = await updateMfgScrapOrderApi(String(props.scrapOrder.id), params)
        ElMessage.success('更新成功')
        emit('updated', (res as any).data || { ...props.scrapOrder, ...params })
      } else {
        const res = await createMfgScrapOrderApi(params)
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
      await updateMfgScrapOrderApi(String(props.scrapOrder.id), { status: nextStatus })
      ElMessage.success('状态更新成功')
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
      scrap_category_id: undefined,
      scrap_category: '',
      product_id: undefined,
      item_id: undefined,
      lot_id: undefined,
      location_id: undefined,
      planned_qty: 0
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
        searchProducts('')
        searchItems('')
        searchLocations('')
        if (isEditMode.value) {
          await loadScrapOrderDetail()
          lastLocationId.value = form.location_id
        } else {
          form.status = 'draft'
          lastLocationId.value = undefined
        }
      }
    }
  )

  watch(
    () => props.scrapOrder,
    async () => {
      if (props.modelValue && isEditMode.value) {
        await loadScrapOrderDetail()
      }
    },
    { deep: true }
  )
</script>

<style scoped lang="scss">
  .scrap-order-dialog {
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
