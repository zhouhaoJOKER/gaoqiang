<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="500px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <ElForm ref="formRef" :model="form" :rules="rules" label-width="100px">
      <ElFormItem label="行政区划码" prop="code">
        <ElInput v-model="form.code" placeholder="行政区划码（唯一）" :readonly="props.readonly" />
      </ElFormItem>
      <ElFormItem label="省名称" prop="name">
        <ElInput v-model="form.name" placeholder="请输入省名称" :readonly="props.readonly" />
      </ElFormItem>
      <ElFormItem label="拼音/检索" prop="py">
        <ElInput v-model="form.py" placeholder="拼音或检索" :readonly="props.readonly" />
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
  import { ElDialog, ElForm, ElFormItem, ElInput, ElButton } from 'element-plus'
  import { createProvinceApi, updateProvinceApi, viewProvinceApi } from '@/api/province'

  interface Props {
    modelValue: boolean
    province?: any
    readonly?: boolean
  }
  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    province: undefined,
    readonly: false
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
  const isEdit = computed(() => !!props.province?.id)
  const dialogTitle = computed(() => (isEdit.value ? '编辑省' : '新增省'))

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    name: [{ required: true, message: '请输入省名称', trigger: 'blur' }]
  })
  const form = reactive({ id: undefined as any, code: '', name: '', py: '' })

  const loadDetail = async () => {
    if (!props.province?.id) return
    try {
      const res = await viewProvinceApi({ id: props.province.id })
      const d = (res as any).data || {}
      Object.assign(form, { id: d.id, code: d.code ?? '', name: d.name ?? '', py: d.py ?? '' })
    } catch {
      ElMessage.error('加载失败')
    }
  }

  const handleSave = async () => {
    if (!formRef.value) return
    try {
      await formRef.value.validate()
      const params: any = {
        code: form.code || undefined,
        name: form.name,
        py: form.py || undefined
      }
      if (isEdit.value) {
        await updateProvinceApi(String(form.id), params)
        ElMessage.success('更新成功')
        emit('updated', { ...props.province, ...params })
      } else {
        const res = await createProvinceApi(params)
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
    Object.assign(form, { id: undefined, code: '', name: '', py: '' })
    formRef.value?.resetFields()
  }

  watch(
    () => props.modelValue,
    (v) => {
      if (v && isEdit.value) loadDetail()
      else if (v && !isEdit.value)
        Object.assign(form, { id: undefined, code: '', name: '', py: '' })
    }
  )
</script>
