<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="800px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <div class="area-dialog">
      <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px">
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="库区名称" prop="name">
              <ElInput
                v-model="form.name"
                placeholder="请输入库区名称"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="库区编码" prop="code">
              <ElInput
                v-model="form.code"
                placeholder="请输入库区编码"
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
            <ElFormItem label="简称">
              <ElInput v-model="form.abbr" placeholder="请输入简称" :readonly="props.readonly" />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="类型">
              <PropertySelectWithAdd
                v-model="form.type_id"
                sign="wms_area_type"
                placeholder="请选择类型"
              />
            </ElFormItem>
          </ElCol>
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
          <ElCol :span="12">
            <ElFormItem label="是否启用">
              <ElSwitch v-model="form.is_active" :disabled="props.readonly" />
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
  import { createWmsAreaApi, updateWmsAreaApi, viewWmsAreaApi } from '@/api/wms/area'
  import { listWmsWarehouseApi } from '@/api/wms/warehouse'

  interface Props {
    modelValue: boolean
    area?: any
    readonly?: boolean
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', area: any): void
    (e: 'updated', area: any): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    area: undefined,
    readonly: false
  })

  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const isEditMode = computed(() => !!props.area && !!props.area.id)
  const dialogTitle = computed(() => {
    if (props.readonly) return '查看库区'
    return isEditMode.value ? '编辑库区' : '创建库区'
  })

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    name: [{ required: true, message: '请输入库区名称', trigger: 'blur' }],
    code: [{ required: true, message: '请输入库区编码', trigger: 'blur' }],
    warehouse_id: [{ required: true, message: '请选择所属仓库', trigger: 'change' }]
  })

  const form = reactive({
    id: undefined,
    warehouse_id: undefined as string | number | undefined,
    name: '',
    abbr: '',
    code: '',
    type_id: undefined as string | number | undefined,
    is_active: true,
    sort: 0,
    description: '',
    py: '',
    pinyin: ''
  })

  const warehouseOptions = ref<any[]>([])
  const warehouseSearchLoading = ref(false)
  const warehouseDialogVisible = ref(false)
  const lastWarehouseId = ref<string | number | undefined>(undefined)

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

  const handleWarehouseSelectChange = (value: string | number): void => {
    if (value === '__add_warehouse__') {
      // 立即恢复之前的值，阻止选择
      form.warehouse_id = lastWarehouseId.value
      // 打开创建仓库对话框
      nextTick(() => {
        warehouseDialogVisible.value = true
      })
    } else {
      lastWarehouseId.value = value
    }
  }

  const handleWarehouseCreated = async (warehouse: any): Promise<void> => {
    if (warehouse?.id) {
      // 刷新仓库列表
      await searchWarehouses('')
      // 自动选中新创建的仓库
      form.warehouse_id = warehouse.id
      lastWarehouseId.value = warehouse.id
    }
  }

  const loadAreaDetail = async (): Promise<void> => {
    if (!props.area?.id) return
    try {
      const res = await viewWmsAreaApi({ id: props.area.id })
      const areaData = (res as any).data || {}
      Object.assign(form, {
        id: areaData.id,
        warehouse_id: areaData.warehouse_id,
        name: areaData.name || '',
        abbr: areaData.abbr || '',
        code: areaData.code || '',
        type_id: areaData.type_id,
        is_active: areaData.is_active !== false,
        sort: areaData.sort || 0,
        description: areaData.description || '',
        py: areaData.py || '',
        pinyin: areaData.pinyin || ''
      })
      if (form.warehouse_id) {
        await searchWarehouses('')
      }
    } catch (error) {
      console.error('加载库区详情失败:', error)
      ElMessage.error('加载库区详情失败')
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
        name: form.name,
        abbr: form.abbr || '',
        code: form.code,
        type_id: form.type_id ? Number(form.type_id) : undefined,
        is_active: form.is_active,
        sort: Number(form.sort) || 0,
        description: form.description || ''
      }
      if (isEditMode.value) {
        const res = await updateWmsAreaApi(String(props.area.id), params)
        ElMessage.success('更新成功')
        emit('updated', (res as any).data || { ...props.area, ...params })
        handleCancel()
      } else {
        const res = await createWmsAreaApi(params)
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
        name: form.name,
        abbr: form.abbr || '',
        code: form.code,
        type_id: form.type_id ? Number(form.type_id) : undefined,
        is_active: form.is_active,
        sort: Number(form.sort) || 0,
        description: form.description || ''
      }
      const res = await createWmsAreaApi(params)
      ElMessage.success('创建成功')
      emit('created', (res as any).data)
      // 重置表单，保持弹窗打开
      Object.assign(form, {
        id: undefined,
        warehouse_id: undefined,
        name: '',
        abbr: '',
        code: '',
        type_id: undefined,
        is_active: true,
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
      name: '',
      abbr: '',
      code: '',
      type_id: undefined,
      is_active: true,
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
    () => props.modelValue,
    async (val) => {
      if (val) {
        searchWarehouses('')
        if (isEditMode.value) {
          await loadAreaDetail()
          lastWarehouseId.value = form.warehouse_id
        } else {
          lastWarehouseId.value = undefined
        }
      }
    }
  )

  watch(
    () => props.area,
    async () => {
      if (props.modelValue && isEditMode.value) {
        await loadAreaDetail()
        lastWarehouseId.value = form.warehouse_id
      }
    },
    { deep: true }
  )
</script>

<style scoped lang="scss">
  .area-dialog {
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
