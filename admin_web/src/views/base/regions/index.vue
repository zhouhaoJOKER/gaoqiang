<template>
  <div class="base-regions">
    <div class="regions-header">
      <h4 class="page-title">行政区划</h4>
      <p class="page-desc">点击左侧列表项加载下一级，支持新增与编辑</p>
    </div>
    <div class="regions-body">
      <div class="region-col">
        <div class="col-header">
          <span class="col-title">省</span>
          <ElButton type="primary" size="small" @click="openProvinceDialog()"
            ><ArtSvgIcon icon="ri:add-line" /> 新增</ElButton
          >
        </div>
        <div class="col-list">
          <div
            v-for="item in provinceList"
            :key="item.id"
            class="list-item"
            :class="{
              active: selectedProvinceId && Number(selectedProvinceId) === Number(item.id)
            }"
            @click="selectProvince(item)"
          >
            <div class="item-content">
              <span class="item-name">{{ item.name || '-' }}</span>
              <span class="item-meta">码 {{ item.code ?? '-' }} · {{ item.py || '-' }}</span>
            </div>
            <div class="item-actions" @click.stop>
              <ArtButtonMore
                :list="[
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ]"
                @click="(e) => buttonProvinceClick(e, item)"
              />
            </div>
          </div>
          <div v-if="provinceLoading" class="col-loading"
            ><ElIcon class="is-loading"><Loading /></ElIcon> 加载中...</div
          >
          <div v-else-if="!provinceList.length" class="col-empty">暂无数据</div>
        </div>
      </div>
      <div class="region-col">
        <div class="col-header">
          <span class="col-title">市</span>
          <ElButton
            :disabled="!selectedProvinceId"
            type="primary"
            size="small"
            @click="openCityDialog()"
            ><ArtSvgIcon icon="ri:add-line" /> 新增</ElButton
          >
        </div>
        <div class="col-list">
          <div
            v-for="item in cityList"
            :key="item.id"
            class="list-item"
            :class="{ active: selectedCityId && Number(selectedCityId) === Number(item.id) }"
            @click="selectCity(item)"
          >
            <div class="item-content">
              <span class="item-name">{{ item.name || '-' }}</span>
              <span class="item-meta">码 {{ item.code ?? '-' }} · {{ item.py || '-' }}</span>
            </div>
            <div class="item-actions" @click.stop>
              <ArtButtonMore
                :list="[
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ]"
                @click="(e) => buttonCityClick(e, item)"
              />
            </div>
          </div>
          <div v-if="cityLoading" class="col-loading"
            ><ElIcon class="is-loading"><Loading /></ElIcon> 加载中...</div
          >
          <div v-else-if="selectedProvinceId && !cityLoading && !cityList.length" class="col-empty"
            >请先选择省，或暂无数据</div
          >
          <div v-else-if="!selectedProvinceId" class="col-empty">请先选择省</div>
        </div>
      </div>
      <div class="region-col">
        <div class="col-header">
          <span class="col-title">县/区</span>
          <ElButton
            :disabled="!selectedCityId"
            type="primary"
            size="small"
            @click="openCountyDialog()"
            ><ArtSvgIcon icon="ri:add-line" /> 新增</ElButton
          >
        </div>
        <div class="col-list">
          <div v-for="item in countyList" :key="item.id" class="list-item">
            <div class="item-content">
              <span class="item-name">{{ item.name || '-' }}</span>
              <span class="item-meta">码 {{ item.code ?? '-' }} · {{ item.py || '-' }}</span>
            </div>
            <div class="item-actions" @click.stop>
              <ArtButtonMore
                :list="[
                  { key: 'edit', label: '编辑', icon: 'ri:edit-2-line' },
                  { key: 'delete', label: '删除', icon: 'ri:delete-bin-4-line', color: '#f56c6c' }
                ]"
                @click="(e) => buttonCountyClick(e, item)"
              />
            </div>
          </div>
          <div v-if="countyLoading" class="col-loading"
            ><ElIcon class="is-loading"><Loading /></ElIcon> 加载中...</div
          >
          <div v-else-if="selectedCityId && !countyLoading && !countyList.length" class="col-empty"
            >暂无数据</div
          >
          <div v-else-if="!selectedCityId" class="col-empty">请先选择市</div>
        </div>
      </div>
    </div>
    <ProvinceDialog
      v-model="provinceDialogVisible"
      :province="currentProvince"
      @created="onProvinceCreated"
      @updated="onProvinceUpdated"
    />
    <CityDialog
      v-model="cityDialogVisible"
      :city="currentCity"
      :province-id="selectedProvinceId"
      :default-code="selectedProvinceCode"
      @created="onCityCreated"
      @updated="onCityUpdated"
    />
    <CountyDialog
      v-model="countyDialogVisible"
      :county="currentCounty"
      :city-id="selectedCityId"
      :default-code="selectedCityCode"
      @created="onCountyCreated"
      @updated="onCountyUpdated"
    />
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onMounted } from 'vue'
  import { ElMessage, ElMessageBox } from 'element-plus'
  import { Loading } from '@element-plus/icons-vue'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import ArtButtonMore from '@/components/core/forms/art-button-more/index.vue'
  import { ElButton, ElIcon } from 'element-plus'
  import { listProvinceApi, deleteProvinceApi } from '@/api/province'
  import { listCityApi, deleteCityApi } from '@/api/city'
  import { listCountyApi, deleteCountyApi } from '@/api/county'
  import ProvinceDialog from './modules/province-dialog.vue'
  import CityDialog from './modules/city-dialog.vue'
  import CountyDialog from './modules/county-dialog.vue'

  defineOptions({ name: 'BaseRegions' })

  const provinceList = ref<any[]>([])
  const cityList = ref<any[]>([])
  const countyList = ref<any[]>([])
  const provinceLoading = ref(false)
  const cityLoading = ref(false)
  const countyLoading = ref(false)
  const selectedProvinceId = ref<string | number | undefined>(undefined)
  const selectedCityId = ref<string | number | undefined>(undefined)
  const provinceDialogVisible = ref(false)
  const cityDialogVisible = ref(false)
  const countyDialogVisible = ref(false)
  const currentProvince = ref<any>(undefined)
  const currentCity = ref<any>(undefined)
  const currentCounty = ref<any>(undefined)

  const selectedProvinceCode = computed(() => {
    const p = provinceList.value.find(
      (x: any) => x.id != null && Number(x.id) === Number(selectedProvinceId.value)
    )
    return p?.code != null ? String(p.code) : ''
  })
  const selectedCityCode = computed(() => {
    const c = cityList.value.find(
      (x: any) => x.id != null && Number(x.id) === Number(selectedCityId.value)
    )
    return c?.code != null ? String(c.code) : ''
  })

  const fetchProvinces = async () => {
    provinceLoading.value = true
    try {
      const res = await listProvinceApi({ per_page: 500 })
      const data = (res as any).data || []
      provinceList.value = Array.isArray(data) ? data : data.list || data.data || []
    } catch {
      provinceList.value = []
    } finally {
      provinceLoading.value = false
    }
  }

  const fetchCities = async (provinceId: string | number) => {
    if (!provinceId) return
    cityLoading.value = true
    cityList.value = []
    countyList.value = []
    selectedCityId.value = undefined
    try {
      const res = await listCityApi({ 'q[province_id_eq]': provinceId, per_page: 500 })
      const data = (res as any).data || []
      cityList.value = Array.isArray(data) ? data : data.list || data.data || []
    } catch {
      cityList.value = []
    } finally {
      cityLoading.value = false
    }
  }

  const fetchCounties = async (cityId: string | number) => {
    if (!cityId) return
    countyLoading.value = true
    countyList.value = []
    try {
      const res = await listCountyApi({ 'q[city_id_eq]': cityId, per_page: 500 })
      const data = (res as any).data || []
      countyList.value = Array.isArray(data) ? data : data.list || data.data || []
    } catch {
      countyList.value = []
    } finally {
      countyLoading.value = false
    }
  }

  const selectProvince = (item: any) => {
    selectedProvinceId.value = item.id
    fetchCities(item.id)
  }

  const selectCity = (item: any) => {
    selectedCityId.value = item.id
    fetchCounties(item.id)
  }

  const openProvinceDialog = (item?: any) => {
    currentProvince.value = item
    provinceDialogVisible.value = true
  }
  const openCityDialog = (item?: any) => {
    currentCity.value = item
    cityDialogVisible.value = true
  }
  const openCountyDialog = (item?: any) => {
    currentCounty.value = item
    countyDialogVisible.value = true
  }

  const buttonProvinceClick = (item: { key: string | number }, row: any) => {
    if (item.key === 'edit') openProvinceDialog(row)
    else if (item.key === 'delete') deleteProvince(row)
  }
  const buttonCityClick = (item: { key: string | number }, row: any) => {
    if (item.key === 'edit') openCityDialog(row)
    else if (item.key === 'delete') deleteCity(row)
  }
  const buttonCountyClick = (item: { key: string | number }, row: any) => {
    if (item.key === 'edit') openCountyDialog(row)
    else if (item.key === 'delete') deleteCounty(row)
  }

  const onProvinceCreated = () => {
    fetchProvinces()
    provinceDialogVisible.value = false
  }
  const onProvinceUpdated = () => {
    fetchProvinces()
    provinceDialogVisible.value = false
  }
  const onCityCreated = () => {
    if (selectedProvinceId.value) fetchCities(selectedProvinceId.value)
    cityDialogVisible.value = false
  }
  const onCityUpdated = () => {
    if (selectedProvinceId.value) fetchCities(selectedProvinceId.value)
    cityDialogVisible.value = false
  }
  const onCountyCreated = () => {
    if (selectedCityId.value) fetchCounties(selectedCityId.value)
    countyDialogVisible.value = false
  }
  const onCountyUpdated = () => {
    if (selectedCityId.value) fetchCounties(selectedCityId.value)
    countyDialogVisible.value = false
  }

  const deleteProvince = (row: any) => {
    ElMessageBox.confirm(`确定删除“${row.name || row.code}”吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() =>
        deleteProvinceApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          fetchProvinces()
          if (selectedProvinceId.value === row.id) {
            selectedProvinceId.value = undefined
            cityList.value = []
            countyList.value = []
            selectedCityId.value = undefined
          }
        })
      )
      .catch(() => {})
  }
  const deleteCity = (row: any) => {
    ElMessageBox.confirm(`确定删除“${row.name || row.code}”吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() =>
        deleteCityApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          if (selectedProvinceId.value) fetchCities(selectedProvinceId.value)
          if (selectedCityId.value === row.id) {
            selectedCityId.value = undefined
            countyList.value = []
          }
        })
      )
      .catch(() => {})
  }
  const deleteCounty = (row: any) => {
    ElMessageBox.confirm(`确定删除“${row.name || row.code}”吗？`, '删除确认', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    })
      .then(() =>
        deleteCountyApi(Number(row.id)).then(() => {
          ElMessage.success('删除成功')
          if (selectedCityId.value) fetchCounties(selectedCityId.value)
        })
      )
      .catch(() => {})
  }

  onMounted(() => fetchProvinces())
</script>

<style scoped lang="scss">
  .base-regions {
    display: flex;
    flex-direction: column;
    height: 100%;
    padding: 16px;
  }

  .regions-header {
    margin-bottom: 16px;
  }

  .page-title {
    margin: 0 0 4px;
    font-size: 18px;
  }

  .page-desc {
    margin: 0;
    font-size: 13px;
    color: var(--el-text-color-secondary);
  }

  .regions-body {
    display: grid;
    flex: 1;
    grid-template-columns: 1fr 1fr 1fr;
    gap: 16px;
    min-height: 0;
  }

  .region-col {
    display: flex;
    flex-direction: column;
    overflow: hidden;
    background: var(--el-bg-color);
    border: 1px solid var(--el-border-color);
    border-radius: 8px;
  }

  .col-header {
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 12px 16px;
    background: var(--el-fill-color-light);
    border-bottom: 1px solid var(--el-border-color);
  }

  .col-title {
    font-weight: 600;
  }

  .col-list {
    flex: 1;
    padding: 8px;
    overflow-y: auto;
  }

  .list-item {
    display: flex;
    gap: 8px;
    align-items: center;
    justify-content: space-between;
    padding: 10px 12px;
    cursor: pointer;
    border-radius: 6px;
  }

  .list-item:hover {
    background: var(--el-fill-color-light);
  }

  .list-item.active {
    color: var(--el-color-primary);
    background: var(--el-color-primary-light-9);
  }

  .list-item .item-content {
    flex: 1;
    min-width: 0;
  }

  .list-item .item-name {
    display: block;
    font-weight: 500;
  }

  .list-item .item-meta {
    display: block;
    margin-top: 2px;
    font-size: 12px;
    color: var(--el-text-color-secondary);
  }

  .list-item .item-actions {
    flex-shrink: 0;
  }

  .col-loading,
  .col-empty {
    padding: 24px;
    font-size: 13px;
    color: var(--el-text-color-secondary);
    text-align: center;
  }
</style>
