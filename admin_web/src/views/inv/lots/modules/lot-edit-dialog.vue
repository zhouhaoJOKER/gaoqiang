<template>
  <ElDialog
    v-model="visible"
    title="编辑批次序列号"
    width="800px"
    align-center
    @close="handleClose"
  >
    <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px">
      <ElRow :gutter="20">
        <ElCol :span="12">
          <ElFormItem label="批次号" prop="code">
            <ElInput v-model="form.code" placeholder="请输入批次号" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="参考号" prop="ref">
            <ElInput v-model="form.ref" placeholder="请输入参考号" />
          </ElFormItem>
        </ElCol>
      </ElRow>
      <ElRow :gutter="20">
        <ElCol :span="12">
          <ElFormItem label="公司" prop="company_id">
            <ElSelect
              v-model="form.company_id"
              placeholder="选择公司"
              filterable
              style="width: 100%"
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
          <ElFormItem label="物品">
            <ElInput v-model="form.item_name" disabled />
          </ElFormItem>
        </ElCol>
      </ElRow>
      <ElRow :gutter="20">
        <ElCol :span="12">
          <ElFormItem label="产品">
            <ElInput v-model="form.product_name" disabled />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="数量">
            <ElInput v-model="form.qty" disabled />
          </ElFormItem>
        </ElCol>
      </ElRow>
      <ElRow :gutter="20">
        <ElCol :span="12">
          <ElFormItem label="单位成本">
            <ElInput v-model="form.unit_cost" disabled />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="过期日期">
            <ElInput v-model="form.expiration_date" disabled />
          </ElFormItem>
        </ElCol>
      </ElRow>
      <ElRow :gutter="20">
        <ElCol :span="12">
          <ElFormItem label="提醒日期">
            <ElInput v-model="form.alert_date" disabled />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="移除日期">
            <ElInput v-model="form.removal_date" disabled />
          </ElFormItem>
        </ElCol>
      </ElRow>
      <ElFormItem label="描述">
        <ElInput v-model="form.description" type="textarea" :rows="3" placeholder="请输入描述" />
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
    ElButton,
    ElRow,
    ElCol,
    ElSelect,
    ElOption
  } from 'element-plus'
  import type { FormInstance, FormRules } from 'element-plus'
  import { updateInvLotApi } from '@/api/inv/lot'
  import { listCompanyApi } from '@/api/company'

  interface Props {
    modelValue: boolean
    lotData?: any
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'success'): void
    (e: 'updateData', data: any): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    lotData: undefined
  })

  const emit = defineEmits<Emits>()

  const visible = computed({
    get: () => props.modelValue,
    set: (value) => emit('update:modelValue', value)
  })

  const formRef = ref<FormInstance>()
  const companyList = ref<any[]>([])

  const rules = reactive<FormRules>({
    code: [{ required: true, message: '请输入批次号', trigger: 'blur' }]
  })

  const form = reactive<any>({
    id: undefined,
    code: '',
    ref: '',
    company_id: undefined,
    item_id: undefined,
    item_name: '',
    product_id: undefined,
    product_name: '',
    qty: 0,
    unit_cost: 0,
    expiration_date: '',
    alert_date: '',
    removal_date: '',
    order_type: '',
    order_id: undefined,
    order_line_id: undefined,
    user_id: undefined,
    user_name: '',
    description: ''
  })

  // 加载公司列表
  const loadCompanyList = async (): Promise<void> => {
    try {
      const res = await listCompanyApi({})
      companyList.value = (res as any).data || []
    } catch (error) {
      console.error('加载公司列表失败:', error)
    }
  }

  watch(
    () => props.modelValue,
    (newVal) => {
      if (newVal) {
        initForm()
        loadCompanyList()
      }
    },
    { immediate: true }
  )

  watch(
    () => props.lotData,
    (newData) => {
      if (newData && props.modelValue) {
        initForm()
      }
    },
    { deep: true }
  )

  const initForm = () => {
    if (props.lotData) {
      Object.assign(form, {
        ...props.lotData
      })
    } else {
      Object.assign(form, {
        id: undefined,
        code: '',
        ref: '',
        company_id: undefined,
        item_id: undefined,
        item_name: '',
        product_id: undefined,
        product_name: '',
        qty: 0,
        unit_cost: 0,
        expiration_date: '',
        alert_date: '',
        removal_date: '',
        order_type: '',
        order_id: undefined,
        order_line_id: undefined,
        user_id: undefined,
        user_name: '',
        description: ''
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
      // 只提交允许修改的字段
      const submitData = {
        code: form.code,
        ref: form.ref,
        company_id: form.company_id,
        description: form.description
      }

      const res = await updateInvLotApi(String(form.id), submitData)
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
