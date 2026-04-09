<template>
  <ElDialog v-model="visible" title="编辑物品" width="900px" align-center @close="handleClose">
    <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px">
      <ElRow :gutter="20">
        <ElCol :span="12">
          <ElFormItem label="物品名称" prop="name">
            <ElInput v-model="form.name" placeholder="请输入物品名称" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="物品编码" prop="code">
            <ElInput v-model="form.code" placeholder="请输入物品编码" />
          </ElFormItem>
        </ElCol>
      </ElRow>
      <ElRow :gutter="20">
        <ElCol :span="12">
          <ElFormItem label="条形码">
            <ElInput v-model="form.barcode" placeholder="请输入条形码" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="SKU">
            <ElInput v-model="form.sku" placeholder="请输入SKU" />
          </ElFormItem>
        </ElCol>
      </ElRow>
      <ElRow :gutter="20">
        <ElCol :span="12">
          <ElFormItem label="类型" prop="type_id">
            <PropertySelectWithAdd
              v-model="form.type_id"
              sign="product_type"
              placeholder="选择类型"
            />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="分类" prop="category_id">
            <PropertySelectWithAdd
              v-model="form.category_id"
              sign="product_category"
              placeholder="选择分类"
            />
          </ElFormItem>
        </ElCol>
      </ElRow>
      <ElRow :gutter="20">
        <ElCol :span="12">
          <ElFormItem label="计量单位" prop="uom_id">
            <PropertySelectWithAdd
              v-model="form.uom_id"
              sign="product_uom"
              placeholder="选择计量单位"
            />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="采购单位" prop="uom_po_id">
            <PropertySelectWithAdd
              v-model="form.uom_po_id"
              sign="product_uom_po"
              placeholder="选择采购单位"
            />
          </ElFormItem>
        </ElCol>
      </ElRow>
      <ElRow :gutter="20">
        <ElCol :span="12">
          <ElFormItem label="销售税" prop="sale_tax_id">
            <PropertySelectWithAdd
              v-model="form.sale_tax_id"
              sign="product_sale_tax"
              placeholder="选择销售税"
            />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="采购税" prop="purchase_tax_id">
            <PropertySelectWithAdd
              v-model="form.purchase_tax_id"
              sign="product_purchase_tax"
              placeholder="选择采购税"
            />
          </ElFormItem>
        </ElCol>
      </ElRow>
      <ElRow :gutter="20">
        <ElCol :span="8">
          <ElFormItem label="售价" prop="price">
            <ElInput v-model="form.price" type="number" placeholder="0.00" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="8">
          <ElFormItem label="成本价" prop="cost_price">
            <ElInput v-model="form.cost_price" type="number" placeholder="0.00" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="8">
          <ElFormItem label="市场价" prop="market_price">
            <ElInput v-model="form.market_price" type="number" placeholder="0.00" />
          </ElFormItem>
        </ElCol>
      </ElRow>
      <ElRow :gutter="20">
        <ElCol :span="12">
          <ElFormItem label="重量">
            <ElInput v-model="form.weight" type="number" placeholder="0.00" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="体积">
            <ElInput v-model="form.volume" type="number" placeholder="0.00" />
          </ElFormItem>
        </ElCol>
      </ElRow>
      <ElRow :gutter="20">
        <ElCol :span="6">
          <ElFormItem label="在手数量">
            <ElInput v-model="form.qty_onhand" type="number" placeholder="0" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="6">
          <ElFormItem label="可用数量">
            <ElInput v-model="form.qty_available" type="number" placeholder="0" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="6">
          <ElFormItem label="入库数量">
            <ElInput v-model="form.qty_incoming" type="number" placeholder="0" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="6">
          <ElFormItem label="出库数量">
            <ElInput v-model="form.qty_outgoing" type="number" placeholder="0" />
          </ElFormItem>
        </ElCol>
      </ElRow>
      <ElFormItem label="描述">
        <ElInput v-model="form.description" type="textarea" :rows="3" placeholder="请输入描述" />
      </ElFormItem>
      <ElRow :gutter="20">
        <ElCol :span="12">
          <ElFormItem label="可销售">
            <ElSwitch v-model="form.is_sale" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="可采购">
            <ElSwitch v-model="form.is_purchase" />
          </ElFormItem>
        </ElCol>
      </ElRow>
      <ElRow :gutter="20">
        <ElCol :span="12">
          <ElFormItem label="可生产">
            <ElSwitch v-model="form.is_manufacture" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="可库存">
            <ElSwitch v-model="form.is_stock" />
          </ElFormItem>
        </ElCol>
      </ElRow>
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
  import { ref, reactive, watch, computed } from 'vue'
  import {
    ElMessage,
    ElDialog,
    ElForm,
    ElFormItem,
    ElInput,
    ElSwitch,
    ElButton,
    ElRow,
    ElCol
  } from 'element-plus'
  import type { FormInstance, FormRules } from 'element-plus'
  import { updateMatItemApi } from '@/api/mat/item'
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'

  interface Props {
    modelValue: boolean
    itemData?: any
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'success'): void
    (e: 'updateData', data: any): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    itemData: undefined
  })

  const emit = defineEmits<Emits>()

  const visible = computed({
    get: () => props.modelValue,
    set: (value) => emit('update:modelValue', value)
  })

  const formRef = ref<FormInstance>()

  const rules = reactive<FormRules>({
    name: [{ required: true, message: '请输入物品名称', trigger: 'blur' }],
    code: [{ required: true, message: '请输入物品编码', trigger: 'blur' }]
  })

  const form = reactive<any>({
    id: undefined,
    name: '',
    logo: '',
    code: '',
    py: '',
    pinyin: '',
    barcode: '',
    type_id: undefined,
    category_id: undefined,
    price: 0,
    cost_price: 0,
    market_price: 0,
    description: '',
    uom_id: undefined,
    uom_po_id: undefined,
    sale_tax_id: undefined,
    purchase_tax_id: undefined,
    is_sale: true,
    is_purchase: true,
    is_manufacture: false,
    is_stock: true,
    is_active: true,
    product_id: undefined,
    value_id: undefined,
    sku: '',
    weight: 0,
    volume: 0,
    qty_onhand: 0,
    qty_available: 0,
    qty_incoming: 0,
    qty_outgoing: 0
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
    () => props.itemData,
    (newData) => {
      if (newData && props.modelValue) {
        initForm()
      }
    },
    { deep: true }
  )

  const initForm = () => {
    if (props.itemData) {
      Object.assign(form, {
        ...props.itemData
      })
    } else {
      Object.assign(form, {
        id: undefined,
        name: '',
        logo: '',
        code: '',
        py: '',
        pinyin: '',
        barcode: '',
        type_id: undefined,
        category_id: undefined,
        price: 0,
        cost_price: 0,
        market_price: 0,
        description: '',
        uom_id: undefined,
        uom_po_id: undefined,
        sale_tax_id: undefined,
        purchase_tax_id: undefined,
        is_sale: true,
        is_purchase: true,
        is_manufacture: false,
        is_stock: true,
        is_active: true,
        product_id: undefined,
        value_id: undefined,
        sku: '',
        weight: 0,
        volume: 0,
        qty_onhand: 0,
        qty_available: 0,
        qty_incoming: 0,
        qty_outgoing: 0
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
      // eslint-disable-next-line @typescript-eslint/no-unused-vars -- 排除提交时的 py/pinyin 字段
      const { py, pinyin, ...formRest } = form
      const submitData = {
        ...formRest,
        price: Number(form.price) || 0,
        cost_price: Number(form.cost_price) || 0,
        market_price: Number(form.market_price) || 0,
        weight: Number(form.weight) || 0,
        volume: Number(form.volume) || 0,
        qty_onhand: Number(form.qty_onhand) || 0,
        qty_available: Number(form.qty_available) || 0,
        qty_incoming: Number(form.qty_incoming) || 0,
        qty_outgoing: Number(form.qty_outgoing) || 0
      }

      const res = await updateMatItemApi(String(form.id), submitData)
      if (res && res.code === 200) {
        ElMessage.success('修改成功')
        emit('success')
        emit('updateData', res.data)
        handleClose()
      }
    } catch (error) {
      console.log('表单验证失败:', error)
    }
  }
</script>
