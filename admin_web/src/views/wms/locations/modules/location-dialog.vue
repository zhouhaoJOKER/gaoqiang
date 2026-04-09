<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="800px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <div class="location-dialog">
      <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px">
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="货位名称" prop="name">
              <ElInput
                v-model="form.name"
                placeholder="请输入货位名称"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="货位编码" prop="code">
              <ElInput
                v-model="form.code"
                placeholder="请输入货位编码"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="所属仓库" prop="warehouse_id">
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
            <ElFormItem label="所属库区" prop="area_id">
              <ElSelect
                v-model="form.area_id"
                placeholder="请选择库区"
                filterable
                remote
                :remote-method="searchAreas"
                :loading="areaSearchLoading"
                style="width: 100%"
                :disabled="props.readonly || !form.warehouse_id"
                @change="handleAreaSelectChange"
              >
                <ElOption
                  v-for="area in areaOptions"
                  :key="area.id"
                  :label="`[${area.code || ''}] ${area.name}`"
                  :value="area.id"
                />
                <ElOption
                  v-if="!props.readonly && form.warehouse_id"
                  value="__add_area__"
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
                    新增库区
                  </span>
                </ElOption>
              </ElSelect>
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="简称">
              <ElInput v-model="form.abbr" placeholder="请输入简称" :readonly="props.readonly" />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="类型">
              <PropertySelectWithAdd
                v-model="form.type_id"
                sign="wms_location_type"
                placeholder="请选择类型"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="排序">
              <ElInput
                v-model="form.sort"
                type="number"
                placeholder="0"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="是否启用">
              <ElSwitch v-model="form.is_active" :disabled="props.readonly" />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="可调整">
              <ElSwitch v-model="form.is_adjustment" :disabled="props.readonly" />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="可预留">
              <ElSwitch v-model="form.is_reservation" :disabled="props.readonly" />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow v-if="props.readonly" :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="拼音">
              <ElInput v-model="form.py" placeholder="-" readonly />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="拼音全拼">
              <ElInput v-model="form.pinyin" placeholder="-" readonly />
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
    </div>

    <!-- 仓库创建对话框 -->
    <WarehouseDialog v-model="warehouseDialogVisible" @created="handleWarehouseCreated" />

    <!-- 库区创建对话框 -->
    <AreaDialog v-model="areaDialogVisible" @created="handleAreaCreated" />

    <template #footer>
      <div class="dialog-footer">
        <ElButton @click="handleCancel">{{ props.readonly ? '关闭' : '取消' }}</ElButton>
        <template v-if="!props.readonly">
          <ElButton v-if="!isEditMode" type="primary" @click="handleSaveAndNew"
            >保存并新建</ElButton
          >
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
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'
  import {
    ElDialog,
    ElForm,
    ElFormItem,
    ElInput,
    ElSelect,
    ElOption,
    ElButton,
    ElSwitch,
    ElRow,
    ElCol
  } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import WarehouseDialog from '@/views/wms/warehouses/modules/warehouse-dialog.vue'
  import AreaDialog from '@/views/wms/areas/modules/area-dialog.vue'
  import {
    createWmsLocationApi,
    updateWmsLocationApi,
    viewWmsLocationApi
  } from '@/api/wms/location'
  import { listWmsWarehouseApi } from '@/api/wms/warehouse'
  import { listWmsAreaApi } from '@/api/wms/area'

  interface Props {
    modelValue: boolean
    location?: any
    readonly?: boolean
    initialWarehouseId?: string | number
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', location: any): void
    (e: 'updated', location: any): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    location: undefined,
    readonly: false,
    initialWarehouseId: undefined
  })

  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const isEditMode = computed(() => !!props.location && !!props.location.id)
  const dialogTitle = computed(() => {
    if (props.readonly) return '查看货位'
    return isEditMode.value ? '编辑货位' : '创建货位'
  })

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    name: [{ required: true, message: '请输入货位名称', trigger: 'blur' }],
    code: [{ required: true, message: '请输入货位编码', trigger: 'blur' }],
    warehouse_id: [{ required: true, message: '请选择所属仓库', trigger: 'change' }],
    area_id: [{ required: true, message: '请选择所属库区', trigger: 'change' }]
  })

  const form = reactive({
    id: undefined,
    warehouse_id: undefined as string | number | undefined,
    area_id: undefined as string | number | undefined,
    name: '',
    abbr: '',
    code: '',
    type_id: undefined as string | number | undefined,
    is_active: true,
    is_adjustment: false,
    is_reservation: false,
    sort: 0,
    description: '',
    py: '',
    pinyin: ''
  })

  const warehouseOptions = ref<any[]>([])
  const warehouseSearchLoading = ref(false)
  const areaOptions = ref<any[]>([])
  const areaSearchLoading = ref(false)
  const warehouseDialogVisible = ref(false)
  const areaDialogVisible = ref(false)
  const lastWarehouseId = ref<string | number | undefined>(undefined)
  const lastAreaId = ref<string | number | undefined>(undefined)

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

  const searchAreas = async (query: string): Promise<void> => {
    if (!form.warehouse_id) {
      areaOptions.value = []
      return
    }
    areaSearchLoading.value = true
    try {
      const res = await listWmsAreaApi({
        'q[warehouse_id_eq]': form.warehouse_id,
        'q[name_or_code_cont]': query || '',
        per_page: 50
      })
      areaOptions.value = (res as any).data || []
    } catch (error) {
      console.error('搜索库区失败:', error)
    } finally {
      areaSearchLoading.value = false
    }
  }

  const handleWarehouseChange = () => {
    form.area_id = undefined
    areaOptions.value = []
    lastAreaId.value = undefined
    if (form.warehouse_id) {
      searchAreas('')
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
      handleWarehouseChange()
    }
  }

  const handleAreaSelectChange = (value: string | number): void => {
    if (value === '__add_area__') {
      form.area_id = lastAreaId.value
      nextTick(() => {
        areaDialogVisible.value = true
      })
    } else {
      lastAreaId.value = value
    }
  }

  const handleWarehouseCreated = async (warehouse: any): Promise<void> => {
    if (warehouse?.id) {
      await searchWarehouses('')
      form.warehouse_id = warehouse.id
      lastWarehouseId.value = warehouse.id
    }
  }

  const handleAreaCreated = async (area: any): Promise<void> => {
    if (area?.id) {
      await searchAreas('')
      form.area_id = area.id
      lastAreaId.value = area.id
    }
  }

  const loadLocationDetail = async (): Promise<void> => {
    if (!props.location?.id) return
    try {
      const res = await viewWmsLocationApi({ id: props.location.id })
      const locationData = (res as any).data || {}
      Object.assign(form, {
        id: locationData.id,
        warehouse_id: locationData.warehouse_id,
        area_id: locationData.area_id,
        name: locationData.name || '',
        abbr: locationData.abbr || '',
        code: locationData.code || '',
        type_id: locationData.type_id,
        is_active: locationData.is_active !== false,
        is_adjustment: locationData.is_adjustment || false,
        is_reservation: locationData.is_reservation || false,
        sort: locationData.sort || 0,
        description: locationData.description || '',
        py: locationData.py || '',
        pinyin: locationData.pinyin || ''
      })
      if (form.warehouse_id) {
        await searchWarehouses('')
        await searchAreas('')
      }
    } catch (error) {
      console.error('加载货位详情失败:', error)
      ElMessage.error('加载货位详情失败')
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
        warehouse_id: form.warehouse_id,
        area_id: form.area_id,
        name: form.name,
        abbr: form.abbr || '',
        code: form.code,
        type_id: form.type_id ? Number(form.type_id) : undefined,
        is_active: form.is_active,
        is_adjustment: form.is_adjustment,
        is_reservation: form.is_reservation,
        sort: Number(form.sort) || 0,
        description: form.description || ''
      }
      if (isEditMode.value) {
        const res = await updateWmsLocationApi(String(props.location.id), params)
        ElMessage.success('更新成功')
        emit('updated', (res as any).data || { ...props.location, ...params })
        handleCancel()
      } else {
        const res = await createWmsLocationApi(params)
        ElMessage.success('创建成功')
        emit('created', (res as any).data)
        handleCancel()
      }
    } catch (error) {
      console.log('表单验证失败:', error)
    }
  }

  const handleSaveAndNew = async (): Promise<void> => {
    if (!formRef.value) return
    try {
      await formRef.value.validate()
      const params: any = {
        warehouse_id: form.warehouse_id ? Number(form.warehouse_id) : undefined,
        area_id: form.area_id ? Number(form.area_id) : undefined,
        name: form.name,
        abbr: form.abbr || '',
        code: form.code,
        type_id: form.type_id ? Number(form.type_id) : undefined,
        is_active: form.is_active,
        is_adjustment: form.is_adjustment,
        is_reservation: form.is_reservation,
        sort: Number(form.sort) || 0,
        description: form.description || ''
      }
      const res = await createWmsLocationApi(params)
      ElMessage.success('创建成功')
      emit('created', (res as any).data)
      // 重置表单，保持弹窗打开
      Object.assign(form, {
        id: undefined,
        warehouse_id: undefined,
        area_id: undefined,
        name: '',
        abbr: '',
        code: '',
        type_id: undefined,
        is_active: true,
        is_adjustment: false,
        is_reservation: false,
        sort: 0,
        description: '',
        py: '',
        pinyin: ''
      })
      formRef.value?.resetFields()
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
      warehouse_id: undefined,
      area_id: undefined,
      name: '',
      abbr: '',
      code: '',
      type_id: undefined,
      is_active: true,
      is_adjustment: false,
      is_reservation: false,
      sort: 0,
      description: '',
      py: '',
      pinyin: ''
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
    () => form.area_id,
    (val) => {
      if (val && val !== '__add_area__') {
        lastAreaId.value = val
      }
    }
  )

  watch(
    () => props.modelValue,
    async (val) => {
      if (val) {
        searchWarehouses('')
        if (isEditMode.value) {
          await loadLocationDetail()
          lastWarehouseId.value = form.warehouse_id
          lastAreaId.value = form.area_id
        } else {
          // 如果提供了初始仓库ID，设置到表单中
          if (props.initialWarehouseId) {
            form.warehouse_id = props.initialWarehouseId
            lastWarehouseId.value = props.initialWarehouseId
            await searchAreas('')
          } else {
            lastWarehouseId.value = undefined
          }
          lastAreaId.value = undefined
        }
      }
    }
  )

  watch(
    () => props.location,
    async () => {
      if (props.modelValue && isEditMode.value) {
        await loadLocationDetail()
        lastWarehouseId.value = form.warehouse_id
        lastAreaId.value = form.area_id
      }
    },
    { deep: true }
  )
</script>

<style scoped lang="scss">
  .location-dialog {
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
