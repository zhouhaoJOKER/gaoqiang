<template>
  <div class="crm-detail-container order-lines-detail-page art-full-height">
    <div class="detail-header-bar">
      <div class="header-left">
        <ElButton text class="back-btn" @click="goBack">
          <ArtSvgIcon icon="ri:arrow-left-line" />
        </ElButton>
        <span class="header-name">{{
          detail.order_code || detail.contract_code || '订单行详情'
        }}</span>
        <ElTag
          v-if="detail.order_status_name"
          v-bind="statusTagAttrs(detail.order_status_color)"
          size="small"
          class="header-status-tag"
        >
          {{ detail.order_status_name }}
        </ElTag>
      </div>
      <div class="header-right">
        <ElButton text class="header-action-btn" @click="loadDetail">
          <ArtSvgIcon icon="ri:refresh-line" class="mr-1" />刷新
        </ElButton>
      </div>
    </div>

    <div class="detail-content-wrapper">
      <div class="detail-panel">
        <div class="detail-main-grid">
          <div class="detail-main-left">
            <ElCard class="info-group-card info-group-card--unified" shadow="never">
              <template #header>
                <span class="group-card-title">订单行信息</span>
              </template>

              <div class="unified-info-body">
                <ElDivider content-position="left">基本信息</ElDivider>
                <ElDescriptions
                  :column="2"
                  border
                  size="small"
                  label-width="140px"
                  class="group-desc group-desc--uniform"
                >
                  <ElDescriptionsItem label="订单编号">{{
                    detail.order.code || '—'
                  }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="合同编号">{{
                    detail.order.contract_code || '—'
                  }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="接单日期">{{
                    fmtDate(detail.order.receive_date)
                  }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="客户名称">{{
                    detail.order.client_name || '—'
                  }}</ElDescriptionsItem>

                  <ElDescriptionsItem label="产品名称">{{
                    detail.product_name || '—'
                  }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="配瓶型/盖型">{{
                    detail.order.model || '—'
                  }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="颜色">{{ detail.color || '—' }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="克重">{{ detail.weight || '—' }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="订单量">{{ detail.qty ?? '—' }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="单位">{{ detail.unit || '—' }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="铝箔结存情况">{{
                    detail.stock_status || '—'
                  }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="色母情况">{{
                    detail.color_master_status || '—'
                  }}</ElDescriptionsItem>
                  <ElDescriptionsItem label="铝箔/要求" :span="2">{{
                    detail.spec_requirements || '—'
                  }}</ElDescriptionsItem>
                </ElDescriptions>

                <ElDivider content-position="left">交付与生产</ElDivider>
                <ElDescriptions
                  :column="2"
                  border
                  size="small"
                  label-width="140px"
                  class="group-desc group-desc--uniform order-lines-editable"
                >
                  <ElDescriptionsItem label="交货情况">
                    <input
                      class="it-excel-input"
                      inputmode="decimal"
                      :value="detail.delivery_qty ?? ''"
                      type="text"
                      placeholder="—"
                      :disabled="savingKeys.delivery_qty"
                      @input="(e) => (detail.delivery_qty = (e.target as HTMLInputElement).value)"
                      @blur="
                        (e) => patchField('delivery_qty', (e.target as HTMLInputElement).value)
                      "
                      @keydown.enter="(e) => (e.currentTarget as HTMLInputElement).blur()"
                    />
                  </ElDescriptionsItem>

                  <ElDescriptionsItem label="交期">
                    <ElDatePicker
                      v-model="detail.line_delivery_date"
                      type="date"
                      value-format="YYYY-MM-DD"
                      size="small"
                      class="it-dp"
                      clearable
                      teleported
                      popper-class="crm-it-date-popper"
                      :disabled="savingKeys.line_delivery_date"
                      @change="(v: unknown) => patchField('line_delivery_date', v)"
                    />
                  </ElDescriptionsItem>

                  <ElDescriptionsItem label="配损量">
                    <input
                      class="it-excel-input it-excel-input--num"
                      inputmode="decimal"
                      :value="detail.loss_qty ?? ''"
                      type="text"
                      placeholder="—"
                      :disabled="savingKeys.loss_qty"
                      @input="(e) => (detail.loss_qty = (e.target as HTMLInputElement).value)"
                      @blur="(e) => patchField('loss_qty', (e.target as HTMLInputElement).value)"
                      @keydown.enter="(e) => (e.currentTarget as HTMLInputElement).blur()"
                    />
                  </ElDescriptionsItem>

                  <ElDescriptionsItem label="生产机台">
                    <input
                      class="it-excel-input"
                      :value="detail.production_machine ?? ''"
                      type="text"
                      placeholder="—"
                      :disabled="savingKeys.production_machine"
                      @input="
                        (e) => (detail.production_machine = (e.target as HTMLInputElement).value)
                      "
                      @blur="
                        (e) =>
                          patchField('production_machine', (e.target as HTMLInputElement).value)
                      "
                      @keydown.enter="(e) => (e.currentTarget as HTMLInputElement).blur()"
                    />
                  </ElDescriptionsItem>

                  <ElDescriptionsItem label="注塑生产编号">
                    <input
                      class="it-excel-input"
                      :value="detail.injection_prod_code ?? ''"
                      type="text"
                      placeholder="—"
                      :disabled="savingKeys.injection_prod_code"
                      @input="
                        (e) => (detail.injection_prod_code = (e.target as HTMLInputElement).value)
                      "
                      @blur="
                        (e) =>
                          patchField('injection_prod_code', (e.target as HTMLInputElement).value)
                      "
                      @keydown.enter="(e) => (e.currentTarget as HTMLInputElement).blur()"
                    />
                  </ElDescriptionsItem>

                  <ElDescriptionsItem label="注塑生产日期">
                    <ElDatePicker
                      v-model="detail.injection_prod_date"
                      type="date"
                      value-format="YYYY-MM-DD"
                      size="small"
                      class="it-dp"
                      clearable
                      teleported
                      popper-class="crm-it-date-popper"
                      :disabled="savingKeys.injection_prod_date"
                      @change="(v: unknown) => patchField('injection_prod_date', v)"
                    />
                  </ElDescriptionsItem>

                  <ElDescriptionsItem label="垫盖机台">
                    <input
                      class="it-excel-input"
                      :value="detail.gasket_machine ?? ''"
                      type="text"
                      placeholder="—"
                      :disabled="savingKeys.gasket_machine"
                      @input="(e) => (detail.gasket_machine = (e.target as HTMLInputElement).value)"
                      @blur="
                        (e) => patchField('gasket_machine', (e.target as HTMLInputElement).value)
                      "
                      @keydown.enter="(e) => (e.currentTarget as HTMLInputElement).blur()"
                    />
                  </ElDescriptionsItem>

                  <ElDescriptionsItem label="垫盖生产编号">
                    <input
                      class="it-excel-input"
                      :value="detail.gasket_prod_code ?? ''"
                      type="text"
                      placeholder="—"
                      :disabled="savingKeys.gasket_prod_code"
                      @input="
                        (e) => (detail.gasket_prod_code = (e.target as HTMLInputElement).value)
                      "
                      @blur="
                        (e) => patchField('gasket_prod_code', (e.target as HTMLInputElement).value)
                      "
                      @keydown.enter="(e) => (e.currentTarget as HTMLInputElement).blur()"
                    />
                  </ElDescriptionsItem>

                  <ElDescriptionsItem label="垫盖生产日期">
                    <ElDatePicker
                      v-model="detail.gasket_prod_date"
                      type="date"
                      value-format="YYYY-MM-DD"
                      size="small"
                      class="it-dp"
                      clearable
                      teleported
                      popper-class="crm-it-date-popper"
                      :disabled="savingKeys.gasket_prod_date"
                      @change="(v: unknown) => patchField('gasket_prod_date', v)"
                    />
                  </ElDescriptionsItem>

                  <ElDescriptionsItem label="结单日期">
                    <ElDatePicker
                      v-model="detail.closing_date"
                      type="date"
                      value-format="YYYY-MM-DD"
                      size="small"
                      class="it-dp"
                      clearable
                      teleported
                      popper-class="crm-it-date-popper"
                      :disabled="savingKeys.closing_date"
                      @change="(v: unknown) => patchField('closing_date', v)"
                    />
                  </ElDescriptionsItem>

                  <ElDescriptionsItem label="半成品库存量">
                    <input
                      class="it-excel-input it-excel-input--num"
                      inputmode="decimal"
                      :value="detail.semi_inventory ?? ''"
                      type="text"
                      placeholder="—"
                      :disabled="savingKeys.semi_inventory"
                      @input="(e) => (detail.semi_inventory = (e.target as HTMLInputElement).value)"
                      @blur="
                        (e) => patchField('semi_inventory', (e.target as HTMLInputElement).value)
                      "
                    />
                  </ElDescriptionsItem>

                  <ElDescriptionsItem label="半成品已完成量">
                    <input
                      class="it-excel-input it-excel-input--num"
                      inputmode="decimal"
                      :value="detail.semi_completed ?? ''"
                      type="text"
                      placeholder="—"
                      :disabled="savingKeys.semi_completed"
                      @input="(e) => (detail.semi_completed = (e.target as HTMLInputElement).value)"
                      @blur="
                        (e) => patchField('semi_completed', (e.target as HTMLInputElement).value)
                      "
                    />
                  </ElDescriptionsItem>

                  <ElDescriptionsItem label="半成品生产备库存量">
                    <input
                      class="it-excel-input it-excel-input--num"
                      inputmode="decimal"
                      :value="detail.semi_reserve ?? ''"
                      type="text"
                      placeholder="—"
                      :disabled="savingKeys.semi_reserve"
                      @input="(e) => (detail.semi_reserve = (e.target as HTMLInputElement).value)"
                      @blur="
                        (e) => patchField('semi_reserve', (e.target as HTMLInputElement).value)
                      "
                    />
                  </ElDescriptionsItem>

                  <ElDescriptionsItem label="原库存量">
                    <input
                      class="it-excel-input it-excel-input--num"
                      inputmode="decimal"
                      :value="detail.original_inventory ?? ''"
                      type="text"
                      placeholder="—"
                      :disabled="savingKeys.original_inventory"
                      @input="
                        (e) => (detail.original_inventory = (e.target as HTMLInputElement).value)
                      "
                      @blur="
                        (e) =>
                          patchField('original_inventory', (e.target as HTMLInputElement).value)
                      "
                    />
                  </ElDescriptionsItem>

                  <ElDescriptionsItem label="外加工量">
                    <input
                      class="it-excel-input it-excel-input--num"
                      inputmode="decimal"
                      :value="detail.outsourcing_qty ?? ''"
                      type="text"
                      placeholder="—"
                      :disabled="savingKeys.outsourcing_qty"
                      @input="
                        (e) => (detail.outsourcing_qty = (e.target as HTMLInputElement).value)
                      "
                      @blur="
                        (e) => patchField('outsourcing_qty', (e.target as HTMLInputElement).value)
                      "
                    />
                  </ElDescriptionsItem>

                  <ElDescriptionsItem label="订单生产未完成量">
                    <input
                      class="it-excel-input it-excel-input--num"
                      inputmode="decimal"
                      :value="detail.unfinished_qty ?? ''"
                      type="text"
                      placeholder="—"
                      :disabled="savingKeys.unfinished_qty"
                      @input="(e) => (detail.unfinished_qty = (e.target as HTMLInputElement).value)"
                      @blur="
                        (e) => patchField('unfinished_qty', (e.target as HTMLInputElement).value)
                      "
                    />
                  </ElDescriptionsItem>

                  <ElDescriptionsItem label="成品已完成量合计">
                    <input
                      class="it-excel-input it-excel-input--num"
                      inputmode="decimal"
                      :value="detail.finished_total ?? ''"
                      type="text"
                      placeholder="—"
                      :disabled="savingKeys.finished_total"
                      @input="(e) => (detail.finished_total = (e.target as HTMLInputElement).value)"
                      @blur="
                        (e) => patchField('finished_total', (e.target as HTMLInputElement).value)
                      "
                    />
                  </ElDescriptionsItem>
                </ElDescriptions>
              </div>
            </ElCard>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { computed, onMounted, reactive, ref, watch } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import {
    ElButton,
    ElCard,
    ElDatePicker,
    ElDescriptions,
    ElDescriptionsItem,
    ElDivider,
    ElMessage,
    ElTag
  } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { HttpError } from '@/utils/http/error'
  import { crmOrderStatusTagAttrs } from '@/views/crm/crm-order-status'
  import { updateCrmOrderLineDataApi, viewCrmOrderLineByIdApi } from '@/api/crm/order'

  defineOptions({ name: 'CrmOrderLinesDetail' })

  const route = useRoute()
  const router = useRouter()

  const loading = ref(false)
  const detailLoaded = ref(false)
  const detail = ref<Record<string, any>>({})

  const savingKeys = reactive<Record<string, boolean>>({})

  const detailId = computed(() => {
    const id = route.params.id
    return Array.isArray(id) ? id[0] : id
  })

  function goBack() {
    router.back()
  }

  function statusTagAttrs(color?: string | null) {
    return crmOrderStatusTagAttrs(color)
  }

  function fmtDate(v?: string | null) {
    if (v == null || v === '') return '—'
    const s = String(v)
    return s.length >= 10 ? s.slice(0, 10) : s
  }

  function normalizeDecimal(v: unknown): number | null {
    if (v === '' || v === null || v === undefined) return null
    const n = Number(v)
    return Number.isNaN(n) ? null : n
  }

  const DECIMAL_KEYS = [
    'delivery_qty',
    'loss_qty',
    'semi_inventory',
    'semi_completed',
    'semi_reserve',
    'original_inventory',
    'outsourcing_qty',
    'unfinished_qty',
    'finished_total'
  ] as const

  const TEXT_KEYS = [
    'production_machine',
    'injection_prod_code',
    'gasket_machine',
    'gasket_prod_code'
  ] as const

  const DATE_KEYS = [
    'line_delivery_date',
    'injection_prod_date',
    'gasket_prod_date',
    'closing_date'
  ] as const

  const EDITABLE_KEYS = Array.from(
    new Set([...DECIMAL_KEYS, ...TEXT_KEYS, ...DATE_KEYS])
  ) as string[]

  function fieldTypeOf(key: string): 'decimal' | 'text' | 'date' | 'other' {
    if (DECIMAL_KEYS.includes(key as (typeof DECIMAL_KEYS)[number])) return 'decimal'
    if (TEXT_KEYS.includes(key as (typeof TEXT_KEYS)[number])) return 'text'
    if (DATE_KEYS.includes(key as (typeof DATE_KEYS)[number])) return 'date'
    return 'other'
  }

  function snapshotCommittedFields(row: Record<string, any>) {
    const m: Record<string, unknown> = {}
    for (const key of EDITABLE_KEYS) {
      const type = fieldTypeOf(key)
      if (type === 'decimal') m[key] = normalizeDecimal(row[key])
      else if (type === 'text')
        m[key] = row[key] == null || row[key] === '' ? null : String(row[key])
      else if (type === 'date')
        m[key] = row[key] == null || row[key] === '' ? null : String(row[key])
    }
    row._crmCommitted = m
  }

  function committedEquals(key: string, committed: unknown, payloadVal: unknown): boolean {
    const type = fieldTypeOf(key)
    if (type === 'decimal') return normalizeDecimal(committed) === (payloadVal as number | null)
    if (type === 'text') return (committed ?? null) === (payloadVal ?? null)
    if (type === 'date') return (committed ?? null) === (payloadVal ?? null)
    return committed === payloadVal
  }

  function preparePayloadVal(key: string, raw: unknown): unknown {
    const type = fieldTypeOf(key)
    if (type === 'decimal') return normalizeDecimal(raw)
    if (type === 'text') return raw == null || raw === '' ? null : String(raw)
    if (type === 'date') return raw == null || raw === '' ? null : raw
    return raw
  }

  async function patchField(key: string, raw: unknown) {
    if (!detail.value?.id) return

    const payloadVal = preparePayloadVal(key, raw)
    const prevCommitted = detail.value._crmCommitted?.[key]
    if (committedEquals(key, prevCommitted, payloadVal)) return

    try {
      savingKeys[key] = true
      await updateCrmOrderLineDataApi(detail.value.id, { [key]: payloadVal })
      detail.value[key] = payloadVal

      if (!detail.value._crmCommitted) detail.value._crmCommitted = {}
      detail.value._crmCommitted[key] = payloadVal

      ElMessage.success({ message: '已保存', duration: 1200 })
    } catch (e) {
      const msg = e instanceof HttpError ? e.message : '保存失败'
      ElMessage.error(msg)
      await loadDetail()
    } finally {
      savingKeys[key] = false
    }
  }

  async function loadDetail() {
    if (!detailId.value) return
    loading.value = true
    detailLoaded.value = false
    try {
      const res = (await viewCrmOrderLineByIdApi(detailId.value)) as any
      const obj = res?.data || null
      if (obj) {
        detail.value = obj
        snapshotCommittedFields(detail.value)
        detailLoaded.value = true
      } else {
        detail.value = {}
        detailLoaded.value = false
      }
    } finally {
      loading.value = false
    }
  }

  watch(
    () => detailId.value,
    () => loadDetail(),
    { immediate: true }
  )

  onMounted(() => {
    if (!detailLoaded.value) loadDetail()
  })
</script>

<style scoped lang="scss">
  @use '@/views/crm/detail-common.scss' as *;

  .order-lines-detail-page .detail-panel {
    max-width: none;
  }

  .order-lines-detail-page .detail-main-grid {
    display: grid;
    grid-template-columns: minmax(0, 1fr);
    gap: 16px;
    align-items: start;
  }

  .unified-info-body {
    display: flex;
    flex-direction: column;
    gap: 0;

    :deep(.el-divider) {
      margin: 20px 0 14px;

      &:first-child {
        margin-top: 0;
      }
    }

    :deep(.el-divider__text) {
      font-size: 14px;
      font-weight: 600;
      color: var(--el-text-color-primary);
    }

    .group-desc {
      margin-bottom: 0;
    }
  }

  /* 各区块 Descriptions 标签列宽一致 */
  .group-desc--uniform {
    width: 100%;

    :deep(.el-descriptions__label) {
      box-sizing: border-box;
      width: 140px !important;
      min-width: 140px;
      max-width: 140px;
    }

    :deep(.el-descriptions__content) {
      min-width: 0;
    }
  }

  .info-group-card--unified {
    :deep(.el-card__body) {
      padding-top: 12px;
    }
  }

  /* 输入框样式：保持与列表页编辑控件一致 */
  .it-excel-input {
    box-sizing: border-box;
    width: 100%;
    min-width: 0;
    max-width: 100%;
    height: 24px;
    padding: 0 6px;
    margin: 0;
    font-family: inherit;
    font-size: 12px;
    line-height: 24px;
    color: var(--el-text-color-primary, #303133);
    vertical-align: middle;
    background: var(--el-fill-color-blank, #fff);
    border: 1px solid var(--el-border-color, #dcdfe6);
    border-radius: 4px;
    box-shadow: none;
  }

  .it-excel-input--num {
    font-variant-numeric: tabular-nums;
    text-align: right;
  }

  .it-excel-input:focus {
    background: var(--el-fill-color-blank, #fff);
    border-color: var(--el-color-primary, #409eff);
    outline: none;
    box-shadow: 0 0 0 1px var(--el-color-primary, #409eff) inset;
  }

  .it-dp {
    width: 100%;
  }

  :deep(.it-dp) {
    width: 100% !important;
    max-width: 100% !important;
  }

  :deep(.it-dp .el-input__wrapper) {
    box-sizing: border-box;
    width: 100% !important;
    min-width: 0 !important;
    max-width: 100% !important;
    min-height: 24px;
    padding: 0 6px;
    background: var(--el-fill-color-blank, #fff);
    border: 1px solid var(--el-border-color, #dcdfe6);
    border-radius: 4px;
    box-shadow: none;
  }

  /* “交付与生产（可编辑）”区块：所有字段值靠左展示 */
  :deep(.order-lines-editable .el-descriptions__content) {
    justify-content: flex-start !important;
    text-align: left !important;
  }

  :deep(.order-lines-editable .el-descriptions__cell) {
    text-align: left !important;
  }

  /* 交货情况：强制输入内容靠左（避免 it-excel-input--num 造成右对齐） */
  :deep(.order-lines-editable input.it-excel-input--num) {
    text-align: left !important;
  }
</style>

<style>
  .crm-it-date-popper {
    z-index: 5000 !important;
  }
</style>
