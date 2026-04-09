<!-- 批次序列号详情页 -->
<template>
  <div class="lot-detail-container">
    <div class="lot-header-bar">
      <div class="header-left">
        <ElButton text class="back-btn" @click="handleGoBack">
          <ArtSvgIcon icon="ri:arrow-left-line" />
        </ElButton>
        <ElInput
          v-model="lotData.code"
          class="header-name-input"
          placeholder="请输入批次号"
          @blur="() => saveLotField('code', lotData.code)"
        />
      </div>
      <div class="header-right">
        <ElButton text class="header-action-btn" @click="handleRefresh">
          <ArtSvgIcon icon="ri:refresh-line" class="mr-1" />
          刷新
        </ElButton>
      </div>
    </div>

    <div class="lot-content-wrapper">
      <div class="lot-detail-panel">
        <div class="fields-grid">
          <div class="field-group">
            <h3 class="group-title">基本信息</h3>
            <div class="field-row">
              <div class="field-label">批次号</div>
              <div class="field-value">
                <ElInput
                  v-model="lotData.code"
                  placeholder="请输入批次号"
                  @blur="() => saveLotField('code', lotData.code)"
                />
              </div>
            </div>
            <div class="field-row">
              <div class="field-label">参考号</div>
              <div class="field-value">
                <ElInput
                  v-model="lotData.ref"
                  placeholder="请输入参考号"
                  @blur="() => saveLotField('ref', lotData.ref)"
                />
              </div>
            </div>
            <div class="field-row">
              <div class="field-label">公司</div>
              <div class="field-value">
                <ElSelect
                  v-model="lotData.company_id"
                  placeholder="选择公司"
                  filterable
                  style="width: 100%"
                  @change="() => saveLotField('company_id', lotData.company_id)"
                >
                  <ElOption
                    v-for="company in companyList"
                    :key="company.id"
                    :label="company.name"
                    :value="company.id"
                  />
                </ElSelect>
              </div>
            </div>
            <div class="field-row">
              <div class="field-label">描述</div>
              <div class="field-value">
                <ElInput
                  v-model="lotData.description"
                  type="textarea"
                  :rows="3"
                  placeholder="请输入描述"
                  @blur="() => saveLotField('description', lotData.description)"
                />
              </div>
            </div>
          </div>

          <div class="field-group">
            <h3 class="group-title">关联信息</h3>
            <div class="field-row">
              <div class="field-label">物品</div>
              <div class="field-value">{{ lotData.item_name || '-' }}</div>
            </div>
            <div class="field-row">
              <div class="field-label">产品</div>
              <div class="field-value">{{ lotData.product_name || '-' }}</div>
            </div>
            <div class="field-row">
              <div class="field-label">用户</div>
              <div class="field-value">{{ lotData.user_name || '-' }}</div>
            </div>
            <div class="field-row">
              <div class="field-label">订单类型</div>
              <div class="field-value">{{ lotData.order_type || '-' }}</div>
            </div>
          </div>

          <div class="field-group">
            <h3 class="group-title">数量信息</h3>
            <div class="field-row">
              <div class="field-label">数量</div>
              <div class="field-value">{{ formatNumber(lotData.qty) }}</div>
            </div>
            <div class="field-row">
              <div class="field-label">单位成本</div>
              <div class="field-value">{{ formatCurrency(lotData.unit_cost) }}</div>
            </div>
          </div>

          <div class="field-group">
            <h3 class="group-title">日期信息</h3>
            <div class="field-row">
              <div class="field-label">过期日期</div>
              <div class="field-value">{{ formatDate(lotData.expiration_date) }}</div>
            </div>
            <div class="field-row">
              <div class="field-label">提醒日期</div>
              <div class="field-value">{{ formatDate(lotData.alert_date) }}</div>
            </div>
            <div class="field-row">
              <div class="field-label">移除日期</div>
              <div class="field-value">{{ formatDate(lotData.removal_date) }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ref, onMounted } from 'vue'
  import { useRoute, useRouter } from 'vue-router'
  import { ElMessage } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { ElButton, ElInput, ElSelect, ElOption } from 'element-plus'
  import { viewInvLotApi, updateInvLotApi } from '@/api/inv/lot'
  import { listCompanyApi } from '@/api/company'

  defineOptions({ name: 'InvLotDetail' })

  const route = useRoute()
  const router = useRouter()

  interface LotData {
    id?: string | number
    code?: string
    ref?: string
    item_id?: string | number
    item_name?: string
    product_id?: string | number
    product_name?: string
    company_id?: string | number
    company_name?: string
    qty?: number | string
    unit_cost?: number | string
    expiration_date?: string
    alert_date?: string
    removal_date?: string
    order_type?: string
    order_id?: string | number
    order_line_id?: string | number
    user_id?: string | number
    user_name?: string
    description?: string
    [key: string]: any
  }

  const lotData = ref<LotData>({})
  const companyList = ref<any[]>([])

  // 加载公司列表
  const loadCompanyList = async (): Promise<void> => {
    try {
      const res = await listCompanyApi({})
      companyList.value = (res as any).data || []
    } catch (error) {
      console.error('加载公司列表失败:', error)
    }
  }

  // 保存字段
  const saveLotField = async (field: string, value: any): Promise<void> => {
    if (!lotData.value.id) return
    try {
      // 只允许修改 code, ref, company_id, description
      const allowedFields = ['code', 'ref', 'company_id', 'description']
      if (!allowedFields.includes(field)) {
        ElMessage.warning('该字段不允许修改')
        return
      }
      await updateInvLotApi(String(lotData.value.id), { [field]: value })
      ElMessage.success('保存成功')
    } catch (error) {
      console.error(`保存${field}失败:`, error)
      ElMessage.error(`保存${field}失败`)
    }
  }

  // 加载批次序列号详情
  const loadLotDetail = async (): Promise<void> => {
    const id = route.params.id
    if (!id) {
      ElMessage.error('缺少批次序列号ID')
      router.back()
      return
    }

    try {
      const res = await viewInvLotApi({ id })
      const data = (res as any).data || {}
      lotData.value = data
    } catch (error) {
      console.error('加载批次序列号详情失败:', error)
      ElMessage.error('加载批次序列号详情失败')
      router.back()
    }
  }

  const handleGoBack = (): void => {
    router.back()
  }

  const handleRefresh = (): void => {
    loadLotDetail()
  }

  const formatCurrency = (value: number | string | undefined): string => {
    const num = Number(value)
    if (Number.isNaN(num)) return '￥0.00'
    return `￥${num.toFixed(2)}`
  }

  const formatNumber = (value: number | string | undefined): string => {
    const num = Number(value)
    if (Number.isNaN(num)) return '0'
    return num.toFixed(2)
  }

  const formatDate = (value: string | undefined): string => {
    if (!value) return '-'
    try {
      const date = new Date(value)
      return date.toLocaleString('zh-CN', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      })
    } catch {
      return value
    }
  }

  onMounted(() => {
    loadLotDetail()
    loadCompanyList()
  })
</script>

<style scoped lang="scss">
  @reference '@styles/core/tailwind.css';

  .lot-detail-container {
    @apply p-4;

    display: flex;
    flex-direction: column;
    height: 100%;
  }

  .lot-header-bar {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 16px;
    margin-bottom: 16px;
    background: var(--el-bg-color);
    border-radius: 8px;
    box-shadow: 0 1px 4px rgb(0 0 0 / 4%);

    .header-left {
      display: flex;
      flex: 1;
      gap: 12px;
      align-items: center;

      .back-btn {
        padding: 6px;
        color: var(--el-text-color-regular);
      }

      .star-btn {
        padding: 6px;
        color: var(--el-text-color-regular);
      }

      .header-name-input {
        flex: 1;
        max-width: 400px;
      }
    }

    .header-right {
      display: flex;
      gap: 8px;
      align-items: center;

      .header-action-btn {
        padding: 6px;
        color: var(--el-text-color-regular);
      }
    }
  }

  .lot-content-wrapper {
    display: flex;
    flex: 1;
    gap: 16px;
    overflow: hidden;
  }

  .lot-detail-panel {
    flex: 1;
    padding: 24px;
    overflow-y: auto;
    background: var(--el-bg-color);
    border-radius: 8px;
    box-shadow: 0 1px 4px rgb(0 0 0 / 4%);
  }

  .fields-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 24px;
  }

  .field-group {
    .group-title {
      padding-bottom: 8px;
      margin: 0 0 16px;
      font-size: 16px;
      font-weight: 600;
      color: var(--el-text-color-primary);
      border-bottom: 1px solid var(--el-border-color-lighter);
    }

    .field-row {
      display: flex;
      gap: 12px;
      align-items: flex-start;
      margin-bottom: 16px;

      .field-label {
        flex-shrink: 0;
        width: 100px;
        padding-top: 8px;
        font-size: 14px;
        color: var(--el-text-color-regular);
      }

      .field-value {
        display: flex;
        flex: 1;
        align-items: center;
        min-height: 32px;
        font-size: 14px;
        color: var(--el-text-color-primary);
      }
    }
  }

  @media (width <= 1200px) {
    .fields-grid {
      grid-template-columns: 1fr;
    }
  }
</style>
