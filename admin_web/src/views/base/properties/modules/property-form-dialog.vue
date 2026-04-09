<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="520px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <ElForm ref="formRef" :model="form" :rules="rules" label-width="100px">
      <ElFormItem label="标识(sign)" prop="sign">
        <ElInput
          v-model="form.sign"
          placeholder="如 product_uom"
          :readonly="!!props.property?.id"
        />
      </ElFormItem>
      <ElFormItem label="父级" prop="parent_id">
        <ElSelect
          v-model="form.parent_id"
          placeholder="可选"
          clearable
          filterable
          style="width: 100%"
        >
          <ElOption v-for="p in parentOptions" :key="p.id" :label="p.name" :value="p.id" />
        </ElSelect>
      </ElFormItem>
      <ElFormItem label="名称" prop="name">
        <ElInput v-model="form.name" placeholder="属性名称" />
      </ElFormItem>
      <ElFormItem label="缩写" prop="abbr">
        <ElInput v-model="form.abbr" placeholder="缩写" />
      </ElFormItem>
      <ElFormItem label="拼音/检索" prop="py">
        <ElInput v-model="form.py" placeholder="拼音或检索" />
      </ElFormItem>
      <ElFormItem label="排序" prop="sort">
        <ElInput v-model.number="form.sort" type="number" placeholder="0" />
      </ElFormItem>
      <ElFormItem label="颜色" prop="color">
        <ElSelect v-model="form.color" placeholder="可选" clearable style="width: 100%">
          <ElOption v-for="t in colorTokens" :key="t" :label="t" :value="t" />
        </ElSelect>
      </ElFormItem>
      <ElFormItem label="启用" prop="is_open">
        <ElSwitch v-model="form.is_open" />
      </ElFormItem>
    </ElForm>
    <template #footer>
      <ElButton @click="handleCancel">取消</ElButton>
      <ElButton type="primary" @click="handleSave">保存</ElButton>
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
    ElSwitch,
    ElButton
  } from 'element-plus'
  import {
    listPropertyApi,
    createPropertyApi,
    updatePropertyApi,
    viewPropertyApi
  } from '@/api/property'

  const colorTokens = [
    'primary',
    'success',
    'warning',
    'danger',
    'info',
    'primary-light-3',
    'success-light-3',
    'warning-light-3',
    'danger-light-3',
    'info-light-3'
  ]

  interface Props {
    modelValue: boolean
    sign?: string
    property?: any
  }
  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    sign: '',
    property: undefined
  })
  const emit = defineEmits<{
    (e: 'update:modelValue', v: boolean): void
    (e: 'created', p: any): void
    (e: 'updated', p: any): void
  }>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (v) => emit('update:modelValue', v)
  })
  const isEdit = computed(() => !!props.property?.id)
  const dialogTitle = computed(() => (isEdit.value ? '编辑属性' : '新增属性'))

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    sign: [{ required: true, message: '请输入标识', trigger: 'blur' }],
    name: [{ required: true, message: '请输入名称', trigger: 'blur' }]
  })
  const form = reactive({
    id: undefined as any,
    sign: '',
    parent_id: undefined as any,
    name: '',
    abbr: '',
    py: '',
    sort: 0,
    color: '',
    is_open: true
  })
  const parentOptions = ref<any[]>([])

  const loadParents = async (sign: string) => {
    if (!sign) {
      parentOptions.value = []
      return
    }
    try {
      const res = await listPropertyApi({ 'q[sign_eq]': sign, per_page: 500 })
      const data = (res as any).data || []
      const list = Array.isArray(data) ? data : data.list || data.data || []
      parentOptions.value = list.filter(
        (p: any) => !isEdit.value || Number(p.id) !== Number(form.id)
      )
    } catch {
      parentOptions.value = []
    }
  }

  const loadDetail = async () => {
    if (!props.property?.id) return
    try {
      const res = await viewPropertyApi({ id: props.property.id })
      const d = (res as any).data || {}
      Object.assign(form, {
        id: d.id,
        sign: d.sign ?? '',
        parent_id: d.parent_id ?? undefined,
        name: d.name ?? '',
        abbr: d.abbr ?? '',
        py: d.py ?? '',
        sort: d.sort ?? 0,
        color: d.color ?? '',
        is_open: d.is_open !== false
      })
      await loadParents(form.sign)
    } catch {
      ElMessage.error('加载失败')
    }
  }

  const handleSave = async () => {
    if (!formRef.value) return
    try {
      await formRef.value.validate()
      const params: any = {
        sign: form.sign,
        parent_id: form.parent_id ?? undefined,
        name: form.name,
        abbr: form.abbr || undefined,
        py: form.py || undefined,
        sort: Number(form.sort) || 0,
        color: form.color || undefined,
        is_open: form.is_open
      }
      if (isEdit.value) {
        await updatePropertyApi(String(form.id), params)
        ElMessage.success('更新成功')
        emit('updated', { ...props.property, ...params })
      } else {
        const res = await createPropertyApi(params)
        ElMessage.success('创建成功')
        emit('created', (res as any).data)
      }
      dialogVisible.value = false
    } catch {
      /* empty */
    }
  }
  const handleCancel = () => {
    dialogVisible.value = false
  }
  const handleClosed = () => {
    Object.assign(form, {
      id: undefined,
      sign: '',
      parent_id: undefined,
      name: '',
      abbr: '',
      py: '',
      sort: 0,
      color: '',
      is_open: true
    })
    parentOptions.value = []
    formRef.value?.resetFields()
  }

  watch(
    () => props.modelValue,
    async (v) => {
      if (v) {
        if (isEdit.value) await loadDetail()
        else {
          form.sign = props.sign || ''
          await loadParents(form.sign)
        }
      }
    }
  )
</script>
