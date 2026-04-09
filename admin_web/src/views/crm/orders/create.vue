<template>
  <div class="order-create-page art-full-height">
    <div class="flex items-center justify-between mb-3">
      <div class="text-base font-medium text-g-900">新建 CRM 订单</div>
      <div class="flex items-center gap-2">
        <ElButton @click="goBack">返回</ElButton>
        <ElButton type="primary" :loading="submitting" @click="submit">保存订单</ElButton>
      </div>
    </div>

    <ElCard class="art-table-card" shadow="never">
      <ElAlert
        v-if="sourceCustomerName"
        class="mb-3"
        type="info"
        :closable="false"
        :title="`来源预购客户：${sourceCustomerName}`"
      />
      <br />

      <ElForm :model="form" label-width="100px" class="grid-form">
        <ElFormItem label="客户" required>
          <ElSelect
            v-model="form.client_id"
            filterable
            remote
            clearable
            reserve-keyword
            :loading="clientsLoading"
            :remote-method="remoteSearchClients"
            placeholder="输入关键字搜索；无匹配时仅显示下方「创建客户」"
          >
            <ElOption v-for="c in clients" :key="c.id" :label="c.name" :value="c.id" />
            <ElOption
              :value="''"
              disabled
              style="border-top: 1px solid var(--el-border-color-lighter)"
            >
              <div class="client-option-footer">
                <ElButton
                  text
                  type="primary"
                  size="small"
                  :disabled="!clientKeyword.trim()"
                  @click.stop="createClientFromKeyword"
                >
                  创建客户：{{ clientKeyword.trim() || '请输入客户名称' }}
                </ElButton>
              </div>
            </ElOption>
          </ElSelect>
        </ElFormItem>
        <ElFormItem label="接单日期">
          <div class="receive-date-row">
            <ElDatePicker v-model="form.receive_date" type="date" value-format="YYYY-MM-DD" />
          </div>
        </ElFormItem>
        <ElFormItem label="合同编号">
          <ElInput v-model="form.contract_code" clearable />
        </ElFormItem>
        <ElFormItem label="危包月份">
          <ElInput v-model="form.hazard_pack_month" clearable placeholder="例如：2026-03" />
        </ElFormItem>
        <ElFormItem label="客户交期">
          <ElDatePicker
            v-model="form.customer_delivery_date"
            type="date"
            value-format="YYYY-MM-DD"
          />
        </ElFormItem>
        <ElFormItem label="跟进人">
          <ElSelect
            v-model="form.follower_id"
            filterable
            clearable
            placeholder="跟进人（默认当前用户）"
          >
            <ElOption
              v-for="u in users"
              :key="u.id"
              :label="u.userName || u.name || String(u.id)"
              :value="u.id"
            />
          </ElSelect>
        </ElFormItem>
        <ElFormItem label="规格要求">
          <ElInput
            v-model="form.spec_requirements"
            type="textarea"
            :rows="2"
            clearable
            placeholder="自动带入，可修改"
          />
        </ElFormItem>
        <ElFormItem label="订单状态">
          <PropertySelectWithAdd
            v-model="form.status_id"
            sign="crm_order_status"
            placeholder="请选择或创建订单状态"
          />
        </ElFormItem>
        <ElFormItem label="金额">
          <ElInput v-model="form.amount" type="number" clearable readonly />
        </ElFormItem>
      </ElForm>

      <div class="flex items-center justify-between mt-2 mb-2">
        <div class="font-medium">订单明细</div>
        <ElButton type="primary" link @click="addLine">新增明细</ElButton>
      </div>

      <ElTable :data="lines" border stripe>
        <ElTableColumn type="index" label="#" width="50" />
        <ElTableColumn label="产品" min-width="160">
          <template #default="{ row }">
            <ElSelect
              v-model="row.product_id"
              filterable
              clearable
              placeholder="选择产品"
              @change="(id: any) => onProductChange(row, id)"
            >
              <ElOption
                v-for="prod in products"
                :key="prod.id"
                :label="`${prod.code || ''} ${prod.name || ''}`"
                :value="prod.id"
              />
            </ElSelect>
          </template>
        </ElTableColumn>
        <ElTableColumn label="产品名称" min-width="140">
          <template #default="{ row }">
            <ElInput
              v-model="row.product_name"
              clearable
              :class="{ 'required-error-input': isRequiredInvalid(row, 'product_name') }"
              @blur="() => syncProductFromLine(row)"
            />
          </template>
        </ElTableColumn>
        <ElTableColumn label="型号" width="120">
          <template #default="{ row }"><ElInput v-model="row.model" clearable /></template>
        </ElTableColumn>
        <ElTableColumn label="颜色" width="110">
          <template #default="{ row }"><ElInput v-model="row.color" clearable /></template>
        </ElTableColumn>
        <ElTableColumn label="克重" width="110">
          <template #default="{ row }"
            ><ElInput v-model="row.weight" clearable @blur="() => syncProductFromLine(row)"
          /></template>
        </ElTableColumn>
        <ElTableColumn label="数量" width="100">
          <template #default="{ row }"
            ><ElInput
              v-model="row.qty"
              type="number"
              :min="0"
              clearable
              :class="{ 'required-error-input': isRequiredInvalid(row, 'qty') }"
              @input="() => onLineNumberChange(row)"
          /></template>
        </ElTableColumn>
        <ElTableColumn label="单位" width="90">
          <template #default="{ row }"><ElInput v-model="row.unit" clearable /></template>
        </ElTableColumn>
        <ElTableColumn label="库存状态" width="140">
          <template #default="{ row }"><ElInput v-model="row.stock_status" clearable /></template>
        </ElTableColumn>
        <ElTableColumn label="色母状况" width="100">
          <template #default="{ row }"
            ><ElInput v-model="row.color_master_status" clearable
          /></template>
        </ElTableColumn>
        <ElTableColumn label="单价" width="120">
          <template #default="{ row }">
            <ElInput
              v-model="row.unit_price"
              type="number"
              :min="0"
              clearable
              @input="() => onLineNumberChange(row)"
            />
          </template>
        </ElTableColumn>
        <ElTableColumn label="金额" width="130">
          <template #default="{ row }"
            ><ElInput v-model="row.line_amount" type="number" readonly
          /></template>
        </ElTableColumn>
        <ElTableColumn label="产品图文" width="130">
          <template #default="{ row }">
            <ElUpload
              :show-file-list="false"
              :auto-upload="false"
              accept="image/*"
              @change="(f: any) => onLineFileChange(row, f)"
            >
              <ElButton size="small" type="primary" link>上传</ElButton>
            </ElUpload>
            <div v-if="row._fileName" class="line-file-name">{{ row._fileName }}</div>
          </template>
        </ElTableColumn>
        <ElTableColumn label="操作" width="100" fixed="right">
          <template #default="{ $index }">
            <ElButton link type="danger" @click="removeLine($index)">删除</ElButton>
          </template>
        </ElTableColumn>
      </ElTable>
    </ElCard>
  </div>
</template>

<script setup lang="ts">
  import { computed, onMounted, reactive, ref } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import { ElButton, ElCard, ElMessage, ElOption, ElSelect, ElUpload } from 'element-plus'
  import { useUserStore } from '@/store/modules/user'
  import { listUserApi } from '@/api/user'
  import { createCrmClientApi, listCrmClientApi } from '@/api/crm/client'
  import { createCrmOrderApi, uploadCrmOrderLineFileApi } from '@/api/crm/order'
  import { viewCrmPreOrderApi } from '@/api/crm/pre-order'
  import { listMatProductApi, updateMatProductApi } from '@/api/mat/product'
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'

  defineOptions({ name: 'CrmOrderCreate' })

  const route = useRoute()
  const router = useRouter()
  const userStore = useUserStore()
  const submitting = ref(false)
  const submitAttempted = ref(false)
  const users = ref<any[]>([])
  const clients = ref<any[]>([])
  const clientsLoading = ref(false)
  const products = ref<any[]>([])
  const clientKeyword = ref('')

  /** 远程搜索：必须用 remote-method，勿与 filter-method 混用（后者会禁用内部过滤且无反应） */
  async function fetchClientsList(query: string) {
    clientKeyword.value = query
    clientsLoading.value = true
    try {
      const t = query.trim()
      const params: Record<string, unknown> = { page: 1, per_page: 200 }
      if (t) {
        // Rails Ransack：扁平键最稳妥，避免 axios 嵌套对象序列化与后端不一致
        ;(params as Record<string, string>)['q[name_cont]'] = t
      }
      const res = await listCrmClientApi(params)
      clients.value = (res as any).data || []
    } finally {
      clientsLoading.value = false
    }
  }

  const remoteSearchClients = useDebounceFn((query: string) => fetchClientsList(query), 300)

  const form = reactive<any>({
    pre_order_id: undefined,
    client_id: undefined,
    follower_id: undefined as number | undefined,
    receive_date: new Date().toISOString().slice(0, 10),
    contract_code: '',
    hazard_pack_month: '',
    customer_delivery_date: '',
    spec_requirements: '',
    status_id: null as number | null,
    amount: 0
  })

  const lines = ref<any[]>([])

  const sourceCustomerName = computed(() => String(route.query.customer_name || ''))

  function addLine() {
    lines.value.push({
      product_id: undefined,
      product_name: '',
      model: '',
      color: '',
      weight: '',
      qty: 0,
      unit: '只',
      stock_status: '',
      color_master_status: '',
      remark: '',
      unit_price: 0,
      line_amount: 0,
      _file: undefined as File | undefined,
      _fileName: '',
      _origin_product_name: '',
      _origin_gram_weight: ''
    })
    syncOrderAmount()
  }

  function onLineFileChange(row: any, uploadFile: any) {
    const raw = uploadFile?.raw as File | undefined
    row._file = raw
    row._fileName = raw?.name || ''
  }

  async function loadUsers() {
    const res = await listUserApi({ page: 1, per_page: 500 })
    users.value = (res as any).data || []
  }

  function removeLine(idx: number) {
    lines.value.splice(idx, 1)
    syncOrderAmount()
  }

  function toNumber(v: unknown): number {
    const n = Number(v)
    return Number.isFinite(n) ? n : 0
  }

  function toNonNegative(v: unknown): number {
    return Math.max(0, toNumber(v))
  }

  function round2(n: number): number {
    return Math.round(n * 100) / 100
  }

  function onLineNumberChange(row: any) {
    const qty = toNonNegative(row.qty)
    const unitPrice = toNonNegative(row.unit_price)
    row.qty = qty
    row.unit_price = unitPrice
    row.line_amount = round2(qty * unitPrice)
    syncOrderAmount()
  }

  function syncOrderAmount() {
    const total = lines.value.reduce((sum, line) => sum + toNumber(line.line_amount), 0)
    form.amount = round2(total)
  }

  function onProductChange(row: any, id: any) {
    const product = products.value.find((x) => x.id === id)
    if (!product) {
      row._origin_product_name = ''
      row._origin_gram_weight = ''
      return
    }
    row.product_name = row.product_name || product.name || ''
    row.model = row.model || product.code || ''
    row.color = row.color || product.material || ''
    row.weight = row.weight || product.gram_weight || product.nominal_capacity || ''
    row.unit = row.unit || product.uom_name || '只'
    row._origin_product_name = String(product.name ?? '').trim()
    row._origin_gram_weight = String(product.gram_weight ?? '').trim()
  }

  async function syncProductFromLine(row: any) {
    if (!row?.product_id) return
    const nextName = String(row.product_name ?? '').trim()
    const nextGramWeight = String(row.weight ?? '').trim()
    const originName = String(row._origin_product_name ?? '').trim()
    const originGramWeight = String(row._origin_gram_weight ?? '').trim()
    if (nextName === originName && nextGramWeight === originGramWeight) return

    const updateFields: Record<string, any> = {}
    if (nextName) updateFields.name = nextName
    updateFields.gram_weight = nextGramWeight

    try {
      await updateMatProductApi(String(row.product_id), { product: updateFields })
      row._origin_product_name = nextName
      row._origin_gram_weight = nextGramWeight

      const local = products.value.find((p) => String(p.id) === String(row.product_id))
      if (local) {
        if (nextName) local.name = nextName
        local.gram_weight = nextGramWeight
      }
    } catch (e: any) {
      ElMessage.warning(e?.message || '产品信息回写失败，请稍后重试')
    }
  }

  async function createClientFromKeyword() {
    const name = clientKeyword.value.trim()
    if (!name) {
      ElMessage.warning('请输入客户名称')
      return
    }
    const exists = clients.value.find((c) => c.name === name)
    if (exists) {
      form.client_id = exists.id
      ElMessage.success('已选择现有客户')
      return
    }
    const created = await createCrmClientApi({ name })
    const id = (created as any).data?.id
    if (id) {
      await fetchClientsList(clientKeyword.value.trim())
      form.client_id = id
      ElMessage.success('客户已创建并选中')
    }
  }

  async function loadProducts() {
    const res = await listMatProductApi({ page: 1, per_page: 500 })
    products.value = (res as any).data || []
  }

  async function loadFromPreOrder() {
    const pid = route.query.pre_order_id
    if (!pid) {
      if (sourceCustomerName.value) {
        form.spec_requirements = `来源客户：${sourceCustomerName.value}`
      }
      return
    }

    form.pre_order_id = pid
    const res = await viewCrmPreOrderApi({ id: pid })
    const po = (res as any).data || {}
    form.contract_code = po.customer_code || ''
    form.spec_requirements = po.spec_requirements || ''
    const items = Array.isArray(po.line_items) ? po.line_items : []
    lines.value = items.map((x: any) => ({
      product_id: x.product_id,
      product_name: x.product_name || '',
      model: x.model || '',
      color: x.color || '',
      weight: x.weight || '',
      qty: x.quantity || x.qty || 0,
      unit: x.unit || '只',
      stock_status: x.stock_status || '',
      color_master_status: x.color_master_status || '',
      remark: x.remark || '',
      unit_price: x.unit_price ?? 0,
      line_amount: x.line_amount ?? 0,
      _origin_product_name: String(x.product_name || '').trim(),
      _origin_gram_weight: String(x.weight || '').trim()
    }))
    lines.value.forEach((line) => onLineNumberChange(line))
    if (!lines.value.length) addLine()
  }

  async function ensureClientId(): Promise<string | number | undefined> {
    const current = form.client_id
    if (current == null || current === '') return undefined
    if (typeof current === 'number') return current
    const text = String(current)
    if (/^\d+$/.test(text)) return Number(text)

    const existing = clients.value.find((c) => c.name === text)
    if (existing) return existing.id

    const created = await createCrmClientApi({ name: text })
    const id = (created as any).data?.id
    if (id) {
      await fetchClientsList('')
      ElMessage.success('客户已创建')
      return id
    }
    return undefined
  }

  function validate() {
    if (!lines.value.length) return '请至少填写一条订单明细'
    const bad = lines.value.find(
      (l) => !l.product_name || !l.color || toNonNegative(l.qty) <= 0 || !l.unit
    )
    if (bad) return '明细必填：产品名称、颜色、数量（大于0）、单位'
    return ''
  }

  function isRequiredInvalid(row: any, field: 'product_name' | 'qty') {
    if (!submitAttempted.value) return false
    if (field === 'product_name') return !String(row?.product_name ?? '').trim()
    return toNonNegative(row?.qty) <= 0
  }

  async function syncChangedProductsFromLines() {
    const updates = new Map<string | number, { name: string; gram_weight: string }>()
    for (const line of lines.value) {
      if (!line?.product_id) continue
      const id = line.product_id as string | number
      updates.set(id, {
        name: String(line.product_name ?? '').trim(),
        gram_weight: String(line.weight ?? '').trim()
      })
    }

    for (const [id, nextVal] of updates.entries()) {
      const line = lines.value.find((l) => l?.product_id === id)
      const originName = String(line?._origin_product_name ?? '').trim()
      const originGramWeight = String(line?._origin_gram_weight ?? '').trim()
      const changed = nextVal.name !== originName || nextVal.gram_weight !== originGramWeight
      if (!changed) continue

      const updateFields: Record<string, any> = {}
      if (nextVal.name) updateFields.name = nextVal.name
      updateFields.gram_weight = nextVal.gram_weight

      // 后端强参数为 params.require(:product)
      await updateMatProductApi(String(id), { product: updateFields })

      if (line) {
        line._origin_product_name = nextVal.name
        line._origin_gram_weight = nextVal.gram_weight
      }
    }
  }

  async function submit() {
    submitAttempted.value = true
    const err = validate()
    if (err) {
      ElMessage.warning(err)
      return
    }
    submitting.value = true
    try {
      const clientId = await ensureClientId()
      if (!clientId) {
        ElMessage.warning('请选择或输入客户')
        return
      }

      const payload = {
        ...form,
        client_id: clientId,
        follow_progress: form.spec_requirements,
        line_items: lines.value.map((l) => {
          const o = { ...l }
          delete o._file
          delete o._fileName
          return o
        }),
        delivered_qty: 0,
        invoice_amount: 0,
        invoice_at: '',
        payment_amount: 0,
        payment_at: ''
      }
      const res = (await createCrmOrderApi(payload)) as any
      const created = res.data || {}
      const createdLines = Array.isArray(created.line_items) ? created.line_items : []
      for (let i = 0; i < lines.value.length; i++) {
        const file = lines.value[i]._file as File | undefined
        const lineId = createdLines[i]?.id
        if (file && lineId) {
          await uploadCrmOrderLineFileApi(lineId, file)
        }
      }
      try {
        await syncChangedProductsFromLines()
      } catch (e: any) {
        ElMessage.warning(e?.message || '订单已创建，但产品名称/克重回写失败，请稍后重试')
      }
      ElMessage.success('订单创建成功')
      router.push({ path: `/crm/orders/${created.id}` })
    } finally {
      submitting.value = false
    }
  }

  function goBack() {
    router.push({ path: '/crm/orders' })
  }

  onMounted(async () => {
    form.follower_id = userStore.info?.userId
    await Promise.all([fetchClientsList(''), loadProducts(), loadUsers()])
    await loadFromPreOrder()
    if (!lines.value.length) addLine()
  })
</script>

<style scoped>
  @reference '@styles/core/tailwind.css';

  .order-create-page {
    @apply p-4;

    display: flex;
    flex-direction: column;
  }

  .grid-form {
    display: grid;
    grid-template-columns: repeat(2, minmax(0, 1fr));
    gap: 0 14px;
  }

  .client-option-footer {
    display: flex;
    align-items: center;
    justify-content: center;
    padding: 4px 0;
  }

  .line-file-name {
    margin-top: 4px;
    font-size: 11px;
    line-height: 1.2;
    color: var(--el-text-color-secondary);
    word-break: break-all;
  }

  .receive-date-row {
    display: flex;
    flex-wrap: wrap;
    gap: 10px;
    align-items: center;
    width: 100%;
  }

  .receive-date-quick {
    flex-shrink: 0;
  }

  :deep(.required-error-input .el-input__wrapper) {
    border-color: var(--el-color-danger) !important;
    box-shadow: 0 0 0 1px var(--el-color-danger) inset !important;
  }
</style>
