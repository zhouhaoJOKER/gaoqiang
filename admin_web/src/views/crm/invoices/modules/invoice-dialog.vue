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
        <ElCol v-if="!props.initialBillable" :span="24">
          <ElFormItem label="关联类型" prop="billable_type">
            <ElSelect
              v-model="form.billable_type"
              placeholder="请选择"
              style="width: 100%"
              :disabled="props.readonly"
              @change="onBillableTypeChange"
            >
              <ElOption label="客户" value="Crm::Client" />
              <ElOption label="供应商" value="Pur::Supplier" />
            </ElSelect>
          </ElFormItem>
        </ElCol>
        <ElCol v-if="!props.initialBillable" :span="24">
          <ElFormItem v-if="form.billable_type === 'Crm::Client'" label="客户" prop="billable_id">
            <ElSelect
              v-model="form.billable_id"
              placeholder="请选择客户"
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
          <ElFormItem
            v-else-if="form.billable_type === 'Pur::Supplier'"
            label="供应商"
            prop="billable_id"
          >
            <ElSelect
              v-model="form.billable_id"
              placeholder="请选择供应商"
              filterable
              remote
              :remote-method="searchSuppliers"
              :loading="supplierSearchLoading"
              clearable
              style="width: 100%"
              :disabled="props.readonly"
            >
              <ElOption
                v-for="s in supplierOptions"
                :key="s.id"
                :label="`[${s.code || ''}] ${s.name}`"
                :value="s.id"
              />
            </ElSelect>
          </ElFormItem>
        </ElCol>
        <ElCol v-if="props.initialBillable" :span="24">
          <ElFormItem label="关联">
            <span class="text-secondary">当前客户</span>
          </ElFormItem>
        </ElCol>
        <ElCol v-if="isClientBillable && !props.readonly" :span="24">
          <ElFormItem label="从地址填充">
            <div class="address-fill-row">
              <ElSelect
                v-model="selectedAddressId"
                placeholder="选择客户地址可自动填充下方地址、电话"
                clearable
                filterable
                style="flex: 1"
                @change="onAddressSelect"
              >
                <ElOption
                  v-for="a in addressOptions"
                  :key="a.id"
                  :label="addressOptionLabel(a)"
                  :value="a.id"
                />
              </ElSelect>
              <ElButton type="primary" link @click="openAddAddress">新增地址</ElButton>
            </div>
          </ElFormItem>
        </ElCol>
        <ElCol :span="24">
          <ElFormItem label="开票抬头" prop="title">
            <ElInput v-model="form.title" placeholder="请输入开票抬头" :readonly="props.readonly" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="税号" prop="tax_no">
            <ElInput v-model="form.tax_no" placeholder="请输入税号" :readonly="props.readonly" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="发票类型" prop="invoice_type_id">
            <PropertySelectWithAdd
              v-model="form.invoice_type_id"
              sign="crm_invoice_type"
              placeholder="请选择发票类型"
              :disabled="props.readonly"
            />
          </ElFormItem>
        </ElCol>
        <ElCol :span="24">
          <ElFormItem label="注册/开票地址" prop="address">
            <ElInput v-model="form.address" placeholder="请输入地址" :readonly="props.readonly" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="注册/开票电话" prop="phone">
            <ElInput v-model="form.phone" placeholder="请输入电话" :readonly="props.readonly" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="是否默认" prop="is_default">
            <ElSwitch v-model="form.is_default" :disabled="props.readonly" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="开户银行" prop="bank_name">
            <ElInput
              v-model="form.bank_name"
              placeholder="请输入开户银行"
              :readonly="props.readonly"
            />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="银行账号" prop="bank_account">
            <ElInput
              v-model="form.bank_account"
              placeholder="请输入银行账号"
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
  <AddressDialog
    v-model="addressDialogVisible"
    :fixed-client-id="clientIdForAddress"
    :readonly="false"
    @created="onAddressCreated"
  />
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
  import { createCrmInvoiceApi, updateCrmInvoiceApi, viewCrmInvoiceApi } from '@/api/crm/invoice'
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'
  import { listCrmClientApi, viewCrmClientApi } from '@/api/crm/client'
  import { listMatSupplierApi, viewMatSupplierApi } from '@/api/mat/supplier'
  import { listCrmAddressApi } from '@/api/crm/address'
  import AddressDialog from '@/views/crm/addresses/modules/address-dialog.vue'

  interface Props {
    modelValue: boolean
    invoice?: any
    readonly?: boolean
    initialBillable?: { billable_type: string; billable_id: string | number }
  }
  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', invoice: any): void
    (e: 'updated', invoice: any): void
  }
  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    invoice: undefined,
    readonly: false,
    initialBillable: undefined
  })
  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })
  const isEditMode = computed(() => !!props.invoice?.id)
  const dialogTitle = computed(() =>
    props.readonly ? '查看开票信息' : isEditMode.value ? '编辑开票信息' : '创建开票信息'
  )
  const isClientBillable = computed(
    () => props.initialBillable && form.billable_type === 'Crm::Client'
  )
  const clientIdForAddress = computed(() =>
    form.billable_type === 'Crm::Client' ? form.billable_id : undefined
  )

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    billable_type: [{ required: true, message: '请选择关联类型', trigger: 'change' }],
    billable_id: [{ required: true, message: '请选择客户/供应商', trigger: 'change' }],
    title: [{ required: true, message: '请输入开票抬头', trigger: 'blur' }]
  })

  const form = reactive({
    id: undefined as string | number | undefined,
    billable_type: 'Crm::Client' as string,
    billable_id: undefined as string | number | undefined,
    title: '',
    tax_no: '',
    address: '',
    phone: '',
    bank_name: '',
    bank_account: '',
    invoice_type_id: null as string | number | null,
    is_default: false,
    remark: ''
  })

  const clientOptions = ref<any[]>([])
  const clientSearchLoading = ref(false)
  const supplierOptions = ref<any[]>([])
  const supplierSearchLoading = ref(false)
  const addressOptions = ref<any[]>([])
  const selectedAddressId = ref<string | number | undefined>(undefined)
  const addressDialogVisible = ref(false)

  const loadAddresses = async () => {
    const cid = form.billable_type === 'Crm::Client' ? form.billable_id : null
    if (!cid) {
      addressOptions.value = []
      return
    }
    try {
      const res = await listCrmAddressApi({ 'q[client_id_eq]': cid, per_page: 500 })
      const data = (res as any).data || []
      addressOptions.value = Array.isArray(data) ? data : data.list || data.data || []
    } catch {
      addressOptions.value = []
    }
  }

  const onAddressSelect = (addrId: string | number | undefined) => {
    if (!addrId) return
    const a = addressOptions.value.find((x: any) => Number(x.id) === Number(addrId))
    if (a) {
      form.address = a.addr || ''
      form.phone = a.phone || ''
    }
  }

  const openAddAddress = () => {
    addressDialogVisible.value = true
  }
  const onAddressCreated = (addr: any) => {
    addressOptions.value = [...addressOptions.value, addr]
    selectedAddressId.value = addr.id
    onAddressSelect(addr.id)
    addressDialogVisible.value = false
  }

  const addressOptionLabel = (a: any) => {
    const parts = []
    if (a.addr_kind) parts.push(`[${a.addr_kind}]`)
    if (a.contact) parts.push(a.contact)
    if (a.phone) parts.push(a.phone)
    if (a.addr) parts.push(a.addr.length > 20 ? a.addr.slice(0, 20) + '…' : a.addr)
    return parts.length ? parts.join(' ') : `地址 #${a.id}`
  }

  const onBillableTypeChange = () => {
    form.billable_id = undefined
    clientOptions.value = []
    supplierOptions.value = []
  }

  const searchClients = async (query: string) => {
    clientSearchLoading.value = true
    try {
      const res = await listCrmClientApi({ 'q[name_or_code_cont]': query || '', per_page: 50 })
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      clientOptions.value = arr.filter((c: any) => c && c.id != null)
      if (form.billable_id && form.billable_type === 'Crm::Client') {
        const viewRes = await viewCrmClientApi({ id: form.billable_id }).catch(() => null)
        const client = viewRes && (viewRes as any).data
        if (
          client &&
          !clientOptions.value.find((c: any) => Number(c.id) === Number(form.billable_id))
        )
          clientOptions.value = [client, ...clientOptions.value]
      }
    } finally {
      clientSearchLoading.value = false
    }
  }

  const searchSuppliers = async (query: string) => {
    supplierSearchLoading.value = true
    try {
      const res = await listMatSupplierApi({ 'q[name_or_code_cont]': query || '', per_page: 50 })
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      supplierOptions.value = arr.filter((s: any) => s && s.id != null)
      if (form.billable_id && form.billable_type === 'Pur::Supplier') {
        const viewRes = await viewMatSupplierApi({ id: form.billable_id }).catch(() => null)
        const supplier = viewRes && (viewRes as any).data
        if (
          supplier &&
          !supplierOptions.value.find((s: any) => Number(s.id) === Number(form.billable_id))
        )
          supplierOptions.value = [supplier, ...supplierOptions.value]
      }
    } finally {
      supplierSearchLoading.value = false
    }
  }

  const loadDetail = async () => {
    if (!props.invoice?.id) return
    try {
      const res = await viewCrmInvoiceApi({ id: props.invoice.id })
      const d = (res as any).data || {}
      Object.assign(form, {
        id: d.id,
        billable_type: d.billable_type || 'Crm::Client',
        billable_id: d.billable_id,
        title: d.title || '',
        tax_no: d.tax_no || '',
        address: d.address || '',
        phone: d.phone || '',
        bank_name: d.bank_name || '',
        bank_account: d.bank_account || '',
        invoice_type_id: d.invoice_type_id ?? null,
        is_default: !!d.is_default,
        remark: d.remark || ''
      })
      if (form.billable_type === 'Crm::Client' && form.billable_id) await searchClients('')
      else if (form.billable_type === 'Pur::Supplier' && form.billable_id) await searchSuppliers('')
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
      const billableId = form.billable_id ?? props.initialBillable?.billable_id
      const params: any = {
        billable_type: form.billable_type,
        billable_id: billableId,
        title: form.title,
        tax_no: form.tax_no || undefined,
        address: form.address || undefined,
        phone: form.phone || undefined,
        bank_name: form.bank_name || undefined,
        bank_account: form.bank_account || undefined,
        invoice_type_id: form.invoice_type_id ?? undefined,
        is_default: form.is_default,
        remark: form.remark || undefined
      }
      if (isEditMode.value) {
        await updateCrmInvoiceApi(String(form.id), params)
        ElMessage.success('更新成功')
        emit('updated', { ...props.invoice, ...params })
        dialogVisible.value = false
      } else {
        const res = await createCrmInvoiceApi(params)
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
      const billableId = form.billable_id ?? props.initialBillable?.billable_id
      const params: any = {
        billable_type: form.billable_type,
        billable_id: billableId,
        title: form.title,
        tax_no: form.tax_no,
        address: form.address,
        phone: form.phone,
        bank_name: form.bank_name,
        bank_account: form.bank_account,
        invoice_type_id: form.invoice_type_id,
        is_default: form.is_default,
        remark: form.remark
      }
      const res = await createCrmInvoiceApi(params)
      ElMessage.success('创建成功')
      emit('created', (res as any).data)
      Object.assign(form, {
        id: undefined,
        billable_type: props.initialBillable?.billable_type ?? 'Crm::Client',
        billable_id: props.initialBillable?.billable_id ?? undefined,
        title: '',
        tax_no: '',
        address: '',
        phone: '',
        bank_name: '',
        bank_account: '',
        invoice_type_id: null,
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
      billable_type: 'Crm::Client',
      billable_id: undefined,
      title: '',
      tax_no: '',
      address: '',
      phone: '',
      bank_name: '',
      bank_account: '',
      invoice_type_id: null,
      is_default: false,
      remark: ''
    })
    selectedAddressId.value = undefined
    formRef.value?.resetFields()
  }

  watch(
    () => props.modelValue,
    async (val) => {
      if (val) {
        if (props.initialBillable) {
          form.billable_type = props.initialBillable.billable_type
          form.billable_id = props.initialBillable.billable_id ?? undefined
        }
        if (isEditMode.value) await loadDetail()
        else if (props.initialBillable && form.billable_id) {
          if (form.billable_type === 'Crm::Client') {
            await searchClients('')
            await loadAddresses()
          } else if (form.billable_type === 'Pur::Supplier') await searchSuppliers('')
        }
      }
    }
  )
  watch(
    () => props.invoice,
    async () => {
      if (props.modelValue && isEditMode.value) await loadDetail()
    },
    { deep: true }
  )
</script>

<style scoped>
  .address-fill-row {
    display: flex;
    gap: 8px;
    align-items: center;
    width: 100%;
  }
</style>
