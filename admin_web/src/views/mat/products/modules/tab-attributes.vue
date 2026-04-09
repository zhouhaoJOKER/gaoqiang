<template>
  <div class="attributes-tab">
    <div class="attributes-table">
      <div class="table-header">
        <div class="header-cell">属性</div>
        <div class="header-cell">值</div>
        <div class="header-cell actions-cell">操作</div>
      </div>
      <div class="table-body">
        <div
          v-for="(line, index) in attributeLines"
          :key="line.id || `new-${index}`"
          class="table-row"
        >
          <!-- 属性选择 -->
          <div class="row-cell attribute-cell">
            <ElSelect
              v-if="line.isNew || editingLineIds.has(line.id)"
              v-model="line.attribute_id"
              placeholder="请选择属性"
              filterable
              remote
              :remote-method="(query) => searchAttributes(query, index)"
              :loading="attributeSearchLoadingMap[index]"
              size="small"
              style="width: 100%"
              @change="(attrId) => handleLineAttributeChange(line, attrId, index)"
            >
              <ElOption
                v-for="attr in attributeOptionsMap[index] || []"
                :key="attr.id"
                :label="attr.name"
                :value="attr.id"
              />
              <ElOption
                :value="''"
                disabled
                style="border-top: 1px solid var(--el-border-color-lighter)"
              >
                <div class="option-footer">
                  <ElButton
                    text
                    type="primary"
                    size="small"
                    @click.stop="handleCreateAttributeForLine(index)"
                  >
                    新增
                  </ElButton>
                  <ElButton text type="primary" size="small" @click.stop="handleShowAllAttributes">
                    更多
                  </ElButton>
                </div>
              </ElOption>
            </ElSelect>
            <span v-else>{{ line.name || line.attribute?.name || '-' }}</span>
          </div>
          <!-- 值选择 -->
          <div class="row-cell values-cell">
            <template v-if="line.isNew || editingLineIds.has(line.id)">
              <!-- 值输入框（多选，tag显示在输入框内） -->
              <div class="value-input-wrapper">
                <ElSelect
                  v-model="line.value_ids"
                  placeholder="搜索或输入新值"
                  filterable
                  remote
                  multiple
                  collapse-tags
                  collapse-tags-tooltip
                  :remote-method="(query) => searchValuesForLine(query, index)"
                  :loading="valueSearchLoadingMap[index]"
                  size="small"
                  style="width: 100%"
                  :disabled="!line.attribute_id"
                  reserve-keyword
                  :no-data-text="
                    showCreateHintMap[index] && (valueOptionsMap[index] || []).length === 0
                      ? ''
                      : '无数据'
                  "
                  :popper-options="{
                    modifiers: [
                      {
                        name: 'offset',
                        options: {
                          offset: [0, 4]
                        }
                      }
                    ]
                  }"
                  @change="() => {}"
                  @visible-change="(visible) => handleSelectVisibleChange(visible, line, index)"
                >
                  <ElOption
                    v-for="val in valueOptionsMap[index] || []"
                    :key="val.id"
                    :value="val.id"
                    :label="val.name"
                  >
                    <ElTag
                      :type="val.color ? undefined : 'info'"
                      :color="val.color"
                      class="value-tag-option"
                    >
                      {{ val.name }}
                    </ElTag>
                  </ElOption>
                  <!-- 更多选项：仅在存在记录时显示 -->
                  <ElOption
                    :value="''"
                    disabled
                    style="border-top: 1px solid var(--el-border-color-lighter)"
                  >
                    <div class="option-footer">
                      <ElButton
                        text
                        type="primary"
                        size="small"
                        @click.stop="handleQuickCreateValueForLine(index)"
                      >
                        添加
                      </ElButton>
                      <ElButton
                        text
                        type="primary"
                        size="small"
                        @click.stop="handleOpenValueSelectDialogForLine(index)"
                      >
                        更多
                      </ElButton>
                    </div>
                  </ElOption>
                </ElSelect>
                <!-- 创建新值提示：仅在值不存在且没有匹配记录时显示 -->
                <div
                  v-if="
                    showCreateHintMap[index] &&
                    valueInputTextMap[index] &&
                    (valueOptionsMap[index] || []).length === 0
                  "
                  class="create-hint"
                  @click.stop="() => handleCreateValueFromInput(line, index)"
                >
                  创建'{{ valueInputTextMap[index] }}'
                </div>
              </div>
            </template>
            <template v-else>
              <div class="selected-values">
                <div
                  v-for="(value, idx) in getAttributeValues(line)"
                  :key="idx"
                  class="value-tag-wrapper"
                >
                  <ElTag
                    :type="value.color ? undefined : 'info'"
                    :color="value.color"
                    class="value-tag"
                  >
                    {{ value.name }}
                  </ElTag>
                </div>
              </div>
              <span v-if="getAttributeValues(line).length === 0" class="empty-values">-</span>
            </template>
          </div>
          <div class="row-cell actions-cell">
            <template v-if="line.isNew">
              <ElButton text size="small" type="primary" @click="handleSaveLine(line)">
                保存
              </ElButton>
            </template>
            <template v-else-if="editingLineIds.has(line.id)">
              <ElButton text size="small" type="primary" @click="handleSaveEditLine(line)">
                保存
              </ElButton>
              <ElButton text size="small" @click="handleCancelEditLine(line)">取消</ElButton>
            </template>
            <template v-else>
              <ElButton text size="small" @click="handleConfigure(line, index)">配置</ElButton>
            </template>
            <ElButton text size="small" type="danger" @click="handleDelete(line)">
              <ArtSvgIcon icon="ri:delete-bin-line" />
            </ElButton>
          </div>
        </div>
        <div v-if="attributeLines.length === 0" class="empty-row">
          <div class="empty-text">暂无属性</div>
        </div>
      </div>
      <div class="table-footer">
        <ElButton text type="primary" @click="handleAddRow">
          <ArtSvgIcon icon="ri:add-line" class="mr-1" />
          添加行
        </ElButton>
      </div>
    </div>

    <!-- 属性配置对话框 -->
    <AttributeConfigDialog
      v-model="configDialogVisible"
      :product-id="productId"
      :product-type-id="productTypeId"
      :attribute-line="currentAttributeLine"
      @success="handleConfigSuccess"
    />

    <!-- 属性管理对话框 -->
    <AttributeManageDialog
      v-model="attributeManageDialogVisible"
      @success="handleAttributeManageSuccess"
    />

    <!-- 快速创建属性对话框 -->
    <QuickCreateAttributeDialog
      v-model="quickCreateAttributeDialogVisible"
      @success="handleAttributeCreated"
    />

    <!-- 值选择对话框 -->
    <ValueSelectDialog
      v-model="valueSelectDialogVisible"
      :attribute-id="currentAttributeIdForValue"
      :selected-value-ids="currentSelectedValueIds"
      @confirm="handleValueSelectConfirm"
    />

    <!-- 快速创建值对话框 -->
    <QuickCreateValueDialog
      v-model="quickCreateValueDialogVisible"
      :attribute-id="currentAttributeIdForValue"
      :initial-name="currentValueInputText"
      @success="handleQuickCreateValueSuccess"
    />
  </div>
</template>

<script setup lang="ts">
  import { ref, computed, onMounted, watch } from 'vue'
  import { ElMessage } from 'element-plus'
  import { ElButton, ElTag, ElSelect, ElOption } from 'element-plus'
  import ArtSvgIcon from '@/components/core/base/art-svg-icon/index.vue'
  import AttributeConfigDialog from './attribute-config-dialog.vue'
  import AttributeManageDialog from './attribute-manage-dialog.vue'
  import QuickCreateAttributeDialog from './quick-create-attribute-dialog.vue'
  import ValueSelectDialog from './value-select-dialog.vue'
  import QuickCreateValueDialog from './quick-create-value-dialog.vue'
  import {
    listMatAttributeLineApi,
    deleteMatAttributeLineApi,
    createMatAttributeLineApi,
    updateMatAttributeLineApi,
    listMatAttributeApi,
    listMatValueApi
  } from '@/api/mat/attribute'

  defineOptions({ name: 'TabAttributes' })

  interface Props {
    productData: any
  }

  const props = defineProps<Props>()

  const productId = computed(() => props.productData?.id)
  const productTypeId = computed(() => props.productData?.type_id)

  const attributeLines = ref<any[]>([])
  const configDialogVisible = ref(false)
  const currentAttributeLine = ref<any>(null)
  const attributeOptionsMap = ref<Record<number, any[]>>({})
  const attributeSearchLoadingMap = ref<Record<number, boolean>>({})
  const attributeValuesMap = ref<Record<number, any[]>>({})
  const attributeInfoMap = ref<Record<number, any>>({})
  const attributeManageDialogVisible = ref(false)
  const quickCreateAttributeDialogVisible = ref(false)
  const valueSelectDialogVisible = ref(false)
  const quickCreateValueDialogVisible = ref(false)
  const currentLineIndex = ref<number | null>(null)
  const currentAttributeIdForValue = ref<number | undefined>(undefined)
  const currentSelectedValueIds = ref<(string | number)[]>([])
  const currentValueInputText = ref<string>('')
  const valueOptionsMap = ref<Record<number, any[]>>({})
  const valueSearchLoadingMap = ref<Record<number, boolean>>({})
  const valueInputTextMap = ref<Record<number, string>>({})
  const showCreateHintMap = ref<Record<number, boolean>>({})
  const editingLineIds = ref<Set<number | string>>(new Set()) // 正在编辑的行ID集合

  // 获取属性值列表
  const getAttributeValues = (line: any): any[] => {
    if (line.values && Array.isArray(line.values) && line.values.length > 0) {
      return line.values
    }
    if (line.value_ids && Array.isArray(line.value_ids) && line.value_ids.length > 0) {
      // 如果只有ID数组，需要从属性中获取值信息
      if (line.attribute_id) {
        const allValues = getLineAttributeValues(line.attribute_id)
        return allValues.filter((v: any) => line.value_ids.includes(v.id))
      }
      return []
    }
    return []
  }

  // 加载属性行列表
  const loadAttributeLines = async (): Promise<void> => {
    if (!productId.value) return

    try {
      const res = await listMatAttributeLineApi({
        'q[product_id_eq]': productId.value
      })
      const data = (res as any).data || {}
      attributeLines.value = Array.isArray(data)
        ? data
        : data.list || data.data || data.records || []
    } catch (error) {
      console.error('加载属性行失败:', error)
      attributeLines.value = []
    }
  }

  // 搜索属性（为特定行）
  const searchAttributes = async (query: string, lineIndex: number): Promise<void> => {
    attributeSearchLoadingMap.value[lineIndex] = true
    try {
      const res = await listMatAttributeApi({
        'q[name_or_py_cont]': query || '',
        per_page: 20
      })
      const data = (res as any).data || {}
      attributeOptionsMap.value[lineIndex] = Array.isArray(data)
        ? data
        : data.list || data.data || []
    } catch (error) {
      console.error('搜索属性失败:', error)
      attributeOptionsMap.value[lineIndex] = []
    } finally {
      attributeSearchLoadingMap.value[lineIndex] = false
    }
  }

  // 加载属性值（为特定属性）
  const loadAttributeValues = async (attributeId: number): Promise<void> => {
    if (attributeValuesMap.value[attributeId]) {
      return
    }
    try {
      const res = await listMatValueApi({
        'q[attribute_id_eq]': attributeId
      })
      const data = (res as any).data || {}
      attributeValuesMap.value[attributeId] = Array.isArray(data)
        ? data
        : data.list || data.data || []
    } catch (error) {
      console.error('加载属性值失败:', error)
      attributeValuesMap.value[attributeId] = []
    }
  }

  // 获取行的属性值列表
  const getLineAttributeValues = (attributeId?: number): any[] => {
    if (!attributeId) return []
    return attributeValuesMap.value[attributeId] || []
  }

  // 行的属性变化
  const handleLineAttributeChange = async (
    line: any,
    attributeId: number,
    lineIndex: number
  ): Promise<void> => {
    if (!attributeId) {
      line.attribute_id = undefined
      line.value_ids = []
      line.display_type = undefined
      return
    }

    // 加载属性信息
    const attribute = attributeOptionsMap.value[lineIndex]?.find((a: any) => a.id === attributeId)
    if (attribute) {
      attributeInfoMap.value[attributeId] = attribute
      line.name = attribute.name
      line.display_type = attribute.display_type

      // 加载该属性的值列表
      await loadAttributeValues(attributeId)

      // 如果是多个复选框类型，自动选中所有值
      if (attribute.display_type === 'checkbox') {
        const values = getLineAttributeValues(attributeId)
        line.value_ids = values.map((v: any) => v.id)
      } else {
        // 单选模式，初始化为空数组
        line.value_ids = []
      }

      // 加载值选项
      await searchValuesForLine('', lineIndex)

      // 刷新值选择对话框的数据（如果已打开）
      if (valueSelectDialogVisible.value && currentAttributeIdForValue.value === attributeId) {
        delete attributeValuesMap.value[attributeId]
        await loadAttributeValues(attributeId)
      }
    }
  }

  // 搜索值（为特定行）
  const searchValuesForLine = async (query: string, lineIndex: number): Promise<void> => {
    valueInputTextMap.value[lineIndex] = query
    const line = attributeLines.value[lineIndex]
    if (!line || !line.attribute_id) {
      valueOptionsMap.value[lineIndex] = []
      showCreateHintMap.value[lineIndex] = query.trim().length > 0
      return
    }

    valueSearchLoadingMap.value[lineIndex] = true
    try {
      const res = await listMatValueApi({
        'q[attribute_id_eq]': line.attribute_id,
        'q[name_cont]': query || '',
        per_page: 20
      })
      const data = (res as any).data || {}
      const values = Array.isArray(data) ? data : data.list || data.data || []
      valueOptionsMap.value[lineIndex] = values
      showCreateHintMap.value[lineIndex] =
        query.trim().length > 0 && !isValueExistsForLine(query, lineIndex)
    } catch (error) {
      console.error('搜索值失败:', error)
      valueOptionsMap.value[lineIndex] = []
      showCreateHintMap.value[lineIndex] = query.trim().length > 0
    } finally {
      valueSearchLoadingMap.value[lineIndex] = false
    }
  }

  // 检查值是否存在（为特定行）
  const isValueExistsForLine = (name: string, lineIndex: number): boolean => {
    const options = valueOptionsMap.value[lineIndex] || []
    const line = attributeLines.value[lineIndex]
    if (!line || !line.attribute_id) return false

    const allValues = getLineAttributeValues(line.attribute_id)
    const valueIds = Array.isArray(line.value_ids) ? line.value_ids : []
    const selectedValues = allValues.filter((v: any) => valueIds.includes(v.id))

    return (
      options.some((v) => v.name.toLowerCase() === name.toLowerCase()) ||
      selectedValues.some((v) => v.name.toLowerCase() === name.toLowerCase())
    )
  }

  // 下拉框显示/隐藏变化
  const handleSelectVisibleChange = (visible: boolean, line: any, lineIndex: number): void => {
    if (visible) {
      // 下拉框打开时，加载值选项
      if (line.attribute_id) {
        searchValuesForLine('', lineIndex)
      }
    } else {
      // 下拉框关闭时，清空输入提示
      valueInputTextMap.value[lineIndex] = ''
      showCreateHintMap.value[lineIndex] = false
    }
  }

  // 从输入创建值（打开快速创建对话框）
  const handleCreateValueFromInput = (line: any, lineIndex: number): void => {
    const name = valueInputTextMap.value[lineIndex]?.trim()
    if (!name) {
      return
    }

    if (!line.attribute_id) {
      ElMessage.warning('请先选择属性')
      return
    }

    // 检查是否已存在
    if (isValueExistsForLine(name, lineIndex)) {
      ElMessage.warning('该值已存在')
      return
    }

    // 打开快速创建对话框，并传入输入的值
    currentLineIndex.value = lineIndex
    currentAttributeIdForValue.value = line.attribute_id
    currentValueInputText.value = name
    quickCreateValueDialogVisible.value = true
  }

  // 添加行
  const handleAddRow = (): void => {
    const newIndex = attributeLines.value.length
    // 直接在表格中添加一行新的空行
    attributeLines.value.push({
      id: undefined,
      attribute_id: undefined,
      name: '',
      values: [],
      value_ids: [], // 初始化为数组，支持多选
      valueInput: undefined, // 值输入框的值
      isNew: true // 标记为新添加的行
    })
    // 初始化该行的属性选项和值选项
    attributeOptionsMap.value[newIndex] = []
    attributeSearchLoadingMap.value[newIndex] = false
    valueOptionsMap.value[newIndex] = []
    valueSearchLoadingMap.value[newIndex] = false
    valueInputTextMap.value[newIndex] = ''
    showCreateHintMap.value[newIndex] = false
    // 加载属性列表
    searchAttributes('', newIndex)
  }

  // 配置属性（进入编辑模式）
  const handleConfigure = (line: any, lineIndex: number): void => {
    if (!line.id) return
    // 进入编辑模式
    editingLineIds.value.add(line.id)
    // 初始化该行的属性选项和值选项
    if (line.attribute_id) {
      // 加载属性选项
      searchAttributes('', lineIndex).catch(console.error)
      // 加载值选项
      searchValuesForLine('', lineIndex).catch(console.error)
      // 加载属性值
      loadAttributeValues(line.attribute_id).catch(console.error)
    }
    // 确保 value_ids 是数组格式
    if (line.value_ids && !Array.isArray(line.value_ids)) {
      line.value_ids = [line.value_ids]
    } else if (!line.value_ids) {
      line.value_ids = []
    }
  }

  // 取消编辑
  const handleCancelEditLine = (line: any): void => {
    if (!line.id) return
    editingLineIds.value.delete(line.id)
    // 重新加载该行数据
    loadAttributeLines()
  }

  // 保存编辑的行
  const handleSaveEditLine = async (line: any): Promise<void> => {
    if (!line.id || !line.attribute_id) {
      ElMessage.warning('请选择属性')
      return
    }

    const valueIds = Array.isArray(line.value_ids) ? line.value_ids : []
    if (valueIds.length === 0) {
      ElMessage.warning('请至少选择一个值')
      return
    }

    try {
      await updateMatAttributeLineApi(line.id, {
        attribute_id: line.attribute_id,
        value_ids: valueIds
      })
      ElMessage.success('保存成功')
      editingLineIds.value.delete(line.id)
      // 重新加载属性行列表
      await loadAttributeLines()
    } catch (error) {
      console.error('保存失败:', error)
      ElMessage.error('保存失败')
    }
  }

  // 删除属性行
  const handleDelete = async (line: any): Promise<void> => {
    if (!line.id) {
      // 如果是新添加的未保存的行，直接从列表中移除
      const index = attributeLines.value.findIndex((l) => l === line)
      if (index > -1) {
        attributeLines.value.splice(index, 1)
      }
      return
    }

    try {
      await deleteMatAttributeLineApi(line.id)
      ElMessage.success('删除成功')
      await loadAttributeLines()
    } catch (error) {
      console.error('删除属性行失败:', error)
      ElMessage.error('删除失败')
    }
  }

  // 保存行
  const handleSaveLine = async (line: any): Promise<void> => {
    if (!line.attribute_id) {
      ElMessage.warning('请选择属性')
      return
    }

    const valueIds = Array.isArray(line.value_ids)
      ? line.value_ids
      : line.value_ids !== undefined && line.value_ids !== null
        ? [line.value_ids]
        : []
    if (valueIds.length === 0) {
      ElMessage.warning('请至少选择一个值')
      return
    }

    if (!productId.value) {
      ElMessage.warning('产品ID不存在')
      return
    }

    const attributeInfo = attributeInfoMap.value[line.attribute_id]
    if (!attributeInfo) {
      ElMessage.warning('属性信息不存在')
      return
    }

    try {
      const params: any = {
        product_id: productId.value,
        attribute_id: line.attribute_id,
        name: line.name,
        display_type: attributeInfo.display_type,
        is_variant: isComboProduct.value ? false : attributeInfo.is_variant || false,
        value_ids: valueIds,
        values: getLineAttributeValues(line.attribute_id)
          .filter((v: any) => valueIds.includes(v.id))
          .map((v: any) => ({
            name: v.name,
            color: v.color,
            extra_price: v.extra_price || 0
          }))
      }

      await createMatAttributeLineApi(params)
      ElMessage.success('保存成功')
      // 重新加载列表
      await loadAttributeLines()
    } catch (error) {
      console.error('保存属性行失败:', error)
      ElMessage.error('保存失败')
    }
  }

  // 为特定行创建属性
  const handleCreateAttributeForLine = (lineIndex: number): void => {
    currentLineIndex.value = lineIndex
    quickCreateAttributeDialogVisible.value = true
  }

  // 显示所有属性
  const handleShowAllAttributes = (): void => {
    attributeManageDialogVisible.value = true
  }

  // 为特定行打开值选择对话框
  const handleOpenValueSelectDialogForLine = (lineIndex: number): void => {
    const line = attributeLines.value[lineIndex]
    if (!line.attribute_id) {
      ElMessage.warning('请先选择属性')
      return
    }
    currentLineIndex.value = lineIndex
    currentAttributeIdForValue.value = line.attribute_id
    currentSelectedValueIds.value = Array.isArray(line.value_ids) ? [...line.value_ids] : []
    valueSelectDialogVisible.value = true
  }

  // 值选择确认
  const handleValueSelectConfirm = (valueIds: (string | number)[]): void => {
    if (currentLineIndex.value !== null) {
      const line = attributeLines.value[currentLineIndex.value]
      if (line) {
        line.value_ids = [...valueIds]
      }
    }
    valueSelectDialogVisible.value = false
  }

  // 为特定行快速创建值
  const handleQuickCreateValueForLine = (lineIndex: number): void => {
    const line = attributeLines.value[lineIndex]
    if (!line.attribute_id) {
      ElMessage.warning('请先选择属性')
      return
    }
    currentLineIndex.value = lineIndex
    currentAttributeIdForValue.value = line.attribute_id
    // 如果有输入的值，传入到对话框
    currentValueInputText.value = valueInputTextMap.value[lineIndex] || ''
    quickCreateValueDialogVisible.value = true
  }

  // 快速创建值成功回调
  const handleQuickCreateValueSuccess = async (value: any): Promise<void> => {
    if (currentLineIndex.value !== null && value && value.id) {
      const line = attributeLines.value[currentLineIndex.value]
      if (line && line.attribute_id) {
        // 将新创建的值添加到选中列表
        if (!Array.isArray(line.value_ids)) {
          line.value_ids = []
        }
        if (!line.value_ids.includes(value.id)) {
          line.value_ids.push(value.id)
        }

        // 将新创建的值添加到属性值缓存中
        if (!attributeValuesMap.value[line.attribute_id]) {
          attributeValuesMap.value[line.attribute_id] = []
        }
        // 检查是否已存在，避免重复添加
        const existingIndex = attributeValuesMap.value[line.attribute_id].findIndex(
          (v: any) => v.id === value.id
        )
        if (existingIndex === -1) {
          attributeValuesMap.value[line.attribute_id].push(value)
        } else {
          // 如果已存在，更新它
          attributeValuesMap.value[line.attribute_id][existingIndex] = value
        }

        // 将新创建的值添加到当前行的值选项列表中
        if (!valueOptionsMap.value[currentLineIndex.value]) {
          valueOptionsMap.value[currentLineIndex.value] = []
        }
        const optionIndex = valueOptionsMap.value[currentLineIndex.value].findIndex(
          (v: any) => v.id === value.id
        )
        if (optionIndex === -1) {
          valueOptionsMap.value[currentLineIndex.value].push(value)
        } else {
          valueOptionsMap.value[currentLineIndex.value][optionIndex] = value
        }

        // 刷新该行的值选项列表（确保从服务器获取最新数据）
        await searchValuesForLine('', currentLineIndex.value)
      }
    }
    quickCreateValueDialogVisible.value = false
  }

  // 属性创建成功回调
  const handleAttributeCreated = async (attribute: any): Promise<void> => {
    if (currentLineIndex.value !== null) {
      // 刷新该行的属性列表
      await searchAttributes('', currentLineIndex.value)
      // 自动选择新创建的属性
      if (attribute && attribute.id) {
        const line = attributeLines.value[currentLineIndex.value]
        if (line) {
          await handleLineAttributeChange(line, attribute.id, currentLineIndex.value)
        }
      }
    }
  }

  // 属性管理成功回调
  const handleAttributeManageSuccess = async (): Promise<void> => {
    // 刷新所有行的属性列表
    for (const index in attributeOptionsMap.value) {
      await searchAttributes('', Number(index))
    }
  }

  // 判断是否为组合类型产品
  const isComboProduct = computed(() => productTypeId.value === 2)

  // 配置成功回调
  const handleConfigSuccess = (): void => {
    loadAttributeLines()
  }

  // 监听产品ID变化
  watch(
    () => productId.value,
    (newVal) => {
      if (newVal) {
        loadAttributeLines()
      }
    },
    { immediate: true }
  )

  onMounted(() => {
    if (productId.value) {
      loadAttributeLines()
    }
  })
</script>

<style scoped lang="scss">
  .attributes-tab {
    padding: 0;
  }

  .attributes-table {
    .table-header {
      display: grid;
      grid-template-columns: 200px 1fr 120px;
      gap: 16px;
      padding: 12px 16px;
      font-size: 13px;
      font-weight: 500;
      color: var(--el-text-color-regular);
      background: var(--el-fill-color-light);
      border-bottom: 1px solid var(--el-border-color-lighter);

      .header-cell {
        &.actions-cell {
          text-align: right;
        }
      }
    }

    .table-body {
      .table-row {
        display: grid;
        grid-template-columns: 200px 1fr 120px;
        gap: 16px;
        padding: 16px;
        border-bottom: 1px solid var(--el-border-color-lighter);
        transition: background-color 0.2s;

        &:hover {
          background: var(--el-fill-color-lighter);
        }

        .row-cell {
          display: flex;
          align-items: center;
          font-size: 14px;
          color: var(--el-text-color-primary);

          &.attribute-cell {
            font-weight: 500;
          }

          &.values-cell {
            .value-input-wrapper {
              position: relative;
              width: 100%;

              .create-hint {
                position: absolute;
                top: 100%;
                right: 0;
                left: 0;
                z-index: 2000;
                padding: 8px 12px;
                margin-top: 4px;
                font-size: 13px;
                color: var(--el-text-color-primary);
                cursor: pointer;
                background: var(--el-fill-color-light);
                border: 1px solid var(--el-border-color-lighter);
                border-radius: 4px;
                transition: background-color 0.2s;

                &:hover {
                  background: var(--el-fill-color);
                }
              }

              // 当显示创建提示时，隐藏 ElSelect 下拉框的"无数据"提示
              :deep(.el-select-dropdown__empty) {
                display: none !important;
              }
            }

            .selected-values {
              display: flex;
              flex-wrap: wrap;
              gap: 8px;
              width: 100%;

              .value-tag-wrapper {
                position: relative;
                display: inline-flex;
                align-items: center;

                .value-tag {
                  margin: 0;
                }
              }
            }

            .value-tag {
              margin: 0;
            }

            .value-tag-option {
              margin: 0;
              border: none;
            }

            .empty-values {
              color: var(--el-text-color-placeholder);
            }

            .option-footer {
              display: flex;
              gap: 8px;
              justify-content: center;
              padding: 8px 0;
            }

            // 下拉选项样式 - 使用标签样式
            :deep(.el-select-dropdown__item) {
              padding: 8px 12px;

              .value-tag-option {
                display: inline-block;
              }
            }
          }

          &.actions-cell {
            gap: 8px;
            justify-content: flex-end;
          }
        }
      }

      .empty-row {
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 60px 16px;
        font-size: 14px;
        color: var(--el-text-color-placeholder);
      }
    }

    .table-footer {
      padding: 16px;
      border-top: 1px solid var(--el-border-color-lighter);
    }
  }

  .mr-1 {
    margin-right: 4px;
  }
</style>
