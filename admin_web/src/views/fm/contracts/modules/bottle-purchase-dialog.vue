<template>
  <ElDialog
    v-model="dialogVisible"
    title="新增包装瓶采购"
    width="980px"
    :close-on-click-modal="false"
    class="bottle-purchase-dialog"
    @closed="handleClosed"
  >
    <div class="dialog-body-scroll">
      <ElForm ref="formRef" :model="form" label-width="120px">
        <ElDivider content-position="left">基本信息</ElDivider>
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="关联销售合同">
              <span class="text-secondary">当前合同</span>
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="合同编号" prop="code">
              <ElInput v-model="form.code" placeholder="自动生成" readonly />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="需方（客户）" prop="client_id">
              <div class="inline-add-wrap">
                <ElSelect
                  v-model="form.client_id"
                  placeholder="请选择或搜索需方客户"
                  filterable
                  remote
                  :remote-method="searchClients"
                  :loading="clientSearchLoading"
                  style="width: 100%"
                  clearable
                >
                  <ElOption
                    v-for="c in clientOptions"
                    :key="c.id"
                    :label="`[${c.code || ''}] ${c.name}`"
                    :value="c.id"
                  />
                </ElSelect>
                <ElButton type="primary" link @click="clientDialogVisible = true">
                  <ArtSvgIcon icon="ri:add-line" />
                </ElButton>
              </div>
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="供方（供应商）" prop="supplier_id">
              <div class="inline-add-wrap">
                <ElSelect
                  v-model="form.supplier_id"
                  placeholder="请选择或搜索供方供应商"
                  filterable
                  remote
                  :remote-method="searchSuppliers"
                  :loading="supplierSearchLoading"
                  style="width: 100%"
                  clearable
                >
                  <ElOption
                    v-for="s in supplierOptions"
                    :key="s.id"
                    :label="`[${s.code || ''}] ${s.name}`"
                    :value="s.id"
                  />
                </ElSelect>
                <ElButton type="primary" link @click="supplierDialogVisible = true">
                  <ArtSvgIcon icon="ri:add-line" />
                </ElButton>
              </div>
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="签订日期" prop="signing_date">
              <ElDatePicker
                v-model="form.signing_date"
                type="date"
                placeholder="签订日期"
                style="width: 100%"
                value-format="YYYY-MM-DD"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="签订地点" prop="signing_location">
              <ElInput v-model="form.signing_location" placeholder="如：传真互签" />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <div class="lines-section">
          <div class="lines-header">
            <span>产品明细</span>
            <ElButton type="primary" size="small" @click="handleAddLine">添加行</ElButton>
          </div>
          <ElTable :data="form.lines" border style="width: 100%">
            <ElTableColumn type="index" label="序号" width="55" />
            <ElTableColumn label="货品名称" min-width="180">
              <template #default="{ row }">
                <ElSelect
                  v-model="row.product_id"
                  placeholder="输入名称或编码搜索，可快速创建"
                  filterable
                  remote
                  :remote-method="(q: string) => searchLineProducts(q, row)"
                  :loading="lineProductLoading"
                  default-first-option
                  style="width: 100%"
                  clearable
                  @change="(val: any) => onLineProductChange(row, val)"
                >
                  <ElOption
                    v-for="item in getLineProductOptions(row)"
                    :key="String(item.id)"
                    :label="
                      typeof item.id === 'string' && String(item.id).startsWith('__create__')
                        ? item.name
                        : `${item.name || ''} [${item.code || ''}]`
                    "
                    :value="item.id"
                  />
                </ElSelect>
              </template>
            </ElTableColumn>
            <ElTableColumn label="规格" width="120">
              <template #default="{ row }">
                <PropertySelectWithAdd
                  v-model="row.unit_id"
                  sign="product_uom"
                  placeholder="规格"
                  style="width: 100%"
                  @change="(id: any) => onLineUnitChange(row, id)"
                />
              </template>
            </ElTableColumn>
            <ElTableColumn label="数量" width="110">
              <template #default="{ row }">
                <ElInput
                  v-model.number="row.qty"
                  type="number"
                  placeholder="0"
                  @input="calcLineAmount(row)"
                />
              </template>
            </ElTableColumn>
            <ElTableColumn label="单价(RMB)" width="110">
              <template #default="{ row }">
                <ElInput
                  v-model="row.price"
                  type="number"
                  step="0.01"
                  placeholder="0.00"
                  @input="calcLineAmount(row)"
                  @blur="row.price = formatMoneyInput(row.price)"
                />
              </template>
            </ElTableColumn>
            <ElTableColumn label="总金额(RMB)" width="110">
              <template #default="{ row }">
                <ElInput :model-value="formatMoney(row.amount)" type="text" readonly />
              </template>
            </ElTableColumn>
            <ElTableColumn label="瓶身颜色" width="120">
              <template #default="{ row }">
                <ElInput v-model="row.bottle_body_color" placeholder="如：乳白" />
              </template>
            </ElTableColumn>
            <ElTableColumn label="盖子" min-width="140">
              <template #default="{ row }">
                <ElInput v-model="row.lid" placeholder="如：白盖配黑手套铝箔垫片" />
              </template>
            </ElTableColumn>
            <ElTableColumn label="备注" min-width="140">
              <template #default="{ row }">
                <ElInput v-model="row.remark" placeholder="备注" />
              </template>
            </ElTableColumn>
            <ElTableColumn label="操作" width="70" fixed="right">
              <template #default="{ $index }">
                <ElButton type="danger" link size="small" @click="handleRemoveLine($index)">
                  删除
                </ElButton>
              </template>
            </ElTableColumn>
          </ElTable>
        </div>
        <ElRow :gutter="20" style="margin-top: 16px">
          <ElCol :span="12">
            <ElFormItem label="总金额(RMB)">
              <ElInput
                :model-value="formatMoney(totalAmountDisplay)"
                readonly
                placeholder="根据明细自动计算"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="总金额大写">
              <ElInput :model-value="totalAmountChinese" readonly placeholder="自动生成" />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="备注" prop="remark">
              <ElInput v-model="form.remark" type="textarea" :rows="2" placeholder="备注" />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <ElDivider content-position="left">条款信息</ElDivider>
        <ElRow :gutter="20">
          <ElCol :span="24">
            <ElFormItem label="质量标准、技术标准" prop="quality_standard">
              <ElInput
                v-model="form.quality_standard"
                type="textarea"
                :rows="2"
                placeholder="如：HDPE/COEX 等符合国标或供方企业标准"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="交货地点及方式" prop="delivery_location_method">
              <ElInput
                v-model="form.delivery_location_method"
                type="textarea"
                :rows="1"
                placeholder="如：汽车运输，送至需方指定地点"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="运输费用负担" prop="transportation_cost_bearer">
              <ElInput v-model="form.transportation_cost_bearer" placeholder="如：供方承担" />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="验收方法" prop="inspection_method">
              <ElInput v-model="form.inspection_method" placeholder="如：到货一周内提出质量异议" />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="结算办法" prop="settlement_method_term">
              <ElInput
                v-model="form.settlement_method_term"
                type="textarea"
                :rows="1"
                placeholder="如：货到一个月内款付清"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="违约责任" prop="breach_of_contract_liability">
              <ElInput
                v-model="form.breach_of_contract_liability"
                placeholder="如：双方协商解决或按《民法典》"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="其它约定" prop="other_agreements">
              <ElInput
                v-model="form.other_agreements"
                type="textarea"
                :rows="1"
                placeholder="如：办危包带商检；传真件有效"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
      </ElForm>
    </div>
    <template #footer>
      <ElButton @click="handleCancel">取消</ElButton>
      <ElButton type="primary" :loading="saving" @click="handleSave">保存</ElButton>
    </template>
    <ClientDialog v-model="clientDialogVisible" @created="onClientCreated" />
    <SupplierDialog v-model="supplierDialogVisible" @created="onSupplierCreated" />
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, reactive, computed, watch } from 'vue'
  import { ElMessage } from 'element-plus'
  import type { FormInstance } from 'element-plus'
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
    ElTableColumn,
    ElDivider
  } from 'element-plus'
  import { ElDatePicker } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'
  import ClientDialog from '@/views/crm/clients/modules/client-dialog.vue'
  import SupplierDialog from '@/views/pur/suppliers/modules/supplier-dialog.vue'
  import { createPurContractApi } from '@/api/pur/contract'
  import { previewDocNumberApi } from '@/api/doc-number'
  import { listCrmClientApi } from '@/api/crm/client'
  import { listMatSupplierApi } from '@/api/mat/supplier'
  import { listMatItemApi, createMatItemApi } from '@/api/mat/item'
  import { viewPropertyApi } from '@/api/property'

  const TAX_RATE = 0.13

  const props = defineProps<{
    modelValue: boolean
    contractId?: string | number
  }>()
  const emit = defineEmits<{
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', data: any): void
  }>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (v) => emit('update:modelValue', v)
  })

  const formRef = ref<FormInstance>()
  const saving = ref(false)
  const clientOptions = ref<any[]>([])
  const clientSearchLoading = ref(false)
  const clientDialogVisible = ref(false)
  const supplierOptions = ref<any[]>([])
  const supplierSearchLoading = ref(false)
  const supplierDialogVisible = ref(false)
  const lineProductLoading = ref(false)
  const productOptionsMap = ref<Record<string, any[]>>({})
  const form = reactive({
    code: '',
    client_id: undefined as string | number | undefined,
    supplier_id: undefined as string | number | undefined,
    signing_date: '',
    signing_location: '',
    remark: '',
    quality_standard: '',
    delivery_location_method: '',
    transportation_cost_bearer: '',
    inspection_method: '',
    settlement_method_term: '',
    breach_of_contract_liability: '',
    other_agreements: '',
    lines: [] as any[]
  })

  const searchClients = async (query: string) => {
    clientSearchLoading.value = true
    try {
      const res = await listCrmClientApi({ 'q[name_or_code_cont]': query || '', per_page: 50 })
      const data = (res as any).data || []
      const arr = Array.isArray(data) ? data : data.list || data.data || []
      clientOptions.value = arr.filter((c: any) => c && c.id != null)
    } finally {
      clientSearchLoading.value = false
    }
  }

  const searchSuppliers = async (query: string) => {
    supplierSearchLoading.value = true
    try {
      const res = await listMatSupplierApi({ 'q[name_or_code_cont]': query || '', per_page: 50 })
      const data = (res as any).data || []
      const arr = Array.isArray(data) ? data : data.list || data.data || []
      supplierOptions.value = arr.filter((s: any) => s && s.id != null)
    } finally {
      supplierSearchLoading.value = false
    }
  }

  const onClientCreated = (c: any) => {
    if (!c?.id) return
    clientOptions.value = [c, ...clientOptions.value]
    form.client_id = c.id
  }

  const onSupplierCreated = (s: any) => {
    if (!s?.id) return
    supplierOptions.value = [s, ...supplierOptions.value]
    form.supplier_id = s.id
  }

  const getLineKey = (row: any) => {
    if (!row._lineKey) row._lineKey = String(Math.random())
    return row._lineKey
  }

  const searchLineProducts = async (query: string, row: any) => {
    const q = (query || '').trim()
    row._productCreateQuery = q && q.length > 0 ? q : undefined
    lineProductLoading.value = true
    try {
      const res = await listMatItemApi({
        'q[name_or_code_cont]': q || '',
        'q[type_id_eq]': 400,
        per_page: 50
      })
      const data = (res as any).data || []
      const arr = Array.isArray(data) ? data : data.list || data.data || []
      const key = getLineKey(row)
      const opts = arr.filter((p: any) => p?.id != null)
      const createLabel =
        q && !opts.some((it: any) => it.name === q)
          ? [{ id: `__create__${q}`, name: `创建: ${q} 或按回车键直接创建记录`, code: '' }]
          : []
      productOptionsMap.value = { ...productOptionsMap.value, [key]: [...opts, ...createLabel] }
    } catch {
      const key = getLineKey(row)
      productOptionsMap.value = { ...productOptionsMap.value, [key]: [] }
    } finally {
      lineProductLoading.value = false
    }
  }

  const getLineProductOptions = (row: any) => {
    const key = row._lineKey
    return key ? productOptionsMap.value[key] || [] : []
  }

  const onLineProductChange = async (row: any, val: string | number | null) => {
    if (val == null) {
      row.product_name = ''
      row.product_id = undefined
      return
    }
    const idStr = String(val)
    if (idStr.startsWith('__create__')) {
      const query = idStr.replace(/^__create__/, '')
      if (!query) return
      try {
        const res = await createMatItemApi({ name: query, type_id: 400 })
        const created = (res as any).data
        if (created?.id != null) {
          const key = getLineKey(row)
          const arr = productOptionsMap.value[key] || []
          productOptionsMap.value = {
            ...productOptionsMap.value,
            [key]: [{ ...created, name: created.name || query, code: created.code || '' }, ...arr]
          }
          row.product_id = created.id
          row.product_name = created.name || query
          row._productCreateQuery = undefined
          ElMessage.success('已创建产品')
        }
      } catch {
        ElMessage.error('创建产品失败')
      }
      return
    }
    const opts = getLineProductOptions(row).filter(
      (o: any) =>
        typeof o.id === 'number' ||
        (typeof o.id === 'string' && !String(o.id).startsWith('__create__'))
    )
    const item = opts.find((o: any) => Number(o.id) === Number(val))
    if (item) row.product_name = item.name
  }

  const onLineUnitChange = async (row: any, id: string | number | null) => {
    if (!id) {
      row.unit = ''
      return
    }
    try {
      const res = await viewPropertyApi({ id })
      const p = (res as any).data || {}
      row.unit = p.name || ''
    } catch {
      row.unit = ''
    }
  }

  const calcTotalAmount = () => {
    let total = 0
    for (const row of form.lines) {
      total += Number(row.amount) || 0
    }
    return Math.round(total * 100) / 100
  }

  const totalAmountDisplay = computed(() => calcTotalAmount())

  const toChineseAmount = (n: number) => {
    const digits = ['零', '壹', '贰', '叁', '肆', '伍', '陆', '柒', '捌', '玖']
    const units = ['', '拾', '佰', '仟']
    const bigUnits = ['', '万', '亿']
    if (n === 0) return '零元整'
    const intPart = Math.floor(n)
    const decPart = Math.round((n - intPart) * 100)
    let s = String(intPart)
    let result = ''
    const len = s.length
    for (let i = 0; i < len; i++) {
      const d = Number(s[i])
      const u = units[(len - 1 - i) % 4]
      const bu = len - 1 - i >= 4 ? bigUnits[Math.floor((len - 1 - i) / 4)] : ''
      if (d !== 0) result += digits[d] + u
      else if (result && result[result.length - 1] !== '零') result += '零'
      if (u === '' && bu) result += bu
    }
    result = result.replace(/零+$/, '') || '零'
    result += '元'
    if (decPart === 0) result += '整'
    else {
      result += digits[Math.floor(decPart / 10)] + (decPart >= 10 ? '角' : '')
      if (decPart % 10) result += digits[decPart % 10] + '分'
    }
    return result
  }

  const totalAmountChinese = computed(() => {
    const t = calcTotalAmount()
    return t === 0 ? '' : toChineseAmount(t)
  })

  const formatMoney = (v: any) => {
    if (v == null || v === '') return ''
    const n = Number(v)
    if (Number.isNaN(n)) return ''
    return n.toFixed(2)
  }

  const formatMoneyInput = (v: any) => {
    if (v == null || v === '') return ''
    const n = Number(v)
    if (Number.isNaN(n)) return ''
    return n.toFixed(2)
  }

  const calcLineAmount = (row: any) => {
    const qty = Number(row.qty) || 0
    const price = Number(row.price) || 0
    const amount = Math.round(qty * price * 100) / 100
    const amount_excl_tax = Math.round((amount / (1 + TAX_RATE)) * 100) / 100
    const tax = Math.round((amount - amount_excl_tax) * 100) / 100
    row.amount = Number.isNaN(amount) ? undefined : amount
    row.amount_excl_tax = Number.isNaN(amount_excl_tax) ? undefined : amount_excl_tax
    row.tax = Number.isNaN(tax) ? undefined : tax
  }

  const handleAddLine = () => {
    form.lines.push({
      product_id: undefined,
      product_name: '',
      unit: '',
      unit_id: undefined,
      qty: undefined,
      price: undefined,
      amount_excl_tax: undefined,
      tax: undefined,
      amount: undefined,
      bottle_body_color: '',
      lid: '',
      remark: '',
      sort: form.lines.length,
      _lineKey: String(Math.random())
    })
  }

  const handleRemoveLine = (index: number) => {
    form.lines.splice(index, 1)
  }

  const handleSave = async () => {
    const validLines = form.lines.filter(
      (l) =>
        (l.product_id != null ||
          (l.product_name != null && String(l.product_name).trim() !== '')) &&
        (typeof l.product_id !== 'string' || !String(l.product_id).startsWith('__create__'))
    )
    if (validLines.length === 0) {
      ElMessage.warning('请至少添加一行产品明细')
      return
    }
    const totalAmount = calcTotalAmount()
    saving.value = true
    try {
      const payload = {
        contract_id: props.contractId,
        sign: 'bottle',
        code: form.code || undefined,
        client_id: form.client_id,
        supplier_id: form.supplier_id,
        signing_date: form.signing_date || undefined,
        signing_location: form.signing_location || undefined,
        total_amount: totalAmount || undefined,
        total_amount_chinese: totalAmount > 0 ? toChineseAmount(totalAmount) : undefined,
        remark: form.remark || undefined,
        quality_standard: form.quality_standard || undefined,
        delivery_location_method: form.delivery_location_method || undefined,
        transportation_cost_bearer: form.transportation_cost_bearer || undefined,
        inspection_method: form.inspection_method || undefined,
        settlement_method_term: form.settlement_method_term || undefined,
        breach_of_contract_liability: form.breach_of_contract_liability || undefined,
        other_agreements: form.other_agreements || undefined,
        collections: validLines.map((l: any, idx: number) => ({
          product_id:
            typeof l.product_id === 'number' ||
            (typeof l.product_id === 'string' && !String(l.product_id).startsWith('__create__'))
              ? l.product_id
              : undefined,
          product_name: l.product_name,
          unit_id: l.unit_id,
          unit: l.unit,
          qty: l.qty,
          price: l.price,
          amount_excl_tax: l.amount_excl_tax,
          tax: l.tax,
          amount: l.amount,
          bottle_body_color: l.bottle_body_color,
          lid: l.lid,
          remark: l.remark,
          sort: idx
        }))
      }
      const res = await createPurContractApi(payload)
      ElMessage.success('创建成功')
      emit('created', (res as any).data)
      dialogVisible.value = false
    } catch (e: any) {
      ElMessage.error(e?.message || '创建失败')
    } finally {
      saving.value = false
    }
  }

  const handleCancel = () => {
    dialogVisible.value = false
  }

  const handleClosed = () => {
    form.code = ''
    form.client_id = undefined
    form.supplier_id = undefined
    form.signing_date = ''
    form.signing_location = ''
    form.remark = ''
    form.quality_standard = ''
    form.delivery_location_method = ''
    form.transportation_cost_bearer = ''
    form.inspection_method = ''
    form.settlement_method_term = ''
    form.breach_of_contract_liability = ''
    form.other_agreements = ''
    form.lines = []
    productOptionsMap.value = {}
  }

  watch(
    () => props.modelValue,
    (val) => {
      if (val) {
        form.signing_date = new Date().toISOString().slice(0, 10)
        if (!form.code) {
          fillCodeFromPreview()
        }
        if (form.lines.length === 0) handleAddLine()
      }
    }
  )

  const fillCodeFromPreview = async () => {
    try {
      const res = await previewDocNumberApi('pur_contracts_bottle')
      const d = (res as any).data || {}
      if (d.code) form.code = d.code
    } catch {
      /* ignore */
    }
  }
</script>

<style scoped>
  .dialog-body-scroll {
    max-height: 65vh;
    overflow-y: auto;
  }

  .inline-add-wrap {
    display: flex;
    gap: 4px;
    align-items: center;
  }

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
