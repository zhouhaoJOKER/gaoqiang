<!-- 仓库创建/编辑对话框 -->
<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="800px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <div class="warehouse-dialog">
      <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px">
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="仓库名称" prop="name">
              <ElInput
                v-model="form.name"
                placeholder="请输入仓库名称"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="仓库编码" prop="code">
              <ElInput
                v-model="form.code"
                placeholder="请输入仓库编码"
                :readonly="props.readonly"
              />
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
            <ElFormItem label="公司" prop="company_id">
              <ElSelect
                v-model="form.company_id"
                placeholder="请选择公司"
                filterable
                style="width: 100%"
                :disabled="props.readonly"
              >
                <ElOption
                  v-for="company in companyList"
                  :key="company.id"
                  :label="company.name"
                  :value="company.id"
                />
              </ElSelect>
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="类型">
              <PropertySelectWithAdd
                v-model="form.type_id"
                sign="wms_warehouse_type"
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
    ElSwitch,
    ElRow,
    ElCol
  } from 'element-plus'
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'
  import {
    createWmsWarehouseApi,
    updateWmsWarehouseApi,
    viewWmsWarehouseApi
  } from '@/api/wms/warehouse'
  import { listCompanyApi } from '@/api/company'

  interface Props {
    modelValue: boolean
    warehouse?: any
    readonly?: boolean
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', warehouse: any): void
    (e: 'updated', warehouse: any): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    warehouse: undefined,
    readonly: false
  })

  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const isEditMode = computed(() => !!props.warehouse && !!props.warehouse.id)

  const dialogTitle = computed(() => {
    if (props.readonly) return '查看仓库'
    return isEditMode.value ? '编辑仓库' : '创建仓库'
  })

  const formRef = ref<FormInstance>()

  const rules = reactive<FormRules>({
    name: [{ required: true, message: '请输入仓库名称', trigger: 'blur' }],
    code: [{ required: true, message: '请输入仓库编码', trigger: 'blur' }],
    company_id: [{ required: true, message: '请选择公司', trigger: 'change' }]
  })

  const form = reactive({
    id: undefined,
    name: '',
    abbr: '',
    code: '',
    type_id: undefined as string | number | undefined,
    is_active: true,
    sort: 0,
    company_id: undefined as string | number | undefined,
    description: '',
    py: '',
    pinyin: ''
  })

  const companyList = ref<any[]>([])

  // 加载公司列表
  const loadCompanyList = async (): Promise<void> => {
    try {
      const res = await listCompanyApi({})
      companyList.value = (res as any).data || []
    } catch (error) {
      console.error('加载公司列表失败:', error)
    }
  }

  // 加载仓库详情
  const loadWarehouseDetail = async (): Promise<void> => {
    if (!props.warehouse?.id) return
    try {
      const res = await viewWmsWarehouseApi({ id: props.warehouse.id })
      const warehouseData = (res as any).data || {}
      Object.assign(form, {
        id: warehouseData.id,
        name: warehouseData.name || '',
        abbr: warehouseData.abbr || '',
        code: warehouseData.code || '',
        type_id: warehouseData.type_id,
        is_active: warehouseData.is_active !== false,
        sort: warehouseData.sort || 0,
        company_id: warehouseData.company_id,
        description: warehouseData.description || '',
        py: warehouseData.py || '',
        pinyin: warehouseData.pinyin || ''
      })
    } catch (error) {
      console.error('加载仓库详情失败:', error)
      ElMessage.error('加载仓库详情失败')
    }
  }

  // 保存
  const handleSave = async (): Promise<void> => {
    if (props.readonly) {
      handleCancel()
      return
    }

    if (!formRef.value) return

    try {
      await formRef.value.validate()
      const params = {
        name: form.name,
        abbr: form.abbr || '',
        code: form.code,
        type_id: form.type_id ? Number(form.type_id) : undefined,
        is_active: form.is_active,
        sort: Number(form.sort) || 0,
        company_id: form.company_id,
        description: form.description || ''
      }

      if (isEditMode.value) {
        const res = await updateWmsWarehouseApi(String(props.warehouse.id), params)
        ElMessage.success('更新成功')
        emit('updated', (res as any).data || { ...props.warehouse, ...params })
        handleCancel()
      } else {
        const res = await createWmsWarehouseApi(params)
        ElMessage.success('创建成功')
        emit('created', (res as any).data)
        handleCancel()
      }
    } catch (error) {
      console.log('表单验证失败:', error)
    }
  }

  // 保存并新建
  const handleSaveAndNew = async (): Promise<void> => {
    if (!formRef.value) return
    await formRef.value.validate()
    try {
      const params: any = {
        name: form.name,
        abbr: form.abbr || '',
        code: form.code,
        type_id: form.type_id ? Number(form.type_id) : undefined,
        is_active: form.is_active,
        sort: Number(form.sort) || 0,
        company_id: form.company_id,
        description: form.description || ''
      }
      const res = await createWmsWarehouseApi(params)
      ElMessage.success('创建成功')
      emit('created', (res as any).data)
      // 重置表单，保持弹窗打开
      Object.assign(form, {
        id: undefined,
        name: '',
        abbr: '',
        code: '',
        type_id: undefined,
        is_active: true,
        sort: 0,
        company_id: undefined,
        description: '',
        py: '',
        pinyin: ''
      })
      formRef.value?.resetFields()
    } catch (error) {
      console.log('表单验证失败:', error)
    }
  }

  // 取消
  const handleCancel = (): void => {
    dialogVisible.value = false
  }

  // 关闭后重置
  const handleClosed = (): void => {
    Object.assign(form, {
      id: undefined,
      name: '',
      abbr: '',
      code: '',
      type_id: undefined,
      is_active: true,
      sort: 0,
      company_id: undefined,
      description: '',
      py: '',
      pinyin: ''
    })
    formRef.value?.resetFields()
  }

  watch(
    () => props.modelValue,
    async (val) => {
      if (val) {
        loadCompanyList()
        if (isEditMode.value) {
          await loadWarehouseDetail()
        }
      }
    }
  )

  watch(
    () => props.warehouse,
    async () => {
      if (props.modelValue && isEditMode.value) {
        await loadWarehouseDetail()
      }
    },
    { deep: true }
  )
</script>

<style scoped lang="scss">
  .warehouse-dialog {
    .dialog-footer {
      display: flex;
      gap: 12px;
      justify-content: flex-end;
    }
  }
</style>
