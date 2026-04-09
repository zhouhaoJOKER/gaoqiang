<template>
  <ElDialog
    v-model="dialogVisible"
    title="新增原料采购"
    width="980px"
    :close-on-click-modal="false"
    class="raw-material-purchase-dialog"
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
              <ElInput v-model="form.signing_location" placeholder="如：南京" />
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
            <ElTableColumn label="产品名称" min-width="180">
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
            <ElTableColumn label="单位" width="120">
              <template #default="{ row }">
                <PropertySelectWithAdd
                  v-model="row.unit_id"
                  sign="product_uom"
                  placeholder="单位"
                  style="width: 100%"
                  @change="(id: any) => onLineUnitChange(row, id)"
                />
              </template>
            </ElTableColumn>
            <ElTableColumn label="数量(KG)" width="110">
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
            <ElTableColumn label="不含税金额" width="120">
              <template #default="{ row }">
                <ElInput
                  v-model="row.amount_excl_tax"
                  type="number"
                  step="0.01"
                  placeholder="0.00"
                  @blur="onAmountExclTaxBlur(row)"
                />
              </template>
            </ElTableColumn>
            <ElTableColumn label="税额(RMB)" width="100">
              <template #default="{ row }">
                <ElInput
                  v-model="row.tax"
                  type="number"
                  step="0.01"
                  placeholder="0.00"
                  @blur="onTaxBlur(row)"
                />
              </template>
            </ElTableColumn>
            <ElTableColumn label="总金额(RMB)" width="110">
              <template #default="{ row }">
                <ElInput :model-value="formatMoney(row.amount)" type="text" readonly />
              </template>
            </ElTableColumn>
            <ElTableColumn label="操作" width="70" fixed="right">
              <template #default="{ $index }">
                <ElButton type="danger" link size="small" @click="handleRemoveLine($index)"
                  >删除</ElButton
                >
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
                placeholder="如：含量≥98%，符合国标等"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="交货地点及方式" prop="delivery_location_method">
              <ElInput
                v-model="form.delivery_location_method"
                type="textarea"
                :rows="1"
                placeholder="如：供方按时将货物送到需方指定地址"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="运输费用负担" prop="transportation_cost_bearer">
              <ElInput
                v-model="form.transportation_cost_bearer"
                placeholder="如：运输费用由供方承担"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="合理损耗及计算方法" prop="loss_calculation_method">
              <ElInput v-model="form.loss_calculation_method" placeholder="如：经双方协商解决" />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="包装标准、包装物供应与回收" prop="packaging_standard">
              <ElInput
                v-model="form.packaging_standard"
                type="textarea"
                :rows="1"
                placeholder="如：25公斤袋装，不能破损"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="包装质量损失责任" prop="packaging_loss_responsibility">
              <ElInput v-model="form.packaging_loss_responsibility" placeholder="选填" />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="复测期限" prop="reinspection_period">
              <ElInput v-model="form.reinspection_period" placeholder="如：3天内复测" />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="验收方式及提出异议期限" prop="inspection_method">
              <ElInput
                v-model="form.inspection_method"
                type="textarea"
                :rows="2"
                placeholder="需方到货核对品名、数量、批号；复测期限、异议期限等"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="异议期限" prop="objection_period">
              <ElInput v-model="form.objection_period" placeholder="如：一周内提出异议" />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="质量问题责任" prop="quality_issue_responsibility">
              <ElInput v-model="form.quality_issue_responsibility" placeholder="选填" />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="随机备品、配件工具" prop="spare_parts_supply">
              <ElInput v-model="form.spare_parts_supply" placeholder="如：无" />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="结算方式及期限" prop="settlement_method_term">
              <ElInput
                v-model="form.settlement_method_term"
                type="textarea"
                :rows="1"
                placeholder="如：到货后提供分析报告，开具增值税发票后扣款"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="违约责任" prop="breach_of_contract_liability">
              <ElInput
                v-model="form.breach_of_contract_liability"
                placeholder="如：按《民法典》有关条款执行"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="解决合同纠纷方式" prop="dispute_resolution_method">
              <ElInput
                v-model="form.dispute_resolution_method"
                placeholder="如：双方友好协商解决"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="其它约定事项" prop="other_agreements">
              <ElInput
                v-model="form.other_agreements"
                type="textarea"
                :rows="1"
                placeholder="如：经双方签字后传真产生法律效力"
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
    loss_calculation_method: '',
    packaging_standard: '',
    packaging_loss_responsibility: '',
    inspection_method: '',
    reinspection_period: '',
    objection_period: '',
    quality_issue_responsibility: '',
    spare_parts_supply: '',
    settlement_method_term: '',
    breach_of_contract_liability: '',
    dispute_resolution_method: '',
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
      const res = await listMatSupplierApi({ 'q[name_or_py_cont]': query || '', per_page: 50 })
      const data = (res as any).data || []
      const arr = Array.isArray(data) ? data : data.list || data.data || []
      supplierOptions.value = arr.filter((s: any) => s && s.id != null)
    } finally {
      supplierSearchLoading.value = false
    }
  }

  const onClientCreated = (client: any) => {
    clientDialogVisible.value = false
    if (client?.id) {
      clientOptions.value = [client, ...clientOptions.value]
      form.client_id = client.id
    }
  }

  const onSupplierCreated = (supplier: any) => {
    supplierDialogVisible.value = false
    if (supplier?.id) {
      supplierOptions.value = [supplier, ...supplierOptions.value]
      form.supplier_id = supplier.id
    }
  }

  const searchLineProducts = async (query: string, row: any) => {
    const q = (query || '').trim()
    row._productCreateQuery = q && q.length > 0 ? q : undefined
    lineProductLoading.value = true
    try {
      const res = await listMatItemApi({
        'q[name_or_code_cont]': q || '',
        'q[type_id_eq]': 200,
        per_page: 50
      })
      const data = (res as any).data || []
      const arr = Array.isArray(data) ? data : data.list || data.data || []
      const key = row._lineKey ?? String(Math.random())
      row._lineKey = key
      productOptionsMap.value = {
        ...productOptionsMap.value,
        [key]: arr.filter((p: any) => p?.id != null)
      }
    } catch {
      const key = row._lineKey ?? String(Math.random())
      row._lineKey = key
      productOptionsMap.value = { ...productOptionsMap.value, [key]: [] }
    } finally {
      lineProductLoading.value = false
    }
  }

  const getLineProductOptions = (row: any) => {
    const key = row._lineKey
    const base = key ? productOptionsMap.value[key] || [] : []
    const createQ = row._productCreateQuery
    if (createQ && base.length === 0) {
      return [
        { id: `__create__${createQ}`, name: `创建: ${createQ} 或按回车键直接创建记录`, code: '' }
      ]
    }
    return base
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
        const res = await createMatItemApi({ name: query, type_id: 200 })
        const created = (res as any).data
        if (created?.id != null) {
          const key = row._lineKey ?? String(Math.random())
          row._lineKey = key
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

  const totalAmountDisplay = computed(() => {
    return calcTotalAmount()
  })

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

  const syncFromAmountExclTax = (row: any) => {
    let amount = Number(row.amount)
    let excl = Number(row.amount_excl_tax)
    if (Number.isNaN(excl)) excl = 0
    excl = Math.round(excl * 100) / 100
    // 如果当前总金额为空，则用 不含税金额 + 税额 反推总金额
    if (Number.isNaN(amount)) {
      const taxFromField = Number(row.tax)
      const taxSafe = Number.isNaN(taxFromField) ? 0 : taxFromField
      amount = Math.round((excl + taxSafe) * 100) / 100
    }
    const tax = Math.round((amount - excl) * 100) / 100
    row.amount = Number.isNaN(amount) ? undefined : amount
    row.amount_excl_tax = Number.isNaN(excl) ? undefined : excl
    row.tax = Number.isNaN(tax) ? undefined : tax
  }

  const syncFromTax = (row: any) => {
    let amount = Number(row.amount)
    let tax = Number(row.tax)
    if (Number.isNaN(tax)) tax = 0
    tax = Math.round(tax * 100) / 100
    // 如果当前总金额为空，则用 不含税金额 + 税额 反推总金额
    if (Number.isNaN(amount)) {
      const exclFromField = Number(row.amount_excl_tax)
      const exclSafe = Number.isNaN(exclFromField) ? 0 : exclFromField
      amount = Math.round((exclSafe + tax) * 100) / 100
    }
    const excl = Math.round((amount - tax) * 100) / 100
    row.amount = Number.isNaN(amount) ? undefined : amount
    row.tax = Number.isNaN(tax) ? undefined : tax
    row.amount_excl_tax = Number.isNaN(excl) ? undefined : excl
  }

  const onAmountExclTaxBlur = (row: any) => {
    if (row.amount == null || row.amount === '') return
    syncFromAmountExclTax(row)
    if (row.amount_excl_tax != null && row.amount_excl_tax !== '') {
      row.amount_excl_tax = formatMoneyInput(row.amount_excl_tax)
    }
    if (row.tax != null && row.tax !== '') {
      row.tax = formatMoneyInput(row.tax)
    }
  }

  const onTaxBlur = (row: any) => {
    if (row.amount == null || row.amount === '') return
    syncFromTax(row)
    if (row.tax != null && row.tax !== '') {
      row.tax = formatMoneyInput(row.tax)
    }
    if (row.amount_excl_tax != null && row.amount_excl_tax !== '') {
      row.amount_excl_tax = formatMoneyInput(row.amount_excl_tax)
    }
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
        sign: 'raw_material',
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
        loss_calculation_method: form.loss_calculation_method || undefined,
        packaging_standard: form.packaging_standard || undefined,
        packaging_loss_responsibility: form.packaging_loss_responsibility || undefined,
        inspection_method: form.inspection_method || undefined,
        reinspection_period: form.reinspection_period || undefined,
        objection_period: form.objection_period || undefined,
        quality_issue_responsibility: form.quality_issue_responsibility || undefined,
        spare_parts_supply: form.spare_parts_supply || undefined,
        settlement_method_term: form.settlement_method_term || undefined,
        breach_of_contract_liability: form.breach_of_contract_liability || undefined,
        dispute_resolution_method: form.dispute_resolution_method || undefined,
        other_agreements: form.other_agreements || undefined,
        collections: validLines.map((l, idx) => ({
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
    form.loss_calculation_method = ''
    form.packaging_standard = ''
    form.packaging_loss_responsibility = ''
    form.inspection_method = ''
    form.reinspection_period = ''
    form.objection_period = ''
    form.quality_issue_responsibility = ''
    form.spare_parts_supply = ''
    form.settlement_method_term = ''
    form.breach_of_contract_liability = ''
    form.dispute_resolution_method = ''
    form.other_agreements = ''
    form.lines = []
    clientOptions.value = []
    supplierOptions.value = []
    productOptionsMap.value = {}
    formRef.value?.resetFields()
  }

  const DEFAULT_CLAUSES = {
    quality_standard:
      '产品含量、杂质等符合国家标准或双方约定（如含量≥98%、≥70%等），无杂质要求，保质期2年。',
    delivery_location_method: '供方按时将货物送到需方指定地址。',
    transportation_cost_bearer: '运输费用由供方承担。',
    loss_calculation_method: '经双方协商解决。',
    packaging_standard: '25公斤袋装，不能破损。供方对因包装质量问题造成的损失负责。',
    packaging_loss_responsibility: '供方对因包装质量问题造成的损失负责。',
    inspection_method:
      '需方到货后核对品名、数量、批号。需方对原料进行复测，复测期限3天内；如有异议一周内提出。需方未对原料进行检测导致的质量问题由需方承担。',
    reinspection_period: '3天内复测。',
    objection_period: '一周内提出异议。',
    quality_issue_responsibility: '需方未对原料进行检测导致的质量问题由需方承担。',
    spare_parts_supply: '无。',
    settlement_method_term: '到货后提供分析报告，开具增值税发票后扣款。',
    breach_of_contract_liability: '按《民法典》有关条款执行。',
    dispute_resolution_method: '双方友好协商解决。',
    other_agreements: '经双方签字后传真产生法律效力。'
  }

  const fillDefaultClauses = () => {
    form.quality_standard = DEFAULT_CLAUSES.quality_standard
    form.delivery_location_method = DEFAULT_CLAUSES.delivery_location_method
    form.transportation_cost_bearer = DEFAULT_CLAUSES.transportation_cost_bearer
    form.loss_calculation_method = DEFAULT_CLAUSES.loss_calculation_method
    form.packaging_standard = DEFAULT_CLAUSES.packaging_standard
    form.packaging_loss_responsibility = DEFAULT_CLAUSES.packaging_loss_responsibility
    form.inspection_method = DEFAULT_CLAUSES.inspection_method
    form.reinspection_period = DEFAULT_CLAUSES.reinspection_period
    form.objection_period = DEFAULT_CLAUSES.objection_period
    form.quality_issue_responsibility = DEFAULT_CLAUSES.quality_issue_responsibility
    form.spare_parts_supply = DEFAULT_CLAUSES.spare_parts_supply
    form.settlement_method_term = DEFAULT_CLAUSES.settlement_method_term
    form.breach_of_contract_liability = DEFAULT_CLAUSES.breach_of_contract_liability
    form.dispute_resolution_method = DEFAULT_CLAUSES.dispute_resolution_method
    form.other_agreements = DEFAULT_CLAUSES.other_agreements
  }

  const fillCodeFromPreview = async () => {
    try {
      const res = await previewDocNumberApi('pur_contracts_raw_material')
      const d = (res as any).data || {}
      if (d.code) form.code = d.code
    } catch {
      /* ignore */
    }
  }

  watch(
    () => props.modelValue,
    (val) => {
      if (val) {
        form.signing_date = new Date().toISOString().slice(0, 10)
        fillDefaultClauses()
        fillCodeFromPreview()
        if (form.lines.length === 0) handleAddLine()
      }
    }
  )
</script>

<style scoped>
  .dialog-body-scroll {
    max-height: 65vh;
    overflow-y: auto;
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

  .inline-add-wrap {
    display: flex;
    gap: 4px;
    align-items: center;
    width: 100%;
  }

  .inline-add-wrap .el-select {
    flex: 1;
    min-width: 0;
  }
</style>
