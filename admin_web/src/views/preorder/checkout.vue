<!-- 预购下单页（无需登录） -->
<template>
  <div class="preorder-checkout">
    <header class="checkout-header">
      <ElButton link @click="goBack">← 返回选购</ElButton>
      <h1 class="checkout-title">预购下单</h1>
      <ElButton link type="primary" @click="goLogin">去登录</ElButton>
    </header>

    <div class="checkout-body">
      <ElCard shadow="never" class="mb-4">
        <template #header>
          <span class="font-semibold">客户信息</span>
        </template>
        <small class="text-gray-500">新下单客户，请填写联系方式，方便我们与您联系</small>
        <br />
        <br />
        <ElForm label-width="100px" class="max-w-xl">
          <ElFormItem label="客户" required>
            <ElInput
              v-model="form.customer_name"
              placeholder="请输入客户名称"
              maxlength="64"
              show-word-limit
            />
          </ElFormItem>
          <ElFormItem label="编号">
            <ElInput
              v-model="form.customer_code"
              placeholder="客户编号 / 合同号等"
              maxlength="64"
            />
          </ElFormItem>
          <ElFormItem label="规格要求">
            <ElInput
              v-model="form.spec_requirements"
              type="textarea"
              :rows="3"
              placeholder="请输入规格、颜色、包装等要求"
              maxlength="2000"
              show-word-limit
            />
          </ElFormItem>
        </ElForm>
      </ElCard>

      <ElCard shadow="never">
        <template #header>
          <span class="font-semibold">订单明细</span>
          <span v-if="totalQty" class="ml-2 text-sm text-gray-500">共 {{ totalQty }} 件</span>
        </template>
        <div v-if="!lines.length" class="py-8 text-center text-gray-500">
          购物车为空，请先
          <RouterLink class="text-theme" :to="{ name: 'Preorder' }">选购产品</RouterLink>
        </div>
        <ElTable v-else :data="lines" border stripe>
          <ElTableColumn type="index" label="#" width="50" />
          <ElTableColumn label="产品名称" min-width="180">
            <template #default="{ row }">
              <ElInput v-model="row.product_name" clearable placeholder="必填" @blur="persist" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="型号" width="160">
            <template #default="{ row }">
              <ElInput v-model="row.model" clearable placeholder="可选" @blur="persist" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="颜色" width="100">
            <template #default="{ row }">
              <ElInput v-model="row.color" clearable placeholder="必填" @blur="persist" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="克重" width="100">
            <template #default="{ row }">
              <ElInput v-model="row.weight" clearable placeholder="可修改" @blur="persist" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="数量" width="160">
            <template #default="{ row }">
              <div class="qty-wrap">
                <ElInput
                  v-model="row.quantity"
                  class="qty-input"
                  clearable
                  type="number"
                  placeholder="必填"
                  @blur="persist"
                  @clear="persist"
                />
                <ElPopover placement="bottom" trigger="hover" :width="188">
                  <template #reference>
                    <button type="button" class="qty-fast-trigger">快捷</button>
                  </template>
                  <div class="qty-fast-menu">
                    <button
                      v-for="item in quantityPresets"
                      :key="item.value"
                      type="button"
                      class="qty-fast-btn"
                      @click="setQuickQty(row, item.value)"
                    >
                      {{ item.label }}
                    </button>
                  </div>
                </ElPopover>
              </div>
            </template>
          </ElTableColumn>
          <ElTableColumn label="单位" width="80">
            <template #default="{ row }">
              <ElInput v-model="row.unit" clearable placeholder="必填" @blur="persist" />
            </template>
          </ElTableColumn>
          <ElTableColumn label="操作" width="190" fixed="right">
            <template #default="{ row }">
              <ElButton link type="primary" @click="copyLine(row)">复制</ElButton>
              <ElButton link type="primary" @click="addLine(row)">增加</ElButton>
              <ElButton link type="danger" @click="removeLine(row)">移除</ElButton>
            </template>
          </ElTableColumn>
        </ElTable>
        <p v-if="detailError" class="detail-error">{{ detailError }}</p>
      </ElCard>

      <div class="checkout-actions">
        <ElButton
          type="primary"
          size="large"
          :loading="submitting"
          :disabled="!canSubmit"
          @click="submit"
        >
          提交预购单
        </ElButton>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { computed, onMounted, reactive, ref } from 'vue'
  import { useRouter } from 'vue-router'
  import { ElMessage, ElMessageBox } from 'element-plus'
  import { preorderCreatePreOrderApi } from '@/api/preorder/mat'
  import { loadPreorderCart, savePreorderCart, type PreorderCartLine } from './cartStorage'

  defineOptions({ name: 'PreorderCheckout' })

  const router = useRouter()
  const submitting = ref(false)

  const form = reactive({
    customer_name: '',
    customer_code: '',
    spec_requirements: ''
  })

  const lines = ref<(PreorderCartLine & { key: string })[]>([])
  const quantityPresets = [
    { label: '5百', value: 500 },
    { label: '1千', value: 1000 },
    { label: '2千', value: 2000 },
    { label: '3千', value: 3000 },
    { label: '5千', value: 5000 },
    { label: '8千', value: 8000 },
    { label: '1万', value: 10000 }
  ]

  const totalQty = computed(() => lines.value.reduce((s, l) => s + (Number(l.quantity) || 0), 0))

  const detailError = computed(() => {
    if (!lines.value.length) return '请先添加产品'
    const bad = lines.value.find((l) => !isLineValid(l))
    if (!bad) return ''
    return '明细存在必填项未填写：产品名称、颜色、数量、单位'
  })

  const canSubmit = computed(
    () =>
      form.customer_name.trim().length > 0 &&
      lines.value.length > 0 &&
      detailError.value === '' &&
      !submitting.value
  )

  function hydrate() {
    const map = loadPreorderCart()
    lines.value = Object.entries(map).map(([key, line]) => ({
      key,
      ...line,
      quantity: Number(line.quantity) > 0 ? Number(line.quantity) : 1
    }))
  }

  function persist() {
    const map: Record<string, PreorderCartLine> = {}
    for (const row of lines.value) {
      const { key, ...rest } = row
      map[key] = {
        ...rest,
        quantity: Number(row.quantity) > 0 ? Number(row.quantity) : 1,
        product_name: (row.product_name || '').trim(),
        color: (row.color || '').trim(),
        unit: (row.unit || '').trim(),
        weight: (row.weight || '').trim(),
        model: (row.model || '').trim()
      }
    }
    savePreorderCart(map)
  }

  function isLineValid(line: PreorderCartLine & { key: string }) {
    return (
      String(line.product_name || '').trim().length > 0 &&
      String(line.color || '').trim().length > 0 &&
      Number(line.quantity) > 0 &&
      String(line.unit || '').trim().length > 0
    )
  }

  function setQuickQty(row: PreorderCartLine & { key: string }, qty: number) {
    row.quantity = qty
    persist()
  }

  function copyLine(row: PreorderCartLine & { key: string }) {
    const newKey = `${row.key}_${Date.now()}`
    lines.value.push({ ...row, key: newKey })
    persist()
  }

  function addLine(row: PreorderCartLine & { key: string }) {
    const newLine: PreorderCartLine & { key: string } = {
      key: `new_${Date.now()}`,
      product_id: row.product_id,
      product_name: '',
      model: '',
      color: '',
      weight: '',
      quantity: 1,
      unit: ''
    }
    const idx = lines.value.findIndex((l) => l.key === row.key)
    if (idx >= 0) {
      lines.value.splice(idx + 1, 0, newLine)
    } else {
      lines.value.push(newLine)
    }
    persist()
  }

  function removeLine(row: PreorderCartLine & { key: string }) {
    lines.value = lines.value.filter((l) => l.key !== row.key)
    persist()
  }

  function goBack() {
    router.push({ name: 'Preorder' })
  }

  function goLogin() {
    router.push({ name: 'Login' })
  }

  async function submit() {
    if (!canSubmit.value) {
      if (detailError.value) ElMessage.warning(detailError.value)
      return
    }
    if (!import.meta.env.VITE_PREORDER_API_TOKEN) {
      ElMessage.warning('未配置 VITE_PREORDER_API_TOKEN，无法提交')
      return
    }
    try {
      await ElMessageBox.confirm('确认提交预购单？', '提示', { type: 'info' })
    } catch {
      return
    }
    submitting.value = true
    try {
      const payload = {
        customer_name: form.customer_name.trim(),
        customer_code: form.customer_code.trim(),
        spec_requirements: form.spec_requirements.trim(),
        line_items: lines.value.map((line) => ({
          product_id: line.product_id,
          product_name: line.product_name,
          model: line.model,
          color: line.color,
          weight: line.weight,
          quantity: line.quantity,
          unit: line.unit
        }))
      }
      const res = await preorderCreatePreOrderApi(payload)
      if ((res as any).code === 200) {
        ElMessage.success('提交成功，我们会尽快与您联系')
        savePreorderCart({})
        lines.value = []
        router.push({ name: 'Preorder' })
      }
    } catch (e) {
      console.error(e)
    } finally {
      submitting.value = false
    }
  }

  onMounted(() => {
    hydrate()
  })
</script>

<style scoped>
  .preorder-checkout {
    box-sizing: border-box;
    min-height: 100vh;
    padding: 16px 20px 48px;
    background: #f5f7fa;
  }

  .checkout-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    max-width: 1100px;
    margin: 0 auto 16px;
  }

  .checkout-title {
    margin: 0;
    font-size: 20px;
    font-weight: 700;
  }

  .checkout-body {
    max-width: 1100px;
    margin: 0 auto;
  }

  .preorder-checkout :deep(.el-card__header) {
    display: flex;
    align-items: center;
  }

  .checkout-actions {
    display: flex;
    justify-content: center;
    margin-top: 24px;
  }

  .qty-wrap {
    display: flex;
    gap: 8px;
    align-items: center;
  }

  .qty-input {
    flex-shrink: 0;
    width: 94px;
  }

  .qty-fast-trigger {
    padding: 0;
    font-size: 12px;
    color: var(--el-color-primary);
    cursor: pointer;
    background: transparent;
    border: none;
  }

  .qty-fast-trigger:hover {
    text-decoration: underline;
  }

  .qty-fast-menu {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
  }

  .qty-fast-btn {
    padding: 4px 8px;
    font-size: 12px;
    color: var(--el-color-primary);
    cursor: pointer;
    background: var(--el-color-primary-light-9);
    border: 1px solid var(--el-color-primary-light-7);
    border-radius: 4px;
  }

  .qty-fast-btn:hover {
    background: var(--el-color-primary-light-8);
  }

  .detail-error {
    margin-top: 10px;
    font-size: 12px;
    color: var(--el-color-danger);
  }

  .text-theme {
    color: var(--el-color-primary);
  }
</style>
