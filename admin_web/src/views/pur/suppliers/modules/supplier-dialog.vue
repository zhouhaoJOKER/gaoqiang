<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="700px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <div class="supplier-dialog">
      <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px">
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="供应商编号" prop="code">
              <ElInput
                v-model="form.code"
                placeholder="请输入供应商编号"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="供应商名称" prop="name">
              <ElInput
                v-model="form.name"
                placeholder="请输入供应商名称"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="简称" prop="abbr">
              <ElInput v-model="form.abbr" placeholder="请输入简称" :readonly="props.readonly" />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="24">
            <ElFormItem label="资质说明" prop="qual_notes">
              <ElInput
                v-model="form.qual_notes"
                type="textarea"
                :rows="2"
                placeholder="请输入资质说明"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="24">
            <ElFormItem label="备注" prop="remark">
              <ElInput
                v-model="form.remark"
                type="textarea"
                :rows="3"
                placeholder="请输入备注"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow v-if="props.readonly" :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="拼音">
              <ElInput v-model="form.py" readonly placeholder="-" />
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
          <ElButton type="primary" @click="handleSave">{{ isEditMode ? '保存' : '保存' }}</ElButton>
        </template>
      </div>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, reactive, computed, watch } from 'vue'
  import { ElMessage } from 'element-plus'
  import type { FormInstance, FormRules } from 'element-plus'
  import { ElDialog, ElForm, ElFormItem, ElInput, ElButton, ElRow, ElCol } from 'element-plus'
  import {
    createPurSupplierApi,
    updatePurSupplierApi,
    viewPurSupplierApi
  } from '@/api/pur/supplier'

  interface Props {
    modelValue: boolean
    supplier?: any
    readonly?: boolean
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', supplier: any): void
    (e: 'updated', supplier: any): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    supplier: undefined,
    readonly: false
  })

  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const isEditMode = computed(() => !!props.supplier && !!props.supplier.id)

  const dialogTitle = computed(() => {
    if (props.readonly) return '查看供应商'
    return isEditMode.value ? '编辑供应商' : '创建供应商'
  })

  const formRef = ref<FormInstance>()

  const rules = reactive<FormRules>({
    name: [{ required: true, message: '请输入供应商名称', trigger: 'blur' }],
    code: [{ required: true, message: '请输入供应商编号', trigger: 'blur' }]
  })

  const form = reactive({
    id: undefined as string | number | undefined,
    code: '',
    name: '',
    abbr: '',
    qual_notes: '',
    remark: '',
    py: ''
  })

  const loadDetail = async (): Promise<void> => {
    if (!props.supplier?.id) return
    try {
      const res = await viewPurSupplierApi({ id: props.supplier.id })
      const d = (res as any).data || {}
      Object.assign(form, {
        id: d.id,
        code: d.code || '',
        name: d.name || '',
        abbr: d.abbr || '',
        qual_notes: d.qual_notes || '',
        remark: d.remark || '',
        py: d.py || ''
      })
    } catch (e) {
      console.error('加载供应商详情失败', e)
      ElMessage.error('加载供应商详情失败')
    }
  }

  const handleSave = async (): Promise<void> => {
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
        abbr: form.abbr || undefined,
        qual_notes: form.qual_notes || undefined,
        remark: form.remark || undefined
      }
      if (isEditMode.value) {
        const res = await updatePurSupplierApi(form.id as string | number, params)
        ElMessage.success('更新成功')
        emit('updated', (res as any).data || { ...props.supplier, ...params })
        dialogVisible.value = false
      } else {
        const res = await createPurSupplierApi(params)
        ElMessage.success('创建成功')
        emit('created', (res as any).data)
        dialogVisible.value = false
      }
    } catch {
      // validate failed
    }
  }

  const handleSaveAndNew = async (): Promise<void> => {
    if (!formRef.value) return
    try {
      await formRef.value.validate()
      const params: any = {
        code: form.code,
        name: form.name,
        abbr: form.abbr || undefined,
        qual_notes: form.qual_notes || undefined,
        remark: form.remark || undefined
      }
      const res = await createPurSupplierApi(params)
      ElMessage.success('创建成功')
      emit('created', (res as any).data)
      Object.assign(form, {
        id: undefined,
        code: '',
        name: '',
        abbr: '',
        qual_notes: '',
        remark: '',
        py: ''
      })
      formRef.value?.resetFields()
    } catch {
      /* empty */
    }
  }

  const handleCancel = (): void => {
    dialogVisible.value = false
  }

  const handleClosed = (): void => {
    Object.assign(form, {
      id: undefined,
      code: '',
      name: '',
      abbr: '',
      qual_notes: '',
      remark: '',
      py: ''
    })
    formRef.value?.resetFields()
  }

  watch(
    () => props.modelValue,
    async (val) => {
      if (val && isEditMode.value) await loadDetail()
    }
  )

  watch(
    () => props.supplier,
    async () => {
      if (props.modelValue && isEditMode.value) await loadDetail()
    },
    { deep: true }
  )
</script>

<style scoped lang="scss">
  .supplier-dialog .dialog-footer {
    display: flex;
    gap: 12px;
    justify-content: flex-end;
  }
</style>
