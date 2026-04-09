<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="800px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <div class="bom-byproduct-dialog">
      <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px">
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="BOM" prop="bom_id">
              <ElSelect
                v-model="form.bom_id"
                placeholder="请选择BOM"
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
                  :label="`[${bom.code || ''}] ${bom.product_name || ''}`"
                  :value="bom.id"
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
            <ElFormItem label="产品数量" prop="product_qty">
              <ElInput
                v-model="form.product_qty"
                type="number"
                placeholder="0.00"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="计量单位">
              <ElSelect
                v-model="form.product_uom_id"
                placeholder="请选择单位"
                style="width: 100%"
                :disabled="props.readonly"
              >
                <ElOption
                  v-for="uom in uomOptions"
                  :key="uom.id"
                  :label="uom.name"
                  :value="uom.id"
                />
              </ElSelect>
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="产出类别" prop="output_category_id">
              <PropertySelectWithAdd
                v-model="form.output_category_id"
                sign="bom_output_category"
                placeholder="请选择产出类别"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="是否入库">
              <ElSwitch v-model="form.is_inventory" :disabled="props.readonly" />
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
          <ElButton type="primary" @click="handleSave">保存</ElButton>
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
    ElRow,
    ElCol,
    ElSwitch
  } from 'element-plus'
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'
  import { listPropertyApi } from '@/api/property'
  import {
    createMfgBomByproductApi,
    updateMfgBomByproductApi,
    viewMfgBomByproductApi
  } from '@/api/mfg/bom'
  import { listMfgBomApi } from '@/api/mfg/bom'
  import { listMatProductApi } from '@/api/mat/product'

  interface Props {
    modelValue: boolean
    bomByproduct?: any
    readonly?: boolean
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', data: any): void
    (e: 'updated', data: any): void
  }

  const props = defineProps<Props>()
  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const dialogTitle = computed(() => {
    if (props.readonly) return '查看BOM副产品'
    return props.bomByproduct?.id ? '编辑BOM副产品' : '新建BOM副产品'
  })

  const isEditMode = computed(() => !!props.bomByproduct?.id)

  const formRef = ref<FormInstance>()
  const uomOptions = ref<any[]>([])

  const form = reactive({
    id: undefined,
    bom_id: undefined,
    product_id: undefined,
    product_qty: '',
    product_uom_id: undefined as string | number | undefined,
    output_category_id: null as string | number | null,
    output_category: 'byproduct',
    is_inventory: false,
    sort: 0
  })

  const rules: FormRules = {
    bom_id: [{ required: true, message: '请选择BOM', trigger: 'change' }],
    product_id: [{ required: true, message: '请选择产品', trigger: 'change' }],
    product_qty: [{ required: true, message: '请输入产品数量', trigger: 'blur' }],
    output_category_id: [{ required: true, message: '请选择产出类别', trigger: 'change' }]
  }

  const bomOptions = ref<any[]>([])
  const bomSearchLoading = ref(false)
  const productOptions = ref<any[]>([])
  const productSearchLoading = ref(false)

  const loadUomOptions = async () => {
    try {
      const res = await listPropertyApi({ 'q[sign_eq]': 'product_uom', per_page: 100 })
      const data = (res as any).data || []
      uomOptions.value = Array.isArray(data)
        ? data.filter((item: any) => item && item.id != null)
        : []
    } catch (error) {
      console.error('加载计量单位失败:', error)
    }
  }

  const searchBoms = async (query: string) => {
    if (!query) {
      bomOptions.value = []
      return
    }
    bomSearchLoading.value = true
    try {
      const res = await listMfgBomApi({ 'q[code_cont]': query, per_page: 50 })
      const list = (res as any).data || []
      bomOptions.value = list.map((bom: any) => ({
        id: bom.id,
        code: bom.code,
        product_name: bom.product_name
      }))
    } catch (error) {
      console.error('搜索BOM失败:', error)
    } finally {
      bomSearchLoading.value = false
    }
  }

  const searchProducts = async (query: string) => {
    if (!query) {
      productOptions.value = []
      return
    }
    productSearchLoading.value = true
    try {
      const res = await listMatProductApi({ 'q[name_cont]': query, per_page: 50 })
      const list = (res as any).data || []
      productOptions.value = list.map((p: any) => ({
        id: p.id,
        code: p.code,
        name: p.name
      }))
    } catch (error) {
      console.error('搜索产品失败:', error)
    } finally {
      productSearchLoading.value = false
    }
  }

  const loadBomByproduct = async () => {
    if (!props.bomByproduct?.id) {
      Object.assign(form, {
        id: undefined,
        bom_id: undefined,
        product_id: undefined,
        product_qty: '',
        product_uom_id: undefined,
        output_category: 'byproduct',
        is_inventory: false,
        sort: 0
      })
      return
    }
    try {
      const res = await viewMfgBomByproductApi({ id: props.bomByproduct.id })
      const data = (res as any).data || {}
      Object.assign(form, {
        id: data.id,
        bom_id: data.bom_id,
        product_id: data.product_id,
        product_qty: data.product_qty || '',
        product_uom_id: data.product_uom_id,
        output_category_id: data.output_category_id ?? data.output_category ?? null,
        output_category: data.output_category || 'byproduct',
        is_inventory: data.is_inventory || false,
        sort: data.sort || 0
      })
      if (data.bom_id) {
        searchBoms('')
      }
      if (data.product_id) {
        searchProducts('')
      }
    } catch (error) {
      console.error('加载BOM副产品失败:', error)
      ElMessage.error('加载失败')
    }
  }

  watch(
    () => props.modelValue,
    (val) => {
      if (val) {
        loadUomOptions()
        loadBomByproduct()
      }
    },
    { immediate: true }
  )

  watch(
    () => props.bomByproduct,
    () => {
      if (props.modelValue) {
        loadBomByproduct()
      }
    }
  )

  const handleCancel = () => {
    dialogVisible.value = false
  }

  const handleClosed = () => {
    formRef.value?.resetFields()
    Object.assign(form, {
      id: undefined,
      bom_id: undefined,
      product_id: undefined,
      product_qty: '',
      product_uom_id: undefined,
      output_category_id: undefined,
      output_category: 'byproduct',
      is_inventory: false,
      sort: 0
    })
    bomOptions.value = []
    productOptions.value = []
  }

  const handleSave = async () => {
    if (!formRef.value) return
    await formRef.value.validate()
    try {
      const params: any = {
        bom_id: form.bom_id ? Number(form.bom_id) : undefined,
        product_id: form.product_id ? Number(form.product_id) : undefined,
        product_qty: form.product_qty ? Number(form.product_qty) : 0,
        product_uom_id: form.product_uom_id ? Number(form.product_uom_id) : undefined,
        output_category_id: form.output_category_id ?? undefined,
        output_category: form.output_category,
        is_inventory: form.is_inventory,
        sort: form.sort ? Number(form.sort) : 0
      }
      if (isEditMode.value) {
        const res = await updateMfgBomByproductApi(String(form.id), params)
        ElMessage.success('更新成功')
        emit('updated', (res as any).data)
        dialogVisible.value = false
      } else {
        const res = await createMfgBomByproductApi(params)
        ElMessage.success('创建成功')
        emit('created', (res as any).data)
        dialogVisible.value = false
      }
    } catch (error: any) {
      console.error('保存失败:', error)
      ElMessage.error(error?.message || '保存失败')
    }
  }

  const handleSaveAndNew = async () => {
    if (!formRef.value) return
    try {
      await formRef.value.validate()
      const params: any = {
        bom_id: form.bom_id ? Number(form.bom_id) : undefined,
        product_id: form.product_id ? Number(form.product_id) : undefined,
        product_qty: form.product_qty ? Number(form.product_qty) : 0,
        product_uom_id: form.product_uom_id ? Number(form.product_uom_id) : undefined,
        output_category_id: form.output_category_id ?? undefined,
        output_category: form.output_category,
        is_inventory: form.is_inventory,
        sort: form.sort ? Number(form.sort) : 0
      }
      const res = await createMfgBomByproductApi(params)
      ElMessage.success('创建成功')
      emit('created', (res as any).data)
      // 重置表单，保持弹窗打开
      Object.assign(form, {
        id: undefined,
        bom_id: undefined,
        product_id: undefined,
        product_qty: '',
        product_uom_id: undefined,
        output_category_id: undefined,
        output_category: 'byproduct',
        is_inventory: false,
        sort: 0
      })
      formRef.value?.resetFields()
      bomOptions.value = []
      productOptions.value = []
    } catch (error: any) {
      console.error('保存失败:', error)
      ElMessage.error(error?.message || '保存失败')
    }
  }
</script>

<style scoped>
  .bom-byproduct-dialog {
    padding: 20px 0;
  }
</style>
