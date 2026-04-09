<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="800px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <div class="bom-loss-dialog">
      <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px">
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="BOM明细行" prop="bom_line_id">
              <ElInput
                v-model="form.bom_line_id"
                type="number"
                placeholder="请输入BOM明细行ID"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="损耗模式" prop="loss_mode">
              <ElSelect
                v-model="form.loss_mode"
                placeholder="请选择损耗模式"
                style="width: 100%"
                :disabled="props.readonly"
              >
                <ElOption label="百分比" value="percent" />
                <ElOption label="固定值" value="fixed" />
              </ElSelect>
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="损耗值" prop="loss_value">
              <ElInput
                v-model="form.loss_value"
                type="number"
                placeholder="0.00"
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
    ElCol
  } from 'element-plus'
  import { createMfgBomLossApi, updateMfgBomLossApi, viewMfgBomLossApi } from '@/api/mfg/bom'

  interface Props {
    modelValue: boolean
    bomLoss?: any
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
    if (props.readonly) return '查看BOM损耗'
    return props.bomLoss?.id ? '编辑BOM损耗' : '新建BOM损耗'
  })

  const isEditMode = computed(() => !!props.bomLoss?.id)

  const formRef = ref<FormInstance>()
  const form = reactive({
    id: undefined,
    bom_line_id: undefined,
    loss_mode: 'percent',
    loss_value: ''
  })

  const rules: FormRules = {
    bom_line_id: [{ required: true, message: '请输入BOM明细行ID', trigger: 'blur' }],
    loss_mode: [{ required: true, message: '请选择损耗模式', trigger: 'change' }],
    loss_value: [{ required: true, message: '请输入损耗值', trigger: 'blur' }]
  }

  const loadBomLoss = async () => {
    if (!props.bomLoss?.id) {
      Object.assign(form, {
        id: undefined,
        bom_line_id: undefined,
        loss_mode: 'percent',
        loss_value: ''
      })
      return
    }
    try {
      const res = await viewMfgBomLossApi({ id: props.bomLoss.id })
      const data = (res as any).data || {}
      Object.assign(form, {
        id: data.id,
        bom_line_id: data.bom_line_id,
        loss_mode: data.loss_mode || 'percent',
        loss_value: data.loss_value || ''
      })
    } catch (error) {
      console.error('加载BOM损耗失败:', error)
      ElMessage.error('加载失败')
    }
  }

  watch(
    () => props.modelValue,
    (val) => {
      if (val) {
        loadBomLoss()
      }
    },
    { immediate: true }
  )

  watch(
    () => props.bomLoss,
    () => {
      if (props.modelValue) {
        loadBomLoss()
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
      bom_line_id: undefined,
      loss_mode: 'percent',
      loss_value: ''
    })
  }

  const handleSave = async () => {
    if (!formRef.value) return
    await formRef.value.validate()
    try {
      const params: any = {
        bom_line_id: form.bom_line_id ? Number(form.bom_line_id) : undefined,
        loss_mode: form.loss_mode,
        loss_value: form.loss_value ? Number(form.loss_value) : 0
      }
      if (isEditMode.value) {
        const res = await updateMfgBomLossApi(String(form.id), params)
        ElMessage.success('更新成功')
        emit('updated', (res as any).data)
        dialogVisible.value = false
      } else {
        const res = await createMfgBomLossApi(params)
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
        bom_line_id: form.bom_line_id ? Number(form.bom_line_id) : undefined,
        loss_mode: form.loss_mode,
        loss_value: form.loss_value ? Number(form.loss_value) : 0
      }
      const res = await createMfgBomLossApi(params)
      ElMessage.success('创建成功')
      emit('created', (res as any).data)
      // 重置表单，保持弹窗打开
      Object.assign(form, {
        id: undefined,
        bom_line_id: undefined,
        loss_mode: 'percent',
        loss_value: ''
      })
      formRef.value?.resetFields()
    } catch (error: any) {
      console.error('保存失败:', error)
      ElMessage.error(error?.message || '保存失败')
    }
  }
</script>

<style scoped>
  .bom-loss-dialog {
    padding: 20px 0;
  }
</style>
