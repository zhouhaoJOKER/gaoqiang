<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="960px"
    :close-on-click-modal="false"
    class="raw-inspection-dialog"
    @closed="handleClosed"
  >
    <div class="dialog-body-scroll">
      <ElForm ref="formRef" :model="form" :rules="rules" label-width="140px">
        <ElDivider content-position="left">原料检验原始记录（原药、助剂）</ElDivider>
        <ElRow :gutter="20">
          <ElCol :span="12" v-if="!props.initialContractId">
            <ElFormItem label="关联合同" prop="contract_id">
              <ElSelect
                v-model="form.contract_id"
                placeholder="请选择合同（fm_contracts）"
                filterable
                remote
                :remote-method="searchContracts"
                :loading="contractSearchLoading"
                style="width: 100%"
                :disabled="props.readonly"
                clearable
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
          <ElCol :span="12" v-if="props.initialContractId">
            <ElFormItem label="关联合同">
              <span class="text-secondary">当前合同</span>
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="检验编号" prop="code">
              <ElInput
                v-model="form.code"
                :placeholder="isEditMode ? '检验编号' : '自动生成'"
                :readonly="props.readonly || !isEditMode"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="原料名称" prop="product_id">
              <ElSelect
                v-model="form.product_id"
                placeholder="请选择原料"
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
            <ElFormItem label="供应商" prop="supplier_id">
              <ElSelect
                v-model="form.supplier_id"
                placeholder="请选择供应商"
                filterable
                remote
                :remote-method="searchSuppliers"
                :loading="supplierSearchLoading"
                style="width: 100%"
                :disabled="props.readonly"
                clearable
                @change="onSupplierChange"
              >
                <ElOption
                  v-for="s in supplierOptions"
                  :key="s.id"
                  :label="
                    s.name != null && s.name !== '' ? `[${s.code || ''}] ${s.name}` : s.name || '-'
                  "
                  :value="s.id"
                />
              </ElSelect>
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="原料批号" prop="batch_number">
              <ElInput
                v-model="form.batch_number"
                placeholder="请输入原料批号"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="检验数量" prop="inspection_qty">
              <ElInput
                v-model="form.inspection_qty"
                placeholder="请输入检验数量"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="请检日期" prop="request_inspection_date">
              <ElDatePicker
                v-model="form.request_inspection_date"
                type="date"
                placeholder="请选择请检日期"
                style="width: 100%"
                value-format="YYYY-MM-DD"
                :disabled="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="检验日期" prop="inspection_date">
              <ElDatePicker
                v-model="form.inspection_date"
                type="date"
                placeholder="请选择检验日期"
                style="width: 100%"
                value-format="YYYY-MM-DD"
                :disabled="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="24">
            <ElFormItem label="检验依据" prop="inspection_basis">
              <ElInput
                v-model="form.inspection_basis"
                placeholder="请输入检验依据"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>

        <ElDivider content-position="left">检测项目 - 有效成分</ElDivider>
        <ElRow :gutter="20">
          <ElCol :span="6">
            <ElFormItem label="标样 m₀" prop="std_sample_m">
              <ElInput
                v-model="form.std_sample_m"
                type="number"
                placeholder="标样 m₀"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="6">
            <ElFormItem label="标样 X₀" prop="std_sample_x">
              <ElInput
                v-model="form.std_sample_x"
                type="number"
                placeholder="标样 X₀"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="6">
            <ElFormItem label="标样 A₀(r₀)-1" prop="std_sample_a_r_1">
              <ElInput
                v-model="form.std_sample_a_r_1"
                type="number"
                placeholder="标样 A₀(r₀)-1"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="6">
            <ElFormItem label="标样 A₀(r₀)-2" prop="std_sample_a_r_2">
              <ElInput
                v-model="form.std_sample_a_r_2"
                type="number"
                placeholder="标样 A₀(r₀)-2"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
        </ElRow>

        <div class="lines-section">
          <div class="lines-header">
            <span>样品</span>
            <span v-if="!props.readonly" class="lines-actions">
              <ElButton type="primary" size="small" @click="handleAddLine">添加行</ElButton>
            </span>
          </div>
          <ElTable :data="form.lines" border style="width: 100%">
            <ElTableColumn type="index" label="序号" width="55" />
            <ElTableColumn label="含量（%）" min-width="120">
              <template #default="{ row }">
                <ElInput
                  v-model="row.content_percent"
                  placeholder="含量"
                  :readonly="props.readonly"
                />
              </template>
            </ElTableColumn>
            <ElTableColumn label="样品 m" min-width="120">
              <template #default="{ row }">
                <ElInput
                  v-model="row.m_value"
                  type="number"
                  placeholder="样品 m"
                  :readonly="props.readonly"
                />
              </template>
            </ElTableColumn>
            <ElTableColumn label="样品 A(r)" min-width="120">
              <template #default="{ row }">
                <ElInput
                  v-model="row.a_r_value"
                  type="number"
                  placeholder="样品 A(r)"
                  :readonly="props.readonly"
                />
              </template>
            </ElTableColumn>
            <ElTableColumn label="样品 X（%）" min-width="120">
              <template #default="{ row }">
                <ElInput
                  v-model="row.x_percent"
                  placeholder="样品 X（%）"
                  :readonly="props.readonly"
                />
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

        <ElDivider content-position="left">其它指标</ElDivider>
        <ElRow :gutter="20">
          <ElCol :span="8">
            <ElFormItem label="PH值（酸度/碱度，%）" prop="ph_value">
              <ElInput v-model="form.ph_value" placeholder="PH值" :readonly="props.readonly" />
            </ElFormItem>
          </ElCol>
          <ElCol :span="8">
            <ElFormItem label="水分（%）" prop="moisture_percent">
              <ElInput
                v-model="form.moisture_percent"
                placeholder="水分"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="8">
            <ElFormItem label="其它" prop="other_indicators">
              <ElInput
                v-model="form.other_indicators"
                placeholder="其它指标"
                :readonly="props.readonly"
              />
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="结论" prop="conclusion">
              <ElRadioGroup v-model="form.conclusion" :disabled="props.readonly">
                <ElRadio label="合格">合格</ElRadio>
                <ElRadio label="不合格">不合格</ElRadio>
              </ElRadioGroup>
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="备注" prop="issue_ncr">
              <ElCheckbox v-model="form.issue_ncr" :disabled="props.readonly"
                >开具不合格评审单</ElCheckbox
              >
            </ElFormItem>
          </ElCol>
          <ElCol :span="12">
            <ElFormItem label="检验" prop="inspector_id">
              <ElSelect
                v-model="form.inspector_id"
                placeholder="请选择检验人"
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
            <ElFormItem label="复核" prop="reviewer_id">
              <ElSelect
                v-model="form.reviewer_id"
                placeholder="请选择复核人"
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
          <ElCol :span="24">
            <ElFormItem label="备注" prop="notes">
              <ElInput
                v-model="form.notes"
                type="textarea"
                :rows="3"
                placeholder="请输入备注"
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
    ElTableColumn,
    ElCheckbox,
    ElDivider,
    ElRadioGroup,
    ElRadio
  } from 'element-plus'
  import { ElDatePicker } from 'element-plus'
  import { createIqcRawApi, updateIqcRawApi, viewIqcRawApi, listIqcRawLineApi } from '@/api/iqc/raw'
  import { listCrmContractApi } from '@/api/crm/contract'
  import { listMatItemApi } from '@/api/mat/item'
  import { listPropertyApi } from '@/api/property'
  import { listMatSupplierApi } from '@/api/mat/supplier'
  import { listUserApi } from '@/api/user'
  import { previewDocNumberApi } from '@/api/doc-number'

  interface Props {
    modelValue: boolean
    raw?: any
    readonly?: boolean
    /** 从合同详情页进入时传入，预填关联合同并锁定 */
    initialContractId?: string | number
  }
  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', raw: any): void
    (e: 'updated', raw: any): void
  }
  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    raw: undefined,
    readonly: false,
    initialContractId: undefined
  })
  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })
  const isEditMode = computed(() => !!props.raw?.id)
  const dialogTitle = computed(() =>
    props.readonly ? '查看原料检验' : isEditMode.value ? '编辑原料检验' : '新建原料检验'
  )

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    product_id: [{ required: true, message: '请选择原料', trigger: 'change' }],
    inspection_date: [{ required: true, message: '请选择检验日期', trigger: 'change' }],
    conclusion: [{ required: true, message: '请选择结论', trigger: 'change' }]
  })

  const form = reactive({
    id: undefined as string | number | undefined,
    contract_id: undefined as string | number | undefined,
    product_id: undefined as string | number | undefined,
    name: '',
    code: '',
    supplier_id: undefined as string | number | undefined,
    supplier_name: '',
    batch_number: '',
    inspection_qty: '',
    request_inspection_date: '',
    inspection_date: '',
    inspection_basis: '',
    std_sample_m: undefined as string | number | undefined,
    std_sample_x: undefined as string | number | undefined,
    std_sample_a_r_1: undefined as string | number | undefined,
    std_sample_a_r_2: undefined as string | number | undefined,
    ph_value: '',
    moisture_percent: '',
    other_indicators: '',
    conclusion: '',
    conclusion_id: undefined as string | number | undefined,
    issue_ncr: false,
    notes: '',
    inspector_id: undefined as string | number | undefined,
    reviewer_id: undefined as string | number | undefined,
    lines: [] as any[]
  })

  const contractOptions = ref<any[]>([])
  const contractSearchLoading = ref(false)
  const productOptions = ref<any[]>([])
  const productSearchLoading = ref(false)
  const supplierOptions = ref<any[]>([])
  const supplierSearchLoading = ref(false)
  const userOptions = ref<any[]>([])
  const userSearchLoading = ref(false)

  const searchContracts = async (query: string) => {
    contractSearchLoading.value = true
    try {
      const res = await listCrmContractApi({ 'q[code_cont]': query || '', per_page: 50 })
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      contractOptions.value = arr.filter((c: any) => c && c.id != null)
    } catch {
      contractOptions.value = []
    } finally {
      contractSearchLoading.value = false
    }
  }

  const searchProducts = async (query: string) => {
    productSearchLoading.value = true
    try {
      const res = await listMatItemApi({
        'q[name_or_code_cont]': query || '',
        'q[type_id_eq]': 200,
        per_page: 50
      })
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      productOptions.value = arr.filter((p: any) => p && p.id != null)
    } finally {
      productSearchLoading.value = false
    }
  }

  const searchSuppliers = async (query: string) => {
    supplierSearchLoading.value = true
    try {
      const res = await listMatSupplierApi({ 'q[name_or_code_cont]': query || '', per_page: 50 })
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      supplierOptions.value = arr.filter((s: any) => s && s.id != null)
    } finally {
      supplierSearchLoading.value = false
    }
  }

  const searchUsers = async (query: string) => {
    userSearchLoading.value = true
    try {
      const res = await listUserApi({ 'q[name_or_py_cont]': query || '', per_page: 50 })
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      userOptions.value = arr.filter((u: any) => u && u.id != null)
    } finally {
      userSearchLoading.value = false
    }
  }

  const onProductChange = (val: string | number) => {
    if (val != null) {
      const p = productOptions.value.find((o: any) => Number(o.id) === Number(val))
      if (p) form.name = p.name || ''
    }
  }

  const onSupplierChange = (val: string | number) => {
    if (val != null) {
      const s = supplierOptions.value.find((o: any) => Number(o.id) === Number(val))
      if (s) form.supplier_name = s.name || ''
    }
  }

  const handleAddLine = () => {
    form.lines.push({
      content_percent: '',
      m_value: undefined,
      a_r_value: undefined,
      x_percent: '',
      sort: form.lines.length
    })
  }

  const handleRemoveLine = (index: number) => {
    form.lines.splice(index, 1)
  }

  const loadDetail = async () => {
    if (!props.raw?.id) return
    try {
      const res = await viewIqcRawApi({ id: props.raw.id })
      const d = (res as any).data || {}
      Object.assign(form, {
        id: d.id,
        contract_id: d.contract_id,
        product_id: d.product_id,
        name: d.name || '',
        code: d.code || '',
        supplier_id: d.supplier_id,
        supplier_name: d.supplier_name || '',
        batch_number: d.batch_number || '',
        inspection_qty: d.inspection_qty || '',
        request_inspection_date: d.request_inspection_date || '',
        inspection_date: d.inspection_date || '',
        inspection_basis: d.inspection_basis || '',
        std_sample_m: d.std_sample_m,
        std_sample_x: d.std_sample_x,
        std_sample_a_r_1: d.std_sample_a_r_1,
        std_sample_a_r_2: d.std_sample_a_r_2,
        ph_value: d.ph_value || '',
        moisture_percent: d.moisture_percent || '',
        other_indicators: d.other_indicators || '',
        conclusion: d.conclusion || '',
        conclusion_id: d.conclusion_id,
        issue_ncr: !!d.issue_ncr,
        notes: d.notes || '',
        inspector_id: d.inspector_id,
        reviewer_id: d.reviewer_id,
        lines: []
      })
      const linesRes = await listIqcRawLineApi({ 'q[raw_id_eq]': d.id })
      const linesData = (linesRes as any).data || []
      const arr = Array.isArray(linesData) ? linesData : linesData.list || linesData.data || []
      form.lines = arr.map((line: any) => ({
        id: line.id,
        content_percent: line.content_percent || '',
        m_value: line.m_value,
        a_r_value: line.a_r_value,
        x_percent: line.x_percent || '',
        sort: line.sort ?? 0
      }))
      if (!d.conclusion_id && d.conclusion) {
        try {
          const propRes = await listPropertyApi({
            'q[sign_eq]': 'iqc_raw_conclusion',
            'q[name_eq]': d.conclusion,
            per_page: 1
          })
          const pl = (propRes as any).data || []
          const prop = Array.isArray(pl) ? pl[0] : pl?.list?.[0] || pl?.data?.[0]
          if (prop) form.conclusion_id = prop.id
        } catch {
          /* ignore */
        }
      }
      await searchContracts('')
      await searchProducts('')
      await searchSuppliers('')
      await searchUsers('')
      // 编辑时确保当前供应商在选项中，以便显示供应商名称
      if (form.supplier_id != null && form.supplier_name) {
        const exists = supplierOptions.value.some(
          (s: any) => Number(s.id) === Number(form.supplier_id)
        )
        if (!exists) {
          supplierOptions.value = [
            { id: form.supplier_id, code: '', name: form.supplier_name },
            ...supplierOptions.value
          ]
        }
      }
    } catch {
      ElMessage.error('加载详情失败')
    }
  }

  const buildParams = () => {
    return {
      contract_id: form.contract_id,
      product_id: form.product_id,
      name: form.name || undefined,
      code: form.code || undefined,
      supplier_id: form.supplier_id,
      supplier_name: form.supplier_name || undefined,
      batch_number: form.batch_number || undefined,
      inspection_qty: form.inspection_qty || undefined,
      request_inspection_date: form.request_inspection_date || undefined,
      inspection_date: form.inspection_date || undefined,
      inspection_basis: form.inspection_basis || undefined,
      std_sample_m:
        form.std_sample_m != null && form.std_sample_m !== ''
          ? Number(form.std_sample_m)
          : undefined,
      std_sample_x:
        form.std_sample_x != null && form.std_sample_x !== ''
          ? Number(form.std_sample_x)
          : undefined,
      std_sample_a_r_1:
        form.std_sample_a_r_1 != null && form.std_sample_a_r_1 !== ''
          ? Number(form.std_sample_a_r_1)
          : undefined,
      std_sample_a_r_2:
        form.std_sample_a_r_2 != null && form.std_sample_a_r_2 !== ''
          ? Number(form.std_sample_a_r_2)
          : undefined,
      ph_value: form.ph_value || undefined,
      moisture_percent: form.moisture_percent || undefined,
      other_indicators: form.other_indicators || undefined,
      conclusion: form.conclusion || undefined,
      conclusion_id: form.conclusion_id,
      issue_ncr: form.issue_ncr,
      notes: form.notes || undefined,
      inspector_id: form.inspector_id,
      reviewer_id: form.reviewer_id,
      lines: form.lines.map((l) => ({
        content_percent: l.content_percent || undefined,
        m_value: l.m_value != null && l.m_value !== '' ? Number(l.m_value) : undefined,
        a_r_value: l.a_r_value != null && l.a_r_value !== '' ? Number(l.a_r_value) : undefined,
        x_percent: l.x_percent || undefined,
        sort: l.sort
      }))
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
      const params = buildParams()
      if (isEditMode.value) {
        await updateIqcRawApi(String(form.id), params)
        ElMessage.success('更新成功')
        emit('updated', { ...props.raw, ...params })
        dialogVisible.value = false
      } else {
        const res = await createIqcRawApi(params)
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
      const params = buildParams()
      const res = await createIqcRawApi(params)
      ElMessage.success('创建成功')
      emit('created', (res as any).data)
      Object.assign(form, {
        id: undefined,
        contract_id: undefined,
        product_id: undefined,
        name: '',
        code: '',
        supplier_id: undefined,
        supplier_name: '',
        batch_number: '',
        inspection_qty: '',
        request_inspection_date: '',
        inspection_date: '',
        inspection_basis: '',
        std_sample_m: undefined,
        std_sample_x: undefined,
        std_sample_a_r_1: undefined,
        std_sample_a_r_2: undefined,
        ph_value: '',
        moisture_percent: '',
        other_indicators: '',
        conclusion: '',
        conclusion_id: undefined,
        issue_ncr: false,
        notes: '',
        inspector_id: undefined,
        reviewer_id: undefined,
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
      product_id: undefined,
      name: '',
      code: '',
      supplier_id: undefined,
      supplier_name: '',
      batch_number: '',
      inspection_qty: '',
      request_inspection_date: '',
      inspection_date: '',
      inspection_basis: '',
      std_sample_m: undefined,
      std_sample_x: undefined,
      std_sample_a_r_1: undefined,
      std_sample_a_r_2: undefined,
      ph_value: '',
      moisture_percent: '',
      other_indicators: '',
      conclusion: '',
      conclusion_id: undefined,
      issue_ncr: false,
      notes: '',
      inspector_id: undefined,
      reviewer_id: undefined,
      lines: []
    })
    formRef.value?.resetFields()
  }

  const fillCodeFromPreview = async () => {
    try {
      const res = await previewDocNumberApi('iqc_raws')
      const d = (res as any).data || {}
      if (d.code) form.code = d.code
    } catch {
      /* ignore */
    }
  }

  watch(
    () => props.modelValue,
    async (val) => {
      if (val) {
        if (isEditMode.value) await loadDetail()
        else {
          if (!form.code) fillCodeFromPreview()
          if (props.initialContractId != null) {
            form.contract_id = props.initialContractId
            await searchContracts('')
            const c = contractOptions.value.find(
              (x: any) => Number(x.id) === Number(props.initialContractId)
            )
            if (!c) {
              try {
                const { viewCrmContractApi } = await import('@/api/crm/contract')
                const res = await viewCrmContractApi({ id: props.initialContractId })
                const d = (res as any).data
                if (d) contractOptions.value = [d, ...contractOptions.value]
              } catch {
                /* ignore */
              }
            }
          } else {
            searchContracts('')
          }
          searchProducts('')
          searchSuppliers('')
          searchUsers('')
        }
      }
    }
  )
  watch(
    () => props.raw,
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
