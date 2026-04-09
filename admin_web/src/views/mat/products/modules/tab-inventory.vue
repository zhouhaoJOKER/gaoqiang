<template>
  <div class="inventory-tab">
    <div class="fields-grid">
      <div class="fields-column">
        <!-- 只有实物(type_id=1)和服务(type_id=0)才显示库存追踪 -->
        <div v-if="productData.type_id === 0 || productData.type_id === 1" class="section-block">
          <div class="section-title">库存追踪</div>

          <!-- 追踪库存字段 -->
          <div class="field-row">
            <div class="field-label">
              <span>追踪库存</span>
              <ElTooltip content="启用后可以根据不同方式追踪产品库存" placement="top">
                <ElIcon class="field-help-icon">
                  <QuestionFilled />
                </ElIcon>
              </ElTooltip>
            </div>
            <div class="field-value">
              <div class="track-inventory-wrapper">
                <ElCheckbox v-model="trackInventory" @change="handleTrackInventoryChange">
                </ElCheckbox>
                <ElSelect
                  v-model="trackInventoryType"
                  placeholder="请选择追踪方式"
                  style="width: 100%"
                  :disabled="!trackInventory"
                  @change="handleTrackInventoryTypeChange"
                >
                  <ElOption label="按唯一序列号" value="serial_number" />
                  <ElOption label="按批次" value="batch" />
                  <ElOption label="按数量" value="quantity" />
                </ElSelect>
              </div>
            </div>
          </div>

          <!-- 在手数量字段 -->
          <div class="field-row">
            <div class="field-label">在手数量</div>
            <div class="field-value">
              <ElInput :model-value="onHandQuantity" readonly placeholder="0.00" />
            </div>
          </div>
        </div>

        <!-- 如果产品类型不是实物或服务，显示提示 -->
        <div v-else class="empty-tab">
          <div class="empty-text">库存追踪功能仅适用于实物和服务类型的产品</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
  import { computed, watch } from 'vue'
  import { ElCheckbox, ElSelect, ElOption, ElInput, ElTooltip, ElIcon } from 'element-plus'
  import { QuestionFilled } from '@element-plus/icons-vue'

  defineOptions({ name: 'TabInventory' })

  interface Props {
    productData: {
      id?: string | number
      type_id?: string | number
      track_inventory?: boolean
      track_inventory_type?: string
      on_hand_quantity?: number | string
      [key: string]: any
    }
  }

  interface Emits {
    (e: 'save-field', field: string, value: any, field2?: string, value2?: any): void
  }

  const props = defineProps<Props>()
  const emit = defineEmits<Emits>()

  // 追踪库存复选框的值（仅 @change 时保存，避免与 set 重复触发）
  const trackInventory = computed({
    get: () => props.productData.track_inventory === true,
    set: () => {
      /* 由 handleTrackInventoryChange 统一 emit */
    }
  })

  // 追踪库存类型（仅 @change 时保存）
  const trackInventoryType = computed({
    get: () => props.productData.track_inventory_type || 'quantity',
    set: () => {
      /* 由 handleTrackInventoryTypeChange 统一 emit */
    }
  })

  // 在手数量
  const onHandQuantity = computed(() => {
    const qty = props.productData.on_hand_quantity
    if (qty === undefined || qty === null) return '0.00'
    return Number(qty).toFixed(2)
  })

  // 处理追踪库存复选框变化
  const handleTrackInventoryChange = (val: import('element-plus').CheckboxValueType): void => {
    const v = val === true
    // 如果取消追踪库存，同时重置追踪类型为默认值（通过父组件一次性保存）
    if (!v) {
      emit('save-field', 'track_inventory', v, 'track_inventory_type', 'quantity')
    } else {
      emit('save-field', 'track_inventory', v)
    }
  }

  // 处理追踪库存类型变化
  const handleTrackInventoryTypeChange = (val: string): void => {
    emit('save-field', 'track_inventory_type', val)
  }

  // 监听产品类型变化，如果改为"结合"类型，重置库存追踪相关字段
  watch(
    () => props.productData.type_id,
    (newTypeId) => {
      // 如果改为"结合"类型(type_id=2)，重置库存追踪字段
      if (newTypeId === 2) {
        if (props.productData.track_inventory) {
          emit('save-field', 'track_inventory', false)
        }
        if (props.productData.track_inventory_type) {
          emit('save-field', 'track_inventory_type', 'quantity')
        }
      }
    }
  )
</script>

<style scoped lang="scss">
  .inventory-tab {
    .fields-grid {
      display: grid;
      grid-template-columns: 1fr;
      gap: 24px;
    }

    .fields-column {
      display: flex;
      flex-direction: column;
    }

    .section-block {
      padding-bottom: 20px;
      margin-bottom: 20px;
      border-bottom: 1px solid var(--el-border-color-lighter);

      &:last-child {
        border-bottom: none;
      }
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
        display: flex;
        flex-shrink: 0;
        gap: 4px;
        align-items: center;
        width: 120px;
        font-size: 13px;
        color: var(--el-text-color-regular);

        .field-help-icon {
          font-size: 14px;
          color: var(--el-color-primary);
          cursor: help;
        }
      }

      .field-value {
        flex: 1;
      }
    }

    .track-inventory-wrapper {
      display: flex;
      gap: 12px;
      align-items: center;
      width: 100%;

      :deep(.el-checkbox) {
        flex-shrink: 0;
      }

      :deep(.el-select) {
        flex: 1;
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
  }
</style>
