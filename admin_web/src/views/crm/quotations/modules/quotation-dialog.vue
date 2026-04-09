<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="1200px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px">
      <ElRow :gutter="20">
        <ElCol :span="12">
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
        <ElCol :span="12">
          <ElFormItem label="报价单号" prop="code">
            <ElInput v-model="form.code" placeholder="请输入报价单号" :readonly="props.readonly" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="报价日期" prop="quote_date">
            <ElDatePicker
              v-model="form.quote_date"
              type="date"
              placeholder="请选择报价日期"
              style="width: 100%"
              value-format="YYYY-MM-DD"
              :disabled="props.readonly"
            />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="有效期至" prop="valid_until">
            <ElDatePicker
              v-model="form.valid_until"
              type="date"
              placeholder="请选择有效期"
              style="width: 100%"
              value-format="YYYY-MM-DD"
              :disabled="props.readonly"
            />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="币种" prop="currency">
            <ElInput v-model="form.currency" placeholder="如 CNY、USD" :readonly="props.readonly" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="状态" prop="status_id">
            <PropertySelectWithAdd
              v-model="form.status_id"
              sign="crm_quotation_status"
              placeholder="请选择状态"
              :disabled="props.readonly"
            />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="税率" prop="tax_rate_id">
            <PropertySelectWithAdd
              v-model="form.tax_rate_id"
              sign="crm_tax_rate"
              placeholder="请选择税率"
              :disabled="props.readonly"
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
      <div class="lines-section">
        <div class="lines-header">
          <span>报价明细</span>
          <ElButton v-if="!props.readonly" type="primary" size="small" @click="handleAddLine"
            >添加行</ElButton
          >
        </div>
        <ElTable :data="form.lines" border style="width: 100%">
          <ElTableColumn type="index" label="序号" width="55" />
          <ElTableColumn label="产品" min-width="200">
            <template #default="{ row, $index }">
              <ElSelect
                v-model="row.item_id"
                placeholder="请选择产品"
                filterable
                remote
                :remote-method="(q) => searchLineProducts(q, $index)"
                :loading="lineProductSearchLoading[$index]"
                style="width: 100%"
                :disabled="props.readonly"
                clearable
                @change="(val) => handleLineProductChange(val, $index)"
              >
                <ElOption
                  v-for="p in lineProductOptions[$index] || []"
                  :key="p.id"
                  :label="`[${p.code || ''}] ${p.name}`"
                  :value="p.id"
                />
              </ElSelect>
            </template>
          </ElTableColumn>
          <ElTableColumn label="产品名称" min-width="140">
            <template #default="{ row }">
              <ElInput
                v-model="row.product_name"
                placeholder="产品名称（可手填）"
                :readonly="props.readonly"
              />
            </template>
          </ElTableColumn>
          <ElTableColumn label="规格" min-width="120">
            <template #default="{ row }">
              <ElInput v-model="row.spec" placeholder="规格" :readonly="props.readonly" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="数量" min-width="100">
            <template #default="{ row }">
              <ElInput v-model="row.qty" type="number" placeholder="0" :readonly="props.readonly" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="单位" min-width="80">
            <template #default="{ row }">
              <ElInput v-model="row.unit" placeholder="单位" :readonly="props.readonly" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="含税单价" min-width="110">
            <template #default="{ row }">
              <ElInput
                v-model="row.unit_price"
                type="number"
                placeholder="0"
                :readonly="props.readonly"
              />
            </template>
          </ElTableColumn>
          <ElTableColumn label="含税金额" min-width="110">
            <template #default="{ row }">
              <ElInput
                v-model="row.amount"
                type="number"
                placeholder="0"
                :readonly="props.readonly"
              />
            </template>
          </ElTableColumn>
          <ElTableColumn label="行备注" min-width="120">
            <template #default="{ row }">
              <ElInput v-model="row.remark" placeholder="备注" :readonly="props.readonly" />
            </template>
          </ElTableColumn>
          <ElTableColumn v-if="!props.readonly" label="操作" width="70" fixed="right">
            <template #default="{ $index }">
              <ElButton type="danger" link size="small" @click="handleRemoveLine($index)"
                >删除</ElButton
              >
            </template>
          </ElTableColumn>
        </ElTable>
      </div>
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
    ElRow,
    ElCol,
    ElTable,
    ElTableColumn
  } from 'element-plus'
  import {
    createCrmQuotationApi,
    updateCrmQuotationApi,
    viewCrmQuotationApi
  } from '@/api/crm/quotation'
  import { listCrmQuotationLineApi } from '@/api/crm/quotation'
  import { listCrmClientApi, viewCrmClientApi } from '@/api/crm/client'
  import { listMatItemApi } from '@/api/mat/item'
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'

  interface Props {
    modelValue: boolean
    quotation?: any
    readonly?: boolean
  }
  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', quotation: any): void
    (e: 'updated', quotation: any): void
  }
  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    quotation: undefined,
    readonly: false
  })
  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })
  const isEditMode = computed(() => !!props.quotation?.id)
  const dialogTitle = computed(() =>
    props.readonly ? '查看报价单' : isEditMode.value ? '编辑报价单' : '创建报价单'
  )

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    client_id: [{ required: true, message: '请选择客户', trigger: 'change' }],
    code: [{ required: true, message: '请输入报价单号', trigger: 'blur' }]
  })

  const form = reactive({
    id: undefined as string | number | undefined,
    contract_id: undefined as string | number | undefined,
    client_id: undefined as string | number | undefined,
    code: '',
    quote_date: '',
    valid_until: '',
    currency: 'CNY',
    status_id: null as string | number | null,
    tax_rate_id: null as string | number | null,
    amount: undefined as number | undefined,
    total_amount: undefined as number | undefined,
    remark: '',
    lines: [] as any[]
  })

  const clientOptions = ref<any[]>([])
  const clientSearchLoading = ref(false)
  const lineProductOptions = ref<Record<number, any[]>>({})
  const lineProductSearchLoading = ref<Record<number, boolean>>({})

  const searchLineProducts = async (query: string, index: number) => {
    lineProductSearchLoading.value = { ...lineProductSearchLoading.value, [index]: true }
    try {
      const res = await listMatItemApi({ 'q[name_or_code_cont]': query || '', per_page: 30 })
      const data = (res as any).data || []
      const arr = Array.isArray(data) ? data : data.list || data.data || []
      lineProductOptions.value = {
        ...lineProductOptions.value,
        [index]: arr.filter((p: any) => p && p.id != null)
      }
    } finally {
      lineProductSearchLoading.value = { ...lineProductSearchLoading.value, [index]: false }
    }
  }

  const handleLineProductChange = (itemId: string | number | undefined, index: number) => {
    const row = form.lines[index]
    if (!row) return
    if (!itemId) {
      row.product_name = ''
      row.spec = ''
      row.unit = ''
      return
    }
    const list = lineProductOptions.value[index] || []
    const item = list.find((p: any) => Number(p.id) === Number(itemId))
    if (item) {
      row.product_name = item.name || row.product_name
      if (item.spec != null) row.spec = item.spec
      if (item.unit != null) row.unit = item.unit
      else if (item.uom_name != null) row.unit = item.uom_name
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

  const handleAddLine = () => {
    form.lines.push({
      item_id: undefined,
      product_name: '',
      spec: '',
      qty: 0,
      unit: '',
      unit_price: 0,
      amount: 0,
      remark: '',
      sort: form.lines.length
    })
  }

  const handleRemoveLine = (index: number) => {
    form.lines.splice(index, 1)
  }

  const loadDetail = async () => {
    if (!props.quotation?.id) return
    try {
      const res = await viewCrmQuotationApi({ id: props.quotation.id })
      const d = (res as any).data || {}
      Object.assign(form, {
        id: d.id,
        contract_id: d.contract_id,
        client_id: d.client_id,
        code: d.code || '',
        quote_date: d.quote_date || '',
        valid_until: d.valid_until || '',
        currency: d.currency || 'CNY',
        status_id: d.status_id ?? null,
        tax_rate_id: d.tax_rate_id ?? null,
        amount: d.amount,
        total_amount: d.total_amount,
        remark: d.remark || '',
        lines: []
      })
      const linesRes = await listCrmQuotationLineApi({ 'q[quotation_id_eq]': d.id })
      const linesData = (linesRes as any).data || []
      const arr = Array.isArray(linesData) ? linesData : linesData.list || linesData.data || []
      form.lines = arr.map((line: any, idx: number) => {
        const row = {
          id: line.id,
          item_id: line.item_id,
          product_name: line.product_name || '',
          spec: line.spec || '',
          qty: line.qty || 0,
          unit: line.unit || '',
          unit_price: line.unit_price || 0,
          amount: line.amount || 0,
          remark: line.remark || '',
          sort: line.sort ?? idx
        }
        if (line.item_id && (line.product_name || line.item_name)) {
          lineProductOptions.value = {
            ...lineProductOptions.value,
            [idx]: [{ id: line.item_id, code: '', name: line.product_name || line.item_name || '' }]
          }
        }
        return row
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
        contract_id: form.contract_id,
        client_id: form.client_id,
        code: form.code,
        quote_date: form.quote_date || undefined,
        valid_until: form.valid_until || undefined,
        currency: form.currency || undefined,
        status_id: form.status_id ?? undefined,
        tax_rate_id: form.tax_rate_id ?? undefined,
        amount: form.amount,
        total_amount: form.total_amount,
        remark: form.remark || undefined,
        lines: form.lines.map((line) => ({
          item_id: line.item_id,
          product_name: line.product_name,
          spec: line.spec,
          qty: line.qty,
          unit: line.unit,
          unit_price: line.unit_price,
          amount: line.amount,
          remark: line.remark,
          sort: line.sort
        }))
      }
      if (isEditMode.value) {
        await updateCrmQuotationApi(String(form.id), params)
        ElMessage.success('更新成功')
        emit('updated', { ...props.quotation, ...params })
        dialogVisible.value = false
      } else {
        const res = await createCrmQuotationApi(params)
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
        code: form.code,
        quote_date: form.quote_date,
        valid_until: form.valid_until,
        currency: form.currency,
        status_id: form.status_id,
        tax_rate_id: form.tax_rate_id,
        amount: form.amount,
        total_amount: form.total_amount,
        remark: form.remark,
        lines: form.lines.map((l) => ({
          item_id: l.item_id,
          product_name: l.product_name,
          spec: l.spec,
          qty: l.qty,
          unit: l.unit,
          unit_price: l.unit_price,
          amount: l.amount,
          remark: l.remark,
          sort: l.sort
        }))
      }
      const res = await createCrmQuotationApi(params)
      ElMessage.success('创建成功')
      emit('created', (res as any).data)
      Object.assign(form, {
        id: undefined,
        client_id: undefined,
        code: '',
        quote_date: '',
        valid_until: '',
        currency: 'CNY',
        status_id: null,
        tax_rate_id: null,
        amount: undefined,
        total_amount: undefined,
        remark: '',
        lines: []
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
      contract_id: undefined,
      client_id: undefined,
      code: '',
      quote_date: '',
      valid_until: '',
      currency: 'CNY',
      status_id: null,
      tax_rate_id: null,
      amount: undefined,
      total_amount: undefined,
      remark: '',
      lines: []
    })
    clientOptions.value = []
    lineProductOptions.value = {}
    lineProductSearchLoading.value = {}
    formRef.value?.resetFields()
  }

  watch(
    () => props.modelValue,
    async (val) => {
      if (val) {
        if (isEditMode.value) await loadDetail()
        else searchClients('')
      }
    }
  )
  watch(
    () => props.quotation,
    async () => {
      if (props.modelValue && isEditMode.value) await loadDetail()
    },
    { deep: true }
  )
</script>

<style scoped>
  .lines-section {
    margin-top: 16px;
  }

  .lines-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    margin-bottom: 8px;
  }
</style>
