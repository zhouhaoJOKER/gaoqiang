<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="700px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px">
      <ElRow :gutter="20">
        <ElCol v-if="!props.fixedClientId" :span="24">
          <ElFormItem label="客户" prop="client_id">
            <ElSelect
              v-model="form.client_id"
              placeholder="请选择客户"
              filterable
              remote
              :remote-method="searchClients"
              :loading="clientSearchLoading"
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
        <ElCol v-if="props.fixedClientId" :span="24">
          <ElFormItem label="客户">
            <span class="text-secondary">{{ clientDisplayName }}</span>
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="联系人姓名" prop="name">
            <ElInput
              v-model="form.name"
              placeholder="请输入联系人姓名"
              :readonly="props.readonly"
            />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="部门" prop="dept">
            <ElInput v-model="form.dept" placeholder="请输入部门" :readonly="props.readonly" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="职务" prop="title">
            <ElInput v-model="form.title" placeholder="请输入职务" :readonly="props.readonly" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="电话" prop="phone">
            <ElInput v-model="form.phone" placeholder="请输入电话" :readonly="props.readonly" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="手机" prop="mobile">
            <ElInput v-model="form.mobile" placeholder="请输入手机" :readonly="props.readonly" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="邮箱" prop="email">
            <ElInput v-model="form.email" placeholder="请输入邮箱" :readonly="props.readonly" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="是否主联系人" prop="is_primary">
            <ElSwitch v-model="form.is_primary" :disabled="props.readonly" />
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
  import {
    ElDialog,
    ElForm,
    ElFormItem,
    ElInput,
    ElSelect,
    ElOption,
    ElButton,
    ElSwitch,
    ElRow,
    ElCol
  } from 'element-plus'
  import { createCrmContactApi, updateCrmContactApi, viewCrmContactApi } from '@/api/crm/contact'
  import { listCrmClientApi, viewCrmClientApi } from '@/api/crm/client'

  interface Props {
    modelValue: boolean
    contact?: any
    readonly?: boolean
    fixedClientId?: string | number
    clientData?: Record<string, any>
  }
  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', contact: any): void
    (e: 'updated', contact: any): void
  }

  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    contact: undefined,
    readonly: false,
    fixedClientId: undefined,
    clientData: undefined
  })
  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })
  const isEditMode = computed(() => !!props.contact?.id)
  const dialogTitle = computed(() =>
    props.readonly ? '查看联系人' : isEditMode.value ? '编辑联系人' : '创建联系人'
  )

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    client_id: [{ required: true, message: '请选择客户', trigger: 'change' }],
    name: [{ required: true, message: '请输入联系人姓名', trigger: 'blur' }]
  })

  const form = reactive({
    id: undefined as string | number | undefined,
    client_id: undefined as string | number | undefined,
    name: '',
    dept: '',
    title: '',
    phone: '',
    mobile: '',
    email: '',
    is_primary: false,
    remark: ''
  })

  const clientOptions = ref<any[]>([])
  const clientSearchLoading = ref(false)

  const clientDisplayName = computed(() => {
    if (props.fixedClientId && props.clientData?.name) return props.clientData.name
    if (props.fixedClientId && props.contact?.client_name) return props.contact.client_name
    const c = clientOptions.value.find((x: any) => Number(x.id) === Number(form.client_id))
    return c ? `[${c.code || ''}] ${c.name}` : '当前客户'
  })

  const searchClients = async (query: string) => {
    clientSearchLoading.value = true
    try {
      const res = await listCrmClientApi({ 'q[name_or_code_cont]': query || '', per_page: 50 })
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      clientOptions.value = arr.filter((c: any) => c && c.id != null)
      if (form.client_id && form.id) {
        const viewRes = await viewCrmClientApi({ id: form.client_id }).catch(() => null)
        const client = viewRes && (viewRes as any).data
        if (
          client &&
          !clientOptions.value.find((c: any) => Number(c.id) === Number(form.client_id))
        )
          clientOptions.value = [client, ...clientOptions.value]
      }
    } finally {
      clientSearchLoading.value = false
    }
  }

  const loadDetail = async () => {
    if (!props.contact?.id) return
    try {
      const res = await viewCrmContactApi({ id: props.contact.id })
      const d = (res as any).data || {}
      Object.assign(form, {
        id: d.id,
        client_id: d.client_id,
        name: d.name || '',
        dept: d.dept || '',
        title: d.title || '',
        phone: d.phone || '',
        mobile: d.mobile || '',
        email: d.email || '',
        is_primary: !!d.is_primary,
        remark: d.remark || ''
      })
      if (form.client_id) await searchClients('')
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
        client_id: form.client_id,
        name: form.name,
        dept: form.dept || undefined,
        title: form.title || undefined,
        phone: form.phone || undefined,
        mobile: form.mobile || undefined,
        email: form.email || undefined,
        is_primary: form.is_primary,
        remark: form.remark || undefined
      }
      if (isEditMode.value) {
        await updateCrmContactApi(String(form.id), params)
        ElMessage.success('更新成功')
        emit('updated', { ...props.contact, ...params })
        dialogVisible.value = false
      } else {
        const res = await createCrmContactApi(params)
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
        client_id: form.client_id,
        name: form.name,
        dept: form.dept,
        title: form.title,
        phone: form.phone,
        mobile: form.mobile,
        email: form.email,
        is_primary: form.is_primary,
        remark: form.remark
      }
      const res = await createCrmContactApi(params)
      ElMessage.success('创建成功')
      emit('created', (res as any).data)
      Object.assign(form, {
        id: undefined,
        client_id: undefined,
        name: '',
        dept: '',
        title: '',
        phone: '',
        mobile: '',
        email: '',
        is_primary: false,
        remark: ''
      })
      formRef.value?.resetFields()
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
      client_id: undefined,
      name: '',
      dept: '',
      title: '',
      phone: '',
      mobile: '',
      email: '',
      is_primary: false,
      remark: ''
    })
    clientOptions.value = []
    formRef.value?.resetFields()
  }

  watch(
    () => props.modelValue,
    async (val) => {
      if (val) {
        if (props.fixedClientId) form.client_id = props.fixedClientId
        if (isEditMode.value) await loadDetail()
        else if (!props.fixedClientId) searchClients('')
      }
    }
  )
  watch(
    () => props.contact,
    async () => {
      if (props.modelValue && isEditMode.value) await loadDetail()
    },
    { deep: true }
  )
</script>
