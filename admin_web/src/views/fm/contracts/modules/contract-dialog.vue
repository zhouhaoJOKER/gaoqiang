<template>
  <ElDialog
    v-model="dialogVisible"
    :title="dialogTitle"
    width="1200px"
    :close-on-click-modal="false"
    @closed="handleClosed"
  >
    <ElForm ref="formRef" :model="form" :rules="rules" label-width="120px">
      <!-- 基本信息 -->
      <ElDivider content-position="left">基本信息</ElDivider>
      <ElRow :gutter="20">
        <ElCol :span="6">
          <ElFormItem label="合同编号" prop="code">
            <ElInput
              v-model="form.code"
              placeholder="自动生成或请输入"
              :readonly="props.readonly"
            />
          </ElFormItem>
        </ElCol>
        <ElCol :span="6">
          <ElFormItem label="签订日期" prop="sign_at">
            <ElDatePicker
              v-model="form.sign_at"
              type="date"
              placeholder="选择签订日期"
              style="width: 100%"
              value-format="YYYY-MM-DD"
              :disabled="props.readonly"
            />
          </ElFormItem>
        </ElCol>
        <ElCol :span="6">
          <ElFormItem label="结算方式" prop="settlement_id">
            <PropertySelectWithAdd
              v-model="form.settlement_id"
              sign="crm_settlement"
              placeholder="请选择结算方式"
              :disabled="props.readonly"
            />
          </ElFormItem>
        </ElCol>
      </ElRow>

      <!-- 采购方信息 -->
      <ElDivider content-position="left">采购方（客户）信息</ElDivider>
      <ElRow :gutter="20">
        <ElCol :span="12">
          <ElFormItem label="客户" prop="client_id">
            <div class="inline-add-wrap">
              <ElSelect
                v-model="form.client_id"
                placeholder="请选择客户"
                filterable
                remote
                :remote-method="searchClients"
                :loading="clientSearchLoading"
                style="width: 100%"
                :disabled="props.readonly"
                @change="handleClientChange"
              >
                <ElOption
                  v-for="c in clientOptions"
                  :key="c.id"
                  :label="`[${c.code || ''}] ${c.name}`"
                  :value="c.id"
                />
              </ElSelect>
              <ElButton
                v-if="!props.readonly"
                type="primary"
                link
                @click="clientDialogVisible = true"
              >
                <ArtSvgIcon icon="ri:add-line" />
              </ElButton>
            </div>
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="联系人" prop="client_contact_id">
            <div class="inline-add-wrap">
              <ElSelect
                v-model="form.client_contact_id"
                placeholder="请选择联系人"
                filterable
                clearable
                style="width: 100%"
                :disabled="props.readonly || !form.client_id"
                @change="handleClientContactChange"
              >
                <ElOption
                  v-for="c in clientContactOptions"
                  :key="c.id"
                  :label="c.name"
                  :value="c.id"
                />
              </ElSelect>
              <ElButton
                v-if="!props.readonly"
                type="primary"
                link
                :disabled="!form.client_id"
                @click="contactDialogVisible = true"
              >
                <ArtSvgIcon icon="ri:add-line" />
              </ElButton>
            </div>
          </ElFormItem>
        </ElCol>
      </ElRow>

      <!-- 供应方信息 -->
      <ElDivider content-position="left">供应方（供应商）信息</ElDivider>
      <ElRow :gutter="20">
        <ElCol :span="12">
          <ElFormItem label="供应商" prop="supplier_id">
            <div class="inline-add-wrap">
              <ElSelect
                v-model="form.supplier_id"
                placeholder="请选择供应商"
                filterable
                remote
                :remote-method="searchSuppliers"
                :loading="supplierSearchLoading"
                style="width: 100%"
                :disabled="props.readonly"
                @change="handleSupplierChange"
              >
                <ElOption
                  v-for="s in supplierOptions"
                  :key="s.id"
                  :label="`[${s.code || ''}] ${s.name}`"
                  :value="s.id"
                />
              </ElSelect>
              <ElButton
                v-if="!props.readonly"
                type="primary"
                link
                @click="supplierDialogVisible = true"
              >
                <ArtSvgIcon icon="ri:add-line" />
              </ElButton>
            </div>
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="联系人" prop="supplier_contact_id">
            <div class="inline-add-wrap">
              <ElSelect
                v-model="form.supplier_contact_id"
                placeholder="请选择或输入联系人"
                filterable
                allow-create
                default-first-option
                style="width: 100%"
                :disabled="props.readonly || !form.supplier_id"
                @change="handleSupplierContactChange"
              >
                <ElOption
                  v-for="c in supplierContactOptions"
                  :key="String(c.id)"
                  :label="c.name"
                  :value="c.id"
                />
              </ElSelect>
              <ElButton
                v-if="!props.readonly"
                type="primary"
                link
                :disabled="!form.supplier_id"
                @click="supplierContactDialogVisible = true"
              >
                <ArtSvgIcon icon="ri:add-line" />
              </ElButton>
            </div>
          </ElFormItem>
        </ElCol>
      </ElRow>

      <!-- 产品信息 -->
      <ElDivider content-position="left">产品信息</ElDivider>
      <ElRow :gutter="20">
        <ElCol :span="12">
          <ElFormItem label="产品">
            <ElSelect
              v-model="productSelectValue"
              placeholder="请选择或输入产品名称"
              filterable
              remote
              :remote-method="searchContractProducts"
              :loading="contractProductSearchLoading"
              style="width: 100%"
              :disabled="props.readonly"
              clearable
              default-first-option
              @change="handleContractProductChange"
            >
              <ElOption
                v-for="p in contractProductDisplayOptions"
                :key="String(p.id)"
                :label="p.label"
                :value="p.id"
              />
            </ElSelect>
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="英文品名">
            <ElInput
              v-model="form.product_en"
              placeholder="请输入英文品名"
              :readonly="props.readonly"
              @blur="onProductEnBlur"
            />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="规格外观">
            <ElInput
              v-model="form.specs"
              type="textarea"
              :rows="2"
              placeholder="规格外观"
              :readonly="props.readonly"
            />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="包装要求">
            <ElInput
              v-model="form.pack_req"
              type="textarea"
              :rows="2"
              placeholder="包装要求"
              :readonly="props.readonly"
            />
          </ElFormItem>
        </ElCol>
      </ElRow>

      <!-- 金额信息 -->
      <ElDivider content-position="left">金额信息</ElDivider>
      <ElRow :gutter="20">
        <ElCol :span="6">
          <ElFormItem label="数量">
            <ElInput
              v-model.number="form.qty"
              type="number"
              placeholder="0"
              :readonly="props.readonly"
              @input="calcTotals"
            />
          </ElFormItem>
        </ElCol>
        <ElCol :span="6">
          <ElFormItem label="单位">
            <PropertySelectWithAdd
              v-model="form.unit_id"
              sign="product_uom"
              placeholder="请选择单位"
              :disabled="props.readonly"
            />
          </ElFormItem>
        </ElCol>
        <ElCol :span="6">
          <ElFormItem label="单价">
            <ElInput
              v-model.number="form.unit_price"
              type="number"
              placeholder="0"
              :readonly="props.readonly"
              @input="calcTotals"
            />
          </ElFormItem>
        </ElCol>
        <ElCol :span="6">
          <ElFormItem label="合计金额">
            <ElInput v-model.number="form.total" type="number" placeholder="0" disabled />
          </ElFormItem>
        </ElCol>
        <ElCol :span="6">
          <ElFormItem label="税率" :class="{ 'is-error': taxRateMismatch }">
            <PropertySelectWithAdd
              v-model="form.tax_id"
              sign="product_purchase_tax"
              placeholder="请选择税率"
              :disabled="props.readonly"
              :refresh-trigger="taxRateRefreshKey"
              @change="onTaxRateChange"
            />
            <div v-if="taxRateMismatch && !props.readonly" class="tax-rate-mismatch-hint">
              <span class="hint-text">是否创建{{ taxRateMismatch.rateLabel }}税率？</span>
              <ElButton type="primary" link size="small" @click="createTaxRateFromImplied">
                创建
              </ElButton>
            </div>
          </ElFormItem>
        </ElCol>
        <ElCol :span="6">
          <ElFormItem label="税额">
            <ElInput
              v-model.number="form.tax"
              type="number"
              placeholder="0"
              :readonly="props.readonly"
              @input="onTaxChange"
            />
          </ElFormItem>
        </ElCol>
        <ElCol :span="6">
          <ElFormItem label="不含税金额">
            <ElInput v-model.number="form.amount_net" type="number" placeholder="0" disabled />
          </ElFormItem>
        </ElCol>
        <ElCol :span="6">
          <ElFormItem label="人民币大写">
            <ElInput v-model="form.total_cn" placeholder="自动生成" disabled />
          </ElFormItem>
        </ElCol>
      </ElRow>

      <!-- 交货与其他 -->
      <ElDivider content-position="left">交货与其他</ElDivider>
      <ElRow :gutter="20">
        <ElCol :span="12">
          <ElFormItem label="交货时间" prop="deliver_at">
            <ElDatePicker
              v-model="form.deliver_at"
              type="date"
              placeholder="选择交货时间"
              style="width: 100%"
              value-format="YYYY-MM-DD"
              :disabled="props.readonly"
            />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="交货地点">
            <ElInput
              v-model="form.deliver_addr"
              placeholder="请输入交货地点"
              :readonly="props.readonly"
            />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="指标要求">
            <ElInput
              v-model="form.indicator_req"
              placeholder="指标要求"
              :readonly="props.readonly"
            />
          </ElFormItem>
        </ElCol>
        <ElCol :span="12">
          <ElFormItem label="所需文件">
            <ElInput v-model="form.req_docs" placeholder="所需文件" :readonly="props.readonly" />
          </ElFormItem>
        </ElCol>
        <ElCol :span="24">
          <ElFormItem label="备注条款">
            <ElInput
              v-model="form.remarks"
              type="textarea"
              :rows="3"
              placeholder="备注条款"
              :readonly="props.readonly"
            />
          </ElFormItem>
        </ElCol>
      </ElRow>

      <!-- 合同款项明细 -->
      <ElDivider content-position="left">合同款项明细</ElDivider>
      <div class="lines-section">
        <div class="lines-header">
          <span />
          <ElButton v-if="!props.readonly" type="primary" size="small" @click="handleAddLine"
            >添加行</ElButton
          >
        </div>
        <ElTable :data="form.lines" border style="width: 100%">
          <ElTableColumn type="index" label="序号" width="55" />
          <ElTableColumn label="产品" min-width="200">
            <template #default="{ row, $index }">
              <ElSelect
                v-model="row.product_id"
                placeholder="请选择产品"
                filterable
                remote
                :remote-method="(q: string) => searchLineProducts(q, $index)"
                :loading="lineProductSearchLoading[$index]"
                style="width: 100%"
                :disabled="props.readonly"
                clearable
                @change="(val: any) => handleLineProductChange(val, $index)"
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
              <ElInput v-model="row.name" placeholder="产品名称" :readonly="props.readonly" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="单位" width="120">
            <template #default="{ row }">
              <ElSelect
                v-model="row.unit_id"
                placeholder="单位"
                clearable
                filterable
                style="width: 100%"
                :disabled="props.readonly"
              >
                <ElOption v-for="u in uomOptions" :key="u.id" :label="u.name" :value="u.id" />
              </ElSelect>
            </template>
          </ElTableColumn>
          <ElTableColumn label="数量(KG)" min-width="100">
            <template #default="{ row }">
              <ElInput
                v-model.number="row.qty"
                type="number"
                placeholder="0"
                :readonly="props.readonly"
                @input="calcLineAmounts(row)"
              />
            </template>
          </ElTableColumn>
          <ElTableColumn label="单价(RMB)" min-width="110">
            <template #default="{ row }">
              <ElInput
                v-model.number="row.price"
                type="number"
                placeholder="0"
                :readonly="props.readonly"
                @input="calcLineAmounts(row)"
              />
            </template>
          </ElTableColumn>
          <ElTableColumn label="不含税金额" min-width="110">
            <template #default="{ row }">
              <span>{{ formatNum(row.amount_excl_tax) }}</span>
            </template>
          </ElTableColumn>
          <ElTableColumn label="税额(RMB)" min-width="100">
            <template #default="{ row }">
              <ElInput
                v-model.number="row.tax"
                type="number"
                placeholder="0"
                :readonly="props.readonly"
                @input="calcLineAmounts(row)"
              />
            </template>
          </ElTableColumn>
          <ElTableColumn label="总金额(RMB)" min-width="110">
            <template #default="{ row }">
              <span>{{ formatNum(row.amount) }}</span>
            </template>
          </ElTableColumn>
          <ElTableColumn label="备注" min-width="120">
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

  <!-- 新增客户弹窗 -->
  <ClientDialog v-model="clientDialogVisible" @created="onClientCreated" />
  <!-- 新增联系人弹窗 -->
  <ContactDialog
    v-model="contactDialogVisible"
    :fixed-client-id="form.client_id"
    :client-data="selectedClientData"
    @created="onContactCreated"
  />
  <!-- 新增供应商弹窗 -->
  <SupplierDialog v-model="supplierDialogVisible" @created="onSupplierCreated" />
  <!-- 新增供应商联系人弹窗 -->
  <ElDialog
    v-model="supplierContactDialogVisible"
    title="新增供应方联系人"
    width="480px"
    :close-on-click-modal="false"
    @closed="supplierContactForm = { name: '', phone: '', fax: '' }"
  >
    <ElForm :model="supplierContactForm" label-width="100px">
      <ElFormItem label="联系人姓名" required>
        <ElInput v-model="supplierContactForm.name" placeholder="请输入联系人姓名" />
      </ElFormItem>
      <ElFormItem label="电话">
        <ElInput v-model="supplierContactForm.phone" placeholder="请输入电话" />
      </ElFormItem>
      <ElFormItem label="传真">
        <ElInput v-model="supplierContactForm.fax" placeholder="请输入传真" />
      </ElFormItem>
    </ElForm>
    <template #footer>
      <ElButton @click="supplierContactDialogVisible = false">取消</ElButton>
      <ElButton type="primary" @click="handleSupplierContactAdd">确定</ElButton>
    </template>
  </ElDialog>
</template>

<script setup lang="ts">
  import { ref, reactive, computed, watch } from 'vue'
  import { ElMessage } from 'element-plus'
  import type { FormInstance, FormRules } from 'element-plus'
  import {
    createCrmContractApi,
    updateCrmContractApi,
    viewCrmContractApi,
    listCrmCollectionApi
  } from '@/api/crm/contract'
  import { listCrmClientApi, viewCrmClientApi } from '@/api/crm/client'
  import { listCrmContactApi } from '@/api/crm/contact'
  import { listMatSupplierApi, viewMatSupplierApi } from '@/api/mat/supplier'
  import {
    createMatSupplierContactApi,
    listMatSupplierContactApi
  } from '@/api/mat/supplier-contact'
  import { previewDocNumberApi, generateDocNumberApi } from '@/api/doc-number'
  import {
    listMatItemApi,
    viewMatItemApi,
    updateMatItemApi,
    createMatItemApi
  } from '@/api/mat/item'
  import { listPropertyApi, viewPropertyApi, createPropertyApi } from '@/api/property'
  import PropertySelectWithAdd from '@/components/PropertySelectWithAdd.vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import ClientDialog from '@/views/crm/clients/modules/client-dialog.vue'
  import ContactDialog from '@/views/crm/contacts/modules/contact-dialog.vue'
  import SupplierDialog from '@/views/pur/suppliers/modules/supplier-dialog.vue'

  interface Props {
    modelValue: boolean
    contract?: any
    readonly?: boolean
  }
  interface Emits {
    (e: 'update:modelValue', value: boolean): void
    (e: 'created', contract: any): void
    (e: 'updated', contract: any): void
  }
  const props = withDefaults(defineProps<Props>(), {
    modelValue: false,
    contract: undefined,
    readonly: false
  })
  const emit = defineEmits<Emits>()

  const dialogVisible = computed({
    get: () => props.modelValue,
    set: (val) => emit('update:modelValue', val)
  })
  const isEditMode = computed(() => !!props.contract?.id)
  const dialogTitle = computed(() =>
    props.readonly ? '查看订购合同' : isEditMode.value ? '编辑订购合同' : '创建订购合同'
  )

  const formRef = ref<FormInstance>()
  const rules = reactive<FormRules>({
    code: [{ required: true, message: '请输入合同编号', trigger: 'blur' }],
    client_id: [{ required: true, message: '请选择客户', trigger: 'change' }]
  })

  const EMPTY_FORM = {
    id: undefined as string | number | undefined,
    code: '',
    sign_at: '',
    client_id: undefined as string | number | undefined,
    client_contact_id: undefined as string | number | undefined,
    client_contact_name: '',
    client_phone: '',
    client_fax: '',
    supplier_id: undefined as string | number | undefined,
    supplier_contact_id: '',
    supplier_contact_name: '',
    supplier_phone: '',
    supplier_fax: '',
    product_id: undefined as string | number | undefined,
    product_en: '',
    product_zh: '',
    specs: '',
    pack_req: '',
    qty: undefined as number | undefined,
    unit_id: undefined as string | number | undefined,
    unit_price: undefined as number | undefined,
    total: undefined as number | undefined,
    tax: undefined as number | undefined,
    amount_net: undefined as number | undefined,
    total_cn: '',
    deliver_at: '',
    deliver_addr: '',
    indicator_req: '',
    req_docs: '',
    settlement_id: null as string | number | null,
    tax_id: null as string | number | null,
    remarks: '',
    lines: [] as any[]
  }

  const form = reactive({ ...EMPTY_FORM })

  // ─── 合同主产品 ───
  const contractProductOptions = ref<any[]>([])
  const contractProductSearchLoading = ref(false)
  const productCreateQuery = ref('')
  const productSelectValue = ref<string | number | undefined>(undefined)

  const contractProductDisplayOptions = computed(() => {
    const opts = contractProductOptions.value.map((p: any) => ({
      id: p.id,
      label: `[${p.code || ''}] ${p.name || p.product_name}`
    }))
    if (productCreateQuery.value && opts.length === 0) {
      opts.push({
        id: `__create__${productCreateQuery.value}`,
        label: `创建: ${productCreateQuery.value} 或按回车键直接创建记录`
      })
    }
    return opts
  })

  watch(
    () => form.product_id,
    (v) => {
      productSelectValue.value = v
    },
    { immediate: true }
  )

  const searchContractProducts = async (query: string) => {
    productCreateQuery.value = (query || '').trim()
    contractProductSearchLoading.value = true
    try {
      const res = await listMatItemApi({ 'q[name_or_code_cont]': query || '', per_page: 30 })
      const data = (res as any).data || []
      const arr = Array.isArray(data) ? data : data.list || data.data || []
      contractProductOptions.value = arr.filter((p: any) => p?.id != null)
      if (
        form.product_id &&
        !contractProductOptions.value.find((p: any) => Number(p.id) === Number(form.product_id))
      ) {
        try {
          const viewRes = await viewMatItemApi({ id: form.product_id })
          const item = (viewRes as any).data
          if (item) contractProductOptions.value = [item, ...contractProductOptions.value]
        } catch {
          /* empty */
        }
      }
    } finally {
      contractProductSearchLoading.value = false
    }
  }

  const handleContractProductChange = async (productId: string | number | undefined) => {
    if (!productId) {
      form.product_zh = ''
      form.product_en = ''
      form.product_id = undefined
      return
    }
    const idStr = String(productId)
    if (idStr.startsWith('__create__')) {
      const query = idStr.replace(/^__create__/, '')
      if (!query) {
        productSelectValue.value = undefined
        return
      }
      try {
        const res = await createMatItemApi({ name: query, type_id: 100 })
        const created = (res as any).data
        if (created?.id != null) {
          contractProductOptions.value = [
            { ...created, name: created.name || query },
            ...contractProductOptions.value
          ]
          form.product_id = created.id
          form.product_zh = query
          form.product_en = created.name_en || ''
          productSelectValue.value = created.id
          productCreateQuery.value = ''
          ElMessage.success('已创建产品')
        }
      } catch {
        ElMessage.error('创建产品失败')
        productSelectValue.value = undefined
      }
      return
    }
    const item = contractProductOptions.value.find((p: any) => Number(p.id) === Number(productId))
    if (item) {
      form.product_id = Number(productId)
      form.product_zh = item.name || item.product_name || form.product_zh
      const enName = item.name_en || item.product_name_en || (item.product as any)?.name_en
      form.product_en = enName || ''
    }
  }

  const onProductEnBlur = async () => {
    if (!form.product_id || !form.product_en || props.readonly) return
    const item = contractProductOptions.value.find(
      (p: any) => Number(p.id) === Number(form.product_id)
    )
    const hasEn = item && (item.name_en || item.product_name_en || (item.product as any)?.name_en)
    if (hasEn) return
    try {
      await updateMatItemApi(String(form.product_id), { name_en: form.product_en })
      ElMessage.success('已更新产品英文名')
      if (item) item.name_en = form.product_en
    } catch {
      /* 静默失败，可能后端未支持 name_en */
    }
  }

  // ─── 客户 ───
  const clientOptions = ref<any[]>([])
  const clientSearchLoading = ref(false)
  const selectedClientData = computed(
    () => clientOptions.value.find((c) => c.id === form.client_id) || {}
  )
  const clientDialogVisible = ref(false)

  const searchClients = async (query: string) => {
    clientSearchLoading.value = true
    try {
      const res = await listCrmClientApi({ 'q[name_or_code_cont]': query || '', per_page: 50 })
      const list = (res as any).data || []
      clientOptions.value = (Array.isArray(list) ? list : list.list || list.data || []).filter(
        (c: any) => c?.id != null
      )
      if (
        form.client_id &&
        !clientOptions.value.find((c) => Number(c.id) === Number(form.client_id))
      ) {
        try {
          const viewRes = await viewCrmClientApi({ id: form.client_id })
          const client = (viewRes as any).data
          if (client) clientOptions.value = [client, ...clientOptions.value]
        } catch {
          /* empty */
        }
      }
    } finally {
      clientSearchLoading.value = false
    }
  }

  const handleClientChange = () => {
    form.client_contact_id = undefined
    form.client_contact_name = ''
    form.client_phone = ''
    form.client_fax = ''
    clientContactOptions.value = []
    if (form.client_id) loadClientContacts(form.client_id)
  }

  const onClientCreated = (client: any) => {
    clientDialogVisible.value = false
    if (client?.id) {
      clientOptions.value = [client, ...clientOptions.value]
      form.client_id = client.id
      handleClientChange()
    }
  }

  // ─── 客户联系人 ───
  const clientContactOptions = ref<any[]>([])
  const contactDialogVisible = ref(false)

  const loadClientContacts = async (clientId: string | number) => {
    try {
      const res = await listCrmContactApi({ 'q[client_id_eq]': clientId, per_page: 200 })
      const list = (res as any).data || []
      clientContactOptions.value = (
        Array.isArray(list) ? list : list.list || list.data || []
      ).filter((c: any) => c?.id != null)
    } catch {
      clientContactOptions.value = []
    }
  }

  const handleClientContactChange = (contactId: string | number | undefined) => {
    if (!contactId) {
      form.client_contact_name = ''
      form.client_phone = ''
      return
    }
    const contact = clientContactOptions.value.find((c) => c.id === contactId)
    if (contact) {
      form.client_contact_name = contact.name || ''
      form.client_phone = contact.phone || contact.mobile || ''
    }
  }

  const onContactCreated = (contact: any) => {
    contactDialogVisible.value = false
    if (contact?.id) {
      clientContactOptions.value = [...clientContactOptions.value, contact]
      form.client_contact_id = contact.id
      form.client_contact_name = contact.name || ''
      form.client_phone = contact.phone || contact.mobile || ''
    }
  }

  // ─── 供应商 ───
  const supplierOptions = ref<any[]>([])
  const supplierSearchLoading = ref(false)
  const supplierDialogVisible = ref(false)

  const searchSuppliers = async (query: string) => {
    supplierSearchLoading.value = true
    try {
      const res = await listMatSupplierApi({ 'q[name_or_code_cont]': query || '', per_page: 50 })
      const list = (res as any).data || []
      supplierOptions.value = (Array.isArray(list) ? list : list.list || list.data || []).filter(
        (s: any) => s?.id != null
      )
      if (
        form.supplier_id &&
        !supplierOptions.value.find((s) => Number(s.id) === Number(form.supplier_id))
      ) {
        try {
          const viewRes = await viewMatSupplierApi({ id: form.supplier_id })
          const supplier = (viewRes as any).data
          if (supplier) supplierOptions.value = [supplier, ...supplierOptions.value]
        } catch {
          /* empty */
        }
      }
    } finally {
      supplierSearchLoading.value = false
    }
  }

  const handleSupplierChange = () => {
    form.supplier_contact_id = ''
    form.supplier_contact_name = ''
    form.supplier_phone = ''
    form.supplier_fax = ''
    supplierContactOptions.value = []
    if (form.supplier_id) loadSupplierContacts()
  }

  // ─── 供应商联系人 ───
  const supplierContactOptions = ref<
    { id: string | number; name: string; phone?: string; fax?: string }[]
  >([])
  const supplierContactDialogVisible = ref(false)
  const supplierContactForm = reactive({ name: '', phone: '', fax: '' })

  const loadSupplierContacts = async () => {
    if (!form.supplier_id) {
      supplierContactOptions.value = []
      return
    }
    try {
      const res = await listMatSupplierContactApi({
        'q[supplier_id_eq]': form.supplier_id,
        per_page: 200
      })
      const list = (res as any).data || []
      const arr = Array.isArray(list) ? list : list.list || list.data || []
      supplierContactOptions.value = arr
        .filter((c: any) => c && c.id != null)
        .map((c: any) => ({ id: c.id, name: c.name || '', phone: c.phone, fax: c.fax }))
    } catch {
      supplierContactOptions.value = []
    }
    if (
      form.supplier_contact_name &&
      !supplierContactOptions.value.find((c) => String(c.id) === String(form.supplier_contact_id))
    ) {
      supplierContactOptions.value = [
        {
          id: form.supplier_contact_id || form.supplier_contact_name,
          name: form.supplier_contact_name,
          phone: form.supplier_phone,
          fax: form.supplier_fax
        },
        ...supplierContactOptions.value
      ]
    }
  }

  const handleSupplierContactChange = (val: string | number | undefined) => {
    if (!val) {
      form.supplier_contact_name = ''
      form.supplier_phone = ''
      form.supplier_fax = ''
      return
    }
    const contact = supplierContactOptions.value.find((c) => String(c.id) === String(val))
    if (contact) {
      form.supplier_contact_name = contact.name
      form.supplier_phone = contact.phone || ''
      form.supplier_fax = contact.fax || ''
    } else if (typeof val === 'string') {
      form.supplier_contact_name = val
      form.supplier_contact_id = val
    }
  }

  const handleSupplierContactAdd = async () => {
    const name = (supplierContactForm.name || '').trim()
    if (!name) {
      ElMessage.warning('请输入联系人姓名')
      return
    }
    const supplierId = form.supplier_id
    if (!supplierId) {
      ElMessage.warning('请先选择供应商')
      return
    }
    try {
      const res = await createMatSupplierContactApi({
        supplier_id: supplierId,
        name,
        phone: supplierContactForm.phone || undefined,
        fax: supplierContactForm.fax || undefined
      })
      const created = (res as any).data
      if (created?.id != null) {
        supplierContactOptions.value = [
          ...supplierContactOptions.value,
          {
            id: created.id,
            name: created.name || name,
            phone: created.phone,
            fax: created.fax
          }
        ]
        form.supplier_contact_id = String(created.id)
        form.supplier_contact_name = created.name || name
        form.supplier_phone = created.phone || ''
        form.supplier_fax = created.fax || ''
        supplierContactDialogVisible.value = false
        ElMessage.success('已添加供应方联系人')
      }
    } catch {
      const id = `sc_${Date.now()}`
      const contact = {
        id,
        name,
        phone: supplierContactForm.phone || '',
        fax: supplierContactForm.fax || ''
      }
      supplierContactOptions.value = [...supplierContactOptions.value, contact]
      form.supplier_contact_id = id
      form.supplier_contact_name = contact.name
      form.supplier_phone = contact.phone
      form.supplier_fax = contact.fax
      supplierContactDialogVisible.value = false
      ElMessage.success('已添加供应方联系人（本地）')
    }
  }

  const onSupplierCreated = (supplier: any) => {
    supplierDialogVisible.value = false
    if (supplier?.id) {
      supplierOptions.value = [supplier, ...supplierOptions.value]
      form.supplier_id = supplier.id
      handleSupplierChange()
    }
  }

  // ─── 金额计算 ───
  function numberToChinese(n: number): string {
    if (isNaN(n) || n === 0) return '零元整'
    const digits = '零壹贰叁肆伍陆柒捌玖'
    const units = ['', '拾', '佰', '仟']
    const bigUnits = ['', '万', '亿', '万亿']
    const neg = n < 0 ? '负' : ''
    const intPart = Math.floor(Math.abs(n))
    const decPart = Math.round((Math.abs(n) - intPart) * 100)
    let result = neg
    if (intPart === 0) {
      result += '零'
    } else {
      const intStr = String(intPart)
      const groups: string[] = []
      let tmp = intStr
      while (tmp.length > 0) {
        groups.unshift(tmp.slice(-4))
        tmp = tmp.slice(0, -4)
      }
      for (let i = 0; i < groups.length; i++) {
        const group = groups[i]
        let groupResult = ''
        let zeroFlag = false
        for (let j = 0; j < group.length; j++) {
          const digit = parseInt(group[j])
          const unitIndex = group.length - j - 1
          if (digit === 0) {
            zeroFlag = true
          } else {
            if (zeroFlag) {
              groupResult += '零'
              zeroFlag = false
            }
            groupResult += digits[digit] + units[unitIndex]
          }
        }
        if (groupResult) result += groupResult + bigUnits[groups.length - i - 1]
      }
    }
    result += '元'
    if (decPart === 0) {
      result += '整'
    } else {
      const jiao = Math.floor(decPart / 10)
      const fen = decPart % 10
      if (jiao > 0) result += digits[jiao] + '角'
      else if (intPart > 0) result += '零'
      if (fen > 0) result += digits[fen] + '分'
    }
    return result
  }

  const taxRateOptions = ref<Array<{ id: string | number; name: string }>>([])
  const taxRateMismatch = ref<{ rate: number; rateLabel: string; rateName: string } | null>(null)
  const taxRateRefreshKey = ref(0)

  const loadTaxRateOptions = async () => {
    try {
      const res = await listPropertyApi({ 'q[sign_eq]': 'product_purchase_tax', per_page: 100 })
      const data = (res as any).data || []
      taxRateOptions.value = (Array.isArray(data) ? data : data.list || data.data || []).filter(
        (p: any) => p && p.id != null
      )
    } catch {
      taxRateOptions.value = []
    }
  }

  /** 从属性名称解析税率（如 "13%" -> 0.13） */
  const parseTaxRateFromName = (name: string): number => {
    if (!name || typeof name !== 'string') return 0
    const m = name.match(/(\d+(?:\.\d+)?)\s*%?/)
    if (!m) return 0
    return Math.min(100, Math.max(0, Number(m[1]))) / 100
  }

  const calcTaxFromRate = async () => {
    if (!form.tax_id) return
    let opt = taxRateOptions.value.find((p) => Number(p.id) === Number(form.tax_id))
    if (!opt) {
      try {
        const res = await viewPropertyApi({ id: form.tax_id })
        const p = (res as any).data
        if (p?.name != null) {
          opt = { id: p.id, name: p.name }
          taxRateOptions.value = [...taxRateOptions.value, opt]
        }
      } catch {
        return
      }
    }
    if (!opt) return
    const rate = parseTaxRateFromName(opt.name)
    const total = Number(form.total) || 0
    if (total <= 0) {
      form.tax = 0
      return
    }
    form.tax = Number(((total * rate) / (1 + rate)).toFixed(2))
  }

  const onTaxRateChange = async () => {
    taxRateMismatch.value = null
    await calcTaxFromRate()
    calcAmountCn()
  }

  const onTaxChange = () => {
    const total = Number(form.total) || 0
    const tax = Number(form.tax) || 0
    form.amount_net = Number((total - tax).toFixed(2))
    calcAmountCn()
    taxRateMismatch.value = null
    if (total <= 0 || tax <= 0) return
    const amountNet = total - tax
    if (amountNet <= 0) return
    const impliedRate = tax / amountNet
    const pct = impliedRate * 100
    const rateLabel = (Number.isInteger(pct) ? String(pct) : pct.toFixed(2)) + '%'
    const rateName = Number.isInteger(pct) ? String(pct) : pct.toFixed(2)
    const matched = taxRateOptions.value.find((opt) => {
      const r = parseTaxRateFromName(opt.name)
      return Math.abs(r - impliedRate) < 0.0001
    })
    if (matched) {
      form.tax_id = matched.id
    } else {
      taxRateMismatch.value = { rate: impliedRate, rateLabel, rateName }
    }
  }

  const createTaxRateFromImplied = async () => {
    const m = taxRateMismatch.value
    if (!m) return
    try {
      const res = await createPropertyApi({
        sign: 'product_purchase_tax',
        name: m.rateName
      })
      const created = (res as any).data
      if (created?.id != null) {
        taxRateOptions.value = [
          ...taxRateOptions.value,
          { id: created.id, name: created.name || m.rateName }
        ]
        form.tax_id = created.id
        taxRateMismatch.value = null
        taxRateRefreshKey.value++
        ElMessage.success(`已创建税率 ${m.rateLabel}`)
      }
    } catch {
      ElMessage.error('创建税率失败')
    }
  }

  const calcTotals = async () => {
    const qty = Number(form.qty) || 0
    const price = Number(form.unit_price) || 0
    form.total = Number((qty * price).toFixed(2))
    await calcTaxFromRate()
    calcAmountCn()
  }

  const calcAmountCn = () => {
    const total = Number(form.total) || 0
    const tax = Number(form.tax) || 0
    form.amount_net = Number((total - tax).toFixed(2))
    form.total_cn = total > 0 ? numberToChinese(total) : ''
  }

  // ─── 明细行 ───
  const lineProductOptions = ref<Record<number, any[]>>({})
  const lineProductSearchLoading = ref<Record<number, boolean>>({})
  const uomOptions = ref<Array<{ id: string | number; name: string }>>([])

  const formatNum = (v: any) =>
    v != null && v !== ''
      ? Number(v).toLocaleString(undefined, { minimumFractionDigits: 2, maximumFractionDigits: 2 })
      : '0.00'

  const calcLineAmounts = (row: any) => {
    const qty = Number(row.qty) || 0
    const price = Number(row.price) || 0
    const tax = Number(row.tax) || 0
    row.amount_excl_tax = Number((qty * price).toFixed(2))
    row.amount = Number((row.amount_excl_tax + tax).toFixed(2))
  }

  const loadUomOptions = async () => {
    try {
      const res = await listPropertyApi({ 'q[sign_eq]': 'product_uom', per_page: 200 })
      const data = (res as any).data || []
      uomOptions.value = Array.isArray(data) ? data : data.list || data.data || []
    } catch {
      uomOptions.value = []
    }
  }

  const searchLineProducts = async (query: string, index: number) => {
    lineProductSearchLoading.value = { ...lineProductSearchLoading.value, [index]: true }
    try {
      const res = await listMatItemApi({
        'q[name_or_code_cont]': query || '',
        'q[type_id_eq]': 100,
        per_page: 30
      })
      const data = (res as any).data || []
      const arr = Array.isArray(data) ? data : data.list || data.data || []
      lineProductOptions.value = {
        ...lineProductOptions.value,
        [index]: arr.filter((p: any) => p?.id != null)
      }
    } finally {
      lineProductSearchLoading.value = { ...lineProductSearchLoading.value, [index]: false }
    }
  }

  const handleLineProductChange = (productId: string | number | undefined, index: number) => {
    const row = form.lines[index]
    if (!row) return
    if (!productId) {
      row.name = ''
      row.unit_id = undefined
      return
    }
    const item = (lineProductOptions.value[index] || []).find(
      (p: any) => Number(p.id) === Number(productId)
    )
    if (item) {
      row.name = item.name || row.name
      if (item.uom_id != null) row.unit_id = item.uom_id
    }
  }

  const handleAddLine = () => {
    form.lines.push({
      product_id: undefined,
      name: '',
      unit_id: undefined,
      unit_name: '',
      qty: 0,
      price: 0,
      amount_excl_tax: 0,
      tax: 0,
      amount: 0,
      remark: '',
      sort: form.lines.length
    })
  }
  const handleRemoveLine = (index: number) => form.lines.splice(index, 1)

  // ─── 加载/保存 ───
  const buildParams = () => ({
    code: form.code,
    sign_at: form.sign_at || undefined,
    client_id: form.client_id,
    client_contact_id: form.client_contact_id ?? undefined,
    client_contact_name: form.client_contact_name || undefined,
    client_phone: form.client_phone || undefined,
    client_fax: form.client_fax || undefined,
    supplier_id: form.supplier_id ?? undefined,
    supplier_contact_id: form.supplier_contact_id || undefined,
    supplier_contact_name: form.supplier_contact_name || undefined,
    supplier_phone: form.supplier_phone || undefined,
    supplier_fax: form.supplier_fax || undefined,
    product_id: form.product_id ?? undefined,
    product_en: form.product_en || undefined,
    product_zh: form.product_zh || undefined,
    specs: form.specs || undefined,
    pack_req: form.pack_req || undefined,
    qty: form.qty ?? undefined,
    unit_id: form.unit_id ?? undefined,
    unit_price: form.unit_price ?? undefined,
    total: form.total ?? undefined,
    tax: form.tax ?? undefined,
    amount_net: form.amount_net ?? undefined,
    total_cn: form.total_cn || undefined,
    deliver_at: form.deliver_at || undefined,
    deliver_addr: form.deliver_addr || undefined,
    indicator_req: form.indicator_req || undefined,
    req_docs: form.req_docs || undefined,
    settlement_id: form.settlement_id ?? undefined,
    tax_id: form.tax_id ?? undefined,
    remarks: form.remarks || undefined,
    lines: form.lines.map((l) => ({
      product_id: l.product_id,
      name: l.name,
      unit_id: l.unit_id,
      qty: l.qty,
      price: l.price,
      amount_excl_tax: l.amount_excl_tax,
      tax: l.tax,
      amount: l.amount,
      remark: l.remark,
      sort: l.sort
    }))
  })

  const loadDetail = async () => {
    if (!props.contract?.id) return
    try {
      const res = await viewCrmContractApi({ id: props.contract.id })
      const d = (res as any).data || {}
      Object.assign(form, {
        id: d.id,
        code: d.code || '',
        sign_at: d.sign_at || '',
        client_id: d.client_id,
        client_contact_id: d.client_contact_id,
        client_contact_name: d.client_contact_name || '',
        client_phone: d.client_phone || '',
        client_fax: d.client_fax || '',
        supplier_id: d.supplier_id,
        supplier_contact_id: d.supplier_contact_id || '',
        supplier_contact_name: d.supplier_contact_name || '',
        supplier_phone: d.supplier_phone || '',
        supplier_fax: d.supplier_fax || '',
        product_id: d.product_id,
        product_en: d.product_en || '',
        product_zh: d.product_zh || '',
        specs: d.specs || '',
        pack_req: d.pack_req || '',
        qty: d.qty,
        unit_id: d.unit_id,
        unit_price: d.unit_price,
        total: d.total,
        tax: d.tax,
        amount_net: d.amount_net,
        total_cn: d.total_cn || '',
        deliver_at: d.deliver_at || '',
        deliver_addr: d.deliver_addr || '',
        indicator_req: d.indicator_req || '',
        req_docs: d.req_docs || '',
        settlement_id: d.settlement_id ?? null,
        tax_id: d.tax_id ?? null,
        remarks: d.remarks || '',
        lines: []
      })
      if (form.client_id) {
        await searchClients('')
        await loadClientContacts(form.client_id)
      }
      if (form.supplier_id) await searchSuppliers('')
      loadSupplierContacts()
      if (form.product_id) await searchContractProducts('')
      calcAmountCn()

      const linesRes = await listCrmCollectionApi({ 'q[contract_id_eq]': d.id })
      const linesData = (linesRes as any).data || []
      const arr = Array.isArray(linesData) ? linesData : linesData.list || linesData.data || []
      form.lines = arr.map((line: any, idx: number) => {
        const row = {
          id: line.id,
          product_id: line.product_id,
          name: line.name || '',
          unit_id: line.unit_id,
          unit_name: line.unit_name || '',
          qty: line.qty || 0,
          price: line.price || 0,
          amount_excl_tax: line.amount_excl_tax || 0,
          tax: line.tax || 0,
          amount: line.amount || 0,
          remark: line.remark || '',
          sort: line.sort ?? idx
        }
        calcLineAmounts(row)
        if (line.product_id && line.product_name)
          lineProductOptions.value = {
            ...lineProductOptions.value,
            [idx]: [{ id: line.product_id, code: '', name: line.product_name || line.name }]
          }
        return row
      })
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
      let params = buildParams()
      if (!isEditMode.value) {
        try {
          const genRes = await generateDocNumberApi('fm_contracts')
          const d = (genRes as any).data || {}
          if (d.code) params = { ...params, code: d.code }
        } catch {
          /* 无规则时使用表单中的编号 */
        }
      }
      if (isEditMode.value) {
        await updateCrmContractApi(String(form.id), params)
        ElMessage.success('更新成功')
        emit('updated', { ...props.contract, ...params })
      } else {
        const res = await createCrmContractApi(params)
        ElMessage.success('创建成功')
        emit('created', (res as any).data)
      }
      dialogVisible.value = false
    } catch {
      /* empty */
    }
  }

  const handleSaveAndNew = async () => {
    if (!formRef.value) return
    try {
      await formRef.value.validate()
      let params = buildParams()
      try {
        const genRes = await generateDocNumberApi('fm_contracts')
        const d = (genRes as any).data || {}
        if (d.code) params = { ...params, code: d.code }
      } catch {
        /* 无规则时使用表单中的编号 */
      }
      const res = await createCrmContractApi(params)
      ElMessage.success('创建成功')
      emit('created', (res as any).data)
      resetForm()
      await fillDocNoFromPreview()
    } catch {
      /* empty */
    }
  }

  const fillDocNoFromPreview = async () => {
    try {
      const res = await previewDocNumberApi('fm_contracts')
      const d = (res as any).data || {}
      if (d.code) form.code = d.code
    } catch {
      /* 无规则或接口失败时留空 */
    }
  }

  const resetForm = () => {
    Object.assign(form, { ...EMPTY_FORM, lines: [] })
    clientOptions.value = []
    clientContactOptions.value = []
    supplierOptions.value = []
    supplierContactOptions.value = []
    lineProductOptions.value = {}
    lineProductSearchLoading.value = {}
    formRef.value?.resetFields()
  }

  const handleCancel = () => {
    dialogVisible.value = false
  }
  const handleClosed = () => resetForm()

  watch(
    () => props.modelValue,
    async (val) => {
      if (val) {
        await loadUomOptions()
        await loadTaxRateOptions()
        if (isEditMode.value) await loadDetail()
        else {
          searchClients('')
          searchSuppliers('')
          await fillDocNoFromPreview()
        }
      }
    }
  )
  watch(
    () => props.contract,
    async () => {
      if (props.modelValue && isEditMode.value) await loadDetail()
    },
    { deep: true }
  )
</script>

<style scoped lang="scss">
  .lines-section {
    margin-top: 8px;
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

    .el-select {
      flex: 1;
    }
  }

  .tax-rate-mismatch-hint {
    display: flex;
    gap: 4px;
    align-items: center;
    margin-top: 4px;
    font-size: 12px;

    .hint-text {
      color: var(--el-color-danger);
    }
  }

  :deep(.el-form-item.is-error .el-form-item__label) {
    color: var(--el-color-danger);
  }
</style>
