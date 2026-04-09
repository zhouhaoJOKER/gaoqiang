<template>
  <div class="combo-tab">
    <div v-if="comboDetailLoading" class="loading-wrapper">
      <div class="empty-text">加载中...</div>
    </div>
    <div v-else-if="comboDetail" class="combo-detail">
      <div class="section-block">
        <div class="section-title">组合信息</div>
        <div class="field-row">
          <div class="field-label">组合名称</div>
          <div class="field-value">{{ comboDetail.name || '-' }}</div>
        </div>
        <div class="field-row">
          <div class="field-label">公司</div>
          <div class="field-value">{{
            comboDetail.company_name || comboDetail.company_id || '-'
          }}</div>
        </div>
        <div class="field-row">
          <div class="field-label">价格</div>
          <div class="field-value">{{ formatCurrency(comboDetail.price) }}</div>
        </div>
        <div class="field-row">
          <div class="field-label">折扣</div>
          <div class="field-value">{{ comboDetail.discount || 0 }}</div>
        </div>
        <div class="field-row">
          <div class="field-label">描述</div>
          <div class="field-value">{{ comboDetail.description || '-' }}</div>
        </div>
      </div>

      <div class="section-block">
        <div class="section-title">组合产品</div>
        <ElTable :data="comboDetail.options || []" style="width: 100%" border>
          <ElTableColumn prop="name" label="产品名称" min-width="200" />
          <ElTableColumn prop="price" label="原价" min-width="100">
            <template #default="{ row }">
              {{ formatCurrency(row.price) }}
            </template>
          </ElTableColumn>
          <ElTableColumn prop="extra_price" label="额外价格" min-width="100">
            <template #default="{ row }">
              {{ formatCurrency(row.extra_price) }}
            </template>
          </ElTableColumn>
          <ElTableColumn label="小计" min-width="100">
            <template #default="{ row }">
              {{ formatCurrency(Number(row.price || 0) + Number(row.extra_price || 0)) }}
            </template>
          </ElTableColumn>
        </ElTable>
      </div>
    </div>
    <div v-else class="empty-tab">
      <div class="empty-text">未选择产品组合</div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { ElTable, ElTableColumn } from 'element-plus'

  interface Props {
    comboDetail: any
    comboDetailLoading: boolean
  }

  defineProps<Props>()

  const formatCurrency = (value: number | string | undefined): string => {
    const num = Number(value)
    if (Number.isNaN(num)) return '￥0.00'
    return `￥${num.toFixed(2)}`
  }
</script>

<style scoped lang="scss">
  .combo-tab {
    padding: 24px;
  }

  .combo-detail {
    .section-block {
      margin-bottom: 24px;
    }

    .section-title {
      margin-bottom: 16px;
      font-size: 15px;
      font-weight: 500;
      color: var(--el-text-color-primary);
    }

    .field-row {
      display: flex;
      gap: 16px;
      align-items: center;
      margin-bottom: 14px;

      .field-label {
        flex-shrink: 0;
        width: 120px;
        font-size: 14px;
        color: var(--el-text-color-regular);
      }

      .field-value {
        flex: 1;
        font-size: 14px;
        color: var(--el-text-color-primary);
      }
    }
  }

  .empty-tab {
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 240px;
    color: var(--el-text-color-placeholder);
  }

  .empty-text {
    font-size: 14px;
  }
</style>
