<!-- 供应商创建/编辑对话框 -->
<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="800px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <div class="supplier-dialog">
      <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px">
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="供应商名称" prop="name">
              <ElInput
                v-model="form.name"
                placeholder="请输入供应商名称"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="供应商编码" prop="code">
              <ElInput
                v-model="form.code"
                placeholder="请输入供应商编码"
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
            <ElFormItem label="最小数量">
              <ElInput
                v-model="form.min_qty"
                type="number"
                placeholder="0.00"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="价格">
              <ElInput
                v-model="form.price"
                type="number"
                placeholder="0.00"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="货币" prop="currency_id">
              <PropertySelectWithAdd
                v-model="form.currency_id"
                sign="currency"
                placeholder="选择货币"
                :disabled="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="延迟天数">
              <ElInput
                v-model="form.delay"
                type="number"
                placeholder="0"
                :readonly="props.readonly"
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
                placeholder="0.00"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="是否主供应商">
              <ElSwitch v-model="form.is_main" :disabled="props.readonly" />
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
  import {
    createMatSupplierApi,
    updateMatSupplierApi,
    viewMatSupplierApi
  } from '@/api/mat/supplier'
  import { listMatProductApi } from '@/api/mat/product'
  import { listCompanyApi } from '@/api/company'
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'

  interface Props {
    modelValue: boolean
    supplier?: any // 编辑模式时传入的供应商数据
    readonly?: boolean // 是否只读模式（查看模式）
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', supplier: any): void
    (e: 'updated', supplier: any): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    supplier: undefined,
    readonly: false
  })

  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const isEditMode = computed(() => !!props.supplier && !!props.supplier.id)

  const dialogTitle = computed(() => {
    if (props.readonly) return '查看供应商'
    return isEditMode.value ? '编辑供应商' : '创建供应商'
  })

  const formRef = ref<FormInstance>()

  const rules = reactive<FormRules>({
    name: [{ required: true, message: '请输入供应商名称', trigger: 'blur' }],
    code: [{ required: true, message: '请输入供应商编码', trigger: 'blur' }],
    company_id: [{ required: true, message: '请选择公司', trigger: 'change' }],
    product_id: [{ required: true, message: '请选择产品', trigger: 'change' }]
  })

  const form = reactive({
    id: undefined,
    company_id: undefined as string | number | undefined,
    product_id: undefined as string | number | undefined,
    name: '',
    code: '',
    py: '',
    pinyin: '',
    min_qty: 0,
    price: 0,
    currency_id: undefined as string | number | undefined,
    delay: 0,
    is_main: false,
    sort: 0
  })

  const companyList = ref<any[]>([])
  const productOptions = ref<any[]>([])
  const productSearchLoading = ref(false)

  // 加载公司列表
  const loadCompanyList = async (): Promise<void> => {
    try {
      const res = await listCompanyApi({})
      companyList.value = (res as any).data || []
    } catch (error) {
      console.error('加载公司列表失败:', error)
    }
  }

  // 搜索产品
  const searchProducts = async (query: string): Promise<void> => {
    productSearchLoading.value = true
    try {
      const res = await listMatProductApi({
        'q[name_or_py_cont]': query || '',
        per_page: 50
      })
      productOptions.value = (res as any).data || []
    } catch (error) {
      console.error('搜索产品失败:', error)
    } finally {
      productSearchLoading.value = false
    }
  }

  // 加载供应商详情
  const loadSupplierDetail = async (): Promise<void> => {
    if (!props.supplier?.id) return
    try {
      const res = await viewMatSupplierApi({ id: props.supplier.id })
      const supplierData = (res as any).data || {}
      Object.assign(form, {
        id: supplierData.id,
        company_id: supplierData.company_id,
        product_id: supplierData.product_id,
        name: supplierData.name || '',
        code: supplierData.code || '',
        py: supplierData.py || '',
        pinyin: supplierData.pinyin || '',
        min_qty: supplierData.min_qty || 0,
        price: supplierData.price || 0,
        currency_id: supplierData.currency_id,
        delay: supplierData.delay || 0,
        is_main: supplierData.is_main || false,
        sort: supplierData.sort || 0
      })
      // 加载产品信息
      if (form.product_id) {
        await searchProducts('')
      }
    } catch (error) {
      console.error('加载供应商详情失败:', error)
      ElMessage.error('加载供应商详情失败')
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
        company_id: form.company_id,
        product_id: form.product_id,
        name: form.name,
        code: form.code,
        min_qty: Number(form.min_qty) || 0,
        price: Number(form.price) || 0,
        currency_id: form.currency_id,
        delay: Number(form.delay) || 0,
        is_main: form.is_main || false,
        sort: Number(form.sort) || 0
      }

      if (isEditMode.value) {
        // 编辑模式
        const res = await updateMatSupplierApi(String(props.supplier.id), params)
        ElMessage.success('更新成功')
        emit('updated', (res as any).data || { ...props.supplier, ...params })
        handleCancel()
      } else {
        // 创建模式
        const res = await createMatSupplierApi(params)
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
    try {
      await formRef.value.validate()
      const params: any = {
        company_id: form.company_id,
        product_id: form.product_id,
        name: form.name,
        code: form.code,
        min_qty: Number(form.min_qty) || 0,
        price: Number(form.price) || 0,
        currency_id: form.currency_id,
        delay: Number(form.delay) || 0,
        is_main: form.is_main || false,
        sort: Number(form.sort) || 0
      }
      const res = await createMatSupplierApi(params)
      ElMessage.success('创建成功')
      emit('created', (res as any).data)
      // 重置表单，保持弹窗打开
      Object.assign(form, {
        id: undefined,
        company_id: undefined,
        product_id: undefined,
        name: '',
        code: '',
        py: '',
        pinyin: '',
        min_qty: 0,
        price: 0,
        currency_id: undefined,
        delay: 0,
        is_main: false,
        sort: 0
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
      company_id: undefined,
      product_id: undefined,
      name: '',
      code: '',
      py: '',
      pinyin: '',
      min_qty: 0,
      price: 0,
      currency_id: undefined,
      delay: 0,
      is_main: false,
      sort: 0
    })
    productOptions.value = []
    formRef.value?.resetFields()
  }

  watch(
    () => props.modelValue,
    async (val) => {
      if (val) {
        loadCompanyList()
        searchProducts('')
        if (isEditMode.value) {
          await loadSupplierDetail()
        }
      }
    }
  )

  watch(
    () => props.supplier,
    async () => {
      if (props.modelValue && isEditMode.value) {
        await loadSupplierDetail()
      }
    },
    { deep: true }
  )
</script>

<style scoped lang="scss">
  .supplier-dialog {
    .dialog-footer {
      display: flex;
      gap: 12px;
      justify-content: flex-end;
    }
  }
</style>
