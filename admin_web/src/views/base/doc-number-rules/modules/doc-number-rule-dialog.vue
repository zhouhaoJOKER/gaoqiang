<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="560px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px">
      <ElFormItem label="标识(key)" prop="key">
        <ElInput
          v-model="form.key"
          placeholder="如 crm_handovers、fm_contracts"
          :readonly="!!props.rule?.id"
        />
      </ElFormItem>
      <ElFormItem label="规则名称" prop="name">
        <ElInput v-model="form.name" placeholder="用于展示" />
      </ElFormItem>
      <ElFormItem label="格式模板" prop="format">
        <ElInput
          v-model="form.format"
          placeholder="如 JH-{YYMMDD}-{seq:4}"
          type="textarea"
          :rows="2"
        />
        <div class="format-hint"> 占位符：{YYYYMMDD}、{YYMMDD}、{seq}、{seq:4} 等 </div>
      </ElFormItem>
      <ElFormItem label="重置周期" prop="reset_period">
        <ElSelect v-model="form.reset_period" placeholder="请选择" style="width: 100%">
          <ElOption label="不重置" value="none" />
          <ElOption label="按日" value="day" />
          <ElOption label="按月" value="month" />
          <ElOption label="按年" value="year" />
        </ElSelect>
      </ElFormItem>
      <ElFormItem v-if="props.rule?.id" label="当前序列" prop="current_sequence">
        <ElInput v-model.number="form.current_sequence" type="number" placeholder="0" />
      </ElFormItem>
      <ElFormItem v-if="props.rule?.id" label="预览下一个">
        <ElButton :loading="previewLoading" @click="handlePreview">
          {{ previewCode || '点击预览' }}
        </ElButton>
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
  import { ElDialog, ElForm, ElFormItem, ElInput, ElSelect, ElOption, ElButton } from 'element-plus'
  import {
    createDocNumberRuleApi,
    updateDocNumberRuleApi,
    viewDocNumberRuleApi,
    previewDocNumberApi
  } from '@/api/doc-number'

  interface Props {
    modelValue: boolean
    rule?: any
  }
  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    rule: undefined
  })
  const emit = defineEmits<{
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', rule: any): void
    (e: 'updated', rule: any): void
  }>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })
  const isEdit = computed(() => !!props.rule?.id)
  const dialogTitle = computed(() => (isEdit.value ? '编辑单号规则' : '新增单号规则'))

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    key: [{ required: true, message: '请输入标识', trigger: 'blur' }],
    name: [{ required: true, message: '请输入规则名称', trigger: 'blur' }],
    format: [{ required: true, message: '请输入格式模板', trigger: 'blur' }]
  })

  const form = reactive({
    id: undefined as string | number | undefined,
    key: '',
    name: '',
    format: '',
    reset_period: 'day' as string,
    current_sequence: 0 as number
  })

  const previewLoading = ref(false)
  const previewCode = ref('')

  const loadDetail = async () => {
    if (!props.rule?.id) return
    try {
      const res = await viewDocNumberRuleApi({ id: props.rule.id })
      const d = (res as any).data || {}
      Object.assign(form, {
        id: d.id,
        key: d.key || '',
        name: d.name || '',
        format: d.format || '',
        reset_period: d.reset_period || 'day',
        current_sequence: d.current_sequence ?? 0
      })
    } catch {
      ElMessage.error('加载失败')
    }
  }

  const handlePreview = async () => {
    if (!form.key?.trim()) {
      ElMessage.warning('请先填写标识')
      return
    }
    previewLoading.value = true
    previewCode.value = ''
    try {
      const res = await previewDocNumberApi(form.key.trim())
      const d = (res as any).data || {}
      previewCode.value = d.code || '-'
    } catch {
      previewCode.value = '预览失败'
    } finally {
      previewLoading.value = false
    }
  }

  const handleSave = async () => {
    if (!formRef.value) return
    try {
      await formRef.value.validate()
      const params: any = {
        key: form.key.trim(),
        name: form.name.trim(),
        format: form.format.trim(),
        reset_period: form.reset_period || 'day'
      }
      if (isEdit.value) {
        params.current_sequence = form.current_sequence
        await updateDocNumberRuleApi(String(form.id), params)
        ElMessage.success('更新成功')
        emit('updated', params)
      } else {
        await createDocNumberRuleApi(params)
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
      key: '',
      name: '',
      format: '',
      reset_period: 'day',
      current_sequence: 0
    })
    previewCode.value = ''
    formRef.value?.resetFields()
  }

  /** 克隆模式：rule 有数据但无 id 时，直接用于初始化表单 */
  const initFormFromRule = () => {
    const r = props.rule
    if (!r) return
    Object.assign(form, {
      id: undefined,
      key: r.key || '',
      name: r.name || '',
      format: r.format || '',
      reset_period: r.reset_period || 'day',
      current_sequence: r.current_sequence ?? 0
    })
  }

  watch(
    () => props.modelValue,
    (val) => {
      if (val) {
        if (isEdit.value) loadDetail()
        else if (props.rule?.key) initFormFromRule()
        else {
          Object.assign(form, {
            id: undefined,
            key: '',
            name: '',
            format: '',
            reset_period: 'day',
            current_sequence: 0
          })
          previewCode.value = ''
        }
      }
    }
  )
  watch(
    () => props.rule,
    () => {
      if (props.modelValue) {
        if (isEdit.value) loadDetail()
        else if (props.rule?.key) initFormFromRule()
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
