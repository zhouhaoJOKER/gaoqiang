<template>
  <ElDialog
    v-model="dialogVisible"
    title="新增包装箱采购"
    width="1200px"
    :close-on-click-modal="false"
    class="carton-purchase-dialog"
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
            <span>包装箱明细</span>
            <ElButton type="primary" size="small" @click="handleAddLine">添加行</ElButton>
          </div>
          <ElTable :data="form.lines" border style="width: 100%">
            <ElTableColumn type="index" label="序号" width="55" />
            <ElTableColumn label="品名" min-width="200">
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
            <ElTableColumn label="长" width="90">
              <template #default="{ row }">
                <ElInput
                  v-model.number="row.length"
                  type="number"
                  placeholder="长"
                  @blur="onSizeBlur(row)"
                />
              </template>
            </ElTableColumn>
            <ElTableColumn label="宽" width="90">
              <template #default="{ row }">
                <ElInput
                  v-model.number="row.width"
                  type="number"
                  placeholder="宽"
                  @blur="onSizeBlur(row)"
                />
              </template>
            </ElTableColumn>
            <ElTableColumn label="高" width="90">
              <template #default="{ row }">
                <ElInput
                  v-model.number="row.height"
                  type="number"
                  placeholder="高"
                  @blur="onSizeBlur(row)"
                />
              </template>
            </ElTableColumn>
            <ElTableColumn label="数量" width="100">
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
            <ElTableColumn label="总金额(RMB)" width="120">
              <template #default="{ row }">
                <ElInput :model-value="formatMoney(row.amount)" type="text" readonly />
              </template>
            </ElTableColumn>
            <ElTableColumn label="备注" min-width="160">
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
                placeholder="如：按甲方认可的样箱标准执行"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="交货地点及方式" prop="delivery_location_method">
              <ElInput
                v-model="form.delivery_location_method"
                type="textarea"
                :rows="1"
                placeholder="如：供方按时将货物送到需方指定地点"
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
                placeholder="如：按合同约定包装箱规格及质量执行"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="验收标准及方法" prop="acceptance_standard">
              <ElInput
                v-model="form.acceptance_standard"
                type="textarea"
                :rows="2"
                placeholder="如：按双方确认样箱及国家相关标准验收"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="交货时间" prop="delivery_time">
              <ElInput
                v-model="form.delivery_time"
                type="textarea"
                :rows="1"
                placeholder="如：按甲方订单约定时间供货"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="结算方式" prop="settlement_method">
              <ElInput
                v-model="form.settlement_method"
                type="textarea"
                :rows="1"
                placeholder="如：按实际到货数量结算，月结等"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="违约责任" prop="breach_liability">
              <ElInput
                v-model="form.breach_liability"
                type="textarea"
                :rows="2"
                placeholder="如：一方违约造成损失由违约方承担"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="其他约定" prop="other_terms">
              <ElInput
                v-model="form.other_terms"
                type="textarea"
                :rows="2"
                placeholder="如：未尽事宜双方友好协商解决"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
      </ElForm>
    </div>
    <template #footer>
      <span class="dialog-footer">
        <ElButton @click="dialogVisible = false">取 消</ElButton>
        <ElButton type="primary" :loading="saving" @click="handleSave">保存</ElButton>
      </span>
    </template>
  </ElDialog>
  <ClientDialog v-model="clientDialogVisible" @created="onClientCreated" />
  <SupplierDialog v-model="supplierDialogVisible" @created="onSupplierCreated" />
</template>

<script setup lang="ts">
  import { computed, reactive, ref, watch } from 'vue'
  import type { FormInstance } from 'element-plus'
  import {
    ElButton,
    ElCol,
    ElDatePicker,
    ElDialog,
    ElDivider,
    ElForm,
    ElFormItem,
    ElInput,
    ElOption,
    ElRow,
    ElSelect,
    ElTable,
    ElTableColumn,
    ElMessage
  } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import ClientDialog from '@/views/crm/clients/modules/client-dialog.vue'
  import SupplierDialog from '@/views/pur/suppliers/modules/supplier-dialog.vue'
  import { previewDocNumberApi } from '@/api/doc-number'
  import { listCrmClientApi } from '@/api/crm/client'
  import { listMatSupplierApi } from '@/api/mat/supplier'
  import { createPurContractApi } from '@/api/pur/contract'
  import { listMatItemApi, createMatItemApi, updateMatItemApi } from '@/api/mat/item'

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

  const form = reactive<any>({
    code: '',
    client_id: undefined,
    supplier_id: undefined,
    signing_date: '',
    signing_location: '',
    remark: '',
    quality_standard: '',
    delivery_location_method: '',
    transportation_cost_bearer: '',
    loss_calculation_method: '',
    packaging_standard: '',
    acceptance_standard: '',
    delivery_time: '',
    settlement_method: '',
    breach_liability: '',
    other_terms: '',
    lines: [] as any[]
  })

  const clientOptions = ref<any[]>([])
  const supplierOptions = ref<any[]>([])
  const clientSearchLoading = ref(false)
  const supplierSearchLoading = ref(false)
  const clientDialogVisible = ref(false)
  const supplierDialogVisible = ref(false)

  const lineProductLoading = ref(false)
  const productOptionsMap = ref<Record<string, any[]>>({})

  const dialogOpened = () => {
    if (!form.code) {
      fillCodeFromPreview()
    }
    if (!form.signing_date) {
      form.signing_date = new Date().toISOString().slice(0, 10)
    }
    if (form.lines.length === 0) {
      handleAddLine()
    }
  }

  const fillCodeFromPreview = async () => {
    try {
      const res = await previewDocNumberApi('pur_contracts_carton')
      const d = (res as any).data || {}
      if (d.code) form.code = d.code
    } catch {
      // ignore
    }
  }

  const searchClients = async (q: string) => {
    clientSearchLoading.value = true
    try {
      const res = await listCrmClientApi({ 'q[name_or_code_cont]': q, per_page: 50 })
      const data = (res as any).data || []
      clientOptions.value = Array.isArray(data) ? data : data.list || data.data || []
    } finally {
      clientSearchLoading.value = false
    }
  }

  const searchSuppliers = async (q: string) => {
    supplierSearchLoading.value = true
    try {
      const res = await listMatSupplierApi({ 'q[name_or_code_cont]': q, per_page: 50 })
      const data = (res as any).data || []
      supplierOptions.value = Array.isArray(data) ? data : data.list || data.data || []
    } finally {
      supplierSearchLoading.value = false
    }
  }

  const onClientCreated = (c: any) => {
    if (!c) return
    clientOptions.value = [c, ...clientOptions.value]
    form.client_id = c.id
  }

  const onSupplierCreated = (s: any) => {
    if (!s) return
    supplierOptions.value = [s, ...supplierOptions.value]
    form.supplier_id = s.id
  }

  const getLineKey = (row: any) => {
    if (!row._lineKey) row._lineKey = String(Math.random())
    return row._lineKey
  }

  const searchLineProducts = async (q: string, row: any) => {
    const key = getLineKey(row)
    lineProductLoading.value = true
    try {
      const res = await listMatItemApi({
        'q[name_or_code_cont]': q,
        'q[type_id_eq]': 300,
        per_page: 50
      })
      const data = (res as any).data || []
      const arr = Array.isArray(data) ? data : data.list || data.data || []
      const opts = arr.filter((it: any) => it && it.id != null)
      const createLabel =
        q && !opts.some((it: any) => it.name === q)
          ? [{ id: `__create__${q}`, name: `创建产品「${q}」`, code: '' }]
          : []
      productOptionsMap.value[key] = [...opts, ...createLabel]
    } finally {
      lineProductLoading.value = false
    }
  }

  const getLineProductOptions = (row: any) => {
    const key = getLineKey(row)
    return productOptionsMap.value[key] || []
  }

  const onLineProductChange = async (row: any, val: any) => {
    if (typeof val === 'string' && val.startsWith('__create__')) {
      const name = val.replace('__create__', '')
      try {
        const res = await createMatItemApi({ name, type_id: 300 })
        const item = (res as any).data || {}
        row.product_id = item.id
        row.product_name = item.name
        const key = getLineKey(row)
        const list = productOptionsMap.value[key] || []
        productOptionsMap.value[key] = [{ id: item.id, name: item.name, code: item.code }, ...list]
      } catch {
        row.product_id = undefined
      }
    } else {
      const key = getLineKey(row)
      const item = (productOptionsMap.value[key] || []).find(
        (it: any) => String(it.id) === String(val)
      )
      row.product_name = item ? item.name : ''
      // 带入产品已有的长宽高
      if (item) {
        row.length = item.length ?? row.length
        row.width = item.width ?? row.width
        row.height = item.height ?? row.height
      }
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

  const onSizeBlur = async (row: any) => {
    if (!row.product_id) return
    const payload: any = {}
    if (row.length != null && row.length !== '') payload.length = row.length
    if (row.width != null && row.width !== '') payload.width = row.width
    if (row.height != null && row.height !== '') payload.height = row.height
    if (Object.keys(payload).length === 0) return
    try {
      await updateMatItemApi(String(row.product_id), payload)
    } catch {
      // ignore 更新失败仅不回写，不影响当前行
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
      length: undefined,
      width: undefined,
      height: undefined,
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
      (l: any) =>
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
        sign: 'carton',
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
        acceptance_standard: form.acceptance_standard || undefined,
        delivery_time: form.delivery_time || undefined,
        settlement_method: form.settlement_method || undefined,
        breach_liability: form.breach_liability || undefined,
        other_terms: form.other_terms || undefined,
        collections: validLines.map((l: any, idx: number) => ({
          product_id: l.product_id,
          product_name: l.product_name,
          unit: l.unit,
          unit_id: l.unit_id,
          qty: l.qty,
          price: l.price,
          amount_excl_tax: l.amount_excl_tax,
          tax: l.tax,
          amount: l.amount,
          length: l.length,
          width: l.width,
          height: l.height,
          remark: l.remark,
          sort: idx
        }))
      }
      const res = await createPurContractApi(payload)
      const data = (res as any).data || res
      ElMessage.success('保存成功')
      emit('created', data)
    } catch (e) {
      console.error(e)
    } finally {
      saving.value = false
    }
  }

  const resetForm = () => {
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
    form.acceptance_standard = ''
    form.delivery_time = ''
    form.settlement_method = ''
    form.breach_liability = ''
    form.other_terms = ''
    form.lines = []
    productOptionsMap.value = {}
  }

  const handleClosed = () => {
    resetForm()
  }

  watch(
    () => dialogVisible.value,
    (v) => {
      if (v) dialogOpened()
    }
  )
</script>

<style scoped>
  .dialog-body-scroll {
    max-height: 70vh;
    padding-right: 4px;
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
