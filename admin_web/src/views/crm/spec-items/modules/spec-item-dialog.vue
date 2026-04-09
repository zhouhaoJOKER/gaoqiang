<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="600px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px">
      <ElRow :gutter="20">
        <ElCol :span="12">
          <ElFormItem label="项目编号" prop="code">
            <ElInput v-model="form.code" placeholder="请输入项目编号" :readonly="props.readonly" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="项目名称" prop="name">
            <ElInput v-model="form.name" placeholder="请输入项目名称" :readonly="props.readonly" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="英文名称" prop="name_en">
            <ElInput
              v-model="form.name_en"
              placeholder="请输入英文名称"
              :readonly="props.readonly"
            />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="排序" prop="sort">
            <ElInput v-model="form.sort" type="number" placeholder="0" :readonly="props.readonly" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="24">
          <ElFormItem label="备注" prop="remark">
            <ElInput
              v-model="form.remark"
              type="textarea"
              :rows="2"
              placeholder="请输入备注"
              :readonly="props.readonly"
            />
          </ElFormItem>
        </ElCol>
      </ElRow>
    </ElForm>
    <template #footer>
      <ElButton @click="handleCancel">{{ props.readonly ? '关闭' : '取消' }}</ElButton>
      <template v-if="!props.readonly">
        <ElButton v-if="!isEditMode" type="primary" @click="handleSaveAndNew">保存并新建</ElButton>
        <ElButton type="primary" @click="handleSave">保存</ElButton>
      </template>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, reactive, computed, watch } from 'vue'
  import { ElMessage } from 'element-plus'
  import type { FormInstance, FormRules } from 'element-plus'
  import { ElDialog, ElForm, ElFormItem, ElInput, ElButton, ElRow, ElCol } from 'element-plus'
  import {
    createCrmSpecItemApi,
    updateCrmSpecItemApi,
    viewCrmSpecItemApi
  } from '@/api/crm/spec-item'

  interface Props {
    modelValue: boolean
    specItem?: any
    readonly?: boolean
  }
  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', specItem: any): void
    (e: 'updated', specItem: any): void
  }
  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    specItem: undefined,
    readonly: false
  })
  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })
  const isEditMode = computed(() => !!props.specItem?.id)
  const dialogTitle = computed(() =>
    props.readonly ? '查看指标项目' : isEditMode.value ? '编辑指标项目' : '创建指标项目'
  )

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    code: [{ required: true, message: '请输入项目编号', trigger: 'blur' }],
    name: [{ required: true, message: '请输入项目名称', trigger: 'blur' }]
  })

  const form = reactive({
    id: undefined as string | number | undefined,
    code: '',
    name: '',
    name_en: '',
    sort: 0,
    remark: ''
  })

  const loadDetail = async () => {
    if (!props.specItem?.id) return
    try {
      const res = await viewCrmSpecItemApi({ id: props.specItem.id })
      const d = (res as any).data || {}
      Object.assign(form, {
        id: d.id,
        code: d.code || '',
        name: d.name || '',
        name_en: d.name_en || '',
        sort: d.sort ?? 0,
        remark: d.remark || ''
      })
    } catch {
      ElMessage.error('加载详情失败')
    }
  }

  const handleSave = async () => {
    if (props.readonly) {
      handleCancel()
      return
    }
    if (!formRef.value) return
    try {
      await formRef.value.validate()
      const params: any = {
        code: form.code,
        name: form.name,
        name_en: form.name_en || undefined,
        sort: Number(form.sort) || 0,
        remark: form.remark || undefined
      }
      if (isEditMode.value) {
        await updateCrmSpecItemApi(String(form.id), params)
        ElMessage.success('更新成功')
        emit('updated', { ...props.specItem, ...params })
        dialogVisible.value = false
      } else {
        const res = await createCrmSpecItemApi(params)
        ElMessage.success('创建成功')
        emit('created', (res as any).data)
        dialogVisible.value = false
      }
    } catch {
      /* empty */
    }
  }

  const handleSaveAndNew = async () => {
    if (!formRef.value) return
    try {
      await formRef.value.validate()
      const params: any = {
        code: form.code,
        name: form.name,
        name_en: form.name_en,
        sort: Number(form.sort) || 0,
        remark: form.remark
      }
      const res = await createCrmSpecItemApi(params)
      ElMessage.success('创建成功')
      emit('created', (res as any).data)
      Object.assign(form, { id: undefined, code: '', name: '', name_en: '', sort: 0, remark: '' })
      formRef.value?.resetFields()
    } catch {
      /* empty */
    }
  }

  const handleCancel = () => {
    dialogVisible.value = false
  }
  const handleClosed = () => {
    Object.assign(form, { id: undefined, code: '', name: '', name_en: '', sort: 0, remark: '' })
    formRef.value?.resetFields()
  }

  watch(
    () => props.modelValue,
    async (val) => {
      if (val && isEditMode.value) await loadDetail()
    }
  )
  watch(
    () => props.specItem,
    async () => {
      if (props.modelValue && isEditMode.value) await loadDetail()
    },
    { deep: true }
  )
</script>
