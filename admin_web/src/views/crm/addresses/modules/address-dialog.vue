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
            <span class="text-secondary">当前客户</span>
          </ElFormItem>
        </ElCol>
        <ElCol v-if="props.fixedClientId && !props.readonly" :span="24">
          <ElFormItem label="选择联系人">
            <ElSelect
              v-model="selectedContactId"
              placeholder="从联系人填充收件人、电话（可清空后手动输入）"
              clearable
              filterable
              style="width: 100%"
              @change="onContactSelect"
            >
              <ElOption
                v-for="c in contactOptions"
                :key="c.id"
                :label="`${c.name || ''} ${c.mobile || c.phone ? `- ${c.mobile || c.phone}` : ''}`"
                :value="c.id"
              />
            </ElSelect>
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="地址类型" prop="addr_kind">
            <ElInput
              v-model="form.addr_kind"
              placeholder="收货/开票等"
              :readonly="props.readonly"
            />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="收件人/联系人" prop="contact">
            <ElInput v-model="form.contact" placeholder="请输入收件人" :readonly="props.readonly" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="电话" prop="phone">
            <ElInput v-model="form.phone" placeholder="请输入电话" :readonly="props.readonly" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="是否默认" prop="is_default">
            <ElSwitch v-model="form.is_default" :disabled="props.readonly" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="24">
          <ElFormItem label="地址" prop="addr">
            <ElInput
              v-model="form.addr"
              type="textarea"
              :rows="3"
              placeholder="请输入地址"
              :readonly="props.readonly"
            />
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
  import { createCrmAddressApi, updateCrmAddressApi, viewCrmAddressApi } from '@/api/crm/address'
  import { listCrmClientApi, viewCrmClientApi } from '@/api/crm/client'
  import { listCrmContactApi } from '@/api/crm/contact'

  interface Props {
    modelValue: boolean
    address?: any
    readonly?: boolean
    fixedClientId?: string | number
  }
  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', address: any): void
    (e: 'updated', address: any): void
  }
  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    address: undefined,
    readonly: false,
    fixedClientId: undefined
  })
  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })
  const isEditMode = computed(() => !!props.address?.id)
  const dialogTitle = computed(() =>
    props.readonly ? '查看收货地址' : isEditMode.value ? '编辑收货地址' : '创建收货地址'
  )

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    client_id: [{ required: true, message: '请选择客户', trigger: 'change' }]
  })

  const form = reactive({
    id: undefined as string | number | undefined,
    client_id: undefined as string | number | undefined,
    addr_kind: '',
    contact: '',
    phone: '',
    addr: '',
    is_default: false,
    remark: ''
  })

  const clientOptions = ref<any[]>([])
  const clientSearchLoading = ref(false)
  const contactOptions = ref<any[]>([])
  const selectedContactId = ref<string | number | undefined>(undefined)

  const loadContacts = async () => {
    if (!props.fixedClientId) return
    try {
      const res = await listCrmContactApi({ 'q[client_id_eq]': props.fixedClientId, per_page: 500 })
      const data = (res as any).data || []
      contactOptions.value = Array.isArray(data) ? data : data.list || data.data || []
    } catch {
      contactOptions.value = []
    }
  }

  const onContactSelect = (contactId: string | number | undefined) => {
    if (!contactId) return
    const c = contactOptions.value.find((x: any) => Number(x.id) === Number(contactId))
    if (c) {
      form.contact = c.name || ''
      form.phone = c.mobile || c.phone || ''
    }
  }

  const searchClients = async (query: string) => {
    clientSearchLoading.value = true
    try {
      const res = await listCrmClientApi({ 'q[name_or_code_cont]': query || '', per_page: 50 })
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      clientOptions.value = arr.filter((c: any) => c && c.id != null)
      if (form.client_id && form.id) {
        try {
          const viewRes = await viewCrmClientApi({ id: form.client_id })
          const client = (viewRes as any).data
          if (
            client &&
            !clientOptions.value.find((c: any) => Number(c.id) === Number(form.client_id))
          )
            clientOptions.value = [client, ...clientOptions.value]
        } catch {
          /* empty */
        }
      }
    } finally {
      clientSearchLoading.value = false
    }
  }

  const loadDetail = async () => {
    if (!props.address?.id) return
    try {
      const res = await viewCrmAddressApi({ id: props.address.id })
      const d = (res as any).data || {}
      Object.assign(form, {
        id: d.id,
        client_id: d.client_id,
        addr_kind: d.addr_kind || '',
        contact: d.contact || '',
        phone: d.phone || '',
        addr: d.addr || '',
        is_default: !!d.is_default,
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
        addr_kind: form.addr_kind || undefined,
        contact: form.contact || undefined,
        phone: form.phone || undefined,
        addr: form.addr || undefined,
        is_default: form.is_default,
        remark: form.remark || undefined
      }
      if (isEditMode.value) {
        await updateCrmAddressApi(String(form.id), params)
        ElMessage.success('更新成功')
        emit('updated', { ...props.address, ...params })
        dialogVisible.value = false
      } else {
        const res = await createCrmAddressApi(params)
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
        addr_kind: form.addr_kind,
        contact: form.contact,
        phone: form.phone,
        addr: form.addr,
        is_default: form.is_default,
        remark: form.remark
      }
      const res = await createCrmAddressApi(params)
      ElMessage.success('创建成功')
      emit('created', (res as any).data)
      Object.assign(form, {
        id: undefined,
        client_id: undefined,
        addr_kind: '',
        contact: '',
        phone: '',
        addr: '',
        is_default: false,
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
      addr_kind: '',
      contact: '',
      phone: '',
      addr: '',
      is_default: false,
      remark: ''
    })
    clientOptions.value = []
    contactOptions.value = []
    selectedContactId.value = undefined
    formRef.value?.resetFields()
  }

  watch(
    () => props.modelValue,
    async (val) => {
      if (val) {
        if (props.fixedClientId) {
          form.client_id = props.fixedClientId
          await loadContacts()
        }
        if (isEditMode.value) await loadDetail()
        else if (!props.fixedClientId) searchClients('')
      }
    }
  )
  watch(
    () => props.address,
    async () => {
      if (props.modelValue && isEditMode.value) await loadDetail()
    },
    { deep: true }
  )
</script>
