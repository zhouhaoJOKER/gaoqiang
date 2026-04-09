<template>
  <ElDialog
    v-model="visible"
    :title="dialogType === 'add' ? '新增产品' : '编辑产品'"
    width="720px"
    align-center
    @close="handleClose"
  >
    <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px">
      <ElFormItem label="产品名称" prop="name">
        <ElInput v-model="form.name" placeholder="请输入产品名称" />
      </ElFormItem>
      <ElFormItem label="产品编码" prop="code">
        <ElInput v-model="form.code" placeholder="请输入产品编码" />
      </ElFormItem>
      <ElFormItem label="类型" prop="type_id">
        <PropertySelectWithAdd v-model="form.type_id" sign="product_type" placeholder="选择类型" />
      </ElFormItem>
      <ElFormItem label="产品大类" prop="parent_category_id">
        <PropertySelectWithAdd
          v-model="form.parent_category_id"
          sign="product_category"
          placeholder="选择产品大类"
          :root-only="true"
          @change="() => (form.category_id = undefined)"
        />
      </ElFormItem>
      <ElFormItem label="规格" prop="category_id">
        <PropertySelectWithAdd
          v-model="form.category_id"
          sign="product_category"
          placeholder="请先选择大类"
          :parent-id-eq="form.parent_category_id"
          :disabled="!form.parent_category_id"
        />
      </ElFormItem>
      <ElFormItem label="计量单位" prop="uom_id">
        <PropertySelectWithAdd
          v-model="form.uom_id"
          sign="product_uom"
          placeholder="选择计量单位"
        />
      </ElFormItem>
      <ElFormItem label="采购单位" prop="uom_po_id">
        <PropertySelectWithAdd
          v-model="form.uom_po_id"
          sign="product_uom_po"
          placeholder="选择采购单位"
        />
      </ElFormItem>
      <ElFormItem label="销售税" prop="sale_tax_id">
        <PropertySelectWithAdd
          v-model="form.sale_tax_id"
          sign="product_sale_tax"
          placeholder="选择销售税"
        />
      </ElFormItem>
      <ElFormItem label="采购税" prop="purchase_tax_id">
        <PropertySelectWithAdd
          v-model="form.purchase_tax_id"
          sign="product_purchase_tax"
          placeholder="选择采购税"
        />
      </ElFormItem>
      <ElFormItem label="售价" prop="price">
        <ElInput v-model="form.price" type="number" placeholder="0.00" />
      </ElFormItem>
      <ElFormItem label="成本价" prop="cost_price">
        <ElInput v-model="form.cost_price" type="number" placeholder="0.00" />
      </ElFormItem>
      <ElFormItem label="市场价" prop="market_price">
        <ElInput v-model="form.market_price" type="number" placeholder="0.00" />
      </ElFormItem>
      <ElFormItem label="描述">
        <ElInput v-model="form.description" type="textarea" :rows="3" placeholder="请输入描述" />
      </ElFormItem>
      <ElFormItem label="可销售">
        <ElSwitch v-model="form.is_sale" />
      </ElFormItem>
      <ElFormItem label="可采购">
        <ElSwitch v-model="form.is_purchase" />
      </ElFormItem>
      <ElFormItem label="可生产">
        <ElSwitch v-model="form.is_manufacture" />
      </ElFormItem>
      <ElFormItem label="可库存">
        <ElSwitch v-model="form.is_stock" />
      </ElFormItem>
      <ElFormItem label="启用">
        <ElSwitch v-model="form.is_active" />
      </ElFormItem>
    </ElForm>
    <template #footer>
      <ElButton @click="handleClose">取消</ElButton>
      <ElButton type="primary" @click="handleSubmit">提交</ElButton>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import { ElMessage } from 'element-plus'
  import type { FormInstance, FormRules } from 'element-plus'
  import { createMatProductApi, updateMatProductApi } from '@/api/mat/product'
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'

  interface Props {
    modelValue: boolean
    dialogType: 'add' | 'edit'
    productData?: any
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'success'): void
    (e: 'updateData', data: any): void
    (e: 'addData', data: any): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    dialogType: 'add',
    productData: undefined
  })

  const emit = defineEmits<Emits>()

  const visible = computed({
    get: () => props.modelValue,
    set: (value) => emit('update:modelValue', value)
  })

  const formRef = ref<FormInstance>()

  const rules = reactive<FormRules>({
    name: [{ required: true, message: '请输入产品名称', trigger: 'blur' }],
    code: [{ required: true, message: '请输入产品编码', trigger: 'blur' }]
  })

  const form = reactive<any>({
    id: undefined,
    name: '',
    code: '',
    type_id: undefined,
    parent_category_id: undefined,
    category_id: undefined,
    uom_id: undefined,
    uom_po_id: undefined,
    sale_tax_id: undefined,
    purchase_tax_id: undefined,
    price: 0,
    cost_price: 0,
    market_price: 0,
    description: '',
    is_sale: true,
    is_purchase: true,
    is_manufacture: false,
    is_stock: true,
    is_active: true
  })

  watch(
    () => props.modelValue,
    (newVal) => {
      if (newVal) {
        initForm()
      }
    },
    { immediate: true }
  )

  watch(
    () => props.productData,
    (newData) => {
      if (newData && props.modelValue) {
        initForm()
      }
    },
    { deep: true }
  )

  const initForm = () => {
    if (props.dialogType === 'edit' && props.productData) {
      Object.assign(form, {
        ...props.productData
      })
    } else {
      Object.assign(form, {
        id: undefined,
        name: '',
        code: '',
        type_id: undefined,
        parent_category_id: undefined,
        category_id: undefined,
        uom_id: undefined,
        uom_po_id: undefined,
        sale_tax_id: undefined,
        purchase_tax_id: undefined,
        price: 0,
        cost_price: 0,
        market_price: 0,
        description: '',
        is_sale: true,
        is_purchase: true,
        is_manufacture: false,
        is_stock: true,
        is_active: true
      })
    }
  }

  const handleClose = () => {
    visible.value = false
    formRef.value?.resetFields()
  }

  const handleSubmit = async () => {
    if (!formRef.value) return

    try {
      await formRef.value.validate()
      const submitData: Record<string, any> = {
        ...form,
        price: Number(form.price) || 0,
        cost_price: Number(form.cost_price) || 0,
        market_price: Number(form.market_price) || 0
      }
      delete submitData.parent_category_id

      if (props.dialogType === 'add') {
        const res = await createMatProductApi(submitData)
        if (res && res.code === 200) {
          ElMessage.success('新增成功')
          emit('success')
          emit('addData', res.data)
          handleClose()
        }
      } else {
        const res = await updateMatProductApi(String(form.id), submitData)
        if (res && res.code === 200) {
          ElMessage.success('修改成功')
          emit('success')
          emit('updateData', res.data)
          handleClose()
        }
      }
    } catch (error) {
      console.log('表单验证失败:', error)
    }
  }
</script>
