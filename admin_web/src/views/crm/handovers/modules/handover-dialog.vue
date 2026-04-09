<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="960px"
    :close-on-click-modal="false"
    class="handover-dialog"
    @closed="handleClosed"
  >
    <div class="dialog-body-scroll">
      <ElForm ref="formRef" :model="form" :rules="rules" label-width="140px">
        <ElRow :gutter="20">
          <ElCol v-if="!props.initialContractId" :span="12">
            <ElFormItem label="关联合同" prop="contract_id">
              <ElSelect
                v-model="form.contract_id"
                placeholder="请选择合同"
                filterable
                remote
                :remote-method="searchContracts"
                :loading="contractSearchLoading"
                style="width: 100%"
                :disabled="props.readonly || !!props.initialContractId"
              >
                <ElOption
                  v-for="c in contractOptions"
                  :key="c.id"
                  :label="`[${c.code || ''}]`"
                  :value="c.id"
                />
              </ElSelect>
            </ElFormItem>
          </ElCol>
          <ElCol v-if="props.initialContractId" :span="24">
            <ElFormItem label="关联合同"><span class="text-secondary">当前合同</span></ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="交接单号" prop="doc_no">
              <ElInput
                v-model="form.doc_no"
                placeholder="请输入交接单号"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="订购公司名称" prop="order_company">
              <ElInput
                v-model="form.order_company"
                placeholder="请输入订购公司名称"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="订购合同号" prop="order_contract_no">
              <ElInput
                v-model="form.order_contract_no"
                placeholder="请输入订购合同号"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="合同要求发货时间" prop="deliver_at">
              <ElDatePicker
                v-model="form.deliver_at"
                type="date"
                placeholder="请选择"
                style="width: 100%"
                value-format="YYYY-MM-DD"
                :disabled="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="合同货物名称" prop="goods_name">
              <ElInput
                v-model="form.goods_name"
                placeholder="请输入合同货物名称"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="包装规格" prop="pack_specs">
              <ElInput
                v-model="form.pack_specs"
                type="textarea"
                :rows="2"
                placeholder="请输入包装规格"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="订货性质" prop="order_kind">
              <div class="order-kind-wrap">
                <ElSelect
                  v-model="form.order_kind"
                  placeholder="请选择或输入订货性质"
                  filterable
                  allow-create
                  default-first-option
                  clearable
                  style="width: 100%"
                  :disabled="props.readonly"
                >
                  <ElOption v-for="opt in orderKindOptions" :key="opt" :label="opt" :value="opt" />
                </ElSelect>
                <ElButton
                  v-if="!props.readonly"
                  type="primary"
                  link
                  class="config-btn"
                  @click="orderKindConfigVisible = true"
                >
                  配置
                </ElButton>
              </div>
              <PropertyConfigDialog
                v-model="orderKindConfigVisible"
                sign="crm_order_kind"
                title="订货性质配置"
                @updated="loadOrderKindOptions"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="特殊订货说明" prop="special_note">
              <ElInput
                v-model="form.special_note"
                placeholder="请输入特殊订货说明"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="数量" prop="qty">
              <ElInput
                v-model="form.qty"
                type="number"
                placeholder="数量"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="数量单位" prop="qty_unit">
              <ElInput
                v-model="form.qty_unit"
                placeholder="如：KG、件"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="货物详细规格" prop="specs">
              <ElInput
                v-model="form.specs"
                type="textarea"
                :rows="2"
                placeholder="请输入货物详细规格"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
        <div class="lines-section">
          <div class="lines-header">
            <span>指标要求明细</span>
            <span v-if="!props.readonly" class="lines-actions">
              <ElButton type="primary" size="small" @click="handleAddLine">添加行</ElButton>
              <ElButton size="small" @click="handleAddAllLines">添加全部</ElButton>
            </span>
          </div>
          <ElTable :data="form.lines" border style="width: 100%">
            <ElTableColumn type="index" label="序号" width="55" />
            <ElTableColumn label="指标项目" min-width="180">
              <template #default="{ row }">
                <ElSelect
                  v-model="row.spec_item_id"
                  placeholder="输入名称或拼音搜索，可输入新名称快速创建"
                  filterable
                  remote
                  :remote-method="searchSpecItems"
                  default-first-option
                  style="width: 100%"
                  :disabled="props.readonly"
                  @change="
                    (val: string | number) => {
                      onSpecItemSelect(row, val)
                      if (typeof val === 'string' && (val || '').trim()) ensureSpecItemCreated(row)
                    }
                  "
                >
                  <ElOption
                    v-for="s in getSpecItemOptions"
                    :key="String(s.id)"
                    :label="s.name"
                    :value="s.id"
                  />
                </ElSelect>
              </template>
            </ElTableColumn>
            <ElTableColumn label="合同要求" min-width="160">
              <template #default="{ row, $index }">
                <ElSelect
                  v-model="row.contract_req"
                  placeholder="从指标值选择或输入新值"
                  filterable
                  default-first-option
                  style="width: 100%"
                  :disabled="props.readonly"
                  :filter-method="
                    (q: string) => {
                      contractReqFilterMap[$index] = q
                    }
                  "
                  @focus="ensureSpecItemValuesLoaded(row.spec_item_id)"
                  @change="(val: string | number) => onContractReqChange(row, val as string)"
                >
                  <ElOption
                    v-for="opt in getContractReqOptions(row, $index)"
                    :key="opt.value"
                    :label="opt.label"
                    :value="opt.value"
                  />
                </ElSelect>
              </template>
            </ElTableColumn>
            <ElTableColumn label="内控要求" min-width="160">
              <template #default="{ row, $index }">
                <ElSelect
                  v-model="row.internal_req"
                  placeholder="从指标值选择或输入新值"
                  filterable
                  default-first-option
                  style="width: 100%"
                  :disabled="props.readonly"
                  :filter-method="
                    (q: string) => {
                      internalReqFilterMap[$index] = q
                    }
                  "
                  @focus="ensureSpecItemValuesLoaded(row.spec_item_id)"
                  @change="(val: string | number) => onInternalReqChange(row, val as string)"
                >
                  <ElOption
                    v-for="opt in getInternalReqOptions(row, $index)"
                    :key="opt.value"
                    :label="opt.label"
                    :value="opt.value"
                  />
                </ElSelect>
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
    </div>
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
    createCrmHandoverApi,
    updateCrmHandoverApi,
    viewCrmHandoverApi
  } from '@/api/crm/handover'
  import { listCrmHandoverLineApi } from '@/api/crm/handover'
  import { listCrmContractApi, viewCrmContractApi } from '@/api/crm/contract'
  import {
    listCrmSpecItemApi,
    createCrmSpecItemApi,
    viewCrmSpecItemApi,
    updateCrmSpecItemApi
  } from '@/api/crm/spec-item'
  import { listPropertyApi } from '@/api/property'
  import { previewDocNumberApi } from '@/api/doc-number'
  import PropertyConfigDialog from '@/components/PropertyConfigDialog.vue'
  import { ElDatePicker } from 'element-plus'

  interface Props {
    modelValue: boolean
    handover?: any
    readonly?: boolean
    initialContractId?: string | number
  }
  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', handover: any): void
    (e: 'updated', handover: any): void
  }
  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    handover: undefined,
    readonly: false,
    initialContractId: undefined
  })
  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })
  const isEditMode = computed(() => !!props.handover?.id)
  const dialogTitle = computed(() =>
    props.readonly ? '查看交接单' : isEditMode.value ? '编辑交接单' : '创建交接单'
  )

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    doc_no: [{ required: true, message: '请输入交接单号', trigger: 'blur' }],
    contract_id: [{ required: true, message: '请选择关联合同', trigger: 'change' }]
  })

  const form = reactive({
    id: undefined as string | number | undefined,
    contract_id: undefined as string | number | undefined,
    doc_no: '',
    order_company: '',
    order_contract_no: '',
    goods_name: '',
    specs: '',
    order_kind: '' as string,
    special_note: '',
    qty: undefined as string | number | undefined,
    qty_unit: '',
    pack_specs: '',
    deliver_at: '',
    notes: '',
    reviewer_id: undefined as string | number | undefined,
    review_at: '',
    prod_signer_id: undefined as string | number | undefined,
    tech_signer_id: undefined as string | number | undefined,
    qa_signer_id: undefined as string | number | undefined,
    lines: [] as any[]
  })

  const contractOptions = ref<any[]>([])
  const contractSearchLoading = ref(false)
  const specItemOptions = ref<any[]>([])
  const specItemFilterQuery = ref('')
  const contractReqFilterMap = reactive<Record<number, string>>({})
  const internalReqFilterMap = reactive<Record<number, string>>({})
  const orderKindOptions = ref<string[]>([])
  const orderKindConfigVisible = ref(false)
  const userOptions = ref<any[]>([])
  const specItemValuesCache = ref<Record<string, string[]>>({})

  const loadOrderKindOptions = async () => {
    try {
      const res = await listPropertyApi({ 'q[sign_eq]': 'crm_order_kind', per_page: 200 })
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      orderKindOptions.value = arr
        .filter((o: any) => o && (o.name != null || o.value != null))
        .map((o: any) => (typeof o.name === 'string' ? o.name : o.value))
    } catch {
      orderKindOptions.value = []
    }
  }

  const searchContracts = async (query: string) => {
    contractSearchLoading.value = true
    try {
      const res = await listCrmContractApi({ 'q[code_cont]': query || '', per_page: 50 })
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      contractOptions.value = arr.filter((c: any) => c && c.id != null)
      if (form.contract_id && form.id) {
        try {
          const viewRes = await viewCrmContractApi({ id: form.contract_id })
          const contract = (viewRes as any).data
          if (
            contract &&
            !contractOptions.value.find((c: any) => Number(c.id) === Number(form.contract_id))
          )
            contractOptions.value = [contract, ...contractOptions.value]
        } catch {
          /* empty */
        }
      }
    } finally {
      contractSearchLoading.value = false
    }
  }

  /** 新建时从合同带出：订购公司、合同号、发货时间、货物名称、规格、数量 */
  const fillFormFromContract = async (contractId: string | number) => {
    if (!contractId) return
    try {
      const res = await viewCrmContractApi({ id: contractId })
      const d = (res as any).data || {}
      form.order_company = d.client_name ?? form.order_company
      form.order_contract_no = d.code ?? form.order_contract_no
      form.deliver_at = d.deliver_at ?? form.deliver_at
      form.goods_name = (d.product_zh || d.product_en) ?? form.goods_name
      form.specs = d.specs ?? form.specs
      form.pack_specs = d.pack_req ?? form.pack_specs
      if (d.qty != null && d.qty !== '') form.qty = Number(d.qty)
      const unitVal = d.qty_unit ?? d.unit_name ?? ''
      if (unitVal != null && unitVal !== '') form.qty_unit = String(unitVal)
    } catch {
      /* 忽略，不打断用户操作 */
    }
  }

  const loadSpecItems = async (query?: string) => {
    try {
      const params: any = { per_page: 200 }
      if (query != null && query !== '') {
        params['q[name_or_py_cont]'] = query
      }
      const res = await listCrmSpecItemApi(params)
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      const items = arr.filter((s: any) => s && s.id != null)
      if (query == null || query === '') {
        specItemOptions.value = items
      } else {
        specItemOptions.value = items
      }
    } catch {
      specItemOptions.value = []
    }
  }

  const searchSpecItems = async (query: string) => {
    specItemFilterQuery.value = query || ''
    await loadSpecItems(query)
  }

  const getSpecItemOptions = computed(() => {
    const list = specItemOptions.value || []
    const q = (specItemFilterQuery.value || '').trim()
    if (!q) return list
    const hasMatch = list.some((s: any) => (s.name || '').toLowerCase() === q.toLowerCase())
    if (hasMatch) return list
    return [...list, { id: q, name: `新增:${q}` }]
  })

  const getSpecItemValues = (specItemId: string | number | undefined): string[] => {
    if (specItemId == null) return []
    const key = String(specItemId)
    if (specItemValuesCache.value[key]) return specItemValuesCache.value[key]
    return []
  }

  const loadSpecItemValues = async (specItemId: string | number, forceRefresh = false) => {
    const key = String(specItemId)
    if (!forceRefresh && specItemValuesCache.value[key]) return
    try {
      const res = await viewCrmSpecItemApi({ id: specItemId })
      const d = (res as any).data || {}
      let values: string[] = []
      const raw = d.values
      if (typeof raw === 'string') {
        try {
          const parsed = JSON.parse(raw)
          values = Array.isArray(parsed)
            ? parsed.map((v: any) =>
                typeof v === 'string' ? v : (v?.name ?? v?.value ?? String(v))
              )
            : []
        } catch {
          values = []
        }
      } else if (Array.isArray(raw)) {
        values = raw.map((v: any) =>
          typeof v === 'string' ? v : (v?.name ?? v?.value ?? String(v))
        )
      }
      specItemValuesCache.value = { ...specItemValuesCache.value, [key]: values }
    } catch {
      specItemValuesCache.value = { ...specItemValuesCache.value, [key]: [] }
    }
  }

  /** 当用户输入新值时，追加到指标项目 values 并更新数据库 */
  const appendValueToSpecItem = async (row: any, newVal: string) => {
    const specItemId = row.spec_item_id
    if (specItemId == null || specItemId === '') return
    const trimmed = String(newVal || '').trim()
    if (!trimmed) return
    const key = String(specItemId)
    const current = specItemValuesCache.value[key] || []
    if (current.includes(trimmed)) return
    try {
      const res = await viewCrmSpecItemApi({ id: specItemId })
      const d = (res as any).data || {}
      let values: string[] = []
      const raw = d.values
      if (typeof raw === 'string') {
        try {
          const parsed = JSON.parse(raw)
          values = Array.isArray(parsed)
            ? parsed.map((v: any) =>
                typeof v === 'string' ? v : (v?.name ?? v?.value ?? String(v))
              )
            : []
        } catch {
          values = []
        }
      } else if (Array.isArray(raw)) {
        values = raw.map((v: any) =>
          typeof v === 'string' ? v : (v?.name ?? v?.value ?? String(v))
        )
      }
      if (values.includes(trimmed)) {
        specItemValuesCache.value = { ...specItemValuesCache.value, [key]: values }
        return
      }
      values = [...values, trimmed]
      await updateCrmSpecItemApi(String(specItemId), { values: JSON.stringify(values) })
      specItemValuesCache.value = { ...specItemValuesCache.value, [key]: values }
      ElMessage.success('已添加至指标项目，后续可选择使用')
    } catch {
      ElMessage.error('添加失败')
    }
  }

  const onContractReqChange = (row: any, val: string) => {
    if (!val || typeof val !== 'string') return
    const trimmed = val.trim()
    if (!trimmed) return
    const existing = getSpecItemValues(row.spec_item_id)
    if (!existing.includes(trimmed)) appendValueToSpecItem(row, trimmed)
  }

  const onInternalReqChange = (row: any, val: string) => {
    if (!val || typeof val !== 'string') return
    const trimmed = val.trim()
    if (!trimmed) return
    const existing = getSpecItemValues(row.spec_item_id)
    if (!existing.includes(trimmed)) appendValueToSpecItem(row, trimmed)
  }

  const getContractReqOptions = (row: any, index: number) => {
    const values = getSpecItemValues(row.spec_item_id)
    const q = (contractReqFilterMap[index] ?? '').trim()
    if (!q) return values.map((v) => ({ value: v, label: v }))
    const filtered = values.filter((v) => v.toLowerCase().includes(q.toLowerCase()))
    const hasExact = values.some((v) => v.toLowerCase() === q.toLowerCase())
    const opts = filtered.map((v) => ({ value: v, label: v }))
    if (!hasExact) opts.push({ value: q, label: `新增:${q}` })
    return opts
  }

  const getInternalReqOptions = (row: any, index: number) => {
    const values = getSpecItemValues(row.spec_item_id)
    const q = (internalReqFilterMap[index] ?? '').trim()
    if (!q) return values.map((v) => ({ value: v, label: v }))
    const filtered = values.filter((v) => v.toLowerCase().includes(q.toLowerCase()))
    const hasExact = values.some((v) => v.toLowerCase() === q.toLowerCase())
    const opts = filtered.map((v) => ({ value: v, label: v }))
    if (!hasExact) opts.push({ value: q, label: `新增:${q}` })
    return opts
  }

  /** 当某行 spec_item_id 为字符串（用户输入新名称）时，快速创建指标项目并替换为 id */
  const ensureSpecItemCreated = async (row: any) => {
    const v = row.spec_item_id
    if (typeof v !== 'string' || !String(v).trim()) return
    const name = String(v).trim()
    try {
      const res = await createCrmSpecItemApi({ name })
      const newItem = (res as any).data
      if (newItem?.id != null) {
        row.spec_item_id = newItem.id
        if (!specItemOptions.value.find((s: any) => Number(s.id) === Number(newItem.id)))
          specItemOptions.value = [
            ...specItemOptions.value,
            { id: newItem.id, name: newItem.name || name }
          ]
        loadSpecItemValues(newItem.id)
        ElMessage.success('已添加指标项目')
      }
    } catch {
      ElMessage.error('创建指标项目失败')
    }
  }

  const handleAddLine = () => {
    form.lines.push({
      spec_item_id: undefined,
      contract_req: '',
      internal_req: '',
      sort: form.lines.length
    })
  }

  const handleAddAllLines = async () => {
    try {
      const res = await listCrmSpecItemApi({ per_page: 500 })
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      const allItems = arr.filter((s: any) => s && s.id != null)
      const existingIds = new Set(
        form.lines
          .map((l: any) => l.spec_item_id)
          .filter((id: any) => id != null && typeof id === 'number')
      )
      const toAdd = allItems.filter((s: any) => !existingIds.has(Number(s.id)))
      const existingOptIds = new Set(specItemOptions.value.map((s: any) => Number(s.id)))
      const newOpts = allItems.filter((s: any) => !existingOptIds.has(Number(s.id)))
      if (newOpts.length > 0) specItemOptions.value = [...specItemOptions.value, ...newOpts]
      for (const item of toAdd) {
        form.lines.push({
          spec_item_id: item.id,
          contract_req: '',
          internal_req: '',
          sort: form.lines.length
        })
      }
      await Promise.all(toAdd.map((item: any) => loadSpecItemValues(item.id)))
      if (toAdd.length > 0) ElMessage.success(`已添加 ${toAdd.length} 个指标项目`)
      else if (allItems.length > 0) ElMessage.info('所有指标项目已存在')
      else ElMessage.info('暂无指标项目')
    } catch {
      ElMessage.error('加载指标项目失败')
    }
  }

  const handleRemoveLine = (index: number) => {
    form.lines.splice(index, 1)
  }

  const onSpecItemSelect = async (row: any, val: string | number) => {
    if (val && typeof val === 'number') {
      await loadSpecItemValues(val)
    }
  }

  const ensureSpecItemValuesLoaded = (specItemId: string | number | undefined) => {
    if (specItemId != null && typeof specItemId === 'number') {
      loadSpecItemValues(specItemId)
    }
  }

  const loadDetail = async () => {
    if (!props.handover?.id) return
    try {
      const res = await viewCrmHandoverApi({ id: props.handover.id })
      const d = (res as any).data || {}
      Object.assign(form, {
        id: d.id,
        contract_id: d.contract_id,
        doc_no: d.doc_no || '',
        order_company: d.order_company || '',
        order_contract_no: d.order_contract_no || '',
        goods_name: d.goods_name || '',
        specs: d.specs || '',
        order_kind: d.order_kind || '',
        special_note: d.special_note || '',
        qty: d.qty,
        qty_unit: d.qty_unit || '',
        pack_specs: d.pack_specs || '',
        deliver_at: d.deliver_at || '',
        notes: d.notes || '',
        reviewer_id: d.reviewer_id,
        review_at: d.review_at || '',
        prod_signer_id: d.prod_signer_id,
        tech_signer_id: d.tech_signer_id,
        qa_signer_id: d.qa_signer_id,
        lines: []
      })
      const linesRes = await listCrmHandoverLineApi({ 'q[handover_id_eq]': d.id })
      const linesData = (linesRes as any).data || []
      const arr = Array.isArray(linesData) ? linesData : linesData.list || linesData.data || []
      form.lines = arr.map((line: any) => ({
        id: line.id,
        spec_item_id: line.spec_item_id,
        contract_req: line.contract_req || '',
        internal_req: line.internal_req || '',
        sort: line.sort ?? 0
      }))
      await loadSpecItems()
      for (const line of form.lines) {
        if (line.spec_item_id != null) await loadSpecItemValues(line.spec_item_id)
      }
      if (form.contract_id) await searchContracts('')
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
      for (const line of form.lines) {
        if (typeof line.spec_item_id === 'string' && String(line.spec_item_id).trim())
          await ensureSpecItemCreated(line)
      }
      const params: any = {
        contract_id: form.contract_id,
        doc_no: form.doc_no,
        order_company: form.order_company || undefined,
        order_contract_no: form.order_contract_no || undefined,
        goods_name: form.goods_name || undefined,
        specs: form.specs || undefined,
        order_kind: form.order_kind || undefined,
        special_note: form.special_note || undefined,
        qty: form.qty != null && form.qty !== '' ? Number(form.qty) : undefined,
        qty_unit: form.qty_unit || undefined,
        pack_specs: form.pack_specs || undefined,
        deliver_at: form.deliver_at || undefined,
        notes: form.notes || undefined,
        reviewer_id: form.reviewer_id,
        review_at: form.review_at || undefined,
        prod_signer_id: form.prod_signer_id,
        tech_signer_id: form.tech_signer_id,
        qa_signer_id: form.qa_signer_id,
        lines: form.lines.map((l) => ({
          spec_item_id: l.spec_item_id,
          contract_req: l.contract_req,
          internal_req: l.internal_req,
          sort: l.sort
        }))
      }
      if (isEditMode.value) {
        await updateCrmHandoverApi(String(form.id), params)
        ElMessage.success('更新成功')
        emit('updated', { ...props.handover, ...params })
        dialogVisible.value = false
      } else {
        const res = await createCrmHandoverApi(params)
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
        contract_id: form.contract_id,
        doc_no: form.doc_no,
        order_company: form.order_company || undefined,
        order_contract_no: form.order_contract_no || undefined,
        goods_name: form.goods_name || undefined,
        specs: form.specs || undefined,
        order_kind: form.order_kind || undefined,
        special_note: form.special_note || undefined,
        qty: form.qty != null && form.qty !== '' ? Number(form.qty) : undefined,
        qty_unit: form.qty_unit || undefined,
        pack_specs: form.pack_specs || undefined,
        deliver_at: form.deliver_at || undefined,
        notes: form.notes || undefined,
        reviewer_id: form.reviewer_id,
        review_at: form.review_at || undefined,
        prod_signer_id: form.prod_signer_id,
        tech_signer_id: form.tech_signer_id,
        qa_signer_id: form.qa_signer_id,
        lines: form.lines.map((l) => ({
          spec_item_id: l.spec_item_id,
          contract_req: l.contract_req,
          internal_req: l.internal_req,
          sort: l.sort
        }))
      }
      const res = await createCrmHandoverApi(params)
      ElMessage.success('创建成功')
      emit('created', (res as any).data)
      Object.assign(form, {
        id: undefined,
        contract_id: undefined,
        doc_no: '',
        order_company: '',
        order_contract_no: '',
        goods_name: '',
        specs: '',
        order_kind: '',
        special_note: '',
        qty: undefined,
        qty_unit: '',
        pack_specs: '',
        deliver_at: '',
        notes: '',
        reviewer_id: undefined,
        review_at: '',
        prod_signer_id: undefined,
        tech_signer_id: undefined,
        qa_signer_id: undefined,
        lines: []
      })
      formRef.value?.resetFields()
      await fillDocNoFromPreview()
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
      doc_no: '',
      order_company: '',
      order_contract_no: '',
      goods_name: '',
      specs: '',
      order_kind: '',
      special_note: '',
      qty: undefined,
      qty_unit: '',
      pack_specs: '',
      deliver_at: '',
      notes: '',
      reviewer_id: undefined,
      review_at: '',
      prod_signer_id: undefined,
      tech_signer_id: undefined,
      qa_signer_id: undefined,
      lines: []
    })
    contractOptions.value = []
    orderKindOptions.value = []
    userOptions.value = []
    specItemValuesCache.value = {}
    specItemFilterQuery.value = ''
    Object.keys(contractReqFilterMap).forEach((k) => delete contractReqFilterMap[Number(k)])
    Object.keys(internalReqFilterMap).forEach((k) => delete internalReqFilterMap[Number(k)])
    formRef.value?.resetFields()
  }

  /** 新建时预览并填充交接单号 */
  const fillDocNoFromPreview = async () => {
    try {
      const res = await previewDocNumberApi('crm_handovers')
      const d = (res as any).data || {}
      if (d.code) form.doc_no = d.code
    } catch {
      /* 无规则或接口失败时留空，用户可手动输入 */
    }
  }

  watch(
    () => props.modelValue,
    async (val) => {
      if (val) {
        if (props.initialContractId) {
          form.contract_id = props.initialContractId
          await fillFormFromContract(props.initialContractId)
        }
        loadOrderKindOptions()
        loadSpecItems()
        if (isEditMode.value) await loadDetail()
        else {
          searchContracts('')
          await fillDocNoFromPreview()
        }
      }
    }
  )
  watch(
    () => props.handover,
    async () => {
      if (props.modelValue && isEditMode.value) await loadDetail()
    },
    { deep: true }
  )

  /** 新建时选择合同后，从合同带出订购公司、合同号、发货时间、货物名称、规格、数量 */
  watch(
    () => form.contract_id,
    async (id) => {
      if (id && !isEditMode.value && props.modelValue) await fillFormFromContract(id)
    }
  )
</script>

<style scoped>
  .dialog-body-scroll {
    max-height: 70vh;
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

  .lines-actions {
    display: flex;
    gap: 8px;
  }

  .order-kind-wrap {
    display: flex;
    gap: 8px;
    align-items: center;
    width: 100%;
  }

  .order-kind-wrap .el-select {
    flex: 1;
  }

  .order-kind-wrap .config-btn {
    flex-shrink: 0;
  }
</style>
