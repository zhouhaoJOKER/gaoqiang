<template>
  <div class="tab-raw-inspections">
    <div class="tab-toolbar">
      <ElButton type="primary" @click="handleAdd">
        <ArtSvgIcon icon="ri:add-line" class="mr-1" />新增原料检验记录
      </ElButton>
    </div>
    <div class="sub-tab-bar">
      <div
        class="sub-tab-item"
        :class="{ active: subTab === 'pending' }"
        @click="subTab = 'pending'"
      >
        待检验<span v-if="pendingList.length > 0" class="sub-tab-badge">{{
          pendingList.length
        }}</span>
      </div>
      <div
        class="sub-tab-item"
        :class="{ active: subTab === 'inspected' }"
        @click="subTab = 'inspected'"
      >
        已检验<span v-if="inspectedList.length > 0" class="sub-tab-badge">{{
          inspectedList.length
        }}</span>
      </div>
    </div>
    <div v-loading="loading" class="inspection-list">
      <template v-if="displayList.length === 0 && !loading">
        <ElEmpty :description="subTab === 'pending' ? '暂无待检验记录' : '暂无已检验记录'" />
      </template>
      <div
        v-for="item in displayList"
        :key="item.id"
        class="inspection-block"
        @click="handleEdit(item)"
      >
        <div class="inspection-block-header">
          <span class="inspection-code">检验编号：{{ item.code || '-' }}</span>
          <span class="inspection-name" v-if="item.name">原料：{{ item.name }}</span>
          <span class="inspection-supplier" v-if="item.supplier_name"
            >供应商：{{ item.supplier_name }}</span
          >
          <span class="inspection-date" v-if="item.inspection_date"
            >检验日期：{{ item.inspection_date }}</span
          >
          <span class="inspection-conclusion" v-if="item.conclusion"
            >结论：{{ item.conclusion }}</span
          >
        </div>
      </div>
    </div>
    <RawInspectionDialog
      v-model="dialogVisible"
      :raw="currentRaw"
      :initial-contract-id="props.contractId"
      :readonly="false"
      @created="onCreated"
      @updated="onUpdated"
    />
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, watch } from 'vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import { ElButton, ElEmpty } from 'element-plus'
  import { listIqcRawApi } from '@/api/iqc/raw'
  import RawInspectionDialog from '@/views/iqc/raw-inspections/modules/raw-inspection-dialog.vue'

  const props = defineProps<{ contractId?: string | number }>()
  defineEmits<{ (e: 'add'): void }>()

  const loading = ref(false)
  const list = ref<any[]>([])
  const subTab = ref<'pending' | 'inspected'>('pending')
  const dialogVisible = ref(false)
  const currentRaw = ref<any>(undefined)

  /** 待检验：检验日期无值 */
  const pendingList = computed(() =>
    list.value.filter((r: any) => r && (r.inspection_date == null || r.inspection_date === ''))
  )
  /** 已检验：检验日期有值 */
  const inspectedList = computed(() =>
    list.value.filter(
      (r: any) => r && r.inspection_date != null && String(r.inspection_date).trim() !== ''
    )
  )
  const displayList = computed(() =>
    subTab.value === 'pending' ? pendingList.value : inspectedList.value
  )

  const fetchList = async (contractId: string | number) => {
    if (!contractId) return
    loading.value = true
    try {
      const res = await listIqcRawApi({
        'q[contract_id_eq]': contractId,
        per_page: 100
      })
      const data = (res as any).data || []
      const arr = Array.isArray(data) ? data : data.list || data.data || []
      list.value = arr.filter((r: any) => r && r.id != null)
    } catch {
      list.value = []
    } finally {
      loading.value = false
    }
  }

  const handleAdd = () => {
    currentRaw.value = undefined
    dialogVisible.value = true
  }

  /** 点击检验记录：以编辑模式打开，可修改检验表 */
  const handleEdit = (item: any) => {
    currentRaw.value = item
    dialogVisible.value = true
  }

  const onCreated = () => {
    dialogVisible.value = false
    if (props.contractId) fetchList(props.contractId)
  }

  const onUpdated = () => {
    dialogVisible.value = false
    if (props.contractId) fetchList(props.contractId)
  }

  watch(
    () => props.contractId,
    (id) => {
      if (id) fetchList(id)
    },
    { immediate: true }
  )
</script>

<style scoped>
  .tab-raw-inspections .tab-toolbar {
    margin-bottom: 16px;
  }

  .sub-tab-bar {
    display: flex;
    gap: 4px;
    margin-bottom: 16px;
    border-bottom: 1px solid var(--el-border-color-lighter);
  }

  .sub-tab-item {
    padding: 8px 16px;
    margin-bottom: -1px;
    font-size: 14px;
    color: var(--el-text-color-regular);
    cursor: pointer;
    border-bottom: 2px solid transparent;
    transition: color 0.2s;
  }

  .sub-tab-item:hover {
    color: var(--el-color-primary);
  }

  .sub-tab-item.active {
    font-weight: 500;
    color: var(--el-color-primary);
    border-bottom-color: var(--el-color-primary);
  }

  .sub-tab-badge {
    padding: 0 6px;
    margin-left: 6px;
    font-size: 12px;
    font-weight: 500;
    color: var(--el-color-primary);
    background: var(--el-color-primary-light-9);
    border-radius: 10px;
  }

  .inspection-list {
    min-height: 120px;
  }

  .inspection-block {
    padding: 12px 16px;
    margin-bottom: 16px;
    cursor: pointer;
    background: var(--el-bg-color);
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 8px;
  }

  .inspection-block:hover {
    border-color: var(--el-color-primary-light-5);
  }

  .inspection-block-header {
    font-size: 14px;
    color: var(--el-text-color-regular);
  }

  .inspection-block-header .inspection-code {
    margin-right: 16px;
    font-weight: 500;
  }

  .inspection-block-header .inspection-name,
  .inspection-block-header .inspection-supplier,
  .inspection-block-header .inspection-date,
  .inspection-block-header .inspection-conclusion {
    margin-right: 16px;
  }
</style>
