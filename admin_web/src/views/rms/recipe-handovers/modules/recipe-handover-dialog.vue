<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="960px"
    :close-on-click-modal="false"
    class="recipe-handover-dialog"
    @closed="handleClosed"
  >
    <div class="dialog-body-scroll">
      <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px">
        <ElRow :gutter="20">
          <ElCol :span="12">
            <ElFormItem label="产品名称" prop="product_id">
              <ElSelect
                v-model="form.product_id"
                placeholder="请选择产品"
                filterable
                remote
                :remote-method="searchProducts"
                :loading="productSearchLoading"
                style="width: 100%"
                :disabled="props.readonly"
                @change="onProductChange"
              >
                <ElOption
                  v-for="p in productOptions"
                  :key="p.id"
                  :label="`${p.name || ''} [${p.code || ''}]`"
                  :value="p.id"
                />
              </ElSelect>
            </ElFormItem>
          </ElCol>

          <ElCol :span="12">
            <ElFormItem label="配方单号" prop="code">
              <ElInput v-model="form.code" placeholder="自动生成" :readonly="true" />
            </ElFormItem>
          </ElCol>
        </ElRow>

        <div class="lines-section">
          <div class="lines-header">
            <span>原辅料明细表</span>
            <span v-if="!props.readonly" class="lines-actions">
              <ElButton type="primary" size="small" @click="handleAddLine">添加行</ElButton>
            </span>
          </div>
          <ElTable :data="form.lines" border style="width: 100%">
            <ElTableColumn type="index" label="序号" width="55" />
            <ElTableColumn label="原、辅料品名" min-width="200">
              <template #default="{ row }">
                <ElSelect
                  v-model="row.product_id"
                  placeholder="输入名称或编码搜索"
                  filterable
                  remote
                  :remote-method="(q: string) => searchMatItems(q, row)"
                  default-first-option
                  style="width: 100%"
                  :disabled="props.readonly"
                  clearable
                  @change="(val: string | number) => onLineProductChange(row, val)"
                >
                  <ElOption
                    v-for="item in getLineProductOptions(row)"
                    :key="String(item.id)"
                    :label="`${item.name || ''} [${item.code || ''}]`"
                    :value="item.id"
                  />
                </ElSelect>
              </template>
            </ElTableColumn>
            <ElTableColumn label="投料比例, g/L" min-width="140">
              <template #default="{ row }">
                <ElInput
                  v-model="row.feeding_rate"
                  placeholder="数值或补足"
                  :readonly="props.readonly"
                />
              </template>
            </ElTableColumn>
            <ElTableColumn label="备注" min-width="140">
              <template #default="{ row }">
                <ElSelect
                  v-if="!props.readonly"
                  v-model="row.remark_id"
                  placeholder="输入备注或创建"
                  filterable
                  remote
                  :remote-method="(q: string) => searchRemarkOptions(q, row)"
                  :loading="remarkSearchLoading"
                  default-first-option
                  style="width: 100%"
                  clearable
                  @change="(val: any) => onLineRemarkSelect(row, val)"
                >
                  <ElOption
                    v-for="item in getLineRemarkOptions(row)"
                    :key="String(item.id)"
                    :label="item.name"
                    :value="item.id"
                  />
                </ElSelect>
                <span v-else>{{ row.remark || '-' }}</span>
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
        <div class="lines-section">
          <div class="lines-header">
            <span>关联合同</span>
            <span v-if="!props.readonly" class="lines-actions">
              <ElButton type="primary" size="small" @click="handleAddContract">添加合同</ElButton>
            </span>
          </div>
          <ElTable :data="form.contracts" border style="width: 100%">
            <ElTableColumn type="index" label="序号" width="55" />
            <ElTableColumn label="合同" min-width="200">
              <template #default="{ row }">
                <ElSelect
                  v-model="row.contract_id"
                  placeholder="请选择合同"
                  filterable
                  remote
                  :remote-method="searchContracts"
                  :loading="contractSearchLoading"
                  style="width: 100%"
                  :disabled="props.readonly"
                  clearable
                  @change="(id: any) => onContractChange(row, id)"
                >
                  <ElOption
                    v-for="c in contractOptions"
                    :key="c.id"
                    :label="`[${c.code || ''}]${c.product_zh || ''}`"
                    :value="c.id"
                  />
                </ElSelect>
              </template>
            </ElTableColumn>
            <ElTableColumn label="数量" min-width="120">
              <template #default="{ row }">
                <ElInput
                  v-model="row.qty"
                  type="number"
                  placeholder="数量"
                  :readonly="props.readonly"
                  @input="syncOrderQtyFromContracts"
                />
              </template>
            </ElTableColumn>
            <ElTableColumn v-if="!props.readonly" label="操作" width="70" fixed="right">
              <template #default="{ $index }">
                <ElButton type="danger" link size="small" @click="handleRemoveContract($index)"
                  >删除</ElButton
                >
              </template>
            </ElTableColumn>
          </ElTable>
        </div>

        <ElRow :gutter="20" style="margin-top: 16px">
          <ElCol :span="24">
            <ElFormItem label="订购公司" prop="ordering_companies_text">
              <ElInput
                v-model="form.ordering_companies_text"
                type="textarea"
                :rows="2"
                placeholder="请输入订购公司信息"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="订货数量" prop="order_qty">
              <ElInput
                v-model="form.order_qty"
                type="number"
                placeholder="订货数量"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="订货数量单位" prop="order_qty_unit_id">
              <PropertySelectWithAdd
                v-model="form.order_qty_unit_id"
                sign="product_uom"
                placeholder="请选择单位"
                :disabled="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="指标要求" prop="handover_order_id">
              <ElSelect
                v-model="form.handover_order_id"
                placeholder="请选择交接单"
                filterable
                remote
                :remote-method="searchHandoverOrders"
                :loading="handoverOrderSearchLoading"
                style="width: 100%"
                :disabled="props.readonly"
                clearable
              >
                <ElOption
                  v-for="h in handoverOrderOptions"
                  :key="h.id"
                  :label="`${h.doc_no || ''}`"
                  :value="h.id"
                />
              </ElSelect>
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="制单人" prop="prepared_id">
              <ElSelect
                v-model="form.prepared_id"
                placeholder="请选择制单人"
                filterable
                remote
                :remote-method="searchUsers"
                :loading="userSearchLoading"
                style="width: 100%"
                :disabled="props.readonly"
                clearable
              >
                <ElOption
                  v-for="u in userOptions"
                  :key="u.id"
                  :label="u.name || u.username"
                  :value="u.id"
                />
              </ElSelect>
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="接收人" prop="received_id">
              <ElSelect
                v-model="form.received_id"
                placeholder="请选择接收人"
                filterable
                remote
                :remote-method="searchUsers"
                :loading="userSearchLoading"
                style="width: 100%"
                :disabled="props.readonly"
                clearable
              >
                <ElOption
                  v-for="u in userOptions"
                  :key="u.id"
                  :label="u.name || u.username"
                  :value="u.id"
                />
              </ElSelect>
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="交接日期" prop="handover_date">
              <ElDatePicker
                v-model="form.handover_date"
                type="date"
                placeholder="请选择交接日期"
                style="width: 100%"
                value-format="YYYY-MM-DD"
                :disabled="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="通用备注" prop="general_notes">
              <ElInput
                v-model="form.general_notes"
                type="textarea"
                :rows="3"
                placeholder="请输入通用备注"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>
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
  import { useUserStore } from '@/store/modules/user'
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
  import { ElDatePicker } from 'element-plus'
  import {
    createRecipeHandoverApi,
    updateRecipeHandoverApi,
    viewRecipeHandoverApi
  } from '@/api/rms/recipe-handover'
  import {
    listRecipeHandoverLineApi,
    listRecipeHandoverContractApi
  } from '@/api/rms/recipe-handover'
  import { listCrmHandoverApi } from '@/api/crm/handover'
  import { listCrmContractApi, viewCrmContractApi } from '@/api/crm/contract'
  import { listMatItemApi, createMatItemApi } from '@/api/mat/item'
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'
  import { viewPropertyApi, listPropertyApi, createPropertyApi } from '@/api/property'
  import { listUserApi } from '@/api/user'
  import { previewDocNumberApi } from '@/api/doc-number'

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
  const userStore = useUserStore()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })
  const isEditMode = computed(() => !!props.handover?.id)
  const dialogTitle = computed(() =>
    props.readonly ? '查看配方交接单' : isEditMode.value ? '编辑配方交接单' : '创建配方交接单'
  )

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    product_id: [{ required: true, message: '请选择产品', trigger: 'change' }]
  })

  const form = reactive({
    id: undefined as string | number | undefined,
    product_id: undefined as string | number | undefined,
    name: '',
    code: '',
    handover_date: '',
    ordering_companies_text: '',
    order_qty: undefined as string | number | undefined,
    order_qty_unit: '',
    order_qty_unit_id: undefined as string | number | undefined,
    handover_order_id: undefined as string | number | undefined,
    prepared_id: undefined as string | number | undefined,
    received_id: undefined as string | number | undefined,
    general_notes: '',
    lines: [] as any[],
    contracts: [] as { contract_id?: number; qty?: number }[]
  })

  const productOptions = ref<any[]>([])
  const contractOptions = ref<any[]>([])
  const contractSearchLoading = ref(false)
  const productSearchLoading = ref(false)
  const matItemOptionsMap = ref<Record<number, any[]>>({})
  const remarkOptionsMap = ref<Record<number, any[]>>({})
  const remarkSearchLoading = ref(false)
  const handoverOrderOptions = ref<any[]>([])
  const handoverOrderSearchLoading = ref(false)
  const userOptions = ref<any[]>([])
  const userSearchLoading = ref(false)

  const searchProducts = async (query: string) => {
    productSearchLoading.value = true
    try {
      const res = await listMatItemApi({
        'q[name_or_code_cont]': query || '',
        'q[type_id_eq]': 100,
        per_page: 50
      })
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      productOptions.value = arr.filter((p: any) => p && p.id != null)
      if (form.product_id && form.id) {
        const current = productOptions.value.find(
          (p: any) => Number(p.id) === Number(form.product_id)
        )
        if (!current) {
          try {
            const viewRes = await listMatItemApi({ 'q[id_eq]': form.product_id, per_page: 1 })
            const d = (viewRes as any).data || []
            const item = Array.isArray(d) ? d[0] : d?.list?.[0] || d?.data?.[0]
            if (item) productOptions.value = [item, ...productOptions.value]
          } catch {
            /* empty */
          }
        }
      }
    } finally {
      productSearchLoading.value = false
    }
  }

  const searchMatItems = async (query: string, row: any) => {
    const q = (query || '').trim()
    row._createQuery = q && q.length > 0 ? q : undefined
    try {
      const res = await listMatItemApi({
        'q[name_or_code_cont]': q || '',
        'q[type_id_eq]': 200,
        per_page: 50
      })
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      const key = row._lineKey ?? Math.random()
      row._lineKey = key
      matItemOptionsMap.value = {
        ...matItemOptionsMap.value,
        [key]: arr.filter((p: any) => p?.id != null)
      }
    } catch {
      const key = row._lineKey ?? Math.random()
      row._lineKey = key
      matItemOptionsMap.value = { ...matItemOptionsMap.value, [key]: [] }
    }
  }

  const getLineProductOptions = (row: any) => {
    const key = row._lineKey
    const base = key != null ? matItemOptionsMap.value[key] || [] : []
    const createQ = row._createQuery
    if (createQ && base.length === 0) {
      return [
        { id: `__create__${createQ}`, name: `创建: ${createQ} 或按回车键直接创建记录`, code: '' }
      ]
    }
    return base
  }

  const onLineProductChange = async (row: any, val: string | number) => {
    if (val == null) return
    const idStr = String(val)
    if (idStr.startsWith('__create__')) {
      const query = idStr.replace(/^__create__/, '')
      if (!query) return
      try {
        const res = await createMatItemApi({ name: query, type_id: 200 })
        const created = (res as any).data
        if (created?.id != null) {
          const key = row._lineKey ?? Math.random()
          row._lineKey = key
          const arr = matItemOptionsMap.value[key] || []
          matItemOptionsMap.value = {
            ...matItemOptionsMap.value,
            [key]: [{ ...created, name: created.name || query, code: created.code || '' }, ...arr]
          }
          row.product_id = created.id
          row.name = created.name || query
          row._createQuery = undefined
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
    if (item) row.name = item.name
  }

  const syncOrderQtyUnitFromId = async (id: string | number) => {
    if (!id) {
      form.order_qty_unit = ''
      return
    }
    try {
      const res = await viewPropertyApi({ id })
      const p = (res as any).data || {}
      form.order_qty_unit = p.name || ''
    } catch {
      form.order_qty_unit = ''
    }
  }

  const onProductChange = (val: string | number) => {
    if (val != null) {
      const p = productOptions.value.find((o: any) => Number(o.id) === Number(val))
      if (p) form.name = p.name || ''
    }
  }

  const searchContracts = async (query: string) => {
    contractSearchLoading.value = true
    try {
      const res = await listCrmContractApi({
        'q[code_cont]': query || '',
        per_page: 50
      })
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      contractOptions.value = arr.filter((c: any) => c && c.id != null)
    } finally {
      contractSearchLoading.value = false
    }
  }

  const searchHandoverOrders = async (query: string) => {
    handoverOrderSearchLoading.value = true
    try {
      const res = await listCrmHandoverApi({
        'q[doc_no_cont]': query || '',
        per_page: 50
      })
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      handoverOrderOptions.value = arr.filter((h: any) => h && h.id != null)
    } finally {
      handoverOrderSearchLoading.value = false
    }
  }

  const searchUsers = async (query: string) => {
    userSearchLoading.value = true
    try {
      const res = await listUserApi({
        'q[name_or_py_cont]': query || '',
        per_page: 50
      })
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      userOptions.value = arr.filter((u: any) => u && u.id != null)
    } finally {
      userSearchLoading.value = false
    }
  }

  const searchRemarkOptions = async (query: string, row: any) => {
    const q = (query || '').trim()
    row._remarkCreateQuery = q && q.length > 0 ? q : undefined
    remarkSearchLoading.value = true
    try {
      const res = await listPropertyApi({
        'q[sign_eq]': 'rms_handover_line_remark',
        'q[name_or_py_cont]': q || '',
        per_page: 50
      })
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      const key = row._remarkKey ?? Math.random()
      row._remarkKey = key
      remarkOptionsMap.value = {
        ...remarkOptionsMap.value,
        [key]: arr.filter((p: any) => p?.id != null)
      }
    } catch {
      const key = row._remarkKey ?? Math.random()
      row._remarkKey = key
      remarkOptionsMap.value = { ...remarkOptionsMap.value, [key]: [] }
    } finally {
      remarkSearchLoading.value = false
    }
  }

  const getLineRemarkOptions = (row: any) => {
    const key = row._remarkKey
    const base = key != null ? remarkOptionsMap.value[key] || [] : []
    const createQ = row._remarkCreateQuery
    if (createQ && base.length === 0) {
      return [{ id: `__create__${createQ}`, name: `创建: ${createQ} 或按回车键直接创建记录` }]
    }
    return base
  }

  const onLineRemarkSelect = async (row: any, val: string | number | null) => {
    if (val == null) {
      row.remark = ''
      return
    }
    const idStr = String(val)
    if (idStr.startsWith('__create__')) {
      const query = idStr.replace(/^__create__/, '')
      if (!query) return
      try {
        const res = await createPropertyApi({
          sign: 'rms_handover_line_remark',
          name: query
        })
        const created = (res as any).data
        if (created?.id != null) {
          const key = row._remarkKey ?? Math.random()
          row._remarkKey = key
          const arr = remarkOptionsMap.value[key] || []
          remarkOptionsMap.value = {
            ...remarkOptionsMap.value,
            [key]: [{ ...created, name: created.name || query }, ...arr]
          }
          row.remark_id = created.id
          row.remark = created.name || query
          row._remarkCreateQuery = undefined
          ElMessage.success('已创建备注')
        }
      } catch {
        ElMessage.error('创建备注失败')
      }
      return
    }
    try {
      const res = await viewPropertyApi({ id: val })
      const p = (res as any).data || {}
      row.remark = p.name || ''
    } catch {
      row.remark = ''
    }
  }

  const handleAddLine = () => {
    form.lines.push({
      product_id: undefined,
      name: '',
      feeding_rate: '',
      remark: '',
      remark_id: undefined,
      sort: form.lines.length,
      _lineKey: Math.random(),
      _remarkKey: Math.random()
    })
  }

  const handleRemoveLine = (index: number) => {
    form.lines.splice(index, 1)
  }

  const handleAddContract = () => {
    form.contracts.push({ contract_id: undefined, qty: undefined })
  }

  const handleRemoveContract = (index: number) => {
    form.contracts.splice(index, 1)
    syncOrderingFromContracts()
  }

  const onContractChange = async (row: any, contractId: string | number | null) => {
    if (contractId) {
      let c = contractOptions.value.find((x: any) => Number(x.id) === Number(contractId))
      if (!c) {
        try {
          const res = await viewCrmContractApi({ id: contractId })
          c = (res as any).data
          if (c)
            contractOptions.value = [
              c,
              ...contractOptions.value.filter((x: any) => Number(x.id) !== Number(c.id))
            ]
        } catch {
          /* ignore */
        }
      }
      if (c?.qty != null && c?.qty !== '') row.qty = Number(c.qty)
    }
    await syncOrderingFromContracts()
  }

  const syncOrderQtyFromContracts = () => {
    const rows = form.contracts.filter((r: any) => r.contract_id)
    let totalQty: number | undefined
    for (const row of rows) {
      const n = row.qty != null && String(row.qty) !== '' ? Number(row.qty) : undefined
      if (n != null && !Number.isNaN(n)) {
        totalQty = totalQty == null ? n : totalQty + n
      }
    }
    form.order_qty = totalQty
  }

  const syncOrderingFromContracts = async () => {
    const rows = form.contracts.filter((r: any) => r.contract_id)
    if (rows.length === 0) return
    const companies: string[] = []
    let firstContract: any = null
    for (const row of rows) {
      let c = contractOptions.value.find((x: any) => Number(x.id) === Number(row.contract_id))
      if (!c) {
        try {
          const res = await viewCrmContractApi({ id: row.contract_id })
          c = (res as any).data
          if (c)
            contractOptions.value = [
              c,
              ...contractOptions.value.filter((x: any) => Number(x.id) !== Number(c.id))
            ]
        } catch {
          /* ignore */
        }
      }
      if (!firstContract && c) firstContract = c
      if (c) {
        const name = c.client_name || ''
        const code = c.code || ''
        if (name || code) companies.push(name && code ? `${name}(${code})` : name || code)
      }
    }
    if (companies.length > 0) form.ordering_companies_text = companies.join('\n')
    syncOrderQtyFromContracts()
    if (firstContract) {
      if (!form.product_id && firstContract.product_id != null) {
        form.product_id = firstContract.product_id
        form.name = firstContract.product_zh || firstContract.product_en || ''
        try {
          const prodRes = await listMatItemApi({
            'q[id_eq]': firstContract.product_id,
            per_page: 1
          })
          const pl = (prodRes as any).data || []
          const prod = Array.isArray(pl) ? pl[0] : pl?.list?.[0] || pl?.data?.[0]
          if (prod)
            productOptions.value = [
              prod,
              ...productOptions.value.filter((p: any) => Number(p.id) !== Number(prod.id))
            ]
          else
            productOptions.value = [
              { id: firstContract.product_id, name: form.name, code: '' },
              ...productOptions.value
            ]
        } catch {
          productOptions.value = [
            { id: firstContract.product_id, name: form.name, code: '' },
            ...productOptions.value
          ]
        }
      }
      if (!form.handover_order_id) {
        try {
          const handoverRes = await listCrmHandoverApi({
            'q[contract_id_eq]': firstContract.id,
            per_page: 1,
            sort: 'id desc'
          })
          const hl = (handoverRes as any).data || []
          const handoverList = Array.isArray(hl) ? hl : hl.list || hl.data || []
          const lastHandover = Array.isArray(handoverList) ? handoverList[0] : handoverList
          if (lastHandover?.id != null) {
            form.handover_order_id = lastHandover.id
            handoverOrderOptions.value = [
              lastHandover,
              ...handoverOrderOptions.value.filter(
                (h: any) => Number(h.id) !== Number(lastHandover.id)
              )
            ]
          }
        } catch {
          /* ignore */
        }
      }
    }
  }

  const loadDetail = async () => {
    if (!props.handover?.id) return
    try {
      const res = await viewRecipeHandoverApi({ id: props.handover.id })
      const d = (res as any).data || {}
      Object.assign(form, {
        id: d.id,
        product_id: d.product_id,
        name: d.name || '',
        code: d.code || '',
        handover_date: d.handover_date || '',
        ordering_companies_text: d.ordering_companies_text || '',
        order_qty: d.order_qty,
        order_qty_unit: d.order_qty_unit || '',
        order_qty_unit_id: d.order_qty_unit_id,
        handover_order_id: d.handover_order_id,
        prepared_id: d.prepared_id,
        received_id: d.received_id,
        general_notes: d.general_notes || '',
        lines: []
      })
      const linesRes = await listRecipeHandoverLineApi({ 'q[handover_id_eq]': d.id })
      const linesData = (linesRes as any).data || []
      const arr = Array.isArray(linesData) ? linesData : linesData.list || linesData.data || []
      form.lines = arr.map((line: any) => ({
        id: line.id,
        product_id: line.product_id,
        name: line.name || '',
        feeding_rate: line.feeding_rate != null ? line.feeding_rate : '',
        remark: line.remark || '',
        remark_id: line.remark_id ?? undefined,
        sort: line.sort ?? 0,
        _lineKey: Math.random(),
        _remarkKey: Math.random()
      }))
      const contractsRes = await listRecipeHandoverContractApi({ 'q[recipe_handover_id_eq]': d.id })
      const contractsData = (contractsRes as any).data || []
      const contractsArr = Array.isArray(contractsData)
        ? contractsData
        : contractsData.list || contractsData.data || []
      form.contracts = contractsArr.map((c: any) => ({
        contract_id: c.contract_id,
        qty: c.qty
      }))
      if (!d.order_qty_unit_id && d.order_qty_unit) {
        try {
          const propRes = await listPropertyApi({
            'q[sign_eq]': 'product_uom',
            'q[name_eq]': d.order_qty_unit,
            per_page: 1
          })
          const pl = (propRes as any).data || []
          const prop = Array.isArray(pl) ? pl[0] : pl?.list?.[0] || pl?.data?.[0]
          if (prop) form.order_qty_unit_id = prop.id
        } catch {
          /* ignore */
        }
      }
      for (const line of form.lines) {
        if (!line.remark_id && line.remark) {
          try {
            const propRes = await listPropertyApi({
              'q[sign_eq]': 'rms_handover_line_remark',
              'q[name_eq]': line.remark,
              per_page: 1
            })
            const pl = (propRes as any).data || []
            const prop = Array.isArray(pl) ? pl[0] : pl?.list?.[0] || pl?.data?.[0]
            if (prop) line.remark_id = prop.id
          } catch {
            /* ignore */
          }
        }
        if (line.remark_id) {
          try {
            const propRes = await viewPropertyApi({ id: line.remark_id })
            const prop = (propRes as any).data
            if (prop) {
              remarkOptionsMap.value = {
                ...remarkOptionsMap.value,
                [line._remarkKey]: [{ id: prop.id, name: prop.name || '' }]
              }
            }
          } catch {
            /* ignore */
          }
        }
      }
      await searchProducts('')
      await searchContracts('')
      await searchHandoverOrders('')
      await searchUsers('')
      for (const line of form.lines) {
        if (line.product_id) {
          try {
            const itemRes = await listMatItemApi({
              'q[id_eq]': line.product_id,
              per_page: 1
            })
            const itemList = (itemRes as any).data || []
            const item = Array.isArray(itemList)
              ? itemList[0]
              : itemList?.list?.[0] || itemList?.data?.[0]
            if (item) {
              matItemOptionsMap.value = {
                ...matItemOptionsMap.value,
                [line._lineKey]: [item]
              }
            }
          } catch {
            /* empty */
          }
        }
      }
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
        product_id: form.product_id,
        name: form.name || undefined,
        code: form.code || undefined,
        handover_date: form.handover_date || undefined,
        ordering_companies_text: form.ordering_companies_text || undefined,
        order_qty:
          form.order_qty != null && form.order_qty !== '' ? Number(form.order_qty) : undefined,
        order_qty_unit: form.order_qty_unit || undefined,
        handover_order_id: form.handover_order_id,
        prepared_id: form.prepared_id,
        received_id: form.received_id,
        general_notes: form.general_notes || undefined,
        lines: form.lines.map((l) => {
          const pid = l.product_id
          const validId =
            pid != null &&
            pid !== '' &&
            (typeof pid === 'number' ||
              (typeof pid === 'string' && !String(pid).startsWith('__create__')))
          return {
            product_id: validId ? pid : undefined,
            name: l.name,
            feeding_rate:
              l.feeding_rate != null && l.feeding_rate !== '' ? l.feeding_rate : undefined,
            remark: l.remark,
            sort: l.sort
          }
        }),
        contracts: form.contracts
          .filter((c) => c.contract_id)
          .map((c) => ({
            contract_id: c.contract_id,
            qty: c.qty != null && String(c.qty) !== '' ? Number(c.qty) : undefined
          }))
      }
      if (isEditMode.value) {
        await updateRecipeHandoverApi(String(form.id), params)
        ElMessage.success('更新成功')
        emit('updated', { ...props.handover, ...params })
        dialogVisible.value = false
      } else {
        const res = await createRecipeHandoverApi(params)
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
        product_id: form.product_id,
        name: form.name || undefined,
        code: form.code || undefined,
        handover_date: form.handover_date || undefined,
        ordering_companies_text: form.ordering_companies_text || undefined,
        order_qty:
          form.order_qty != null && form.order_qty !== '' ? Number(form.order_qty) : undefined,
        order_qty_unit: form.order_qty_unit || undefined,
        handover_order_id: form.handover_order_id,
        prepared_id: form.prepared_id,
        received_id: form.received_id,
        general_notes: form.general_notes || undefined,
        lines: form.lines.map((l) => {
          const pid = l.product_id
          const validId =
            pid != null &&
            pid !== '' &&
            (typeof pid === 'number' ||
              (typeof pid === 'string' && !String(pid).startsWith('__create__')))
          return {
            product_id: validId ? pid : undefined,
            name: l.name,
            feeding_rate:
              l.feeding_rate != null && l.feeding_rate !== '' ? l.feeding_rate : undefined,
            remark: l.remark,
            sort: l.sort
          }
        }),
        contracts: form.contracts
          .filter((c) => c.contract_id)
          .map((c) => ({
            contract_id: c.contract_id,
            qty: c.qty != null && String(c.qty) !== '' ? Number(c.qty) : undefined
          }))
      }
      const res = await createRecipeHandoverApi(params)
      ElMessage.success('创建成功')
      emit('created', (res as any).data)
      Object.assign(form, {
        id: undefined,
        product_id: undefined,
        name: '',
        code: '',
        handover_date: '',
        ordering_companies_text: '',
        order_qty: undefined,
        order_qty_unit: '',
        order_qty_unit_id: undefined,
        handover_order_id: undefined,
        prepared_id: undefined,
        received_id: undefined,
        general_notes: '',
        lines: [],
        contracts: []
      })
      matItemOptionsMap.value = {}
      formRef.value?.resetFields()
      await fillCodeFromPreview()
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
      product_id: undefined,
      name: '',
      code: '',
      handover_date: '',
      ordering_companies_text: '',
      order_qty: undefined,
      order_qty_unit: '',
      order_qty_unit_id: undefined,
      handover_order_id: undefined,
      prepared_id: undefined,
      received_id: undefined,
      general_notes: '',
      lines: [],
      contracts: []
    })
    productOptions.value = []
    handoverOrderOptions.value = []
    userOptions.value = []
    matItemOptionsMap.value = {}
    formRef.value?.resetFields()
  }

  const fillCodeFromPreview = async () => {
    try {
      const res = await previewDocNumberApi('rms_handovers')
      const d = (res as any).data || {}
      if (d.code) form.code = d.code
    } catch {
      /* empty */
    }
  }

  watch(
    () => form.order_qty_unit_id,
    (id) => {
      if (id) syncOrderQtyUnitFromId(id)
      else form.order_qty_unit = ''
    }
  )

  watch(
    () => props.modelValue,
    async (val) => {
      if (val) {
        if (isEditMode.value) await loadDetail()
        else {
          searchProducts('')
          searchContracts('')
          searchHandoverOrders('')
          searchUsers('')
          await fillCodeFromPreview()
          form.handover_date = new Date().toISOString().slice(0, 10)
          const curUser = userStore.getUserInfo as any
          const curUserId = curUser?.userId ?? curUser?.id
          if (curUserId != null) {
            form.prepared_id = curUserId
            const exists = userOptions.value.some((u: any) => Number(u.id) === Number(curUserId))
            if (!exists) {
              userOptions.value = [
                {
                  id: curUserId,
                  name: curUser?.userName ?? curUser?.name ?? curUser?.username ?? '当前用户'
                },
                ...userOptions.value
              ]
            }
          }
          if (props.initialContractId) {
            const cid = Number(props.initialContractId)
            form.contracts = [{ contract_id: cid, qty: undefined }]
            try {
              const res = await viewCrmContractApi({ id: props.initialContractId })
              const c = (res as any).data
              if (c && c.id != null) {
                contractOptions.value = [
                  c,
                  ...contractOptions.value.filter((x: any) => Number(x.id) !== Number(c.id))
                ]
                form.ordering_companies_text =
                  c.client_name && c.code
                    ? `${c.client_name}(${c.code})`
                    : c.client_name || c.code || ''
                if (c.qty != null && c.qty !== '') {
                  form.order_qty = Number(c.qty)
                  const first = form.contracts[0]
                  if (first && Number(first.contract_id) === cid) first.qty = Number(c.qty)
                }
                const unitVal = c.order_qty_unit ?? c.qty_unit ?? c.unit_name ?? ''
                if (unitVal) {
                  form.order_qty_unit = String(unitVal)
                  if (c.unit_id != null) form.order_qty_unit_id = c.unit_id
                  else if (c.order_qty_unit_id != null) form.order_qty_unit_id = c.order_qty_unit_id
                  else {
                    try {
                      const propRes = await listPropertyApi({
                        'q[sign_eq]': 'product_uom',
                        'q[name_eq]': unitVal,
                        per_page: 1
                      })
                      const pl = (propRes as any).data || []
                      const prop = Array.isArray(pl) ? pl[0] : pl?.list?.[0] || pl?.data?.[0]
                      if (prop) form.order_qty_unit_id = prop.id
                    } catch {
                      /* ignore */
                    }
                  }
                }
                if (c.product_id != null) {
                  form.product_id = c.product_id
                  form.name = c.product_zh || c.product_en || ''
                  try {
                    const prodRes = await listMatItemApi({
                      'q[id_eq]': c.product_id,
                      per_page: 1
                    })
                    const pl = (prodRes as any).data || []
                    const prod = Array.isArray(pl) ? pl[0] : pl?.list?.[0] || pl?.data?.[0]
                    if (prod)
                      productOptions.value = [
                        prod,
                        ...productOptions.value.filter((p: any) => Number(p.id) !== Number(prod.id))
                      ]
                  } catch {
                    productOptions.value = [
                      { id: c.product_id, name: form.name, code: '' },
                      ...productOptions.value
                    ]
                  }
                }
                try {
                  const handoverRes = await listCrmHandoverApi({
                    'q[contract_id_eq]': cid,
                    per_page: 1,
                    sort: 'id desc'
                  })
                  const hl = (handoverRes as any).data || []
                  const handoverList = Array.isArray(hl) ? hl : hl.list || hl.data || []
                  const lastHandover = Array.isArray(handoverList) ? handoverList[0] : handoverList
                  if (lastHandover?.id != null) {
                    form.handover_order_id = lastHandover.id
                    handoverOrderOptions.value = [
                      lastHandover,
                      ...handoverOrderOptions.value.filter(
                        (h: any) => Number(h.id) !== Number(lastHandover.id)
                      )
                    ]
                  }
                } catch {
                  /* ignore */
                }
              }
            } catch {
              /* ignore */
            }
          }
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
</style>
