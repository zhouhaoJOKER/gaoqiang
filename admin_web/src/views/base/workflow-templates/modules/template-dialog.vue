<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="560px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <ElForm ref="formRef" :model="form" :rules="rules" label-width="100px">
      <ElFormItem label="模板编码" prop="code">
        <ElInput
          v-model="form.code"
          placeholder="如 contract_full、contract_simple"
          :readonly="!!props.template?.id"
        />
      </ElFormItem>
      <ElFormItem label="模板名称" prop="name">
        <ElInput v-model="form.name" placeholder="如 订购合同全流程" />
      </ElFormItem>
      <ElFormItem label="描述" prop="description">
        <ElInput
          v-model="form.description"
          type="textarea"
          :rows="2"
          placeholder="流程描述（可选）"
        />
      </ElFormItem>
      <ElFormItem label="主流程节点" prop="main_step_keys">
        <ElInput
          v-model="mainStepKeysStr"
          type="textarea"
          :rows="2"
          placeholder="主流程节点 key 顺序，逗号分隔，如 order,formula,purchase,..."
        />
        <div class="format-hint">用于步骤条展示，填写节点 key，逗号分隔</div>
      </ElFormItem>
      <ElFormItem label="默认模板" prop="is_default">
        <ElSwitch v-model="form.is_default" />
      </ElFormItem>
      <ElFormItem label="启用" prop="is_active">
        <ElSwitch v-model="form.is_active" />
      </ElFormItem>
      <ElFormItem label="排序" prop="sort">
        <ElInputNumber v-model="form.sort" :min="0" style="width: 120px" />
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
    ElInputNumber,
    ElSwitch,
    ElButton
  } from 'element-plus'
  import {
    createWorkflowTemplateApi,
    updateWorkflowTemplateApi,
    viewWorkflowTemplateApi
  } from '@/api/fm/workflow'

  interface Props {
    modelValue: boolean
    template?: any
  }
  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    template: undefined
  })
  const emit = defineEmits<{
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', template: any): void
    (e: 'updated', template: any): void
  }>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })
  const isEdit = computed(() => !!props.template?.id)
  const dialogTitle = computed(() => (isEdit.value ? '编辑流程模板' : '新增流程模板'))

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    code: [{ required: true, message: '请输入模板编码', trigger: 'blur' }],
    name: [{ required: true, message: '请输入模板名称', trigger: 'blur' }]
  })

  const form = reactive({
    id: undefined as string | number | undefined,
    code: '',
    name: '',
    description: '',
    main_step_keys: [] as string[],
    is_default: false,
    is_active: true,
    sort: 0
  })

  const mainStepKeysStr = computed({
    get: () => (Array.isArray(form.main_step_keys) ? form.main_step_keys.join(',') : ''),
    set: (val: string) => {
      form.main_step_keys = val
        ? val
            .split(/[,，\s]+/)
            .map((s) => s.trim())
            .filter(Boolean)
        : []
    }
  })

  const loadDetail = async () => {
    if (!props.template?.id) return
    try {
      const res = await viewWorkflowTemplateApi({ id: props.template.id })
      const d = (res as any).data || {}
      const template = d.template || d
      Object.assign(form, {
        id: template.id,
        code: template.code || '',
        name: template.name || '',
        description: template.description || '',
        main_step_keys: template.main_step_keys || [],
        is_default: !!template.is_default,
        is_active: template.is_active !== false,
        sort: template.sort ?? 0
      })
    } catch {
      ElMessage.error('加载失败')
    }
  }

  const handleSave = async () => {
    if (!formRef.value) return
    try {
      await formRef.value.validate()
      const params: any = {
        code: form.code.trim(),
        name: form.name.trim(),
        description: form.description?.trim() || '',
        main_step_keys: form.main_step_keys,
        is_default: form.is_default,
        is_active: form.is_active,
        sort: form.sort ?? 0
      }
      if (isEdit.value) {
        await updateWorkflowTemplateApi(String(form.id), params)
        ElMessage.success('更新成功')
        emit('updated', params)
      } else {
        await createWorkflowTemplateApi(params)
        ElMessage.success('创建成功')
        emit('created', params)
      }
      dialogVisible.value = false
    } catch {
      /* validation failed */
    }
  }

  const handleCancel = () => {
    dialogVisible.value = false
  }
  const handleClosed = () => {
    Object.assign(form, {
      id: undefined,
      code: '',
      name: '',
      description: '',
      main_step_keys: [],
      is_default: false,
      is_active: true,
      sort: 0
    })
    formRef.value?.resetFields()
  }

  const initFormFromTemplate = () => {
    const t = props.template
    if (!t) return
    Object.assign(form, {
      id: undefined,
      code: t.code || '',
      name: t.name || '',
      description: t.description || '',
      main_step_keys: t.main_step_keys || [],
      is_default: false,
      is_active: t.is_active !== false,
      sort: t.sort ?? 0
    })
  }

  watch(
    () => props.modelValue,
    (val) => {
      if (val) {
        if (isEdit.value) loadDetail()
        else if (props.template?.code) initFormFromTemplate()
        else {
          Object.assign(form, {
            id: undefined,
            code: '',
            name: '',
            description: '',
            main_step_keys: [],
            is_default: false,
            is_active: true,
            sort: 0
          })
        }
      }
    }
  )
  watch(
    () => props.template,
    () => {
      if (props.modelValue) {
        if (isEdit.value) loadDetail()
        else if (props.template?.code) initFormFromTemplate()
      }
    },
    { deep: true }
  )
</script>

<style scoped>
  .format-hint {
    margin-top: 4px;
    font-size: 12px;
    color: var(--el-text-color-secondary);
  }
</style>
