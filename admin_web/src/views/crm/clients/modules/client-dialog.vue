<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="800px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <div class="client-dialog">
      <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px">
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="父级客户" prop="parent_id">
              <ElSelect
                v-model="form.parent_id"
                placeholder="请选择父级客户（可选）"
                filterable
                remote
                :remote-method="searchClients"
                :loading="clientSearchLoading"
                clearable
                style="width: 100%"
                :disabled="props.readonly"
              >
                <ElOption
                  v-for="c in clientOptions"
                  :key="c.id"
                  :label="`[${c.code || ''}] ${c.name}`"
                  :value="c.id"
                />
              </ElSelect>
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="客户编号" prop="code">
              <ElInput
                v-model="form.code"
                placeholder="请输入客户编号"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="客户名称" prop="name">
              <ElInput
                v-model="form.name"
                placeholder="请输入客户名称"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="简称" prop="abbr">
              <ElInput v-model="form.abbr" placeholder="请输入简称" :readonly="props.readonly" />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="结算方式" prop="settlement_id">
              <PropertySelectWithAdd
                v-model="form.settlement_id"
                sign="crm_settlement"
                placeholder="请选择结算方式"
                :disabled="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="默认发票类型" prop="invoice_type_id">
              <PropertySelectWithAdd
                v-model="form.invoice_type_id"
                sign="crm_invoice_type"
                placeholder="请选择发票类型"
                :disabled="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElRow :gutter="20">
          <ElCol :span="24">
            <ElFormItem label="付款条款" prop="payment_terms">
              <ElInput
                v-model="form.payment_terms"
                type="textarea"
                :rows="2"
                placeholder="请输入付款条款"
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
  import { createCrmClientApi, updateCrmClientApi, viewCrmClientApi } from '@/api/crm/client'
  import { listCrmClientApi } from '@/api/crm/client'
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'

  interface Props {
    modelValue: boolean
    client?: any
    readonly?: boolean
  }

  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', client: any): void
    (e: 'updated', client: any): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    client: undefined,
    readonly: false
  })

  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })

  const isEditMode = computed(() => !!props.client && !!props.client.id)

  const dialogTitle = computed(() => {
    if (props.readonly) return '查看客户'
    return isEditMode.value ? '编辑客户' : '创建客户'
  })

  const formRef = ref<FormInstance>()

  const rules = reactive<FormRules>({
    name: [{ required: true, message: '请输入客户名称', trigger: 'blur' }],
    code: [{ required: true, message: '请输入客户编号', trigger: 'blur' }]
  })

  const form = reactive({
    id: undefined as string | number | undefined,
    parent_id: undefined as string | number | null | undefined,
    code: '',
    name: '',
    abbr: '',
    settlement_id: null as string | number | null,
    payment_terms: '',
    invoice_type_id: null as string | number | null,
    remark: '',
    py: ''
  })

  const clientOptions = ref<any[]>([])
  const clientSearchLoading = ref(false)

  const searchClients = async (query: string): Promise<void> => {
    clientSearchLoading.value = true
    try {
      const res = await listCrmClientApi({
        'q[name_or_code_or_abbr_cont]': query || '',
        per_page: 50
      })
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      clientOptions.value = arr.filter((c: any) => c && c.id != null)
      if (form.id && form.parent_id) {
        const exists = clientOptions.value.find((c: any) => Number(c.id) === Number(form.parent_id))
        if (!exists) {
          const viewRes = await viewCrmClientApi({ id: form.parent_id })
          const parent = (viewRes as any).data
          if (parent) clientOptions.value = [parent, ...clientOptions.value]
        }
      }
    } catch (e) {
      console.error('搜索客户失败', e)
    } finally {
      clientSearchLoading.value = false
    }
  }

  const loadClientDetail = async (): Promise<void> => {
    if (!props.client?.id) return
    try {
      const res = await viewCrmClientApi({ id: props.client.id })
      const d = (res as any).data || {}
      Object.assign(form, {
        id: d.id,
        parent_id: d.parent_id ?? null,
        code: d.code || '',
        name: d.name || '',
        abbr: d.abbr || '',
        settlement_id: d.settlement_id ?? null,
        payment_terms: d.payment_terms || '',
        invoice_type_id: d.invoice_type_id ?? null,
        remark: d.remark || '',
        py: d.py || ''
      })
      if (form.parent_id) await searchClients('')
    } catch (e) {
      console.error('加载客户详情失败', e)
      ElMessage.error('加载客户详情失败')
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
        parent_id: form.parent_id || undefined,
        code: form.code,
        name: form.name,
        abbr: form.abbr || undefined,
        settlement_id: form.settlement_id ?? undefined,
        payment_terms: form.payment_terms || undefined,
        invoice_type_id: form.invoice_type_id ?? undefined,
        remark: form.remark || undefined
      }
      if (isEditMode.value) {
        const res = await updateCrmClientApi(String(form.id), params)
        ElMessage.success('更新成功')
        emit('updated', (res as any).data || { ...props.client, ...params })
        dialogVisible.value = false
      } else {
        const res = await createCrmClientApi(params)
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
        parent_id: form.parent_id || undefined,
        code: form.code,
        name: form.name,
        abbr: form.abbr || undefined,
        settlement_id: form.settlement_id ?? undefined,
        payment_terms: form.payment_terms || undefined,
        invoice_type_id: form.invoice_type_id ?? undefined,
        remark: form.remark || undefined
      }
      const res = await createCrmClientApi(params)
      ElMessage.success('创建成功')
      emit('created', (res as any).data)
      Object.assign(form, {
        id: undefined,
        parent_id: undefined,
        code: '',
        name: '',
        abbr: '',
        settlement_id: null,
        payment_terms: '',
        invoice_type_id: null,
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
      parent_id: undefined,
      code: '',
      name: '',
      abbr: '',
      settlement_id: null,
      payment_terms: '',
      invoice_type_id: null,
      remark: '',
      py: ''
    })
    clientOptions.value = []
    formRef.value?.resetFields()
  }

  watch(
    () => props.modelValue,
    async (val) => {
      if (val) {
        if (isEditMode.value) await loadClientDetail()
        else searchClients('')
      }
    }
  )

  watch(
    () => props.client,
    async () => {
      if (props.modelValue && isEditMode.value) await loadClientDetail()
    },
    { deep: true }
  )
</script>

<style scoped lang="scss">
  .client-dialog .dialog-footer {
    display: flex;
    gap: 12px;
    justify-content: flex-end;
  }
</style>
